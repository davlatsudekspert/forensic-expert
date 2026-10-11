import '../qa/qa_models.dart';

/// «Savol-javob (Hamjamiyat)» server porti.
///
/// Hamma qoida serverda: kim javob yozadi, kim pin qiladi, maxfiylik filtri,
/// kunlik limitlar. Mijoz faqat so‘rov yuboradi va javobni ko‘rsatadi.
/// Server ulanmagan bo‘lsa [isConfigured] `false` bo‘ladi va bo‘lim ilovada
/// umuman ko‘rinmaydi — ishlamaydigan funksiya ishlayotgandek ko‘rsatilmaydi.
abstract interface class QaService {
  bool get isConfigured;

  /// O‘z holati: profil, teglar, bugungi urinishlar, javob yozish huquqi.
  /// Kirmagan yoki xato — `null`.
  Future<QaMe?> status();

  /// Savollar ro‘yxati. Xato/oflayn — `null`.
  Future<QaFeed?> feed({String? tag, String? query, int limit, int offset});

  /// Bitta savol javoblari bilan; topilmasa yoki xato — `null`.
  Future<QaQuestion?> question(String id);

  /// O‘z savollari va javoblari (holati bilan).
  Future<QaMine?> mine();

  /// Savol berish. Maxfiylik filtri ishlasa natija `moderation` bo‘ladi.
  Future<QaPostResult?> ask({
    required QaLang lang,
    required String title,
    required String body,
    List<String> tags,
  });

  /// Javob yozish — faqat tasdiqlangan mutaxassis (serverda tekshiriladi).
  Future<QaPostResult?> answer({
    required String questionId,
    required QaLang lang,
    required String body,
  });

  /// Ovoz: −1, 0 (bekor qilish) yoki 1. Yangi ball yoki `null`.
  Future<QaAnswer?> vote(String answerId, int value);

  /// Eng yaxshi javobni belgilash (faqat savol egasi). `null` — bekor qilish.
  Future<bool> accept(String questionId, String? answerId);

  /// Shikoyat. Uch xil foydalanuvchi shikoyat qilsa post yashiriladi.
  Future<QaReportResult?> report({
    required QaTargetType target,
    required String id,
    required String reason,
  });

  /// Serverdagi mashina tarjimasi (keshlangan). Xato — `null`.
  Future<QaTranslation?> translate({
    required QaTargetType target,
    required String id,
    required QaLang lang,
  });

  /// Hujjat bo‘yicha tekshiruv. Hujjat **saqlanmaydi** — faqat so‘rov
  /// davomida xotirada bo‘ladi.
  Future<QaVerifyOutcome> verify({
    required QaRole role,
    required String countryCode,
    required QaDocument document,
    required QaLang lang,
  });

  /// Admin navbati — faqat admin uchun, aks holda `null`.
  Future<QaModerationQueue?> moderationQueue();

  Future<bool> moderate({
    required QaModerationAction action,
    required QaTargetType target,
    required String id,
    String? reason,
  });
}

/// Server ulanmagan holat. Hamma narsa `null`/`false` — bo‘lim yashiriladi.
class UnconfiguredQaService implements QaService {
  const UnconfiguredQaService();

  @override
  bool get isConfigured => false;

  @override
  Future<QaMe?> status() async => null;

  @override
  Future<QaFeed?> feed({
    String? tag,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async => null;

  @override
  Future<QaQuestion?> question(String id) async => null;

  @override
  Future<QaMine?> mine() async => null;

  @override
  Future<QaPostResult?> ask({
    required QaLang lang,
    required String title,
    required String body,
    List<String> tags = const [],
  }) async => null;

  @override
  Future<QaPostResult?> answer({
    required String questionId,
    required QaLang lang,
    required String body,
  }) async => null;

  @override
  Future<QaAnswer?> vote(String answerId, int value) async => null;

  @override
  Future<bool> accept(String questionId, String? answerId) async => false;

  @override
  Future<QaReportResult?> report({
    required QaTargetType target,
    required String id,
    required String reason,
  }) async => null;

  @override
  Future<QaTranslation?> translate({
    required QaTargetType target,
    required String id,
    required QaLang lang,
  }) async => null;

  @override
  Future<QaVerifyOutcome> verify({
    required QaRole role,
    required String countryCode,
    required QaDocument document,
    required QaLang lang,
  }) async => QaVerifyOutcome.failed('not_configured');

  @override
  Future<QaModerationQueue?> moderationQueue() async => null;

  @override
  Future<bool> moderate({
    required QaModerationAction action,
    required QaTargetType target,
    required String id,
    String? reason,
  }) async => false;
}
