/// Marshrut yo‘llari — bitta joyda, string takrorlanmasligi uchun.
abstract final class Routes {
  static const language = '/onboarding/language';
  static const disclaimer = '/onboarding/disclaimer';
  static const mode = '/onboarding/mode';

  /// Onboarding’dan keyingi ixtiyoriy qadam: hisobsiz davom etish yoki
  /// hisob yaratish. Majburiy emas (redirect qadamlari ro‘yxatida yo‘q).
  static const welcomeAccount = '/welcome/account';
  static const welcomeProfile = '/welcome/account/profile';

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
  // Qidiruv natijalari uchun Home tabidagi nusxa yo‘llar (tab almashmaydi).
  static String homeSubstance(String id) => '/home/substance/$id';

  /// Pro: modda bo‘yicha tahlil rejasi.
  static String homePlan(String id) => '/home/substance/$id/plan';

  /// Pro: kengaytirilgan qidiruv (faset + teskari qidiruv).
  static const proSearch = '/home/search/pro';
  static String proSearchWith(String query) =>
      Uri(path: proSearch, queryParameters: {'q': query}).toString();
  static String homeTool(String id) => '/home/tool/$id';
  static String homeGuideline(String id) =>
      '/home/guideline/${Uri.encodeComponent(id)}';
  static String homeSpecimen(String id) => '/home/specimen/$id';
  static const homeStandards = '/home/standards';
  static const disciplines = '/home/disciplines';
  static String discipline(String code) => '/home/disciplines/$code';
  static const jurisdictions = '/home/jurisdictions';
  static const jurisdictionSelect = '/home/jurisdictions/select';
  static String jurisdiction(String id) => '/home/jurisdictions/$id';
  static String librarySection(String section) => '/library/section/$section';
  static const libraryStandards = '/library/standards';
  static const guidelines = '/library/guidelines';
  static const practiceCatalog = '/library/guidelines/practice';
  // «Ilmiy lug‘at» (term_translations).
  static const glossary = '/library/glossary';
  static String glossaryTerm(String id) =>
      '/library/glossary/term/${Uri.encodeComponent(id)}';
  static String homeGlossaryTerm(String id) =>
      '/home/glossary/${Uri.encodeComponent(id)}';
  static String guideline(String id) =>
      '/library/guidelines/card/${Uri.encodeComponent(id)}';
  // «Sudda so‘roq: tayyorgarlik» (Mutaxassis Pro; bepul — namunalar).
  static const courtPrep = '/library/court-prep';
  static const courtPrepPractice = '/library/court-prep/practice';
  static const courtPrepPrinciples = '/library/court-prep/principles';
  static const courtPrepSimulator = '/library/court-prep/simulator';
  static const courtPrepDrill = '/library/court-prep/drill';
  static const courtPrepStats = '/library/court-prep/stats';
  static String courtPrepScenario(String id) =>
      '/library/court-prep/simulator/${Uri.encodeComponent(id)}';
  static String courtPrepTopic(String id) =>
      '/library/court-prep/topic/${Uri.encodeComponent(id)}';
  static String courtPrepQuestion(String id) =>
      '/library/court-prep/q/${Uri.encodeComponent(id)}';
  // «Ekspert maqolalari» (FE_PUBLICATIONS yoki admin).
  static const publications = '/library/publications';
  static String publication(String id) =>
      '/library/publications/item/${Uri.encodeComponent(id)}';
  static const publicationSubmit = '/library/publications/submit';
  static const publicationsMine = '/library/publications/mine';
  static const publicationsModeration = '/library/publications/moderation';
  // Provenance qatlami.
  static const conflicts = '/library/conflicts';
  static String conflict(String id) => '/library/conflicts/$id';
  static const specimens = '/library/specimens';
  static String specimen(String id) => '/library/specimens/$id';
  static String chain(String id) => '/library/chain/$id';
  static const reviewStatus = '/library/review';
  static const quiz = '/home/learn/quiz';
  static const flashcards = '/home/learn/flashcards';

  /// O‘quv rejimi: manbali kartochkalar (Leitner) va test.
  static const study = '/home/learn/study';
  static String studyCards(String deckId) =>
      '$study/${Uri.encodeComponent(deckId)}/cards';

  /// [exam] — baholanadigan imtihon (aks holda mashq).
  static String studyQuiz(String deckId, {bool exam = false}) =>
      '$study/${Uri.encodeComponent(deckId)}/quiz${exam ? '?mode=exam' : ''}';

  static const tools = '/tools';
  static String tool(String id) => '/tools/tool/$id';

  /// «Ekspert ish daftari» — faqat qurilmada saqlanadigan shaxsiy yozuvlar.
  static const casebook = '/tools/casebook';
  static String casebookEntry(String id) =>
      '/tools/casebook/entry/${Uri.encodeComponent(id)}';

  static const library = '/library';
  static String libraryEntry(String id) => '/library/entry/$id';
  static const sources = '/library/sources';
  static String source(String id) =>
      '/library/source/${Uri.encodeComponent(id)}';

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
  static const aboutSources = '/profile/about/sources';
  static const aiDisclaimer = '/profile/ai-disclaimer';

  // Profil, professional tasdiqlash va taqriz ish joyi.
  static const profileEdit = '/profile/edit';
  static const verification = '/profile/verification';
  static const verificationDocuments = '/profile/verification/documents';
  static const reviewDashboard = '/profile/reviews';

  /// «Hamkasbingizni taklif qiling».
  static const referral = '/profile/invite';

  /// Egasi uchun admin panel (faqat identity_admin).
  static const admin = '/profile/admin';
  static const adminInbox = '/profile/admin/inbox';
  static String adminThread(String id) =>
      '/profile/admin/inbox/${Uri.encodeComponent(id)}';
  static const adminUsers = '/profile/admin/users';
  static const adminAudit = '/profile/admin/audit';
  static const adminVerifications = '/profile/admin/verifications';
  static String adminVerification(String applicantId) =>
      '/profile/admin/verifications/${Uri.encodeComponent(applicantId)}';

  /// «Taklif va murojaatlar» (foydalanuvchi).
  static const support = '/profile/support';
  static const supportNew = '/profile/support/new';

  /// Oldindan to‘ldirilgan forma (masalan, ilmiy xato: `category` +
  /// `entity` kontent identifikatori, `title` — mavzu uchun nom).
  static String supportNewFor({
    required String category,
    String? entity,
    String? title,
  }) => Uri(
    path: supportNew,
    queryParameters: {'category': category, 'entity': ?entity, 'title': ?title},
  ).toString();
  static String supportThread(String id) =>
      '/profile/support/thread/${Uri.encodeComponent(id)}';

  /// Kiruvchi taklif havolasi: `/invite/<CODE>` (deep link).
  static const invitePrefix = '/invite/';

  // Akkaunt (ixtiyoriy). Email marshrut satriga yozilmaydi — `extra`.
  static const accountSignIn = '/profile/account/sign-in';
  static const accountRegister = '/profile/account/register';
  static const accountVerify = '/profile/account/verify';
  static const accountForgot = '/profile/account/forgot';
  static const accountReset = '/profile/account/reset';
  static const accountDelete = '/profile/account/delete';
  static const accountEmailCode = '/profile/account/email';
  static const welcomeEmailCode = '/welcome/account/email';

  /// Onboarding qadamlari tartibi.
  static const onboardingSteps = [language, disclaimer, mode];
}
