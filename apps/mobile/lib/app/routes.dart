/// Marshrut yo‘llari — bitta joyda, string takrorlanmasligi uchun.
abstract final class Routes {
  static const language = '/onboarding/language';
  static const disclaimer = '/onboarding/disclaimer';
  static const mode = '/onboarding/mode';

  static const home = '/home';
  static const search = '/home/search';
  static String module(String id) => '/home/module/$id';

  static const tools = '/tools';
  static const library = '/library';
  static const ai = '/ai';
  static const profile = '/profile';
  static const profileLanguage = '/profile/language';
  static const profileMode = '/profile/mode';
  static const profileDisclaimer = '/profile/disclaimer';

  /// Onboarding qadamlari tartibi.
  static const onboardingSteps = [language, disclaimer, mode];
}
