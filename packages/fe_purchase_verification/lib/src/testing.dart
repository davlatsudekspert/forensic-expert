import 'models.dart';
import 'ports.dart';

/// Xotiradagi ombor — testlar va lokal ishlab chiqish uchun. Production’da
/// noyob indeksli tranzaksion DB bilan almashtiriladi.
class InMemoryEntitlementStore implements EntitlementStore {
  final _byTx = <String, EntitlementRecord>{};
  final _idem = <String, VerificationResult>{};

  String _k(StorePlatform p, String id) => '${p.name}:$id';

  @override
  Future<EntitlementRecord?> byOriginalTransaction(
    StorePlatform platform,
    String originalTransactionId,
  ) async => _byTx[_k(platform, originalTransactionId)];

  @override
  Future<List<EntitlementRecord>> forAccount(String accountId) async => [
    for (final r in _byTx.values)
      if (r.accountId == accountId) r,
  ];

  @override
  Future<bool> insertIfAbsent(EntitlementRecord r) async {
    final k = _k(r.platform, r.originalTransactionId);
    if (_byTx.containsKey(k)) return false;
    _byTx[k] = r;
    return true;
  }

  @override
  Future<void> update(EntitlementRecord r) async =>
      _byTx[_k(r.platform, r.originalTransactionId)] = r;

  final audit = <EntitlementAuditEntry>[];

  @override
  Future<void> appendAudit(EntitlementAuditEntry e) async => audit.add(e);

  @override
  Future<VerificationResult?> idempotent(String key) async => _idem[key];

  @override
  Future<void> rememberIdempotent(String key, VerificationResult r) async =>
      _idem[key] = r;
}

/// MOCK store tekshiruvchisi — haqiqiy Apple/Google API’ga murojaat
/// QILMAYDI. Faqat testlar uchun; production konfiguratsiyada ishlatilsa,
/// [PurchaseVerificationService] har doim «serverVerified» natija beradi —
/// shuning uchun server ishga tushishida mock’lar taqiqlanadi
/// ([assertNoMocksInProduction]).
class MockStoreVerifier implements StoreVerifier {
  MockStoreVerifier(this.platform, this.transactions);

  @override
  final StorePlatform platform;

  /// credential → tranzaksiya. `null` qiymat — `unavailable`.
  final Map<String, StoreTransaction?> transactions;
  final acknowledged = <String>[];
  int calls = 0;

  @override
  Future<StoreTransaction> fetch(String credential, String productId) async {
    calls++;
    if (!transactions.containsKey(credential)) {
      throw const StoreVerifierException('invalid');
    }
    final t = transactions[credential];
    if (t == null) throw const StoreVerifierException('unavailable');
    return t;
  }

  @override
  Future<void> acknowledge(StoreTransaction t) async =>
      acknowledged.add(t.originalTransactionId);
}

/// MOCK JWS tekshiruvchisi: `valid.<id>.<type>` ko‘rinishidagi satrlarni
/// «tekshirilgan» deb qabul qiladi, qolganini rad etadi. Kriptografiya YO‘Q.
class MockJwsChainVerifier implements JwsChainVerifier {
  MockJwsChainVerifier(this.payloads);

  final Map<String, Map<String, Object?>> payloads;

  @override
  Map<String, Object?> verify(String jws) {
    final p = payloads[jws];
    if (p == null) throw const FormatException('invalid signature');
    return p;
  }
}

/// Production server ishga tushishida chaqiriladi: mock verifier/JWS bilan
/// production rejimi — xato.
void assertNoMocksInProduction({
  required bool production,
  required Iterable<Object> components,
}) {
  if (!production) return;
  for (final c in components) {
    if (c is MockStoreVerifier || c is MockJwsChainVerifier) {
      throw StateError(
        'Mock purchase verifier in production configuration: $c',
      );
    }
  }
}
