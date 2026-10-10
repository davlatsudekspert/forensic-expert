/// Professional qidiruv (Pro): faset filtrlar, aniq/ibora qidiruvi va teskari
/// (reverse) qidiruvlar.
///
/// Hammasi faqat kontent paketidagi **mavjud** bog‘lanishlar va claim’lardan
/// yig‘iladi (`measured_in`, `analysed_by`, `screened_by`, `confirmed_by`,
/// `used_in`, retseptning `associated_method_ids`). Hech narsa taxmin
/// qilinmaydi: paketda bog‘lanish bo‘lmasa — natija bo‘sh va UI buni halol
/// aytadi.
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../evidence/evidence_models.dart';
import '../evidence/provenance_models.dart';
import '../knowledge/knowledge_models.dart';
import '../library/library_models.dart';

/// Natija turi (guruhlash tartibi shu).
enum ProEntityType { substance, method, screening, reagent }

/// Metod oilasi (faset). Texnika kodlaridan yoki skrining/reagent
/// ta’rifidan; matndan taxmin qilinmaydi (mikrokristall — faqat nomida
/// aytilgan bo‘lsa).
enum MethodFamily {
  colourTest,
  tlc,
  microcrystal,
  uvVis,
  immunoassay,
  gcMs,
  lcMs,
  hrms,
  gcFid,
  hplc,
}

Set<MethodFamily> familiesOfTechniques(Iterable<AnalyticalTechnique> ts) => {
  for (final t in ts)
    ...switch (t) {
      AnalyticalTechnique.tlc => {MethodFamily.tlc},
      AnalyticalTechnique.uvVis ||
      AnalyticalTechnique.spectrophotometry => {MethodFamily.uvVis},
      AnalyticalTechnique.immunoassay => {MethodFamily.immunoassay},
      AnalyticalTechnique.gcMs ||
      AnalyticalTechnique.gcMsMs => {MethodFamily.gcMs},
      AnalyticalTechnique.lcMs ||
      AnalyticalTechnique.lcMsMs => {MethodFamily.lcMs},
      AnalyticalTechnique.hrms => {MethodFamily.hrms},
      AnalyticalTechnique.gcFid ||
      AnalyticalTechnique.headspaceGc => {MethodFamily.gcFid},
      AnalyticalTechnique.hplc => {MethodFamily.hplc},
      _ => <MethodFamily>{},
    },
};

/// Skrining testining oilasi: faqat uning o‘z ID’si / `principle` maydonidagi
/// aniq so‘zlardan.
Set<MethodFamily> familiesOfScreening(String id, String principle) {
  final s = '${id.toLowerCase()} ${principle.toLowerCase()}';
  return {
    if (s.contains('colour') || s.contains('color')) MethodFamily.colourTest,
    if (s.contains('immunoassay')) MethodFamily.immunoassay,
    if (s.contains('microcryst')) MethodFamily.microcrystal,
    if (s.contains('tlc') || s.contains('thin-layer')) MethodFamily.tlc,
  };
}

/// Qidiruv uchun normallashtirish: kichik harf, apostrof/ʻ olib tashlanadi,
/// ё→е, harf/raqam bo‘lmagan belgilar bo‘shliqqa.
String proNormalize(String s) {
  final lower = s
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(RegExp('[‘’ʻʼ\'`´]'), '');
  return lower.replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ').trim();
}

enum ProFacet {
  discipline,
  substanceClass,
  specimen,
  family,
  reagent,
  evidence,
  status,
  jurisdiction,
  year,
}

const _unset = Object();

/// Qidiruv filtri. Bo‘sh filtr — hamma yozuv.
@immutable
class ProFilter {
  const ProFilter({
    this.text = '',
    this.exact = false,
    this.types = const {},
    this.discipline,
    this.substanceClass,
    this.specimenId,
    this.family,
    this.reagentId,
    this.evidenceAtLeast,
    this.status,
    this.jurisdictionId,
    this.yearFrom,
    this.yearTo,
  });

