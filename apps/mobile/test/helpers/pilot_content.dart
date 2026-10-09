import 'dart:io';

import 'package:drift/native.dart';
import 'package:fe_database/fe_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/data/content/bundled_pack.dart';
import 'package:forensic_expert/data/content/content_evidence_loader.dart';
import 'package:forensic_expert/data/content/content_knowledge_repository.dart';
import 'package:forensic_expert/data/content/content_library_repository.dart';
import 'package:forensic_expert/data/content/content_provenance.dart';
import 'package:forensic_expert/data/local/content_store.dart';
import 'package:forensic_expert/domain/evidence/content_translations.dart';
import 'package:forensic_expert/domain/evidence/evidence_models.dart';
import 'package:forensic_expert/domain/evidence/provenance_models.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';

/// Asset’larni diskdan o‘qiydigan bundle (testlarda `rootBundle` o‘rniga).
class DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = File(key).readAsBytesSync();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

/// Ilovaga kiritilgan HAQIQIY pilot paket (kutubxona, bilim sohalari,
/// yurisdiksiya qatlami).
class PilotContent {
  const PilotContent(
    this.library,
    this.knowledge,
    this.legal,
    this.status,
    this.evidence,
    this.images,
    this.provenance,
    this.translations,
  );

  final ContentLibraryRepository library;
  final KnowledgeRepository knowledge;
  final ContentLegalData legal;
  final ContentStatus status;
  final EvidenceData evidence;
  final MemoryImageBytesLoader images;

  /// PHASE 7 provenance qatlami.
  final ProvenanceIndex provenance;

  /// Kontent tarjimalari (asl iqtibos, sarlavha …).
  final ContentTranslations translations;

  List<Override> get overrides => overridesWith();

  /// [machine] berilsa — paketdagi tarjimalar o‘rniga (eskirgan xesh testi).
  List<Override> overridesWith({ContentTranslations? machine}) => [
    evidenceDataProvider.overrideWithValue(evidence),
    imageBytesLoaderProvider.overrideWith((ref) async => images),
    libraryRepositoryProvider.overrideWithValue(library),
    knowledgeRepositoryProvider.overrideWithValue(knowledge),
    contentLegalDataProvider.overrideWithValue(legal),
    contentStatusProvider.overrideWith((ref) async => status),
    provenanceIndexProvider.overrideWithValue(provenance),
    contentTranslationsProvider.overrideWithValue(machine ?? translations),
  ];
}

Future<PilotContent> loadPilotContent() async {
  final root = Directory.systemTemp.createTempSync('fe_pilot');
  final report = await BundledPackInstaller(
    root: root,
    assets: DiskAssetBundle(),
    acceptedChannel: 'development',
  ).ensureInstalled();
  if (report == null || report.version == null) {
    throw StateError('pilot pack not installed: ${report?.outcome}');
  }
  final db = ContentDatabase(
    NativeDatabase(File('${root.path}/active/content.db')),
  );
  final prov = await ContentProvenance.load(db);
  final content = PilotContent(
    await ContentLibraryRepository.load(db),
    await ContentKnowledgeLoader.load(db, provenance: prov),
    await ContentLegalData.load(db, provenance: prov),
    ContentStatus(
      packVersion: await db.metaValue('pack_version'),
      isTestData: await db.containsTestData(),
    ),
    await ContentEvidenceLoader.load(db),
    MemoryImageBytesLoader({
      for (final r
          in await db.customSelect('SELECT image_id, bytes FROM images').get())
        r.read<String>('image_id'): r.read<Uint8List>('bytes'),
    }),
    prov.index,
    prov.translations,
  );
  await db.close();
  return content;
}

/// Rasm baytlari xotirada (testlarda DB yopilgandan keyin ham ishlaydi).
class MemoryImageBytesLoader implements ImageBytesLoader {
  const MemoryImageBytesLoader(this.bytes);

  final Map<String, Uint8List> bytes;

  @override
  Future<Uint8List?> load(String imageId) async => bytes[imageId];
}

/// Faqat kutubxona (eski testlar uchun).
Future<ContentLibraryRepository> loadPilotLibrary() async =>
    (await loadPilotContent()).library;
