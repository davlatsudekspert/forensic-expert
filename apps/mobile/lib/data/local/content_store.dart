import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:fe_database/fe_database.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/perf/startup_metrics.dart';
import '../content/bundled_pack.dart';

/// O‘rnatilgan ilmiy baza holati.
@immutable
class ContentStatus {
  const ContentStatus({required this.packVersion, required this.isTestData});

  static const notInstalled = ContentStatus(
    packVersion: null,
    isTestData: false,
  );

  /// Masalan `2026.10`; `null` — paket o‘rnatilmagan.
  final String? packVersion;
  final bool isTestData;

  bool get isInstalled => packVersion != null;
}

/// Lokal kontent bazasiga kirish nuqtasi.
///
/// * Baza **hech qachon** startup yo‘lida ochilmaydi — birinchi kadrdan
///   keyin, kerak bo‘lganda (lazy).
/// * Ochilish vaqti `content_db.open` sifatida o‘lchanadi.
/// * Faol paket `fe_content_package` `PackInstaller.activeDir` da turadi.
abstract interface class ContentStore {
  Future<ContentStatus> status();

  /// Ilova bilan kelgan pilot paketni (kerak bo‘lsa) tekshirib o‘rnatadi va
  /// faol bazani qaytaradi. Paket yo‘q yoki rad etilgan bo‘lsa — `null`.
  Future<ContentDatabase?> openActive();
}

class LocalContentStore implements ContentStore {
  LocalContentStore({Future<Directory> Function()? supportDir})
    : _supportDir = supportDir ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _supportDir;
  ContentDatabase? _db;

  static const _packDir = 'content/active';
  static const _dbFile = 'content.db';

  Future<File> _activeDbFile() async {
    final dir = await _supportDir();
    return File('${dir.path}/$_packDir/$_dbFile');
  }

  Future<void>? _installing;

  Future<void> _ensureBundled() => _installing ??= () async {
    final dir = await _supportDir();
    try {
      final report = await BundledPackInstaller(
        root: Directory('${dir.path}/content'),
      ).ensureInstalled();
      if (report != null && kDebugMode) {
        debugPrint(
          '[content] bundled pack: ${report.outcome.name} '
          '${report.rejection?.name ?? ''}',
        );
      }
    } on Object catch (e) {
      // Asset yo‘q (testlar) yoki o‘qish xatosi — ilova bazasiz ishlaydi.
      if (kDebugMode) debugPrint('[content] bundled pack skipped: $e');
    }
  }();

  @override
  Future<ContentDatabase?> openActive() async {
    await _ensureBundled();
    final file = await _activeDbFile();
    if (!file.existsSync()) return null;
    return _open(file);
  }

  @override
  Future<ContentStatus> status() async {
    await _ensureBundled();
    final file = await _activeDbFile();
    if (!file.existsSync()) return ContentStatus.notInstalled;
    final db = await _open(file);
    return ContentStatus(
      packVersion: await db.metaValue('pack_version'),
      isTestData: await db.containsTestData(),
    );
  }

  Future<ContentDatabase> _open(File file) async {
    final existing = _db;
    if (existing != null) return existing;
    return StartupMetrics.instance.measure(PerfMarks.contentDbOpen, () async {
      final db = ContentDatabase(
        driftDatabase(
          name: 'content',
          native: DriftNativeOptions(databasePath: () async => file.path),
        ),
      );
      await db.customSelect('SELECT 1').get();
      return _db = db;
    });
  }
}

/// Testlar uchun.
class FakeContentStore implements ContentStore {
  const FakeContentStore([this.value = ContentStatus.notInstalled]);

  final ContentStatus value;

  @override
  Future<ContentStatus> status() async => value;

  @override
  Future<ContentDatabase?> openActive() async => null;
}