  /// Erkin matn. `"..."` ichida — ibora (ketma-ket so‘zlar).
  final String text;

  /// Faqat to‘liq nom/sinonim mosligi.
  final bool exact;
  final Set<ProEntityType> types;
  final ForensicDiscipline? discipline;
  final String? substanceClass;
  final String? specimenId;
  final MethodFamily? family;
  final String? reagentId;

  /// `A`…`D`: yozuvning eng yaxshi dalil darajasi shu yoki yuqori.
  final String? evidenceAtLeast;
  final ScientificStatus? status;
  final String? jurisdictionId;
  final int? yearFrom;
  final int? yearTo;

  bool get isEmpty =>
      text.trim().isEmpty && activeFacets.isEmpty && types.isEmpty && !exact;

  Set<ProFacet> get activeFacets => {
    if (discipline != null) ProFacet.discipline,
    if (substanceClass != null) ProFacet.substanceClass,
    if (specimenId != null) ProFacet.specimen,
    if (family != null) ProFacet.family,
    if (reagentId != null) ProFacet.reagent,
    if (evidenceAtLeast != null) ProFacet.evidence,
    if (status != null) ProFacet.status,
    if (jurisdictionId != null) ProFacet.jurisdiction,
    if (yearFrom != null || yearTo != null) ProFacet.year,
  };

  ProFilter copyWith({
    String? text,
    bool? exact,
    Set<ProEntityType>? types,
    Object? discipline = _unset,
    Object? substanceClass = _unset,
    Object? specimenId = _unset,
    Object? family = _unset,
    Object? reagentId = _unset,
    Object? evidenceAtLeast = _unset,
    Object? status = _unset,
    Object? jurisdictionId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
  }) => ProFilter(
    text: text ?? this.text,
    exact: exact ?? this.exact,
    types: types ?? this.types,
    discipline: identical(discipline, _unset)
        ? this.discipline
        : discipline as ForensicDiscipline?,
    substanceClass: identical(substanceClass, _unset)
        ? this.substanceClass
        : substanceClass as String?,
    specimenId: identical(specimenId, _unset)
        ? this.specimenId
        : specimenId as String?,
    family: identical(family, _unset) ? this.family : family as MethodFamily?,
    reagentId: identical(reagentId, _unset)
        ? this.reagentId
        : reagentId as String?,
    evidenceAtLeast: identical(evidenceAtLeast, _unset)
        ? this.evidenceAtLeast
        : evidenceAtLeast as String?,
    status: identical(status, _unset)
        ? this.status
        : status as ScientificStatus?,
    jurisdictionId: identical(jurisdictionId, _unset)
        ? this.jurisdictionId
        : jurisdictionId as String?,
    yearFrom: identical(yearFrom, _unset) ? this.yearFrom : yearFrom as int?,
    yearTo: identical(yearTo, _unset) ? this.yearTo : yearTo as int?,
  );

  /// Faqat matn, aniqlik va turlar qoladi, faset filtrlar tozalanadi.
  ProFilter clearFacets() => ProFilter(text: text, exact: exact, types: types);
}

/// Indekslangan yozuv.
@immutable
class ProRecord {
  const ProRecord({
    required this.id,
    required this.type,
    required this.names,
    required this.terms,
    this.synonyms = const [],
    this.disciplines = const {},
    this.substanceClass,
    this.specimens = const {},
    this.families = const {},
    this.methodIds = const {},
    this.reagentIds = const {},
    this.bestEvidence,
    this.status = ScientificStatus.needsReview,
    this.jurisdictions = const {},
    this.years = const {},
  });

  final String id;
  final ProEntityType type;

  /// til → nom.
  final Map<String, String> names;

