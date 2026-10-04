import 'dart:io';

import 'package:drift/native.dart';
import 'package:fe_database/fe_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/data/content/bundled_pack.dart';
import 'package:forensic_expert/data/content/content_knowledge_repository.dart';
import 'package:forensic_expert/data/content/content_library_repository.dart';
import 'package:forensic_expert/data/content/content_provenance.dart';
import 'package:forensic_expert/data/local/content_store.dart';
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
  const PilotContent(this.library, this.knowledge, this.legal, this.status);

  final ContentLibraryRepository library;
  final KnowledgeRepository knowledge;
  final ContentLegalData legal;
  final ContentStatus status;

  List<Override> get overrides => [
    libraryRepositoryProvider.overrideWithValue(library),
    knowledgeRepositoryProvider.overrideWithValue(knowledge),
    contentLegalDataProvider.overrideWithValue(legal),
    contentStatusProvider.overrideWith((ref) async => status),
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
  );
  await db.close();
  return content;
}

/// Faqat kutubxona (eski testlar uchun).
Future<ContentLibraryRepository> loadPilotLibrary() async =>
    (await loadPilotContent()).library;
