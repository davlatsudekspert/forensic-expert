/// PHASE 9: Forensic AI — production’ga yo‘naltirilgan RAG quvuri.
///
/// LLM ilmiy ma’lumotlar bazasi EMAS. Har bir javob faqat shu so‘rov uchun
/// olingan ichki bo‘laklarga tayanadi va quyidagi zanjirdan o‘tadi:
///
/// ```
/// SAVOL → xavfsizlik → niyat/domen → yurisdiksiya → ichki qidiruv
///       → dalil reytingi → (provayder) → citation tekshiruvi
///       → identifikator yaxlitligi → javob xavfsizligi → tuzilgan javob
/// ```
///
/// Ustuvorlik: 1) review qilingan ichki kontent, 2) manbalar katalogi,
/// 3) xalqaro standartlar, 4) rasmiy yurisdiksiya kontenti, 5) tashqi
/// tekshirilmagan qidiruv (faqat kerak bo‘lsa; hozir ulanmagan).
///
/// Maxfiylik: savol hech qayerga log qilinmaydi; PII topilsa savol
/// yuborilmaydi ([SafetyPolicy]). Telemetriya savol matnini qabul qilmaydi
/// (`TelemetryPolicy`).
library;

import 'package:flutter/foundation.dart';

import '../ports/ai_ports.dart';
import '../ports/billing_ports.dart';
import 'ai_architecture.dart';

/// Savol domeni (qidiruv va reviewer roli uchun).
enum AiDomain {
  toxicology,
  forensicMedicine,
  laboratory,
  biochemistry,
  legal,
  general,
}

/// Savol niyati.
enum AiIntent {
  definition,
  interpretation,
  method,
  legal,
  calculation,
  general,
}

@immutable
class AiIntentResult {
  const AiIntentResult(this.domain, this.intent);

  final AiDomain domain;
  final AiIntent intent;
}

/// Kalit so‘zlar (EN/RU/UZ) bo‘yicha deterministik tasnif — model emas.
abstract final class AiIntentClassifier {
  static final _rules = <(AiDomain, RegExp)>[
    (
      AiDomain.legal,
      RegExp(
        r'\blaw\b|legal|schedule[d ]|controlled|jurisdiction|закон|правов|'
        r'qonun|huquq',
        caseSensitive: false,
      ),
    ),
    (
      AiDomain.laboratory,
      RegExp(
        r'gc-?ms|lc-?ms|hplc|chromatograph|calibrat|validat|lod|loq|'
        r'хроматограф|валидац|kalibr|xromatograf',
        caseSensitive: false,
      ),
    ),
    (
      AiDomain.biochemistry,
      RegExp(
        r'vitreous|potassium|glucose|tryptase|hba1c|стекловидн|калий|'
        r'shishasimon|kaliy',
        caseSensitive: false,
      ),
    ),
    (
      AiDomain.forensicMedicine,
      RegExp(
        r'mortis|post-?mortem interval|autopsy|injur|trauma|livor|rigor|'
        r'трупн|вскрыт|травм|murda|jarohat',
        caseSensitive: false,
      ),
    ),
    (
      AiDomain.toxicology,
      RegExp(
        r'metabolit|concentration|toxic|drug|opioid|fentanyl|morphine|'
        r'метаболит|концентрац|токсик|metabolit|konsentrats|zahar',
        caseSensitive: false,
      ),
    ),
  ];

  static AiIntentResult classify(String q) {
    var domain = AiDomain.general;
    for (final (d, rx) in _rules) {
      if (rx.hasMatch(q)) {
        domain = d;
        break;
      }
    }
    final s = q.toLowerCase();
    final intent = SafetyPolicy.isJurisdictional(q)
        ? AiIntent.legal
        : RegExp(r'what is|define|что такое|nima\b|ta.rif').hasMatch(s)
        ? AiIntent.definition
        : RegExp(r'interpret|mean|significan|означает|talqin').hasMatch(s)
        ? AiIntent.interpretation
        : RegExp(r'calculat|рассчит|hisobla').hasMatch(s)
        ? AiIntent.calculation
        : RegExp(r'method|how to (analy|detect|measure)|метод|metod')
              .hasMatch(s)
        ? AiIntent.method
        : AiIntent.general;
    return AiIntentResult(domain, intent);
  }
}

/// Bo‘lak turi — manba ustuvorligi.
enum AiSourcePriority {
  reviewedInternal,
  sourceCatalogue,
  internationalStandard,
  officialJurisdiction,
  externalUnverified,
}

