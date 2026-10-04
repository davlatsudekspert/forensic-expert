/// Marshrut yo‘llari — bitta joyda, string takrorlanmasligi uchun.
abstract final class Routes {
  static const language = '/onboarding/language';
  static const disclaimer = '/onboarding/disclaimer';
  static const mode = '/onboarding/mode';

  static const home = '/home';
  static const search = '/home/search';
  static String searchWith(String query) =>
      Uri(path: search, queryParameters: {'q': query}).toString();
  static String module(String id) => '/home/module/$id';
  static const learn = '/home/learn';
  static const compare = '/home/compare';
  static String knowledge(String kind) => '/home/knowledge/$kind';
  static String knowledgeEntry(String id) => '/home/entry/$id';
  static const forensicMedicine = '/home/area/forensicMedicine';
  static const biochemistry = '/home/area/biochemistry';
  static const exam = '/home/learn/exam';
  static const histology = '/home/area/histology';
  static const research = '/home/research';
  static String researchFor(String entityId) =>
      Uri(path: research, queryParameters: {'entity': entityId}).toString();
  static String researchEntry(String id) => '/home/research/$id';
  static String image(String id) => '/home/image/$id';
  static const disciplines = '/home/disciplines';
  static String discipline(String code) => '/home/disciplines/$code';
  static const jurisdictions = '/home/jurisdictions';
  static const jurisdictionSelect = '/home/jurisdictions/select';
  static String jurisdiction(String id) => '/home/jurisdictions/$id';
  static String librarySection(String section) => '/library/section/$section';
  static const libraryStandards = '/library/standards';
  static const quiz = '/home/learn/quiz';
  static const flashcards = '/home/learn/flashcards';

  static const tools = '/tools';
  static String tool(String id) => '/tools/tool/$id';

  static const library = '/library';
  static String libraryEntry(String id) => '/library/entry/$id';

  static const ai = '/ai';
  static const profile = '/profile';
  static const profileLanguage = '/profile/language';
  static const profileMode = '/profile/mode';
  static const profileJurisdiction = '/profile/jurisdiction';
  static const profileDisclaimer = '/profile/disclaimer';
  static const purchase = '/profile/purchase';
  static const privacy = '/profile/privacy';
  static const terms = '/profile/terms';
  static const about = '/profile/about';

  /// Onboarding qadamlari tartibi.
  static const onboardingSteps = [language, disclaimer, mode];
}
