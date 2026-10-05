/// Forensic AI va AI Tutor arxitekturasi (PHASE 4).
///
/// * **Provider’dan mustaqil**: [AiProvider] — interfeys; hech qaysi vendor
///   SDK yoki API kaliti ilovada yo‘q. PHASE 4 da real LLM ulanmagan.
/// * **RAG-first**: javob faqat [RetrievalProvider] topgan ichki bo‘laklarga
///   tayanadi. Kontekst bo‘lmasa — «ishonchli javob yo‘q».
/// * **Citation**: [CitationResolver] model qaytargan har bir havolani
///   olingan bo‘laklar bilan solishtiradi; noma’lum bo‘lak yoki manba —
///   javob rad etiladi (to‘qilgan manba hech qachon ko‘rsatilmaydi).
/// * **Xavfsizlik**: [SafetyPolicy] PII’ni, yakuniy o‘lim sababi/turi va
///   huquqiy xulosa so‘rovlarini bloklaydi.
/// * **Kvota**: AI Lifetime’ga «cheksiz» kirmaydi ([AiEntitlement]).
library;

import 'package:flutter/foundation.dart';

import '../ports/ai_ports.dart';
import '../ports/billing_ports.dart';

/// Ikki tajriba: professional (qisqa, manbali) va o‘quv (tushuntiruvchi).
enum AiExperience { professional, tutor }

/// Ichki bilim bazasidan olingan bo‘lak.
@immutable
class RetrievedChunk {
  const RetrievedChunk({
    required this.chunkId,
    required this.entityId,
    required this.text,
    required this.sourceIds,
    required this.tier,
    required this.score,
    this.title,
  });

  /// Barqaror ID (masalan, claim ID).
  final String chunkId;
  final String entityId;
  final String? title;
  final String text;
  final List<String> sourceIds;
  final AiEvidenceTier tier;
  final double score;
}

abstract interface class RetrievalProvider {
  Future<List<RetrievedChunk>> retrieve(String query, {int limit = 5});
}

/// Modelga beriladigan so‘rov — faqat olingan bo‘laklar bilan.
@immutable
class AiPrompt {
  const AiPrompt({
    required this.question,
    required this.experience,
    required this.chunks,
  });

  final AiQuestion question;
  final AiExperience experience;
  final List<RetrievedChunk> chunks;
}

/// Modelning xom javobi: matn va u ishora qilgan bo‘lak ID’lari.
@immutable
class AiDraft {
  const AiDraft({required this.text, required this.citedChunkIds});

  final String text;
  final List<String> citedChunkIds;
}

/// LLM provayderi (kelajak: server orqali). Ilovada kalit yo‘q.
abstract interface class AiProvider {
  bool get isConfigured;

  Future<AiDraft> generate(AiPrompt prompt);
}

/// PHASE 4: provayder ulanmagan.
class UnconfiguredAiProvider implements AiProvider {
  const UnconfiguredAiProvider();

  @override
  bool get isConfigured => false;

  @override
  Future<AiDraft> generate(AiPrompt prompt) =>
      throw StateError('AI provider is not configured');
}

// ---------------------------------------------------------------------------
// Xavfsizlik siyosati
// ---------------------------------------------------------------------------

enum SafetyBlock {
  /// Shaxsiy ma’lumot (ism, pasport, ish raqami…).
  personalData,

  /// Yakuniy o‘lim sababi / turi bo‘yicha xulosa so‘rovi.
  finalCauseOrManner,

  /// Huquqiy xulosa (aybdorlik, jinoyat tarkibi…) so‘rovi.
  legalConclusion,

  /// Rasmiy ekspert xulosasi / o‘lim guvohnomasi / qat’iy zaharlanish
  /// xulosasini yozib berish so‘rovi.
  officialOpinion,
}

@immutable
class SafetyDecision {
  const SafetyDecision(this.blocks);

  final Set<SafetyBlock> blocks;

  bool get allowed => blocks.isEmpty;
}

/// Kiruvchi savol va chiquvchi javob uchun qoidalar.
///
/// Kalit so‘z qoidalari — birinchi qatlam (server tarafda ikkinchisi
/// bo‘ladi). Ataylab ehtiyotkor: noto‘g‘ri blok ma’lumot sizib chiqishidan
/// yoki ekspert o‘rniga xulosa berishdan arzon.
class SafetyPolicy {
  const SafetyPolicy(this._pii);

  final PiiScanner _pii;

