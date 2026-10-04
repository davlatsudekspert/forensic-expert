/// Research / Evidence Library, bilim grafigi va ilmiy rasmlar (PHASE 5).
///
/// Faqat metadata; to‘liq matn yo‘q. Rasm baytlari kerak bo‘lganda
/// ([ImageBytesLoader]) yuklanadi.
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../library/library_models.dart';

@immutable
class ResearchEntry {
  const ResearchEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.evidenceLevel,
    required this.peerReviewed,
    required this.status,
    this.authors = const [],
    this.organization,
    this.container,
    this.year,
    this.doi,
    this.pmid,
    this.pmcid,
    this.handle,
    this.url,
    this.degree,
    this.sourceApi,
    this.accessedDate,
    this.linkedEntityIds = const [],
    this.isTestData = false,
    this.openAccess,
    this.forensicRelevance = ForensicRelevance.unassessed,
    this.language,
  });

  final String id;
  final ResearchKind kind;

  /// `pmc` / `free_link` / `unknown` (manba API’sidan).
  final String? openAccess;

  /// Dalil sifatidan alohida; reviewer baholamaguncha `unassessed`.
  final ForensicRelevance forensicRelevance;
  final String? language;

  bool get isOpenAccess => openAccess == 'pmc' || openAccess == 'free_link';
  final String title;
  final List<String> authors;
  final String? organization;
  final String? container;
  final String? year;
  final String? doi;
  final String? pmid;
  final String? pmcid;
  final String? handle;
  final String? url;
  final String? degree;
  final String? sourceApi;
  final DateTime? accessedDate;
  final String evidenceLevel;
  final bool peerReviewed;
  final ScientificStatus status;
  final List<String> linkedEntityIds;
  final bool isTestData;

  /// Asosiy havola: DOI → PubMed → URL.
  String? get primaryLink => doi != null
      ? 'https://doi.org/$doi'
      : pmid != null
      ? 'https://pubmed.ncbi.nlm.nih.gov/$pmid/'
      : url;
}

@immutable
class GraphLink {
  const GraphLink({
    required this.fromId,
    required this.toId,
    required this.relation,
    required this.basis,
  });

  final String fromId;
  final String toId;
  final LinkRelation relation;

  /// Asos: claim ID, research ID yoki `editorial:…`.
  final String basis;
}

@immutable
class ImageMeta {
  const ImageMeta({
    required this.id,
    required this.kind,
    required this.entityId,
    required this.title,
    required this.alt,
    required this.license,
    required this.attribution,
    required this.isOriginalDiagram,
    required this.representsRealData,
    this.creator,
    this.sourceName,
    this.sourceUrl,
    this.doi,
    this.captionOriginal,
    this.accessedDate,
  });

  final String id;
  final ImageKind kind;
  final String entityId;
  final LocalizedText title;
  final LocalizedText alt;
  final String license;
  final String attribution;
  final bool isOriginalDiagram;
  final bool representsRealData;
  final String? creator;
  final String? sourceName;
  final String? sourceUrl;
  final String? doi;
  final String? captionOriginal;
  final DateTime? accessedDate;
}

/// Kontent paketidagi dalillar kutubxonasi, graf va rasmlar katalogi.
@immutable
class EvidenceData {
  EvidenceData({
    this.research = const [],
    this.links = const [],
    this.images = const [],
  }) : _researchById = {for (final r in research) r.id: r},
       _from = _index(links, (l) => l.fromId),
       _to = _index(links, (l) => l.toId),
       _imagesByEntity = _group(images);

  static final empty = EvidenceData();

  final List<ResearchEntry> research;
  final List<GraphLink> links;
  final List<ImageMeta> images;
  final Map<String, ResearchEntry> _researchById;
  final Map<String, List<GraphLink>> _from;
  final Map<String, List<GraphLink>> _to;
  final Map<String, List<ImageMeta>> _imagesByEntity;

  static Map<String, List<GraphLink>> _index(
    List<GraphLink> links,
    String Function(GraphLink) key,
  ) {
    final m = <String, List<GraphLink>>{};
    for (final l in links) {
      m.putIfAbsent(key(l), () => []).add(l);
    }
    return m;
  }

  static Map<String, List<ImageMeta>> _group(List<ImageMeta> images) {
    final m = <String, List<ImageMeta>>{};
    for (final i in images) {
      m.putIfAbsent(i.entityId, () => []).add(i);
    }
    return m;
  }

  ResearchEntry? researchById(String id) => _researchById[id];

  List<GraphLink> linksFrom(String id) => _from[id] ?? const [];

  List<GraphLink> linksTo(String id) => _to[id] ?? const [];

  /// Yozuvga bog‘langan research (ikki yo‘nalishda).
  List<ResearchEntry> researchFor(String entityId) => [
    for (final l in linksFrom(entityId))
      if (l.relation == LinkRelation.research) ?_researchById[l.toId],
  ];

  List<ImageMeta> imagesFor(String entityId) =>
      _imagesByEntity[entityId] ?? const [];
}

/// Rasm baytlarini lazily yuklovchi (DB BLOB yoki fixture).
abstract interface class ImageBytesLoader {
  Future<Uint8List?> load(String imageId);
}

class NoImageBytesLoader implements ImageBytesLoader {
  const NoImageBytesLoader();

  @override
  Future<Uint8List?> load(String imageId) async => null;
}
