/// «Modda bo‘yicha tahlil rejasi» (Pro): bitta moddaning paketdagi mavjud
/// ma’lumotlaridan amaliy ketma-ketlik.
///
/// Qat’iy qoida: hech qanday yangi ilmiy da’vo, metod, qiymat yoki chegara
/// yo‘q. Har bir satr — paketdagi claim yoki manbali izoh (iqtibos, manba,
/// joylashuv, holat). Paketda yo‘q narsa halol «hujjatlashtirilmagan» deb
/// qoladi. «Xulosa uchun eslatma» — faqat paket bayroqlari va manbali
/// cheklov iqtiboslaridan.
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../evidence/evidence_models.dart';
import '../evidence/provenance_models.dart';
import '../evidence/substance_analysis.dart';
import '../knowledge/knowledge_models.dart';
import '../library/library_models.dart';
import 'pro_search.dart';

/// Iqtibosning plandagi roli (UI yorlig‘i shundan).
enum PlanRole {
  basis,
  presumptive,
  confirmationRequirement,
  limitation,
  crossReactivity,
  falsePositive,
  falseNegative,
  interference,
  detectionWindow,
  use,
  principle,
  application,
  observation,
}

/// Manbali iqtibos + holat + joylashuv.
@immutable
class PlanQuote {
  const PlanQuote({
    required this.role,
    required this.kind,
    required this.id,
    required this.text,
    required this.status,
    required this.level,
    this.texts = const {},
    this.source,
    this.locator,
    this.claimId,
    this.aboutId,
  });

  final PlanRole role;

  /// Tarjima turi (`claim_excerpt` yoki `entity_note`) va ID’si.
  final String kind;
  final String id;

  /// Asl iqtibos.
  final String text;

  /// Tilga moslangan matn (bo‘lsa; retsept/skrining izohlari).
  final Map<String, String> texts;
  final ScientificStatus status;
  final String level;
  final SourceView? source;

  /// Manba ichidagi aniq joy (bo‘lim, jadval, sahifa).
  final String? locator;
  final String? claimId;

  /// Iqtibos aynan qaysi yozuvga (metod, skrining, namuna) tegishli — modda
  /// emas: metod/test/namunaning umumiy cheklovi moddaga xos deb
  /// ko'rsatilmasligi uchun.
  final String? aboutId;

  static PlanQuote? fromClaim(ClaimView c, PlanRole role, {String? aboutId}) {
    final ex = c.excerpt;
    if (ex == null || ex.trim().isEmpty) return null;
    final src = c.sources.isEmpty ? null : c.sources.first;
    return PlanQuote(
      role: role,
      kind: 'claim_excerpt',
      id: c.claimId,
      text: ex,
      status: c.status,
      level: c.evidenceLevel,
      source: src,
      locator: (c.value['section'] as String?) ?? src?.locator,
      claimId: c.claimId,
      aboutId: aboutId,
    );
  }

  static PlanQuote fromNote(
    KnowledgeEntry e,
    SourcedNote n,
    String trId,
    PlanRole role,
  ) {
    final src = e.sourceById(n.sourceId);
    return PlanQuote(
      role: role,
      kind: 'entity_note',
      id: trId,
      text: n.text,
      texts: n.texts,
      status: e.status,
      level: src?.evidenceLevel ?? 'D',
      source: src,
      locator: n.locator ?? src?.locator,
      aboutId: e.id,
    );
  }
}

@immutable
class PlanSpecimen {
  const PlanSpecimen({
    required this.specimenId,
    required this.basis,
    required this.notes,
    required this.methodIds,
  });

  final String specimenId;

  /// Shu namunada qiymat keltirilgan manbali iqtiboslar.
  final List<PlanQuote> basis;

  /// Namunaning o‘z manbali izohlari (qo‘llanish, cheklov, aniqlash oynasi).
  final List<PlanQuote> notes;
  final List<String> methodIds;
}

@immutable
class PlanReagent {
  const PlanReagent({
    required this.reagentId,
    required this.hasRecipe,
    required this.quotes,
  });

  final String reagentId;

  /// Retsept sahifasi bor (reagentning o‘z yozuvi).
  final bool hasRecipe;

