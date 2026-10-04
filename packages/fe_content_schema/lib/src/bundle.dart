import 'package:meta/meta.dart';

import 'claim.dart';
import 'enums.dart';
import 'evidence_graph.dart';
import 'jurisdiction.dart';
import 'knowledge.dart';
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
    this.authorities = const [],
    this.recipes = const [],
    this.screeningTests = const [],
    this.methods = const [],
    this.emergingIssues = const [],
    this.topics = const [],
    this.research = const [],
    this.links = const [],
    this.images = const [],
    this.knownEntityIds = const {},
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
  final List<Authority> authorities;

  // PHASE 4 bilim sohalari.
  final List<SolutionRecipe> recipes;
  final List<ScreeningTest> screeningTests;
  final List<MethodRecord> methods;
  final List<EmergingIssue> emergingIssues;
  final List<KnowledgeTopic> topics;

  // PHASE 5: evidence library, bilim grafigi, rasmlar.
  final List<ResearchRecord> research;
  final List<EntityLink> links;
  final List<ScientificImage> images;

  /// Bundle’dan tashqari ma’lum yozuvlar (masalan, moddalar) — bog‘lanish
  /// yaxlitligi uchun (FE030).
  final Set<String> knownEntityIds;
}