/// Qidiruv natijasi + PHASE 7 provenance holati.
@immutable
class RankedChunk {
  const RankedChunk({
    required this.chunk,
    required this.priority,
    this.lifecycle = 'NEEDS_REVIEW',
    this.hasConflict = false,
    this.identifiers = const {},
  });

  final RetrievedChunk chunk;
  final AiSourcePriority priority;

  /// Claim hayot sikli kodi (`CURRENT`, `NEEDS_REVIEW`, `RETRACTED`…).
  final String lifecycle;
  final bool hasConflict;

  /// Bo‘lak manbalarining DOI/PMID’lari (javob matnidagi identifikatorlarni
  /// tekshirish uchun).
  final Set<String> identifiers;

  bool get excluded =>
      lifecycle == 'RETRACTED' ||
      lifecycle == 'SUPERSEDED' ||
      lifecycle == 'REJECTED';
}

/// Dalil reytingi: retraksiya/almashtirilgan/rad etilgan bo‘laklar
/// **chiqariladi**; qolgani ustuvorlik, so‘ng moslik bo‘yicha.
abstract final class EvidenceRanker {
  static List<RankedChunk> rank(Iterable<RankedChunk> input) {
    final kept = [
      for (final c in input)
        if (!c.excluded) c,
    ];
    kept.sort((a, b) {
      final p = a.priority.index.compareTo(b.priority.index);
      return p != 0 ? p : b.chunk.score.compareTo(a.chunk.score);
    });
    return kept;
  }
}

/// Javob matnida keltirilgan DOI/PMID faqat keltirilgan bo‘laklar
/// manbalarida bo‘lishi mumkin — aks holda to‘qilgan havola.
abstract final class IdentifierIntegrity {
  static final _doi = RegExp(r'10\.\d{4,9}/[^\s,;)\]]+', caseSensitive: false);
  static final _pmid = RegExp(r'PMID:?\s*(\d{5,9})', caseSensitive: false);

  static Set<String> mentioned(String text) => {
    for (final m in _doi.allMatches(text))
      m.group(0)!.toLowerCase().replaceAll(RegExp(r'[.]+$'), ''),
    for (final m in _pmid.allMatches(text)) m.group(1)!,
  };

  static bool ok(String text, Iterable<RankedChunk> cited) {
    final allowed = {
      for (final c in cited)
        for (final i in c.identifiers) i.toLowerCase(),
    };
    return mentioned(text).every(allowed.contains);
  }
}

/// Provayderning ulanish holati — UI va hisobotda halol ko‘rsatiladi.
enum AiProviderMode {
  /// Hech narsa ulanmagan.
  none,

  /// Test/mock provayder — **production’ga ulangan emas**.
  mock,

  /// Server proksi orqali haqiqiy LLM (kalit faqat serverda).
  production,
}

/// MOCK provayder — faqat testlar va demo uchun. Berilgan bo‘laklardan
/// birinchisini qaytaradi; hech qachon «production» deb belgilanmaydi.
class MockAiProvider implements AiProvider {
  MockAiProvider({this.respond});

  /// Testlar uchun maxsus javob (gallyutsinatsiya simulyatsiyasi).
  final AiDraft Function(AiPrompt prompt)? respond;

  static const mode = AiProviderMode.mock;

  @override
  bool get isConfigured => true;

  @override
  Future<AiDraft> generate(AiPrompt prompt) async {
    if (respond != null) return respond!(prompt);
    final first = prompt.chunks.first;
    return AiDraft(text: first.text, citedChunkIds: [first.chunkId]);
  }
}

enum RagOutcome {
  blocked,
  jurisdictionRequired,
  noReliableContext,
  retrievalOnly,
  quotaUnavailable,
  rejectedCitation,
  rejectedIdentifier,
  rejectedSafety,
  answered,
}

/// Tuzilgan javob: JAVOB · MANBALAR · DALIL HOLATI · YURISDIKSIYA ·
/// CHEKLOVLAR · BOG‘LIQ YOZUVLAR.
@immutable
class RagAnswer {
  const RagAnswer({
    required this.outcome,
    required this.intent,
    this.text,
    this.sources = const [],
    this.evidence = const [],
    this.jurisdictionId,
    this.limitations = const [],
    this.relatedEntityIds = const [],
    this.safety,
    this.excludedRetracted = 0,
    this.providerMode = AiProviderMode.none,
  });

  final RagOutcome outcome;
  final AiIntentResult intent;
  final String? text;
  final List<AiCitation> sources;

  /// Javobga tayangan bo‘laklar (hayot sikli va ziddiyat bilan).
  final List<RankedChunk> evidence;
  final String? jurisdictionId;

