import 'dart:async';

import '../../core/flags.dart';
import '../../domain/ports/billing_ports.dart';
import 'store_client.dart';

/// FORENSIC EXPERT Lifetime — bir martalik xarid
/// (App Store Non-Consumable / Google Play one-time product).
///
/// Xavfsizlik qoidalari:
/// * Huquq **faqat** store tasdiqlagan xariddan (StoreKit / Play Billing,
///   shu Apple ID / Google akkaunti). Ilova lokal bool, SharedPreferences
///   yoki fayl orqali premium ochmaydi — ilova yoki APK boshqa qurilmaga
///   ko‘chirilsa, u yerda store xaridni tasdiqlamaguncha bepul rejim.
/// * Har ishga tushishda egalik store’dan jim qayta so‘raladi
///   ([refreshOwnership]); avvalgi sessiya natijasi saqlanmaydi.
/// * Har bir xarid [PurchaseVerifier] (backend) orqali tekshiriladi.
///   Backend hozir yo‘q ([VerificationStatus.serverNotConfigured]):
///   [FeFlags.requireServerPurchaseVerification] `false` bo‘lsa — faqat
///   store tasdig‘i bilan ([EntitlementVerification.storeConfirmed])
///   ochiladi; `true` bo‘lsa — ochilmaydi. Public release uchun
///   server tekshiruvi majburiy: RELEASE BLOCKER RG-18.
/// * Backend rad etsa ([VerificationStatus.rejected]) — huquq yo‘q va
///   tranzaksiya yakunlanmaydi (Google Play 3 kunda qaytaradi).
/// * Forensic AI bu huquqqa kirmaydi (alohida [AiEntitlement]).
class StoreEntitlementService implements EntitlementService {
  StoreEntitlementService({
    required this._client,
    required this._platformSource,
    this._verifier = const UnconfiguredPurchaseVerifier(),
    bool? requireServerVerification,
    this._restoreTimeout = const Duration(seconds: 8),
  }) : _requireServer =
           requireServerVerification ??
           FeFlags.requireServerPurchaseVerification {
    _sub = _client.events.listen(_onEvents);
  }

  final StoreClient _client;
  final EntitlementSource _platformSource;
  final PurchaseVerifier _verifier;
  final bool _requireServer;
  final Duration _restoreTimeout;
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
    final prices = await _client.localizedPrices({ProductIds.lifetime});
    return [
      for (final e in prices.entries)
        Offer(
          productId: e.key,
          type: StoreProductType.lifetimeUnlock,
          localizedPrice: e.value,
        ),
    ];
  }

  @override
  Future<PurchaseOutcome> purchase(String productId) async {
    if (productId != ProductIds.lifetime || !await _client.isAvailable()) {
      return PurchaseOutcome.unavailable;
    }
    if (_current.hasFullAccess) return PurchaseOutcome.purchased;
    final completer = _purchase = Completer<PurchaseOutcome>();
    final started = await _client.buyNonConsumable(productId);
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
      if (e.productId != ProductIds.lifetime) continue;
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
    final data = e.serverVerificationData;
    final status = data == null || data.isEmpty
        ? VerificationStatus.rejected
        : await _verifier.verify(
            PurchaseEvidence(
              productId: e.productId,
              platform: _platformSource,
              serverVerificationData: data,
              purchaseId: e.purchaseId,
            ),
          );
    final verification = switch (status) {
      VerificationStatus.verified => EntitlementVerification.serverVerified,
      VerificationStatus.rejected => null,
      // Backend sozlangan, lekin tarmoq yo‘q: offline foydalanuvchi uchun
      // store tasdig‘i bilan vaqtincha (keyingi sessiyada qayta tekshiriladi).
      VerificationStatus.networkError => EntitlementVerification.storeConfirmed,
      VerificationStatus.serverNotConfigured =>
        _requireServer ? null : EntitlementVerification.storeConfirmed,
    };
    if (verification == null) return false;
    final upgraded =
        !_current.hasFullAccess ||
        (verification == EntitlementVerification.serverVerified &&
            _current.verification != EntitlementVerification.serverVerified);
    if (upgraded) {
      _current = Entitlements(
        access: AccessLevel.lifetime,
        source: _platformSource,
        purchasedAt: DateTime.now().toUtc(),
        verification: verification,
      );
      _changes.add(_current);
    }
    return true;
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
