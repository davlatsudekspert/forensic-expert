/// Yig‘ish bayroqlari (`--dart-define` orqali).
abstract final class FeFlags {
  /// TEST fixture’lar (namunaviy, ilmiy bo‘lmagan ma’lumot). PHASE 3 dan
  /// boshlab **standart o‘chiq**: ilova faqat imzolangan kontent paketini
  /// ko‘rsatadi. Fixture’lar faqat testlar va UI preview uchun
  /// (`--dart-define=FE_TEST_FIXTURES=true`). RELEASE GATE RG-12.
  static const showTestFixtures = bool.fromEnvironment('FE_TEST_FIXTURES');

  /// Ilova qabul qiladigan kontent paketi kanali.
  ///
  /// Hozir yagona paket — reviewer tasdig‘idan o‘tmagan pilot
  /// (`development`). Public release yig‘masi
  /// `--dart-define=FE_CONTENT_CHANNEL=production` bilan quriladi; u holda
  /// development paket imzo tekshiruvida rad etiladi va tekshirilmagan
  /// kontent foydalanuvchiga chiqmaydi. RELEASE GATE RG-17.
  static const contentChannel = String.fromEnvironment(
    'FE_CONTENT_CHANNEL',
    defaultValue: 'development',
  );

  /// Lifetime huquqi uchun server tekshiruvi majburiymi.
  ///
  /// `false` (hozirgi standart): store tasdig‘i (StoreKit / Play Billing)
  /// yetarli — faqat development/QA uchun. Public release:
  /// `--dart-define=FE_REQUIRE_SERVER_PURCHASE_VERIFICATION=true` va ishlaydigan
  /// backend (App Store Server API, Google Play Developer API).
  /// RELEASE BLOCKER RG-18.
  static const requireServerPurchaseVerification = bool.fromEnvironment(
    'FE_REQUIRE_SERVER_PURCHASE_VERIFICATION',
  );

  /// «Ekspert maqolalari» bo‘limi (hub plitkasi, yuborish). Standart o‘chiq;
  /// admin uchun bayroqsiz ham ko‘rinadi (egasi sinovi). O‘qish bepul.
  /// `--dart-define=FE_PUBLICATIONS=true`.
  static const publications = bool.fromEnvironment('FE_PUBLICATIONS');
}
