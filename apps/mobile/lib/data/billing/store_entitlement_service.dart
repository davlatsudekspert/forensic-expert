import 'dart:async';

import '../../core/flags.dart';
import '../../domain/ports/billing_ports.dart';
import 'store_client.dart';

/// Obunalar (Student Pro / Professional Pro) — App Store auto-renewable
/// subscriptions va Google Play subscriptions.
///
/// Xavfsizlik qoidalari:
/// * Huquq **faqat** store tasdiqlagan xariddan (StoreKit / Play Billing,
///   shu Apple ID / Google akkaunti). Ilova lokal bool, SharedPreferences
///   yoki fayl orqali Pro ochmaydi; har ishga tushishda egalik store’dan
///   jim qayta so‘raladi ([refreshOwnership]).
/// * Har bir xarid [PurchaseVerifier] (backend) orqali tekshiriladi.
///   Backend hozir yo‘q ([VerificationStatus.serverNotConfigured]):
///   [FeFlags.requireServerPurchaseVerification] `false` bo‘lsa — faqat
///   store tasdig‘i bilan ([EntitlementVerification.storeConfirmed])
///   ochiladi; `true` bo‘lsa — ochilmaydi. Public release uchun server
///   tekshiruvi majburiy: RELEASE BLOCKER RG-18.
/// * Server holati (expired / billing retry / revoked) huquqni yopadi;
///   grace va «bekor qilingan, muddat oxirigacha» — ochiq qoladi.
/// * Backend rad etsa — huquq yo‘q va tranzaksiya yakunlanmaydi.
/// * Bir nechta faol obuna bo‘lsa — eng yuqori tarif olinadi.
class StoreEntitlementService implements EntitlementService {
  StoreEntitlementService({
    required this._client,
    required this._platformSource,
    this._verifier = const UnconfiguredPurchaseVerifier(),
    bool? requireServerVerification,
    this._restoreTimeout = const Duration(seconds: 8),
    DateTime Function()? clock,
  }) : _requireServer =
           requireServerVerification ??
           FeFlags.requireServerPurchaseVerification,
       _now = clock ?? DateTime.now {
    _sub = _client.events.listen(_onEvents);
  }

  final StoreClient _client;
  final EntitlementSource _platformSource;
  final PurchaseVerifier _verifier;
  final bool _requireServer;
  final Duration _restoreTimeout;
  final DateTime Function() _now;
  final _changes = StreamController<Entitlements>.broadcast();
  late final StreamSubscription<List<StoreEvent>> _sub;

  Entitlements _current = Entitlements.free;
  Completer<PurchaseOutcome>? _purchase;
  Completer<void>? _restore;
  Future<void>? _refreshing;

  @override
  Entitlements get current => _current;

  @override
  Stream<Entitlements> watch() async* {
    unawaited(refreshOwnership());
    yield _current;
    yield* _changes.stream;
  }

  /// Store’dan egalikni jim qayta so‘rash (har sessiyada bir marta).
  Future<void> refreshOwnership() => _refreshing ??= () async {
    try {
      if (!await _client.isAvailable()) return;
      await _onEvents(await _client.ownedPurchases());
    } on Object {
      // Store xatosi — bepul rejim saqlanadi (xavfsiz tomon).
    }
  }();

  @override
  Future<List<Offer>> offers() async {
    if (!await _client.isAvailable()) return const [];
    final products = await _client.queryProducts(ProductIds.all.toSet());
    final offers = [
      for (final p in products)
        if (ProductIds.tierOf(p.id) case final tier?)
          Offer(
            productId: p.id,
            tier: tier,
            localizedPrice: p.price,
            currencyCode: p.currencyCode,
            period: periodFromIso(p.billingPeriod),
          ),
    ];
    offers.sort(
      (a, b) => ProductIds.all
          .indexOf(a.productId)
          .compareTo(ProductIds.all.indexOf(b.productId)),
    );
    return offers;
  }

  /// ISO 8601 (`P1M`, `P1Y`, `P12M`) → davr. Boshqasi — noma’lum.
  static BillingPeriod periodFromIso(String? iso) => switch (iso) {
    'P1M' || 'P4W' => BillingPeriod.month,
    'P1Y' || 'P12M' => BillingPeriod.year,
    _ => BillingPeriod.unknown,
  };

