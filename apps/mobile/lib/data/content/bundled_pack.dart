import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:fe_content_package/fe_content_package.dart';
import 'package:fe_database/fe_database.dart';
import 'package:flutter/services.dart';

import '../../app/app_info.dart';
import '../../core/flags.dart';
import 'trusted_keys.g.dart';

/// Ilova bilan birga keladigan pilot kontent paketi.
///
/// * Birinchi kadrdan keyin (lazy) o‘rnatiladi — startup’ni kutdirmaydi.
/// * O‘rnatishdan oldin `fe_content_package` `PackVerifier`: Ed25519 imzo
///   (ochiq kalit ilova KODIDA), SHA-256 yaxlitlik, kanal, versiya
///   monotonligi, sxema mosligi. So‘ng `integrity_check` sog‘lomlik
///   tekshiruvi va atomik almashtirish.
/// * Kanal [FeFlags.contentChannel] ga mos kelmasa (masalan, production
///   yig‘ma development paketni oladi) — paket **rad etiladi**.
class BundledPackInstaller {
  BundledPackInstaller({
    required this.root,
    AssetBundle? assets,
    Map<String, String>? trustedKeys,
    String? acceptedChannel,
  }) : _assets = assets ?? rootBundle,
       _trustedKeys = trustedKeys ?? bundledPackTrustedKeys,
       _acceptedChannel = acceptedChannel ?? FeFlags.contentChannel;

  /// `<support>/content` — ichida `active/`, `previous/`, `staging/`.
  final Directory root;
  final AssetBundle _assets;
  final Map<String, String> _trustedKeys;
  final String _acceptedChannel;

  static const _assetDir = 'assets/content/pilot';

  Future<InstallReport?> ensureInstalled() async {
    final manifestBytes = await _bytes('manifest.json');
    final signature = await _bytes('manifest.sig');
    final bundledVersion = PackManifest.fromJson(
      (jsonDecode(utf8.decode(manifestBytes)) as Map).cast(),
    ).packVersion;

    final installer = PackInstaller(
      root: root,
      verifier: PackVerifier(
        TrustedKeys({
          for (final e in _trustedKeys.entries) e.key: base64Decode(e.value),
        }),
      ),
      healthCheck: _healthCheck,
    );
    final current = await _activeVersion(installer.activeDir);
    if (current != null && !(bundledVersion > current)) return null;

    return installer.install(
      manifestBytes: manifestBytes,
      signature: signature,
      files: {'content.db': await _bytes('content.db')},
      context: InstallContext(
        currentPackVersion: current,
        appVersion: AppVersion.parse(AppInfo.version),
        acceptedChannel: PackChannel.values.byName(_acceptedChannel),
        supportedSchemaVersions: {ContentDatabase.contentSchemaVersion},
      ),
    );
  }

  Future<List<int>> _bytes(String name) async {
    final data = await _assets.load('$_assetDir/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  static Future<PackVersion?> _activeVersion(Directory active) async {
    final f = File('${active.path}/manifest.json');
    if (!f.existsSync()) return null;
    try {
      final j = (jsonDecode(await f.readAsString()) as Map)
          .cast<String, Object?>();
      return PackManifest.fromJson(j).packVersion;
    } on Object {
      return null;
    }
  }

  static Future<bool> _healthCheck(Directory staged) async {
    final db = ContentDatabase(
      NativeDatabase(File('${staged.path}/content.db')),
    );
    try {
      return await db.integrityOk() &&
          await db.metaValue('schema_version') ==
              '${ContentDatabase.contentSchemaVersion}';
    } on Object {
      return false;
    } finally {
      await db.close();
    }
  }
}
