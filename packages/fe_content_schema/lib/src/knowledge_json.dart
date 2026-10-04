import 'enums.dart';
import 'knowledge.dart';

/// PHASE 4 bilim yozuvlarining JSON ko‘rinishi — bitta joyda.
///
/// Bir xil format `fe-bundle/2` (pipeline kirishi) va `content.db`
/// `knowledge_entities.payload_json` (ilova o‘qiydi) uchun ishlatiladi.
/// Noma’lum enum yoki yetishmayotgan majburiy maydon — [FormatException]
/// (jim o‘tkazib yuborish yo‘q).
abstract final class KnowledgeJson {
  // -- SourcedValue / SourcedNote ------------------------------------------

  static Map<String, Object?> value(SourcedValue v) => {
    'value': v.value,
    'unit': v.unit,
    'source_id': v.sourceId,
    if (v.locator != null) 'locator': v.locator,
    if (v.context != null) 'context': v.context,
  };

  static SourcedValue? valueFrom(Object? j) {
    if (j == null) return null;
    final m = _map(j);
    return SourcedValue(
      value: _req<num>(m, 'value'),
      unit: _req<String>(m, 'unit'),
      sourceId: _req<String>(m, 'source_id'),
      locator: m['locator'] as String?,
      context: m['context'] as String?,
    );
  }

  static Map<String, Object?> note(SourcedNote n) => {
    'text': n.text,
    'source_id': n.sourceId,
    if (n.locator != null) 'locator': n.locator,
  };

  static SourcedNote? noteFrom(Object? j) {
    if (j == null) return null;
    final m = _map(j);
    return SourcedNote(
      text: _req<String>(m, 'text'),
      sourceId: _req<String>(m, 'source_id'),
      locator: m['locator'] as String?,
    );
  }

  static List<SourcedNote> _notes(Object? j) => [
    for (final e in (j as List? ?? const [])) noteFrom(e)!,
  ];

  // -- SolutionRecipe -------------------------------------------------------

  static Map<String, Object?> recipe(SolutionRecipe r) => {
    'recipe_id': r.id,
    'reagent_id': r.reagentId,
    'names': r.names,
    'domain': r.domain.code,
    'status': r.status.code,
    if (r.purpose != null) 'purpose': r.purpose,
    'associated_method_ids': r.associatedMethodIds,
    'ingredients': [
      for (final i in r.ingredients)
        {
          'name': i.name,
          'amount': i.amount,
          'unit': i.unit,
          if (i.role != null) 'role': i.role,
        },
    ],
    if (r.finalVolume != null) 'final_volume': value(r.finalVolume!),
    'steps': [
      for (final s in r.steps)
        {'text': s.text, if (s.order != null) 'order': s.order},
    ],
    'order_explicit_in_source': r.orderExplicitInSource,
    if (r.storage != null) 'storage': note(r.storage!),
    if (r.temperature != null) 'temperature': value(r.temperature!),
    if (r.stability != null) 'stability': note(r.stability!),
    'hazards': [for (final h in r.hazards) note(h)],
    if (r.disposalReference != null)
      'disposal_reference': note(r.disposalReference!),
    if (r.qcRequirement != null) 'qc_requirement': note(r.qcRequirement!),
    'source_ids': r.sourceIds,
    'version': r.version,
    'is_test_data': r.isTestData,
  };

  static SolutionRecipe recipeFrom(Object? j) {
    final m = _map(j);
    return SolutionRecipe(
      id: _req<String>(m, 'recipe_id'),
      reagentId: _req<String>(m, 'reagent_id'),
      names: _strMap(m['names']),
      domain: _domain(_req<String>(m, 'domain')),
      status: ScientificStatus.fromCode(_req<String>(m, 'status')),
      purpose: m['purpose'] as String?,
      associatedMethodIds: _strList(m['associated_method_ids']),
      ingredients: [
        for (final e in (m['ingredients'] as List? ?? const []))
          () {
            final i = _map(e);
            return Ingredient(
              name: _req<String>(i, 'name'),
              amount: _req<num>(i, 'amount'),
              unit: _req<String>(i, 'unit'),
              role: i['role'] as String?,
            );
          }(),
      ],
      finalVolume: valueFrom(m['final_volume']),
      steps: [
        for (final e in (m['steps'] as List? ?? const []))
          () {
            final s = _map(e);
            return PreparationStep(
              text: _req<String>(s, 'text'),
              order: s['order'] as int?,
            );
          }(),
      ],
      orderExplicitInSource: m['order_explicit_in_source'] == true,
      storage: noteFrom(m['storage']),
      temperature: valueFrom(m['temperature']),
      stability: noteFrom(m['stability']),
      hazards: _notes(m['hazards']),
      disposalReference: noteFrom(m['disposal_reference']),
      qcRequirement: noteFrom(m['qc_requirement']),
      sourceIds: _strList(m['source_ids']),
      version: (m['version'] as int?) ?? 1,
      isTestData: m['is_test_data'] == true,
    );
  }

