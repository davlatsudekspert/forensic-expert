import 'package:meta/meta.dart';

import 'claim.dart';
import 'enums.dart';
import 'jurisdiction.dart';
import 'review.dart';
import 'source.dart';

/// Validatsiya qilinadigan kontent to‘plami (content pipeline kirishi).
@immutable
class ContentBundle {
  const ContentBundle({
    required this.channel,
    this.sources = const [],
    this.claims = const [],
    this.citations = const [],
    this.groups = const [],
    this.reviewers = const [],
    this.reviews = const [],
    this.authorships = const [],
    this.jurisdictions = const [],
    this.instruments = const [],
    this.jurisdictionalRules = const [],
  });

  final BundleChannel channel;
  final List<Source> sources;
  final List<Claim> claims;
  final List<Citation> citations;
  final List<ClaimGroup> groups;
  final List<Reviewer> reviewers;
  final List<Review> reviews;
  final List<Authorship> authorships;

  /// Yurisdiksiya qatlami (Global Scientific Core’dan alohida).
  final List<Jurisdiction> jurisdictions;
  final List<JurisdictionalInstrument> instruments;
  final List<JurisdictionalRule> jurisdictionalRules;
}
