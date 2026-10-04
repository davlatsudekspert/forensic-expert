import 'dart:convert';

import 'bundle.dart';
import 'enums.dart';
import 'knowledge_json.dart';
import 'validator.dart';

/// Ko‘rib chiqilgan (REVIEWED/VERIFIED) ma’lumot yangi paketda **jimgina**
/// tekshirilmagan ma’lumot bilan almashtirilmasligi kafolati (FE027).
///
/// Oldingi paketdagi har bir ko‘rib chiqilgan yozuv uchun yangi paketda
/// quyidagilardan biri bo‘lishi shart:
/// * yozuv REVIEWED/VERIFIED holda qolgan va mazmuni o‘zgarmagan, yoki
///   versiyasi oshirilgan (yangi versiya — yangi review talab qiladi);
/// * yozuv **aniq** OUTDATED yoki REJECTED deb belgilangan (izohli qaror).
///
/// Yozuvning yo‘qolishi yoki NEEDS_REVIEW/DRAFT ga tushishi — xato.
abstract final class ReviewRegressionGuard {
  static ValidationReport compare(ContentBundle previous, ContentBundle next) {
    final prev = _snapshot(previous);
    final cur = _snapshot(next);
    final issues = <ValidationIssue>[];
    void err(String id, String msg) => issues.add(
      ValidationIssue(
        RuleCodes.silentReviewRegression,
        IssueSeverity.error,
        id,
        msg,
      ),
    );

    for (final e in prev.entries) {
      final p = e.value;
      if (!_isReviewed(p.status)) continue;
      final n = cur[e.key];
      if (n == null) {
        err(e.key, 'reviewed record removed without OUTDATED/REJECTED');
        continue;
      }
      if (n.status == ScientificStatus.outdated ||
          n.status == ScientificStatus.rejected) {
        continue;
      }
      if (!_isReviewed(n.status)) {
        err(
          e.key,
          'status downgraded ${p.status.code} → ${n.status.code} silently',
        );
        continue;
      }
      if (n.fingerprint != p.fingerprint && n.version == p.version) {
        err(e.key, 'reviewed content changed without a version bump');
      }
    }
    return ValidationReport(issues);
  }

  static bool _isReviewed(ScientificStatus s) =>
      s == ScientificStatus.reviewed || s == ScientificStatus.verified;

  static Map<String, _Snap> _snapshot(ContentBundle b) => {
    for (final c in b.claims)
      'claim:${c.claimId}': _Snap(
        c.declaredStatus,
        '${c.version}',
        jsonEncode([c.field, c.value, c.entityId]),
      ),
    for (final i in b.instruments)
      'instrument:${i.id}': _Snap(
        i.status,
        i.version,
        jsonEncode([i.titles, i.officialReference, '${i.effectiveFrom}']),
      ),
    for (final r in b.jurisdictionalRules)
      'rule:${r.id}': _Snap(
        r.status,
        '${r.version}',
        jsonEncode([r.value, r.subjectId, '${r.effectiveFrom}', r.topicKey]),
      ),
    for (final r in b.recipes)
      'recipe:${r.id}': _Snap(
        r.status,
        '${r.version}',
        jsonEncode(KnowledgeJson.recipe(r)..remove('status')),
      ),
    for (final t in b.screeningTests)
      'screening:${t.id}': _Snap(
        t.status,
        '${t.version}',
        jsonEncode(KnowledgeJson.screening(t)..remove('status')),
      ),
    for (final m in b.methods)
      'method:${m.id}': _Snap(
        m.status,
        '${m.version}',
        jsonEncode(KnowledgeJson.method(m)..remove('status')),
      ),
    for (final e in b.emergingIssues)
      'emerging:${e.id}': _Snap(
        e.status,
        '1',
        jsonEncode(KnowledgeJson.emerging(e)..remove('status')),
      ),
  };
}

class _Snap {
  const _Snap(this.status, this.version, this.fingerprint);

  final ScientificStatus status;
  final String version;
  final String fingerprint;
}