  static final _finalConclusion = RegExp(
    r'(cause|manner)\s+of\s+death\s+(was|is|in this case)|'
    r'determine\s+(the\s+)?(cause|manner)\s+of\s+death|'
    r'was\s+(it|this)\s+(a\s+)?(homicide|suicide|murder)|'
    r'причин[аеуы]\s+смерти\s+(был|была|в\s+данном)|'
    r'установ\p{L}*\s+причин\p{L}*\s+смерти|род\s+смерти\s+(был|в\s+данном)|'
    r'это\s+(убийство|самоубийство)|'
    r'o‘lim\s+sababi(ni)?\s+(aniqla|ayt|nima\s+edi)|'
    r'(qotillik|o‘z\s*joniga\s+qasd)\s+(edimi|bo‘lganmi)',
    caseSensitive: false,
    unicode: true,
  );

  static final _legal = RegExp(
    r'\bis\s+(he|she|the\s+suspect|the\s+driver)\s+guilty\b|'
    r'will\s+(he|she)\s+be\s+(convicted|charged)|'
    r'вино(вен|вна|вны)|будет\s+ли\s+(он|она)\s+осужд|'
    r'aybdor(mi|\s+bo‘ladimi)|sudlanadimi|jazo\s+oladimi',
    caseSensitive: false,
    unicode: true,
  );

  static final _official = RegExp(
    r'(write|draft|prepare|issue)\s+(the\s+|an?\s+)?(official\s+)?'
    r'(expert\s+(opinion|report|conclusion)|death\s+certificate)|'
    r'was\s+(he|she|the\s+deceased|the\s+victim)\s+(intoxicated|poisoned)|'
    r'(напиш|состав|подготов)\p{L}*\s+(заключени\p{L}*\s+эксперт|экспертн\p{L}*\s+заключени|свидетельств\p{L}*\s+о\s+смерти)|'
    r'был\p{L}*\s+ли\s+(он|она|погибш\p{L}*)\s+(отравлен|в\s+состоянии\s+опьянения)|'
    r'ekspert\s+xulosasi(ni)?\s+(yoz|tayyorla)|'
    r'(zaharlangan|mast)\s+(edimi|bo‘lganmi)',
    caseSensitive: false,
    unicode: true,
  );

  /// Huquqiy / protsessual savol (yurisdiksiya kerak) — kalit so‘zlar.
  static final _jurisdictional = RegExp(
    r'\b(law|legal|illegal|statut\w*|regulation|controlled\s+substance|'
    r'schedule[ds]?|drink[-\s]?driv\w*|driving\s+limit|prohibited|'
    r'permitted|penalt\w*|offen[cs]e)\b|'
    r'закон\p{L}*|правов\p{L}*|запрещ\p{L}*|контролируем\p{L}*|'
    r'список\s+[IVX]+|наказани\p{L}*|лимит\p{L}*\s+алкогол|'
    r'qonun\p{L}*|huquqiy|taqiqlan\p{L}*|nazorat\s+ro‘yxat\p{L}*|'
    r'jazo\p{L}*|ruxsat\s+etilgan',
    caseSensitive: false,
    unicode: true,
  );

  /// Savol huquqiy qatlamga tegishlimi (yurisdiksiya tanlash kerakmi).
  static bool isJurisdictional(String text) => _jurisdictional.hasMatch(text);

  SafetyDecision checkQuestion(String text) => SafetyDecision({
    if (_pii.scan(text).isNotEmpty) SafetyBlock.personalData,
    if (_finalConclusion.hasMatch(text)) SafetyBlock.finalCauseOrManner,
    if (_legal.hasMatch(text)) SafetyBlock.legalConclusion,
    if (_official.hasMatch(text)) SafetyBlock.officialOpinion,
  });

  /// Model javobi ham tekshiriladi (yakuniy xulosa yoki PII qaytmasin).
  SafetyDecision checkAnswer(String text) => checkQuestion(text);
}

// ---------------------------------------------------------------------------
// Citation
// ---------------------------------------------------------------------------

enum CitationRejection { noCitations, unknownChunk, unknownSource }

@immutable
class CitationCheck {
  const CitationCheck.ok(this.citations) : rejection = null;

  const CitationCheck.rejected(this.rejection) : citations = const [];

  final List<AiCitation> citations;
  final CitationRejection? rejection;

  bool get isValid => rejection == null;
}

/// Model havolalarini **faqat** shu so‘rov uchun olingan bo‘laklar bilan
/// moslaydi. Bitta noma’lum havola — butun javob rad etiladi.
class CitationResolver {
  const CitationResolver({required this.knownSourceIds});

  /// Kontent paketidagi manbalar (bo‘lak manbalari ham shu ro‘yxatda
  /// bo‘lishi shart).
  final Set<String> knownSourceIds;

