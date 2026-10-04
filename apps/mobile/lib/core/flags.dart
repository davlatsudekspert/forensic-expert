/// Yig‘ish bayroqlari (`--dart-define` orqali).
abstract final class FeFlags {
  /// PHASE 2 UI prototipida TEST fixture’lar ko‘rsatiladi.
  /// Production yig‘mada: `--dart-define=FE_TEST_FIXTURES=false`
  /// (RELEASE GATE RG-12).
  static const showTestFixtures = bool.fromEnvironment(
    'FE_TEST_FIXTURES',
    defaultValue: true,
  );
}
