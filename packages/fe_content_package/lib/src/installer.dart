import 'dart:io';

import 'package:meta/meta.dart';

import 'manifest.dart';
import 'verifier.dart';

/// O‘rnatishdan keyingi sog‘lomlik tekshiruvi (24.2, 5-qadam):
/// `PRAGMA integrity_check`, sxema versiyasi, smoke so‘rovlar va
/// kalkulyator reference testlari. Implementatsiyani `fe_database` beradi.
typedef PackHealthCheck = Future<bool> Function(Directory stagedPackDir);

enum InstallOutcome {
  installed,
  rejectedByVerifier,
  failedHealthCheck,
  rolledBack,
  nothingToRollBack,
}

@immutable
class InstallReport {
  const InstallReport(this.outcome, {this.rejection, this.version});

  final InstallOutcome outcome;
  final PackRejection? rejection;
  final PackVersion? version;
}

/// Atomik o‘rnatish va rollback (24.2, 6–8-qadamlar).
///
/// Katalog tuzilmasi (`root` ichida):
/// * `active/`   — joriy paket;
/// * `previous/` — oldingi paket (rollback uchun);
/// * `staging/`  — yangi paket tekshiruv vaqtida.
///
/// Kafolat: imzo, yaxlitlik yoki sog‘lomlik tekshiruvidan o‘tmagan paket
/// hech qachon `active/` ga aylanmaydi.
class PackInstaller {
  PackInstaller({
    required this.root,
    required this.verifier,
    required this.healthCheck,
  });

  final Directory root;
  final PackVerifier verifier;
  final PackHealthCheck healthCheck;

  Directory get activeDir => Directory('${root.path}/active');
  Directory get previousDir => Directory('${root.path}/previous');
  Directory get _stagingDir => Directory('${root.path}/staging');

  Future<InstallReport> install({
    required List<int> manifestBytes,
    required List<int> signature,
    required Map<String, List<int>> files,
    required InstallContext context,
  }) async {
    final verification = await verifier.verify(
      manifestBytes: manifestBytes,
      signature: signature,
      files: files,
      context: context,
    );
    if (!verification.isValid) {
      return InstallReport(
        InstallOutcome.rejectedByVerifier,
        rejection: verification.rejection,
      );
    }

    // Staging’ga yozish.
    if (_stagingDir.existsSync()) await _stagingDir.delete(recursive: true);
    await _stagingDir.create(recursive: true);
    for (final entry in files.entries) {
      final file = File('${_stagingDir.path}/${entry.key}');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(entry.value, flush: true);
    }
    await File('${_stagingDir.path}/manifest.json')
        .writeAsBytes(manifestBytes, flush: true);
    await File('${_stagingDir.path}/manifest.sig')
        .writeAsBytes(signature, flush: true);

    if (!await healthCheck(_stagingDir)) {
      await _stagingDir.delete(recursive: true);
      return const InstallReport(InstallOutcome.failedHealthCheck);
    }

    // Atomik almashtirish: rename bitta fayl tizimi ichida atomik.
    if (previousDir.existsSync()) await previousDir.delete(recursive: true);
    if (activeDir.existsSync()) await activeDir.rename(previousDir.path);
    await _stagingDir.rename(activeDir.path);
    return InstallReport(
      InstallOutcome.installed,
      version: verification.manifest!.packVersion,
    );
  }

  /// Oldingi paketga qaytish (masalan, yangi bazani birinchi ochishda xato).
  Future<InstallReport> rollback() async {
    if (!previousDir.existsSync()) {
      return const InstallReport(InstallOutcome.nothingToRollBack);
    }
    final failed = Directory('${root.path}/failed');
    if (failed.existsSync()) await failed.delete(recursive: true);
    if (activeDir.existsSync()) await activeDir.rename(failed.path);
    await previousDir.rename(activeDir.path);
    return const InstallReport(InstallOutcome.rolledBack);
  }
}
