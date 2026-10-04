import 'claim.dart';
import 'enums.dart';
import 'review.dart';
import 'source.dart';

/// Ilmiy statusni review yozuvlaridan **deterministik** hisoblaydi (22.3).
///
/// Qoidalar:
/// * `REVIEWED` — claim domenidagi kamida 1 ta faol reviewer `approve`
///   bergan; u claim muallifi emas.
/// * `VERIFIED` — 2 ta **turli** shunday reviewer, ulardan kamida bittasi
///   `canVerify`, va claim’ning barcha manbalarida DOI/PMID bo‘lsa,
///   ular API orqali tekshirilgan (`identifierVerified`).
/// * Joriy versiyaga `reject` bo‘lsa — `REJECTED`.
/// * Aks holda — `NEEDS_REVIEW`.
///
/// `OUTDATED` faqat tahririy qaror bilan belgilanadi va bu yerda hisoblanmaydi.
class StatusResolver {
  StatusResolver({
    required Iterable<Reviewer> reviewers,
    required Iterable<Review> reviews,
    required Iterable<Authorship> authorships,
  }) : _reviewers = {for (final r in reviewers) r.reviewerId: r},
       _reviewsByClaim = _group(reviews),
       _authors = {for (final a in authorships) a.claimId: a.authorId};

  final Map<String, Reviewer> _reviewers;
  final Map<String, List<Review>> _reviewsByClaim;
  final Map<String, String> _authors;

  static Map<String, List<Review>> _group(Iterable<Review> reviews) {
    final map = <String, List<Review>>{};
    for (final r in reviews) {
      map.putIfAbsent(r.claimId, () => []).add(r);
    }
    return map;
  }

  ScientificStatus resolve(Claim claim, List<Source> claimSources) =>
      resolveSubject(
        subjectId: claim.claimId,
        version: claim.version,
        domain: claim.domain,
        sources: claimSources,
      );

  /// Har qanday review qilinadigan obyekt (claim, yurisdiksion qoida,
  /// reagent retsepti, skrining testi, metod) uchun status.
  ///
  /// **Domen chegarasi:** faqat [domain] bo‘yicha huquqi bor reviewer’ning
  /// review’i hisoblanadi — legal reviewer ilmiy claim’ni, ilmiy reviewer
  /// davlat qonunini, tarjima reviewer’i esa hech birini tasdiqlay olmaydi.
  ScientificStatus resolveSubject({
    required String subjectId,
    required int version,
    required ContentDomain domain,
    required List<Source> sources,
  }) {
    final claimSources = sources;
    final reviews = (_reviewsByClaim[subjectId] ?? const <Review>[])
        .where((r) => r.claimVersion == version)
        .where((r) => r.domain == domain)
        .where(_isQualified)
        .where((r) => r.reviewerId != _authors[subjectId])
        .toList();

    if (reviews.any((r) => r.decision == ReviewDecision.reject)) {
      return ScientificStatus.rejected;
    }

    final approvers = <String>{
      for (final r in reviews)
        if (r.decision == ReviewDecision.approve) r.reviewerId,
    };
    if (approvers.isEmpty) return ScientificStatus.needsReview;

    final hasSenior = approvers.any(
      (id) => _reviewers[id]!.grantFor(domain)!.canVerify,
    );
    final identifiersOk = claimSources
        .where((s) => s.hasPersistentIdentifier)
        .every((s) => s.identifierVerified);

    if (approvers.length >= 2 && hasSenior && identifiersOk) {
      return ScientificStatus.verified;
    }
    return ScientificStatus.reviewed;
  }

  bool _isQualified(Review r) {
    final reviewer = _reviewers[r.reviewerId];
    if (reviewer == null || !reviewer.active) return false;
    return reviewer.grantFor(r.domain) != null;
  }
}
