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
}