  /// Mashina kodlari: `not_human_verified`, `evidence_conflict`,
  /// `mock_provider`, `retracted_excluded`, `expert_judgment_required`.
  final List<String> limitations;
  final List<String> relatedEntityIds;
  final SafetyDecision? safety;
  final int excludedRetracted;
  final AiProviderMode providerMode;
}

/// To‘liq RAG quvuri. Qidiruv natijasi `RankedChunk` sifatida beriladi
/// (provenance qatlami bilan boyitilgan).
class RagPipeline {
  RagPipeline({
    required this.safety,
    required this.retrieve,
    required this.provider,
    required this.knownSourceIds,
    this.providerMode = AiProviderMode.none,
    this.limit = 6,
  });

  final SafetyPolicy safety;

  /// Qidiruv: so‘rov, niyat va tanlangan yurisdiksiya (huquqiy bo‘laklar
  /// faqat shu yurisdiksiya va INT dan).
  final Future<List<RankedChunk>> Function(
    String query,
    AiIntentResult intent,
    String? jurisdictionId,
  )
  retrieve;
  final AiProvider provider;
  final Set<String> knownSourceIds;
  final AiProviderMode providerMode;
  final int limit;

  Future<RagAnswer> ask(
    AiQuestion q, {
    required AiExperience experience,
    required AiEntitlement entitlement,
  }) async {
    final intent = AiIntentClassifier.classify(q.text);
    final s = safety.checkQuestion(q.text);
    if (!s.allowed) {
      return RagAnswer(outcome: RagOutcome.blocked, intent: intent, safety: s);
    }
    final j = q.jurisdictionId;
    final needsJ =
        intent.intent == AiIntent.legal || intent.domain == AiDomain.legal;
    if (needsJ && (j == null || j == 'INT')) {
      return RagAnswer(
        outcome: RagOutcome.jurisdictionRequired,
        intent: intent,
      );
    }

    final raw = await retrieve(q.text, intent, j);
    final ranked = EvidenceRanker.rank(raw).take(limit).toList();
    final excluded = raw.where((c) => c.excluded).length;
    if (ranked.isEmpty) {
      return RagAnswer(
        outcome: RagOutcome.noReliableContext,
        intent: intent,
        excludedRetracted: excluded,
      );
    }
    final limitations = <String>[
      if (ranked.every((c) => c.lifecycle != 'CURRENT')) 'not_human_verified',
      if (ranked.any((c) => c.hasConflict)) 'evidence_conflict',
      if (excluded > 0) 'retracted_excluded',
      'expert_judgment_required',
    ];
    final related = {for (final c in ranked) c.chunk.entityId}.toList();

    if (!provider.isConfigured) {
      return RagAnswer(
        outcome: RagOutcome.retrievalOnly,
        intent: intent,
        evidence: ranked,
        jurisdictionId: needsJ ? j : null,
        limitations: limitations,
        relatedEntityIds: related,
        excludedRetracted: excluded,
      );
    }
    if (!entitlement.canAsk) {
      return RagAnswer(
        outcome: RagOutcome.quotaUnavailable,
        intent: intent,
        evidence: ranked,
        relatedEntityIds: related,
      );
    }
    final draft = await provider.generate(
      AiPrompt(
        question: q,
        experience: experience,
        chunks: [for (final c in ranked) c.chunk],
      ),
    );
    final check = CitationResolver(knownSourceIds: knownSourceIds)
        .resolve(draft, [for (final c in ranked) c.chunk]);
    if (!check.isValid) {
      return RagAnswer(
        outcome: RagOutcome.rejectedCitation,
        intent: intent,
        evidence: ranked,
      );
    }
    final cited = [
      for (final c in ranked)
        if (draft.citedChunkIds.contains(c.chunk.chunkId)) c,
    ];
    if (!IdentifierIntegrity.ok(draft.text, cited)) {
      return RagAnswer(
        outcome: RagOutcome.rejectedIdentifier,
        intent: intent,
        evidence: ranked,
      );
    }
    final out = safety.checkAnswer(draft.text);
    if (!out.allowed) {
      return RagAnswer(
        outcome: RagOutcome.rejectedSafety,
        intent: intent,
        evidence: ranked,
        safety: out,
      );
    }
    return RagAnswer(
      outcome: RagOutcome.answered,
      intent: intent,
      text: draft.text,
      sources: check.citations,
      evidence: cited,
      jurisdictionId: needsJ ? j : null,
      limitations: [
        ...limitations,
        if (providerMode == AiProviderMode.mock) 'mock_provider',
      ],
      relatedEntityIds: related,
      excludedRetracted: excluded,
      providerMode: providerMode,
    );
  }
}