  @override
  Future<PurchaseOutcome> purchase(String productId) async {
    final tier = ProductIds.tierOf(productId);
    if (tier == null || !await _client.isAvailable()) {
      return PurchaseOutcome.unavailable;
    }
    if (_current.includes(tier) && _current.productId == productId) {
      return PurchaseOutcome.purchased;
    }
    final completer = _purchase = Completer<PurchaseOutcome>();
    final started = await _client.buySubscription(productId);
    if (!started) {
      _purchase = null;
      return PurchaseOutcome.failed;
    }
    return completer.future;
  }

  @override
  Future<Entitlements> restore() async {
    if (!await _client.isAvailable()) return _current;
    final done = _restore = Completer<void>();
    await _client.restore();
    // Restore oqimidan tashqari: store’ning joriy egalik ro‘yxati.
    await _onEvents(await _client.ownedPurchases());
    if (!done.isCompleted) {
      await done.future.timeout(_restoreTimeout, onTimeout: () {});
    }
    _restore = null;
    return _current;
  }

  Future<void> _onEvents(List<StoreEvent> events) async {
    for (final e in events) {
      if (ProductIds.tierOf(e.productId) == null) continue;
      switch (e.status) {
        case StoreEventStatus.purchased:
        case StoreEventStatus.restored:
          final granted = await _verifyAndGrant(e);
          _finish(granted ? PurchaseOutcome.purchased : PurchaseOutcome.failed);
          if (granted && e.pendingCompletion) await _client.complete(e);
          if (_restore?.isCompleted == false) _restore!.complete();
          continue;
        case StoreEventStatus.pending:
          _finish(PurchaseOutcome.pending);
        case StoreEventStatus.error:
          _finish(PurchaseOutcome.failed);
        case StoreEventStatus.canceled:
          _finish(PurchaseOutcome.cancelled);
      }
      if (e.pendingCompletion) await _client.complete(e);
    }
  }

  Future<bool> _verifyAndGrant(StoreEvent e) async {
    final tier = ProductIds.tierOf(e.productId)!;
    // Store bergan muddat o‘tgan bo‘lsa (iOS Transaction.all eski
    // tranzaksiyalarni ham qaytaradi) — huquq yo‘q.
    final storeExpiry = e.expiresAt;
    if (storeExpiry != null && !_now().isBefore(storeExpiry)) return false;

    final data = e.serverVerificationData;
    final result = data == null || data.isEmpty
        ? PurchaseVerification.rejected
        : await _verifier.verify(
            PurchaseEvidence(
              productId: e.productId,
              platform: _platformSource,
              serverVerificationData: data,
              purchaseId: e.purchaseId,
            ),
          );

    final EntitlementVerification verification;
    var status = EntitlementStatus.active;
    var expiresAt = storeExpiry;
    switch (result.status) {
      case VerificationStatus.verified:
        verification = EntitlementVerification.serverVerified;
        status = result.entitlementStatus ?? EntitlementStatus.unknown;
        expiresAt = result.expiresAt ?? expiresAt;
      case VerificationStatus.rejected:
        return false;
      // Backend sozlangan, lekin tarmoq yo‘q: offline foydalanuvchi uchun
      // store tasdig‘i bilan vaqtincha (keyingi sessiyada qayta tekshiriladi).
      case VerificationStatus.networkError:
        verification = EntitlementVerification.storeConfirmed;
      case VerificationStatus.serverNotConfigured:
        if (_requireServer) return false;
        verification = EntitlementVerification.storeConfirmed;
    }

    final candidate = Entitlements(
      tier: tier,
      status: status,
      source: _platformSource,
      verification: verification,
      productId: e.productId,
      purchasedAt: _now().toUtc(),
      expiresAt: expiresAt,
    );
    if (!Entitlements.statusGrantsAccess(status)) {
      // Server yopdi (expired / billing retry / revoked): agar joriy huquq
      // shu mahsulotdan bo‘lsa — yopiladi.
      if (_current.productId == e.productId) _set(candidate);
      return false;
    }
    if (_better(candidate, _current)) _set(candidate);
    return true;
  }

  /// Yuqoriroq tarif yoki o‘sha tarifning kuchliroq tasdig‘i.
  static bool _better(Entitlements next, Entitlements now) {
    final a = next.effectiveTier.index;
    final b = now.effectiveTier.index;
    if (a != b) return a > b;
    return next.verification.index > now.verification.index ||
        next.productId == now.productId;
  }

  void _set(Entitlements e) {
    _current = e;
    _changes.add(e);
  }

  void _finish(PurchaseOutcome o) {
    final c = _purchase;
    if (c != null && !c.isCompleted) c.complete(o);
    _purchase = null;
  }

  Future<void> dispose() async {
    await _sub.cancel();
    await _changes.close();
  }
}