  // -- ScreeningTest --------------------------------------------------------

  static Map<String, Object?> screening(ScreeningTest t) => {
    'screening_id': t.id,
    'names': t.names,
    'analyte': t.analyte,
    'specimen': t.specimen,
    'principle': t.principle,
    if (t.manufacturer != null) 'manufacturer': t.manufacturer,
    if (t.model != null) 'model': t.model,
    if (t.cutoff != null) 'cutoff': value(t.cutoff!),
    if (t.sensitivity != null) 'sensitivity': value(t.sensitivity!),
    if (t.specificity != null) 'specificity': value(t.specificity!),
    'cross_reactivity': [for (final n in t.crossReactivity) note(n)],
    'false_positive': [for (final n in t.falsePositive) note(n)],
    'false_negative': [for (final n in t.falseNegative) note(n)],
    'limitations': [for (final n in t.limitations) note(n)],
    'confirmatory_method_ids': t.confirmatoryMethodIds,
    if (t.storage != null) 'storage': note(t.storage!),
    'supports_definitive_identification': t.supportsDefinitiveIdentification,
    if (t.definitiveIdentificationSourceId != null)
      'definitive_identification_source_id': t.definitiveIdentificationSourceId,
    'status': t.status.code,
    'source_ids': t.sourceIds,
    'version': t.version,
    'is_test_data': t.isTestData,
  };

  static ScreeningTest screeningFrom(Object? j) {
    final m = _map(j);
    return ScreeningTest(
      id: _req<String>(m, 'screening_id'),
      names: _strMap(m['names']),
      analyte: _req<String>(m, 'analyte'),
      specimen: _req<String>(m, 'specimen'),
      principle: _req<String>(m, 'principle'),
      manufacturer: m['manufacturer'] as String?,
      model: m['model'] as String?,
      cutoff: valueFrom(m['cutoff']),
      sensitivity: valueFrom(m['sensitivity']),
      specificity: valueFrom(m['specificity']),
      crossReactivity: _notes(m['cross_reactivity']),
      falsePositive: _notes(m['false_positive']),
      falseNegative: _notes(m['false_negative']),
      limitations: _notes(m['limitations']),
      confirmatoryMethodIds: _strList(m['confirmatory_method_ids']),
      storage: noteFrom(m['storage']),
      supportsDefinitiveIdentification:
          m['supports_definitive_identification'] == true,
      definitiveIdentificationSourceId:
          m['definitive_identification_source_id'] as String?,
      status: ScientificStatus.fromCode(_req<String>(m, 'status')),
      sourceIds: _strList(m['source_ids']),
      version: (m['version'] as int?) ?? 1,
      isTestData: m['is_test_data'] == true,
    );
  }

  // -- MethodRecord ---------------------------------------------------------

  static Map<String, Object?> method(MethodRecord r) => {
    'method_id': r.id,
    'kind': r.kind.name,
    'titles': r.titles,
    'techniques': [for (final t in r.techniques) t.name],
    if (r.organization != null) 'organization': r.organization,
    if (r.jurisdictionId != null) 'jurisdiction_id': r.jurisdictionId,
    if (r.documentVersion != null) 'document_version': r.documentVersion,
    if (r.effectiveFrom != null) 'effective_from': _d(r.effectiveFrom),
    if (r.supersededAt != null) 'superseded_at': _d(r.supersededAt),
    'sections': {for (final e in r.sections.entries) e.key.name: e.value},
    'text_origin': r.textOrigin.name,
    'status': r.status.code,
    'source_ids': r.sourceIds,
    'version': r.version,
    'is_test_data': r.isTestData,
  };

