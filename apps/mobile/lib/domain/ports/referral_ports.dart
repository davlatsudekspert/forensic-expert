import '../referral/referral_models.dart';

/// Referral xizmati. Barcha qarorlar serverda; mijoz faqat so‘raydi.
abstract interface class ReferralService {
  /// Backend ulanganmi (aks holda UI halol «ulanmagan» holatini ko‘rsatadi).
  bool get isConfigured;

  /// O‘z kodi va agregat sonlar (kod birinchi so‘rovda serverda yaratiladi).
  Future<ReferralResult> fetch();

  /// Taklif kodini qo‘llash (faqat yangi, kirgan akkaunt uchun).
  Future<ReferralClaimOutcome> claim(String code);
}

/// Backend yo‘q — hech narsa soxtalashtirilmaydi.
class UnconfiguredReferralService implements ReferralService {
  const UnconfiguredReferralService();

  @override
  bool get isConfigured => false;

  @override
  Future<ReferralResult> fetch() async =>
      const ReferralResult.fail(ReferralFailure.notConfigured);

  @override
  Future<ReferralClaimOutcome> claim(String code) async =>
      ReferralClaimOutcome.notConfigured;
}

/// Kutilayotgan taklif kodi (deep link yoki qo‘lda kiritilgan) — faqat
/// qurilmada, akkaunt ochilgach serverga bir marta yuboriladi.
abstract interface class PendingReferralStore {
  String? read();

  Future<void> write(String? code);
}

class InMemoryPendingReferralStore implements PendingReferralStore {
  InMemoryPendingReferralStore([this.value]);

  String? value;

  @override
  String? read() => value;

  @override
  Future<void> write(String? code) async => value = code;
}
