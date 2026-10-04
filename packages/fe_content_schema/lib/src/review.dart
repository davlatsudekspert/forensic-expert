import 'package:meta/meta.dart';

import 'enums.dart';

/// Reviewer (22-bo‘lim).
@immutable
class Reviewer {
  const Reviewer({
    required this.reviewerId,
    required this.displayName,
    required this.grants,
    this.active = true,
  });

  final String reviewerId;
  final String displayName;
  final List<ReviewerGrant> grants;
  final bool active;

  ReviewerGrant? grantFor(ContentDomain domain) {
    for (final g in grants) {
      if (g.domain == domain) return g;
    }
    return null;
  }
}

/// Reviewer’ga berilgan domen huquqi.
@immutable
class ReviewerGrant {
  const ReviewerGrant({required this.domain, this.canVerify = false});

  final ContentDomain domain;

  /// VERIFIED berish huquqi (faqat tayinlangan katta reviewer).
  final bool canVerify;
}

enum ReviewDecision { approve, requestChanges, reject }

/// Bitta review yozuvi. Muayyan claim **versiyasiga** bog‘langan:
/// claim o‘zgarsa, eski review’lar unga taalluqli bo‘lmaydi.
@immutable
class Review {
  const Review({
    required this.reviewId,
    required this.claimId,
    required this.claimVersion,
    required this.reviewerId,
    required this.domain,
    required this.decision,
    required this.createdAt,
  });

  final String reviewId;
  final String claimId;
  final int claimVersion;
  final String reviewerId;
  final ContentDomain domain;
  final ReviewDecision decision;
  final DateTime createdAt;
}

/// Claim muallifligi (four-eyes qoidasi uchun).
@immutable
class Authorship {
  const Authorship({required this.claimId, required this.authorId});

  final String claimId;
  final String authorId;
}