  /// Normallashtirilgan qidiruv atamalari (nomlar + sinonimlar +
  /// metabolit nomlari).
  final List<String> terms;
  final List<String> synonyms;
  final Set<ForensicDiscipline> disciplines;
  final String? substanceClass;
  final Set<String> specimens;
  final Set<MethodFamily> families;
  final Set<String> methodIds;
  final Set<String> reagentIds;

  /// `A` (eng kuchli) … `D`.
  final String? bestEvidence;
  final ScientificStatus status;
  final Set<String> jurisdictions;
  final Set<int> years;

  String name(String lang) =>
      names[lang] ??
      names['en'] ??
      (names.values.isEmpty ? id : names.values.first);
}

/// Teskari qidiruv qatori: moddaga olib boruvchi aniq asos.
@immutable
class ReverseHit {
  const ReverseHit({
    required this.substanceId,
    required this.basisIds,
    this.viaIds = const [],
    this.roles = const {},
  });

  final String substanceId;

  /// Bog‘lanish asoslari (claim ID).
  final List<String> basisIds;

  /// Oraliq yozuvlar (masalan reagent → skrining → modda).
  final List<String> viaIds;

  /// `analysed`, `confirmation`, `screened`, `measured`.
  final Set<String> roles;
}

@immutable
class ProSearchResult {
  const ProSearchResult(this.groups);

  final Map<ProEntityType, List<ProRecord>> groups;

  int get total => groups.values.fold(0, (a, g) => a + g.length);
  bool get isEmpty => total == 0;
}

int _evidenceRank(String? level) {
  const order = ['A', 'B', 'C', 'D'];
  final i = order.indexOf((level ?? '').toUpperCase());
  return i < 0 ? 99 : i;
}

/// Pro indeks. Qurilmada, offline.
class ProSearchIndex {
  ProSearchIndex._(
    this.records,
    this._evidence,
    this._substanceIds,
    this._reagentToTargets,
    this._screeningMethods,
    this.specimenIds,
  );

