/// Ilova versiyasi. `pubspec.yaml` dagi `version` bilan mosligi testda
/// tekshiriladi (`test/unit/app_info_test.dart`) — qo‘shimcha plagin kerak emas.
///
/// Ilova versiyasi va ilmiy baza versiyasi ALOHIDA (34-bo‘lim):
/// ilmiy baza versiyasi kontent paketi manifestidan o‘qiladi.
abstract final class AppInfo {
  static const version = '0.3.0';
  static const build = 4;

  /// VAQTINCHALIK ID (RG-09). Nomzod: `com.forensicexpert.app` — egasi
  /// tasdiqlamaguncha va store’da ro‘yxatdan o‘tmaguncha o‘zgartirilmaydi.
  static const applicationId = 'uz.forensicexpert.forensic_expert';

  /// Ommaviy maxfiylik siyosati (Play Console «Privacy policy» maydoni bilan
  /// bir xil manzil). Sahifa manbasi: `docs/legal/privacy.html`.
  static const privacyPolicyUrl =
      'https://davlatsudekspert.github.io/forensic-expert-legal/';
}