  CitationCheck resolve(AiDraft draft, List<RetrievedChunk> retrieved) {
    if (draft.citedChunkIds.isEmpty) {
      return const CitationCheck.rejected(CitationRejection.noCitations);
    }
    final byId = {for (final c in retrieved) c.chunkId: c};
    final out = <AiCitation>[];
    for (final id in draft.citedChunkIds) {
      final chunk = byId[id];
      if (chunk == null) {
        return const CitationCheck.rejected(CitationRejection.unknownChunk);
      }
      for (final s in chunk.sourceIds) {
        if (!knownSourceIds.contains(s)) {
          return const CitationCheck.rejected(CitationRejection.unknownSource);
        }
        out.add(AiCitation(chunkId: id, sourceId: s, tier: chunk.tier));
      }
    }
    return CitationCheck.ok(out);
  }
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

enum AiRouteOutcome {
  /// Xavfsizlik qoidasi blokladi.
  blocked,

  /// Huquqiy savol, lekin yurisdiksiya tanlanmagan — AI taxmin qilmaydi,
  /// foydalanuvchidan tanlashni so‘raydi.
  jurisdictionRequired,

  /// Kvota yo‘q yoki AI rejasi yo‘q.
  quotaUnavailable,

  /// Ichki bazada mos bo‘lak yo‘q — ishonchli javob yo‘q.
  noReliableContext,

  /// LLM ulanmagan: faqat lokal manbalar ko‘rsatiladi (AI javobi emas).
  retrievalOnly,

  /// Model javobi citation/xavfsizlik tekshiruvidan o‘tmadi.
  rejected,

  answered,
}

@immutable
class AiRouteResult {
  const AiRouteResult(
    this.outcome, {
    this.chunks = const [],
    this.answer,
    this.safety,
    this.citationRejection,
  });

  final AiRouteOutcome outcome;
  final List<RetrievedChunk> chunks;
  final AiAnswer? answer;
  final SafetyDecision? safety;
  final CitationRejection? citationRejection;
}

/// Savolni xavfsizlik → kvota → qidiruv → (provayder) → citation →
/// javob xavfsizligi zanjiridan o‘tkazadi.
class AiRouter {
  const AiRouter({
    required this.safety,
    required this.retrieval,
    required this.provider,
    required this.citations,
  });

  final SafetyPolicy safety;
  final RetrievalProvider retrieval;
  final AiProvider provider;
  final CitationResolver citations;

  Future<AiRouteResult> route(
    AiQuestion question, {
    required AiExperience experience,
    required AiEntitlement entitlement,
  }) async {
    final s = safety.checkQuestion(question.text);
    if (!s.allowed) return AiRouteResult(AiRouteOutcome.blocked, safety: s);
    final j = question.jurisdictionId;
    if (SafetyPolicy.isJurisdictional(question.text) &&
        (j == null || j == 'INT')) {
      return const AiRouteResult(AiRouteOutcome.jurisdictionRequired);
    }

    final chunks = await retrieval.retrieve(question.text);
    if (chunks.isEmpty) {
      return const AiRouteResult(AiRouteOutcome.noReliableContext);
    }
    // Provayder yo‘q yoki kvota yo‘q — LLM chaqirilmaydi; lokal manbalar
    // (qidiruv natijasi) ko‘rsatiladi, AI javobi deb atalmaydi.
    if (!provider.isConfigured) {
      return AiRouteResult(AiRouteOutcome.retrievalOnly, chunks: chunks);
    }
    if (!entitlement.canAsk) {
      return AiRouteResult(AiRouteOutcome.quotaUnavailable, chunks: chunks);
    }
    final AiDraft draft;
    try {
      draft = await provider.generate(
        AiPrompt(question: question, experience: experience, chunks: chunks),
      );
    } on Exception {
      // Server/tarmoq xatosi — AI javobi o‘ylab topilmaydi; lokal manbalar.
      return AiRouteResult(AiRouteOutcome.retrievalOnly, chunks: chunks);
    }
    final check = citations.resolve(draft, chunks);
    if (!check.isValid) {
      return AiRouteResult(
        AiRouteOutcome.rejected,
        chunks: chunks,
        citationRejection: check.rejection,
      );
    }
    final out = safety.checkAnswer(draft.text);
    if (!out.allowed) {
      return AiRouteResult(
        AiRouteOutcome.rejected,
        chunks: chunks,
        safety: out,
      );
    }
    return AiRouteResult(
      AiRouteOutcome.answered,
      chunks: chunks,
      answer: AiAnswer(
        text: draft.text,
        citations: check.citations,
        noReliableAnswer: false,
      ),
    );
  }
}