  /// Paketdan quradi.
  factory ProSearchIndex.build({
    required LibraryRepository library,
    required KnowledgeRepository knowledge,
    required EvidenceData evidence,
    required ProvenanceIndex provenance,
  }) {
    final substances = library.entries(LibrarySection.substances);
    final substanceIds = {for (final s in substances) s.id};

    String? best(Iterable<ClaimView> claims) {
      String? b;
      for (final c in claims) {
        if (_evidenceRank(c.evidenceLevel) < _evidenceRank(b)) {
          b = c.evidenceLevel.toUpperCase();
        }
      }
      return b;
    }

    Iterable<GraphLink> from(String id, LinkRelation r) =>
        evidence.linksFrom(id).where((l) => l.relation == r);

    final methods = knowledge.byKind(KnowledgeKind.method);
    final screenings = knowledge.byKind(KnowledgeKind.screeningTest);

    final reagentToTargets = reagentTargets(
      knowledge: knowledge,
      evidence: evidence,
    );
    // skrining → tasdiqlovchi metodlar.
    final screeningMethods = <String, Set<String>>{
      for (final s in screenings)
        s.id: {
          ...?s.screening?.confirmatoryMethodIds,
          for (final l in from(s.id, LinkRelation.confirmedBy)) l.toId,
        },
    };
    final targetToReagents = <String, Set<String>>{};
    reagentToTargets.forEach((rid, ts) {
      for (final t in ts) {
        targetToReagents.putIfAbsent(t, () => {}).add(rid);
      }
    });

    final methodFamilies = <String, Set<MethodFamily>>{
      for (final m in methods)
        m.id: {
          ...familiesOfTechniques(m.method?.techniques ?? const []),
          if (m.id.toLowerCase().contains('microcryst') ||
              m.name.values.values.any(
                (n) => n.toLowerCase().contains('microcryst'),
              ))
            MethodFamily.microcrystal,
        },
    };
    final screeningFamilies = <String, Set<MethodFamily>>{
      for (final s in screenings)
        s.id: familiesOfScreening(s.id, s.screening?.principle ?? ''),
    };
    Set<MethodFamily> familiesOf(String id) =>
        methodFamilies[id] ?? screeningFamilies[id] ?? const {};

    final records = <ProRecord>[];
    final specimensOfMethod = <String, Set<String>>{};
    for (final s in substances) {
      final measured = {
        for (final l in from(s.id, LinkRelation.measuredIn)) l.toId,
      };
      final analysed = {
        for (final l in from(s.id, LinkRelation.analysedBy)) l.toId,
      };
      final screened = {
        for (final l in from(s.id, LinkRelation.screenedBy)) l.toId,
      };
      final confirm = {for (final sid in screened) ...?screeningMethods[sid]};
      final allMethods = {...analysed, ...confirm};
      for (final m in allMethods) {
        specimensOfMethod.putIfAbsent(m, () => {}).addAll(measured);
      }
      final claims = s.details?.claims ?? const <ClaimView>[];
      records.add(
        ProRecord(
          id: s.id,
          type: ProEntityType.substance,
          names: s.name.values,
          synonyms: s.synonyms,
          terms: _terms(s.name.values.values, s.synonyms, [
            for (final c in claims)
              if (c.field == 'metabolites') ...c.items,
          ]),
          disciplines: {ForensicDiscipline.forensicToxicology},
          substanceClass: s.group,
          specimens: measured,
          families: {
            for (final id in [...allMethods, ...screened]) ...familiesOf(id),
          },
          methodIds: allMethods,
          reagentIds: {
            for (final id in [...allMethods, ...screened])
              ...?targetToReagents[id],
          },
          bestEvidence: best(claims),
          status: s.status,
          jurisdictions: {
            for (final r in s.details?.legalRules ?? const <LegalRuleView>[])
              r.jurisdictionId,
          },
          years: {
            for (final c in claims)
              for (final src in c.sources) ?src.year,
          },
        ),
      );
    }

    for (final kind in [
      KnowledgeKind.method,
      KnowledgeKind.screeningTest,
      KnowledgeKind.reagent,
    ]) {
      for (final e in knowledge.byKind(kind)) {
        final type = switch (kind) {
          KnowledgeKind.method => ProEntityType.method,
          KnowledgeKind.screeningTest => ProEntityType.screening,
          _ => ProEntityType.reagent,
        };
        final syn = e.recipe?.synonyms ?? const <String>[];
        records.add(
          ProRecord(
            id: e.id,
            type: type,
            names: e.name.values,
            synonyms: syn,
            terms: _terms(e.name.values.values, syn, const []),
            disciplines: {e.effectiveDiscipline},
            specimens: specimensOfMethod[e.id] ?? const {},
            families: {
              ...familiesOf(e.id),
              if (kind == KnowledgeKind.reagent &&
                  e.claims.any((c) => c.field == 'test_class_limitation'))
                MethodFamily.colourTest,
            },
            methodIds: switch (kind) {
              KnowledgeKind.screeningTest => screeningMethods[e.id] ?? {},
              KnowledgeKind.reagent => reagentToTargets[e.id] ?? {},
              _ => const {},
            },
            reagentIds: targetToReagents[e.id] ?? const {},
            bestEvidence: best(e.claims),
            status: e.status,
            years: {for (final src in e.allSources) ?src.year},
          ),
        );
      }
    }

    return ProSearchIndex._(
      records,
      evidence,
      substanceIds,
      reagentToTargets,
      screeningMethods,
      [for (final s in provenance.specimens) s.id],
    );
  }

