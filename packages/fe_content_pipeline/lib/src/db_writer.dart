import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart' as db;
import 'package:fe_search_core/fe_search_core.dart';

import 'bundle_codec.dart';

/// Tahlil qilingan to‘plamni `content.db` ga yozadi.
///
/// Drift’ning generatsiya qilingan klasslari `fe_content_schema` nomlari
/// bilan to‘qnashmasligi uchun parametrli SQL ishlatiladi; sxema
/// CHECK/FK cheklovlari baribir bazaning o‘zida ishlaydi (ikkinchi himoya
/// qatlami — validator’dan keyin).
class ContentDbWriter {
  ContentDbWriter(this._db);

  final db.ContentDatabase _db;

  /// Metabolit nomlaridan qidiruv termini yasalmaydigan umumiy so‘zlar.
  static const _genericItems = {
    'sulfate',
    'glucuronide',
    'acetate',
    'm2',
    'm5',
    'eme',
    'be',
  };

  static const _searchableFields = {
    'metabolites',
    'biomarker',
    'transformation_product',
  };

  Future<void> write(PipelineBundle b, {required DateTime builtAt}) async {
    await _db.customStatement('PRAGMA foreign_keys = ON');
    await _db.transaction(() async {
      final c = b.content;
      Future<void> run(String sql, List<Object?> args) =>
          _db.customStatement(sql, args);

      for (final m in {
        'pack_version': b.packVersion,
        'channel': b.channel.name,
        'schema_version': '${db.ContentDatabase.contentSchemaVersion}',
        'built_at': builtAt.toUtc().toIso8601String(),
        'bundle_format': BundleCodec.format,
      }.entries) {
        await run(
          'INSERT INTO content_meta (meta_key, meta_value) VALUES (?, ?)',
          [m.key, m.value],
        );
      }

      for (final s in c.sources) {
        await run(
          'INSERT INTO sources (source_id, source_type, title, authors_json, '
          'organization, journal, publication_year, edition, doi, pmid, '
          'official_url, accessed_date, tier, evidence_level, license_mode, '
          'identifier_verified, review_status, is_test_data) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            s.sourceId,
            BundleCodec.sourceTypeCode(s.sourceType),
            s.title,
            jsonEncode(s.authors),
            s.organization,
            s.journal,
            s.publicationYear,
            s.edition,
            s.doi,
            s.pmid,
            s.officialUrl,
            _d(s.accessedDate),
            s.tier.index + 1,
            s.evidenceLevel.code,
            s.licenseMode.name,
            s.identifierVerified ? 1 : 0,
            ScientificStatus.needsReview.code,
            s.isTestData ? 1 : 0,
          ],
        );
      }

      for (final j in c.jurisdictions) {
        await run(
          'INSERT INTO jurisdictions (jurisdiction_id, level, parent_id, '
          'iso3166, names_json) VALUES (?,?,?,?,?)',
          [j.id, j.level.name, j.parentId, j.iso3166, jsonEncode(j.names)],
        );
      }
      for (final i in c.instruments) {
        await run(
          'INSERT INTO jurisdictional_instruments (instrument_id, '
          'jurisdiction_id, instrument_type, titles_json, official_source_id, '
          'official_reference, effective_from, effective_to, version, '
          'last_verified_at, review_status, is_test_data) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            i.id,
            i.jurisdictionId,
            BundleCodec.instrumentTypeCode(i.type),
            jsonEncode({
              ...i.titles,
              if (b.instrumentDatePrecision[i.id] != null)
                '_date_precision': b.instrumentDatePrecision[i.id],
            }),
            i.officialSourceId,
            i.officialReference,
            _d(i.effectiveFrom),
            _d(i.effectiveTo),
            i.version,
            _d(i.lastVerifiedAt),
            i.status.code,
            i.isTestData ? 1 : 0,
          ],
        );
      }
      for (final r in c.jurisdictionalRules) {
        await run(
          'INSERT INTO jurisdictional_rules (rule_id, instrument_id, '
          'rule_type, subject_type, subject_id, value_json, effective_from, '
          'effective_to, review_status, is_test_data) '
          'VALUES (?,?,?,?,?,?,?,?,?,?)',
          [
            r.id,
            r.instrumentId,
            BundleCodec.ruleTypeCode(r.ruleType),
            r.subjectType,
            r.subjectId,
            jsonEncode(r.value),
            _d(r.effectiveFrom),
            _d(r.effectiveTo),
            r.status.code,
            r.isTestData ? 1 : 0,
          ],
        );
      }

      for (final s in b.substances) {
        await run(
          'INSERT INTO substances (substance_id, canonical_name, entity_kind, '
          'molecular_formula, tier_access, review_status, content_version, '
          'is_test_data) VALUES (?,?,?,?,?,?,?,0)',
          [
            s.substanceId,
            s.canonicalName,
            s.entityKind,
            s.molecularFormula,
            s.tierAccess,
            ScientificStatus.needsReview.code,
            b.packVersion,
          ],
        );
        for (final n in s.names.entries) {
          await run(
            'INSERT INTO substance_i18n (substance_id, lang, name, '
            'translation_status) VALUES (?,?,?,?)',
            [s.substanceId, n.key, n.value, s.translationStatus[n.key]],
          );
        }
      }

      for (final cl in c.claims) {
        await run(
          'INSERT INTO claims (claim_id, entity_type, entity_id, field, '
          'value_json, domain, review_status, evidence_level, preferred, '
          'preference_reason, version, updated_at, is_test_data, '
          'knowledge_layer, jurisdiction_id, instrument_id) '
          'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [
            cl.claimId,
            cl.entityType.name,
            cl.entityId,
            cl.field,
            jsonEncode(cl.value),
            cl.domain.code,
            cl.declaredStatus.code,
            cl.evidenceLevel.code,
            cl.preferred ? 1 : 0,
            cl.preferenceReason,
            cl.version,
            _d(builtAt),
            cl.isTestData ? 1 : 0,
            cl.layer.code,
            cl.jurisdictionId,
            cl.instrumentId,
          ],
        );
      }
      for (final ci in c.citations) {
        await run(
          'INSERT INTO citations (claim_id, source_id, locator) VALUES (?,?,?)',
          [ci.claimId, ci.sourceId, ci.locator],
        );
      }
    });

    await _db.insertSearchTerms(_searchTerms(b));
  }

  List<SearchTerm> _searchTerms(PipelineBundle b) {
    final terms = <SearchTerm>[];
    for (final s in b.substances) {
      final cat = s.entityKind == 'metabolite'
          ? SearchCategory.metabolite
          : SearchCategory.substance;
      for (final n in s.names.entries) {
        terms.add(
          SearchTerm(
            entityId: s.substanceId,
            category: cat,
            term: n.value,
            kind: n.key == 'en' ? TermKind.canonical : TermKind.localized,
            lang: n.key,
          ),
        );
      }
      for (final syn in s.synonyms) {
        terms.add(
          SearchTerm(
            entityId: s.substanceId,
            category: cat,
            term: syn,
            kind: TermKind.synonym,
          ),
        );
      }
      if (s.molecularFormula != null) {
        terms.add(
          SearchTerm(
            entityId: s.substanceId,
            category: cat,
            term: s.molecularFormula!,
            kind: TermKind.formula,
            weight: 0.5,
          ),
        );
      }
    }
    // Metabolit / biomarker nomi bo‘yicha ota moddani topish.
    for (final cl in b.content.claims) {
      if (!_searchableFields.contains(cl.field)) continue;
      for (final item in (cl.value['items'] as List? ?? const [])) {
        final t = item as String;
        if (_genericItems.contains(t.toLowerCase())) continue;
        terms.add(
          SearchTerm(
            entityId: cl.entityId,
            category: SearchCategory.substance,
            term: t,
            kind: TermKind.synonym,
            weight: 0.6,
          ),
        );
      }
    }
    return terms;
  }

  static String? _d(DateTime? d) => d?.toIso8601String().substring(0, 10);
}
