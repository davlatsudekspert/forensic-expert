import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/guidelines/guideline_models.dart';
import '../domain/guidelines/practice_catalog.dart';
import 'account.dart';

/// Ilovaga qo‘shilgan mustaqil yo‘riqnoma kartalari (ochiq kontent).
const guidelinesAsset = 'assets/content/guidelines/guidelines_v1.json';

final guidelineBundleLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(guidelinesAsset),
);

final guidelinesProvider = FutureProvider<GuidelineBundle>((ref) async {
  try {
    final text = await ref.watch(guidelineBundleLoaderProvider)();
    return GuidelineBundle.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
    );
  } on Object {
    // Buzilgan yoki yo‘q paket — bo‘sh bo‘lim (soxta kontent yo‘q).
    return GuidelineBundle.empty;
  }
});

/// Yopiq katalog fayli ilovaning shaxsiy papkasida (`restricted/`).
/// Paketga, zaxira nusxaga yoki serverga hech qachon qo‘shilmaydi.
class FilePracticeCatalogStore implements PracticeCatalogStore {
  const FilePracticeCatalogStore();

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/restricted/practice_catalog.json');
  }

  @override
  Future<String?> read() async {
    final f = await _file();
    return await f.exists() ? f.readAsString() : null;
  }

  @override
  Future<void> write(String json) async {
    final f = await _file();
    await f.parent.create(recursive: true);
    await f.writeAsString(json, flush: true);
  }

  @override
  Future<void> clear() async {
    final f = await _file();
    if (await f.exists()) await f.delete();
  }
}

final practiceCatalogStoreProvider = Provider<PracticeCatalogStore>(
  (ref) => const FilePracticeCatalogStore(),
);

/// Faqat admin uchun: aks holda faylni o‘qimaymiz ham.
final practiceCatalogProvider = FutureProvider<PracticeCatalog?>((ref) async {
  final access = await ref.watch(serverAccessProvider.future);
  if (!access.isAdmin) return null;
  final text = await ref.watch(practiceCatalogStoreProvider).read();
  if (text == null) return null;
  try {
    return PracticeCatalog.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
    );
  } on Object {
    return null;
  }
});

/// Importdan oldin tekshiradi; noto‘g‘ri fayl saqlanmaydi.
Future<PracticeCatalog> importPracticeCatalog(
  PracticeCatalogStore store,
  String text,
) async {
  final catalog = PracticeCatalog.fromJson(
    (jsonDecode(text) as Map).cast<String, Object?>(),
  );
  await store.write(text);
  return catalog;
}