  /// reagent → bog‘langan metod / skrining ID’lari: `used_in` (ikki
  /// yo‘nalishda) va retseptning `associated_method_ids`. Boshqa hech narsa.
  static Map<String, Set<String>> reagentTargets({
    required KnowledgeRepository knowledge,
    required EvidenceData evidence,
  }) {
    final out = <String, Set<String>>{};
    for (final r in knowledge.byKind(KnowledgeKind.reagent)) {
      final set = out.putIfAbsent(r.id, () => {});
      for (final l in evidence.linksFrom(r.id)) {
        if (l.relation == LinkRelation.usedIn) set.add(l.toId);
      }
      for (final l in evidence.linksTo(r.id)) {
        if (l.relation == LinkRelation.usedIn) set.add(l.fromId);
      }
      set.addAll(r.recipe?.associatedMethodIds ?? const []);
    }
    return out;
  }

  static List<String> _terms(
    Iterable<String> names,
    Iterable<String> synonyms,
    Iterable<String> extra,
  ) {
    final out = <String>{};
    for (final t in [...names, ...synonyms, ...extra]) {
      final n = proNormalize(t);
      if (n.isNotEmpty) out.add(n);
    }
    return out.toList();
  }

  final List<ProRecord> records;
  final EvidenceData _evidence;
  final Set<String> _substanceIds;
  final Map<String, Set<String>> _reagentToTargets;
  final Map<String, Set<String>> _screeningMethods;

  /// Paketdagi namunalar (tartib bilan).
  final List<String> specimenIds;

  late final Map<String, ProRecord> _byId = {for (final r in records) r.id: r};

  ProRecord? byId(String id) => _byId[id];

  // ---------------------------------------------------------------- qidiruv

  /// Matn mosligi: 0 — mos emas; 3 — to‘liq; 2 — so‘z boshidan; 1 — ichida.
  /// `"ibora"` — ketma-ket so‘zlar; [exact] — butun nom/sinonim.
  static int textScore(ProRecord r, String query, {required bool exact}) {
    final raw = query.trim();
    final q = proNormalize(raw);
    if (q.isEmpty) return 1;
    if (exact) return r.terms.contains(q) ? 3 : 0;
    const open = '"“«';
    const close = '"”»';
    final quoted =
        raw.length >= 2 &&
        open.contains(raw[0]) &&
        close.contains(raw[raw.length - 1]);
    if (quoted) {
      var s = 0;
      for (final t in r.terms) {
        if (t == q) {
          s = 3;
        } else if (t.startsWith('$q ')) {
          s = s < 2 ? 2 : s;
        } else if (' $t '.contains(' $q ')) {
          s = s < 1 ? 1 : s;
        }
      }
      return s;
    }
    var worst = 3;
    for (final tok in q.split(' ')) {
      var s = 0;
      for (final t in r.terms) {
        if (t == tok) {
          s = 3;
          break;
        }
        if (t.startsWith(tok)) {
          s = s < 2 ? 2 : s;
        } else if (t.contains(tok)) {
          s = s < 1 ? 1 : s;
        }
      }
      if (s == 0) return 0;
      if (s < worst) worst = s;
    }
    return worst;
  }

  bool _facetOk(ProRecord r, ProFilter f, ProFacet facet) {
    switch (facet) {
      case ProFacet.discipline:
        return f.discipline == null || r.disciplines.contains(f.discipline);
      case ProFacet.substanceClass:
        return f.substanceClass == null || r.substanceClass == f.substanceClass;
      case ProFacet.specimen:
        return f.specimenId == null || r.specimens.contains(f.specimenId);
      case ProFacet.family:
        return f.family == null || r.families.contains(f.family);
      case ProFacet.reagent:
        return f.reagentId == null ||
            r.reagentIds.contains(f.reagentId) ||
            r.id == f.reagentId;
      case ProFacet.evidence:
        return f.evidenceAtLeast == null ||
            _evidenceRank(r.bestEvidence) <= _evidenceRank(f.evidenceAtLeast);
      case ProFacet.status:
        return f.status == null || r.status == f.status;
      case ProFacet.jurisdiction:
        return f.jurisdictionId == null ||
            r.jurisdictions.contains(f.jurisdictionId);
      case ProFacet.year:
        if (f.yearFrom == null && f.yearTo == null) return true;
        return r.years.any(
          (y) =>
              (f.yearFrom == null || y >= f.yearFrom!) &&
              (f.yearTo == null || y <= f.yearTo!),
        );
    }
  }