  /// Manbali kuzatuv / qo‘llanish konteksti (bo‘lsa).
  final List<PlanQuote> quotes;
}

@immutable
class PlanScreening {
  const PlanScreening({
    required this.screeningId,
    required this.principle,
    required this.supportsDefinitive,
    required this.quotes,
    required this.reagents,
    required this.confirmationIds,
  });

  final String screeningId;
  final String principle;
  final bool supportsDefinitive;
  final List<PlanQuote> quotes;
  final List<PlanReagent> reagents;
  final List<String> confirmationIds;
}

@immutable
class PlanMethod {
  const PlanMethod({
    required this.methodId,
    required this.families,
    required this.quotes,
    this.afterScreeningIds = const [],
  });

  final String methodId;
  final Set<MethodFamily> families;
  final List<PlanQuote> quotes;
  final List<String> afterScreeningIds;
}

/// «Xulosa uchun eslatma» turlari. Har biri paket bayrog‘i yoki manbali
/// iqtibosdan kelib chiqadi (yangi ilmiy da’vo emas).
enum PlanReminderKind {
  /// Skrining aniq identifikatsiyani qo‘llab-quvvatlamaydi (paket bayrog‘i).
  presumptiveOnly,

  /// Paketda tasdiqlovchi metod hujjatlashtirilgan (nomlari bilan).
  confirmationDocumented,

  /// Paketda tasdiqlovchi metod hujjatlashtirilmagan.
  confirmationNotDocumented,

  /// Manbadagi konsentratsiyalar `not_a_threshold`.
  concentrationNotThreshold,

  /// Metod namunaga bog‘lanmagan.
  methodsNotPaired,

  /// Hech bir asos reviewer tomonidan tasdiqlanmagan.
  nothingVerified,

  /// Paketda ochiq «evidence conflict» bor.
  openConflict,

  /// Paketda tahlil ma’lumoti yo‘q.
  noData,
}

@immutable
class PlanReminder {
  const PlanReminder({
    required this.kind,
    this.ids = const [],
    this.quotes = const [],
    this.count = 0,
  });

  final PlanReminderKind kind;

  /// Eslatmada nomi keltiriladigan yozuvlar (metod, skrining…).
  final List<String> ids;
  final List<PlanQuote> quotes;
  final int count;

  /// «Mumkin» (true) yoki «mumkin emas / ehtiyot bo‘ling» (false).
  bool get allowed => kind == PlanReminderKind.confirmationDocumented;
}

@immutable
class AnalysisPlan {
  const AnalysisPlan({
    required this.entityId,
    this.specimens = const [],
    this.presumptive = const [],
    this.bench = const [],
    this.confirmation = const [],
    this.instrumental = const [],
    this.interferences = const [],
    this.limits = const [],
    this.conflictIds = const [],
    this.reminders = const [],
  });

  final String entityId;
  final List<PlanSpecimen> specimens;
  final List<PlanScreening> presumptive;

  /// TLC / mikrokristall / UV-Vis (paketdagi tizimlari bilan).
  final List<PlanMethod> bench;
  final List<PlanMethod> confirmation;

  /// Boshqa instrumental metodlar (GC-FID, HPLC, immunoassay…).
  final List<PlanMethod> instrumental;
  final List<PlanQuote> interferences;
  final List<PlanQuote> limits;
  final List<String> conflictIds;
  final List<PlanReminder> reminders;

  bool get isEmpty =>
      specimens.isEmpty &&
      presumptive.isEmpty &&
      bench.isEmpty &&
      confirmation.isEmpty &&
      instrumental.isEmpty;

  /// Reja ichida tilga olingan barcha manbalar (takrorsiz, tartib bilan).
  List<SourceView> get allSources {
    final seen = <String>{};
    final out = <SourceView>[];
    void add(PlanQuote q) {
      final s = q.source;
      if (s != null && seen.add(s.sourceId)) out.add(s);
    }

    for (final s in specimens) {
      s.basis.forEach(add);
      s.notes.forEach(add);
    }
    for (final s in presumptive) {
      s.quotes.forEach(add);
      for (final r in s.reagents) {
        r.quotes.forEach(add);
      }
    }
    for (final m in [...bench, ...confirmation, ...instrumental]) {
      m.quotes.forEach(add);
    }
    interferences.forEach(add);
    limits.forEach(add);
    for (final r in reminders) {
      r.quotes.forEach(add);
    }
    return out;
  }

