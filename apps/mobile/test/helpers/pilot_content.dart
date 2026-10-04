import 'dart:io';

import 'package:drift/native.dart';
import 'package:fe_database/fe_database.dart';
import 'package:flutter/services.dart';
import 'package:forensic_expert/data/content/bundled_pack.dart';
import 'package:forensic_expert/data/content/content_library_repository.dart';

/// Asset’larni diskdan o‘qiydigan bundle (testlarda `rootBundle` o‘rniga).
class DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = File(key).readAsBytesSync();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

/// Ilovaga kiritilgan HAQIQIY pilot paketni vaqtinchalik katalogga
/// o‘rnatib, kutubxonani yuklaydi.
Future<ContentLibraryRepository> loadPilotLibrary() async {
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
  final repo = await ContentLibraryRepository.load(db);
  await db.close();
  return repo;
}