  bool _matches(ProRecord r, ProFilter f, {ProFacet? skip}) {
    if (f.types.isNotEmpty && !f.types.contains(r.type)) return false;
    for (final facet in ProFacet.values) {
      if (facet == skip) continue;
      if (!_facetOk(r, f, facet)) return false;
    }
    return true;
  }

  /// Filtr bo‘yicha natija; turlar bo‘yicha guruhlangan, mosligi va nomi
  /// bo‘yicha tartiblangan.
  ProSearchResult search(ProFilter f, {String lang = 'en'}) {
    final scored = <(ProRecord, int)>[];
    for (final r in records) {
      if (!_matches(r, f)) continue;
      final s = textScore(r, f.text, exact: f.exact);
      if (s == 0) continue;
      scored.add((r, s));
    }
    scored.sort((a, b) {
      final c = b.$2.compareTo(a.$2);
      return c != 0
          ? c
          : a.$1
                .name(lang)
                .toLowerCase()
                .compareTo(b.$1.name(lang).toLowerCase());
    });
    final groups = {for (final t in ProEntityType.values) t: <ProRecord>[]};
    for (final (r, _) in scored) {
      groups[r.type]!.add(r);
    }
    return ProSearchResult(groups);
  }

  /// Faset qiymatlari va ularning joriy filtrdagi soni (shu fasetning o‘z
  /// filtri hisobga olinmaydi — tanlovni almashtirish mumkin bo‘lsin).
  /// Soni 0 bo‘lgan qiymatlar kiritilmaydi.
  Map<String, int> facetCounts(ProFacet facet, ProFilter f) {
    final out = <String, int>{};
    for (final r in records) {
      if (!_matches(r, f, skip: facet)) continue;
      if (textScore(r, f.text, exact: f.exact) == 0) continue;
      for (final v in _facetValues(r, facet)) {
        out[v] = (out[v] ?? 0) + 1;
      }
    }
    return out;
  }

  Iterable<String> _facetValues(ProRecord r, ProFacet facet) => switch (facet) {
    ProFacet.discipline => r.disciplines.map((d) => d.code),
    ProFacet.substanceClass => [?r.substanceClass],
    ProFacet.specimen => r.specimens,
    ProFacet.family => r.families.map((x) => x.name),
    ProFacet.reagent => r.reagentIds,
    ProFacet.evidence => [
      for (final (i, l) in const ['A', 'B', 'C', 'D'].indexed)
        if (_evidenceRank(r.bestEvidence) <= i) l,
    ],
    ProFacet.status => [r.status.code],
    ProFacet.jurisdiction => r.jurisdictions,
    ProFacet.year => r.years.map((y) => '$y'),
  };

  /// Barcha yillar (o‘sish tartibida) — yil oralig‘i uchun.
  List<int> get allYears =>
      ({for (final r in records) ...r.years}.toList()..sort());

  // -------------------------------------------------------- teskari qidiruv

  /// Namuna → paketda shu namunada qiymati keltirilgan moddalar.
  List<ReverseHit> analytesForSpecimen(String specimenId) {
    final m = <String, List<String>>{};
    for (final l in _evidence.linksTo(specimenId)) {
      if (l.relation != LinkRelation.measuredIn) continue;
      if (!_substanceIds.contains(l.fromId)) continue;
      final b = m.putIfAbsent(l.fromId, () => []);
      if (!b.contains(l.basis)) b.add(l.basis);
    }
    return [
      for (final id in m.keys.toList()..sort())
        ReverseHit(
          substanceId: id,
          basisIds: m[id]!,
          roles: const {'measured'},
        ),
    ];
  }