  static MethodRecord methodFrom(Object? j) {
    final m = _map(j);
    return MethodRecord(
      id: _req<String>(m, 'method_id'),
      kind: _enum(MethodKind.values, _req<String>(m, 'kind')),
      titles: _strMap(m['titles']),
      techniques: [
        for (final t in _strList(m['techniques']))
          _enum(AnalyticalTechnique.values, t),
      ],
      organization: m['organization'] as String?,
      jurisdictionId: m['jurisdiction_id'] as String?,
      documentVersion: m['document_version'] as String?,
      effectiveFrom: _date(m['effective_from']),
      supersededAt: _date(m['superseded_at']),
      sections: {
        for (final e in _strMap(m['sections']).entries)
          _enum(MethodSection.values, e.key): e.value,
      },
      textOrigin: _enum(
        TextOrigin.values,
        (m['text_origin'] as String?) ?? TextOrigin.originalSummary.name,
      ),
      status: ScientificStatus.fromCode(_req<String>(m, 'status')),
      sourceIds: _strList(m['source_ids']),
      version: (m['version'] as int?) ?? 1,
      isTestData: m['is_test_data'] == true,
    );
  }

  // -- EmergingIssue --------------------------------------------------------

  static Map<String, Object?> emerging(EmergingIssue e) => {
    'issue_id': e.id,
    'category': e.category.name,
    'titles': e.titles,
    'source_ids': e.sourceIds,
    if (e.date != null) 'date': _d(e.date),
    'evidence_type': e.evidenceType.name,
    if (e.scopeJurisdictionId != null)
      'scope_jurisdiction_id': e.scopeJurisdictionId,
    'status': e.status.code,
    'is_test_data': e.isTestData,
  };

  static EmergingIssue emergingFrom(Object? j) {
    final m = _map(j);
    return EmergingIssue(
      id: _req<String>(m, 'issue_id'),
      category: _enum(EmergingCategory.values, _req<String>(m, 'category')),
      titles: _strMap(m['titles']),
      sourceIds: _strList(m['source_ids']),
      date: _date(m['date']),
      evidenceType: _enum(
        EvidenceType.values,
        _req<String>(m, 'evidence_type'),
      ),
      scopeJurisdictionId: m['scope_jurisdiction_id'] as String?,
      status: ScientificStatus.fromCode(_req<String>(m, 'status')),
      isTestData: m['is_test_data'] == true,
    );
  }

  // -- KnowledgeTopic -------------------------------------------------------

  static Map<String, Object?> topic(KnowledgeTopic t) => {
    'topic_id': t.id,
    'area': t.area.name,
    'names': t.names,
    if (t.forensicMedicineTopic != null)
      'forensic_medicine_topic': t.forensicMedicineTopic!.name,
    'is_test_data': t.isTestData,
  };

  static KnowledgeTopic topicFrom(Object? j) {
    final m = _map(j);
    final fm = m['forensic_medicine_topic'] as String?;
    return KnowledgeTopic(
      id: _req<String>(m, 'topic_id'),
      area: _enum(KnowledgeArea.values, _req<String>(m, 'area')),
      names: _strMap(m['names']),
      forensicMedicineTopic: fm == null
          ? null
          : _enum(ForensicMedicineTopic.values, fm),
      isTestData: m['is_test_data'] == true,
    );
  }

  // -- yordamchilar ---------------------------------------------------------

  static Map<String, Object?> _map(Object? j) {
    if (j is! Map) throw const FormatException('expected an object');
    return j.cast<String, Object?>();
  }

  static T _req<T>(Map<String, Object?> m, String k) {
    final v = m[k];
    if (v is! T || (v is String && v.isEmpty)) {
      throw FormatException('missing or invalid "$k"');
    }
    return v;
  }

  static Map<String, String> _strMap(Object? j) =>
      (j as Map? ?? const {}).cast<String, String>();

  static List<String> _strList(Object? j) => [...?(j as List?)?.cast<String>()];

  static T _enum<T extends Enum>(List<T> values, String name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    throw FormatException('unknown enum value "$name"');
  }

  static ContentDomain _domain(String code) {
    for (final d in ContentDomain.values) {
      if (d.code == code) return d;
    }
    throw FormatException('unknown domain "$code"');
  }

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.parse(v as String);

  static String? _d(DateTime? d) => d?.toIso8601String().substring(0, 10);
}