  static const _specimenNoteFields = {
    'use': PlanRole.use,
    'limitation': PlanRole.limitation,
    'detection_window': PlanRole.detectionWindow,
  };

  /// Reagent claim maydonlari: kutilgan kuzatuv (paketda hozir bo‘lmasligi
  /// mumkin — bo‘lsa ko‘rsatiladi) va qo‘llanish konteksti.
  static const observationFields = {
    'expected_observation',
    'colour_reaction',
    'color_reaction',
  };

  static AnalysisPlan build({
    required String entityId,
    required SubstanceAnalysis analysis,
    required KnowledgeRepository knowledge,
    required ProvenanceIndex provenance,
    required EvidenceData evidence,
  }) {
    String norm(String s) => proNormalize(s);
    final seenByScope = <String, Set<String>>{};
    // Har blok o'z doirasida takrorlarni olib tashlaydi; [anyRole] — bir xil
    // matn turli rolda (masalan cross-reactivity va false positive) bir
    // marta; [skip] — boshqa blokda allaqachon ko'rsatilgan matnlar.
    List<PlanQuote> uniq(
      Iterable<PlanQuote?> qs, {
      String scope = 'x',
      bool anyRole = false,
      Set<String> skip = const {},
    }) {
      final seen = seenByScope.putIfAbsent(scope, () => {});
      final out = <PlanQuote>[];
      for (final q in qs) {
        if (q == null) continue;
        final text = norm(q.text);
        if (skip.contains(text)) continue;
        if (seen.add(anyRole ? text : '${q.role.name}|$text')) out.add(q);
      }
      return out;
    }

    List<PlanQuote> basisOf(Iterable<ClaimView> cs, String scope) => [
      ...uniq([
        for (final c in cs) PlanQuote.fromClaim(c, PlanRole.basis),
      ], scope: scope),
    ];

    final targetToReagents = <String, Set<String>>{};
    ProSearchIndex.reagentTargets(
      knowledge: knowledge,
      evidence: evidence,
    ).forEach((r, ts) {
      for (final t in ts) {
        targetToReagents.putIfAbsent(t, () => {}).add(r);
      }
    });

    // --- namunalar ----------------------------------------------------------
    final specimens = <PlanSpecimen>[];
    for (final s in analysis.specimens) {
      specimens.add(
        PlanSpecimen(
          specimenId: s.specimenId,
          basis: basisOf(s.basisClaims, 'spec'),
          notes: [
            for (final c in provenance.claimsAbout(s.specimenId))
              if (_specimenNoteFields.containsKey(c.field))
                ...uniq([
                  PlanQuote.fromClaim(
                    c,
                    _specimenNoteFields[c.field]!,
                    aboutId: s.specimenId,
                  ),
                ], scope: 'spec-notes'),
          ],
          methodIds: s.methodIds,
        ),
      );
    }

    // --- skrining (presumptive) ---------------------------------------------
    PlanQuote? claimQuote(KnowledgeEntry e, String field, PlanRole role) {
      for (final c in e.claims) {
        if (c.field == field) {
          return PlanQuote.fromClaim(c, role, aboutId: e.id);
        }
      }
      return null;
    }

    final presumptive = <PlanScreening>[];
    for (final sc in analysis.screenings) {
      final e = knowledge.byId(sc.screeningId);
      final t = e?.screening;
      final quotes = <PlanQuote>[...basisOf(sc.basisClaims, 'pres')];
      if (e != null) {
        quotes.addAll(
          uniq([
            claimQuote(e, 'presumptive_nature', PlanRole.presumptive),
            claimQuote(
              e,
              'confirmation_requirement',
              PlanRole.confirmationRequirement,
            ),
          ], scope: 'pres'),
        );
      }
      final reagentIds = [...?targetToReagents[sc.screeningId]]..sort();
      presumptive.add(
        PlanScreening(
          screeningId: sc.screeningId,
          principle: t?.principle ?? '',
          supportsDefinitive: t?.supportsDefinitiveIdentification ?? false,
          quotes: quotes,
          confirmationIds: sc.confirmationMethodIds,
          reagents: [
            for (final rid in reagentIds)
              PlanReagent(
                reagentId: rid,
                hasRecipe: knowledge.byId(rid)?.recipe != null,
                quotes: [
                  for (final c
                      in knowledge.byId(rid)?.claims ?? const <ClaimView>[])
                    if (observationFields.contains(c.field) ||
                        c.field == 'use_context')
                      ...uniq([
                        PlanQuote.fromClaim(
                          c,
                          observationFields.contains(c.field)
                              ? PlanRole.observation
                              : PlanRole.use,
                          aboutId: rid,
                        ),
                      ], scope: 'reagent'),
                ],
              ),
          ],
        ),
      );
    }

    // --- metodlar -----------------------------------------------------------
    PlanMethod planMethod(AnalysisMethod m) => PlanMethod(
      methodId: m.methodId,
      families: {
        ...familiesOfTechniques(
          knowledge.byId(m.methodId)?.method?.techniques ?? const [],
        ),
      },
      quotes: basisOf(m.basisClaims, 'methods'),
      afterScreeningIds: m.afterScreeningIds,
    );

    final confirmation = [
      for (final m in analysis.confirmationMethods) planMethod(m),
    ];
    final confirmationIds = {for (final m in confirmation) m.methodId};
    const benchFamilies = {
      MethodFamily.tlc,
      MethodFamily.microcrystal,
      MethodFamily.uvVis,
    };
    final bench = <PlanMethod>[];
    final instrumental = <PlanMethod>[];
    for (final m in analysis.analyticalMethods) {
      if (confirmationIds.contains(m.methodId)) continue;
      final pm = planMethod(m);
      (pm.families.any(benchFamilies.contains) ? bench : instrumental).add(pm);
    }

    // --- halaqitlar va talqin chegaralari -----------------------------------
    // Bu iqtiboslar moddaga emas, aynan ko'rsatilgan test / metod / namunaga
    // tegishli ([PlanQuote.aboutId]). Boshqa blokda allaqachon ko'rsatilgan
    // matn takrorlanmaydi.
    final shown = <String>{
      for (final s in presumptive)
        for (final q in s.quotes) norm(q.text),
      for (final m in [...bench, ...confirmation, ...instrumental])
        for (final q in m.quotes) norm(q.text),
    };
    final interferences = <PlanQuote>[];
    final limits = <PlanQuote>[];
    List<PlanQuote> noteQuotes(
      KnowledgeEntry e,
      List<SourcedNote> notes,
      String key,
      PlanRole role,
      String scope,
    ) => uniq(
      [
        for (final (i, n) in notes.indexed)
          PlanQuote.fromNote(e, n, '${e.id}#$key[$i]', role),
      ],
      scope: scope,
      anyRole: true,
      skip: scope == 'limits' ? shown : const {},
    );
    List<PlanQuote> limitClaims(KnowledgeEntry e) => uniq(
      [
        for (final c in e.claims)
          if (c.field == 'limitation')
            PlanQuote.fromClaim(c, PlanRole.limitation, aboutId: e.id),
      ],
      scope: 'limits',
      anyRole: true,
      skip: shown,
    );
    for (final sc in analysis.screenings) {
      final e = knowledge.byId(sc.screeningId);
      final t = e?.screening;
      if (e == null || t == null) continue;
      interferences
        ..addAll(
          noteQuotes(
            e,
            t.crossReactivity,
            'cross_reactivity',
            PlanRole.crossReactivity,
            'interf',
          ),
        )
        ..addAll(
          noteQuotes(
            e,
            t.falsePositive,
            'false_positive',
            PlanRole.falsePositive,
            'interf',
          ),
        )
        ..addAll(
          noteQuotes(
            e,
            t.falseNegative,
            'false_negative',
            PlanRole.falseNegative,
            'interf',
          ),
        )
        ..addAll(
          noteQuotes(
            e,
            t.interferences,
            'interferences',
            PlanRole.interference,
            'interf',
          ),
        )
        ..addAll(
          uniq(
            [
              claimQuote(e, 'cross_reactivity', PlanRole.crossReactivity),
              claimQuote(e, 'test_class_limitation', PlanRole.limitation),
            ],
            scope: 'interf',
            anyRole: true,
          ),
        );
      limits
        ..addAll(
          noteQuotes(
            e,
            t.limitations,
            'limitations',
            PlanRole.limitation,
            'limits',
          ),
        )
        ..addAll(limitClaims(e));
    }
    for (final m in [...bench, ...confirmation, ...instrumental]) {
      final e = knowledge.byId(m.methodId);
      if (e != null) limits.addAll(limitClaims(e));
    }
    // Namuna cheklovlari (PMR, barqarorlik, aniqlash oynasi - faqat manbali).
    for (final s in specimens) {
      limits.addAll(
        uniq(
          [
            for (final n in s.notes)
              if (n.role == PlanRole.limitation ||
                  n.role == PlanRole.detectionWindow)
                n,
          ],
          scope: 'limits',
          anyRole: true,
          skip: shown,
        ),
      );
    }

    // --- eslatmalar ---------------------------------------------------------
    final allStatuses = <ScientificStatus>[
      for (final s in specimens) ...s.basis.map((q) => q.status),
      for (final m in [...bench, ...confirmation, ...instrumental])
        ...m.quotes.map((q) => q.status),
      for (final s in presumptive) ...s.quotes.map((q) => q.status),
    ];
    final reminders = <PlanReminder>[];
    final nonDefinitive = [
      for (final s in presumptive)
        if (!s.supportsDefinitive) s,
    ];
    if (nonDefinitive.isNotEmpty) {
      reminders.add(
        PlanReminder(
          kind: PlanReminderKind.presumptiveOnly,
          ids: [for (final s in nonDefinitive) s.screeningId],
          quotes: [
            for (final s in nonDefinitive)
              for (final q in s.quotes)
                if (q.role == PlanRole.presumptive ||
                    q.role == PlanRole.confirmationRequirement)
                  q,
          ],
        ),
      );
    }
    if (confirmation.isNotEmpty) {
      reminders.add(
        PlanReminder(
          kind: PlanReminderKind.confirmationDocumented,
          ids: [for (final m in confirmation) m.methodId],
        ),
      );
    } else if (presumptive.isNotEmpty) {
      reminders.add(
        const PlanReminder(kind: PlanReminderKind.confirmationNotDocumented),
      );
    }
    final notThreshold = [
      for (final s in analysis.specimens)
        for (final c in s.basisClaims)
          if (c.field == 'reported_concentration' &&
              c.value['not_a_threshold'] == true)
            c,
    ];
    if (notThreshold.isNotEmpty) {
      reminders.add(
        PlanReminder(
          kind: PlanReminderKind.concentrationNotThreshold,
          count: notThreshold.length,
        ),
      );
    }
    if (analysis.analyticalMethods.isNotEmpty &&
        !analysis.methodsLinkedToSpecimens) {
      reminders.add(
        const PlanReminder(kind: PlanReminderKind.methodsNotPaired),
      );
    }
    final openConflicts = [
      for (final c in provenance.conflictsFor(entityId))
        if (c.state == EvidenceConflictState.open) c.id,
    ];
    if (openConflicts.isNotEmpty) {
      reminders.add(
        PlanReminder(
          kind: PlanReminderKind.openConflict,
          ids: openConflicts,
          count: openConflicts.length,
        ),
      );
    }
    if (allStatuses.isNotEmpty &&
        !allStatuses.contains(ScientificStatus.verified)) {
      reminders.add(const PlanReminder(kind: PlanReminderKind.nothingVerified));
    }
    if (analysis.isEmpty) {
      reminders
        ..clear()
        ..add(const PlanReminder(kind: PlanReminderKind.noData));
    }

    return AnalysisPlan(
      entityId: entityId,
      specimens: specimens,
      presumptive: presumptive,
      bench: bench,
      confirmation: confirmation,
      instrumental: instrumental,
      interferences: interferences,
      limits: limits,
      conflictIds: openConflicts,
      reminders: reminders,
    );
  }
}