  /// Namuna ID → undagi moddalar soni (faqat > 0).
  Map<String, int> specimenCounts() => {
    for (final id in specimenIds)
      if (analytesForSpecimen(id).isNotEmpty)
        id: analytesForSpecimen(id).length,
  };

  /// Metod → paketda u bilan hujjatlashtirilgan moddalar (`analysed_by`) va
  /// skriningdan keyingi tasdiqlash (`screened_by` → `confirmed_by`).
  List<ReverseHit> substancesForMethod(String methodId) {
    final basis = <String, List<String>>{};
    final roles = <String, Set<String>>{};
    final via = <String, List<String>>{};
    void add(String sid, String role, String basisId, [String? viaId]) {
      final b = basis.putIfAbsent(sid, () => []);
      if (!b.contains(basisId)) b.add(basisId);
      roles.putIfAbsent(sid, () => {}).add(role);
      if (viaId != null) {
        final v = via.putIfAbsent(sid, () => []);
        if (!v.contains(viaId)) v.add(viaId);
      }
    }

    for (final l in _evidence.linksTo(methodId)) {
      if (l.relation == LinkRelation.analysedBy &&
          _substanceIds.contains(l.fromId)) {
        add(l.fromId, 'analysed', l.basis);
      }
    }
    for (final e in _screeningMethods.entries) {
      if (!e.value.contains(methodId)) continue;
      for (final l in _evidence.linksTo(e.key)) {
        if (l.relation == LinkRelation.screenedBy &&
            _substanceIds.contains(l.fromId)) {
          add(l.fromId, 'confirmation', l.basis, e.key);
        }
      }
    }
    return [
      for (final id in basis.keys.toList()..sort())
        ReverseHit(
          substanceId: id,
          basisIds: basis[id]!,
          viaIds: via[id] ?? const [],
          roles: roles[id]!,
        ),
    ];
  }

  /// Reagent → reagent bog‘langan metod/skrining orqali hujjatlashtirilgan
  /// moddalar. Bog‘lanish yo‘q bo‘lsa — bo‘sh (reaksiya taxmin qilinmaydi).
  List<ReverseHit> substancesForReagent(String reagentId) {
    final targets = _reagentToTargets[reagentId] ?? const <String>{};
    final basis = <String, List<String>>{};
    final via = <String, List<String>>{};
    final roles = <String, Set<String>>{};
    void add(String sid, String basisId, String viaId, String role) {
      final b = basis.putIfAbsent(sid, () => []);
      if (!b.contains(basisId)) b.add(basisId);
      final v = via.putIfAbsent(sid, () => []);
      if (!v.contains(viaId)) v.add(viaId);
      roles.putIfAbsent(sid, () => {}).add(role);
    }

    for (final t in targets) {
      for (final l in _evidence.linksTo(t)) {
        if (!_substanceIds.contains(l.fromId)) continue;
        if (l.relation == LinkRelation.analysedBy) {
          add(l.fromId, l.basis, t, 'analysed');
        } else if (l.relation == LinkRelation.screenedBy) {
          add(l.fromId, l.basis, t, 'screened');
        }
      }
    }
    return [
      for (final id in basis.keys.toList()..sort())
        ReverseHit(
          substanceId: id,
          basisIds: basis[id]!,
          viaIds: via[id]!,
          roles: roles[id]!,
        ),
    ];
  }

  /// Hech bo‘lmasa bitta metod/skriningga bog‘langan reagentlar.
  List<String> get linkedReagentIds => [
    for (final e in _reagentToTargets.entries)
      if (e.value.isNotEmpty) e.key,
  ]..sort();

  int get reagentCount =>
      records.where((r) => r.type == ProEntityType.reagent).length;

  /// Metod ID → undagi moddalar soni (faqat > 0).
  Map<String, int> methodCounts() {
    final out = <String, int>{};
    for (final r in records) {
      if (r.type != ProEntityType.method) continue;
      final n = substancesForMethod(r.id).length;
      if (n > 0) out[r.id] = n;
    }
    return out;
  }
}
