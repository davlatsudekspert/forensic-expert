import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:fe_content_package/fe_content_package.dart';
import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart' as db;

import 'bundle_codec.dart';
import 'db_writer.dart';

/// Validator xatolari — paket yaratilmaydi.
class PipelineValidationError implements Exception {
  PipelineValidationError(this.report);

  final ValidationReport report;

  @override
  String toString() =>
      'Content validation failed:\n${report.errors.join('\n')}';
}

/// Yaratilgan paket.
class BuiltPack {
  const BuiltPack({
    required this.directory,
    required this.manifest,
    required this.keyId,
    required this.publicKey,
    required this.report,
  });

  final Directory directory;
  final PackManifest manifest;
  final String keyId;
  final List<int> publicKey;

  /// Ogohlantirishlar (xato bo‘lsa paket yaratilmagan bo‘lardi).
  final ValidationReport report;
}

/// manba → validator → content.db → manifest + Ed25519 imzo.
///
/// Kalit siyosati:
/// * `development` / `test` kanal: har safar **vaqtinchalik** kalit
///   juftligi; maxfiy kalit xotirada qoladi va hech qayerga yozilmaydi.
///   Ochiq kalit paket yonida `signing_public_key.json` sifatida chiqadi.
/// * `production` kanal: maxfiy kalit faqat tashqaridan ([signingSeed],
///   CI secret / KMS) beriladi. Busiz production paket yaratilmaydi.
class PackBuilder {
  const PackBuilder({this.validator = const ContentValidator()});

  final ContentValidator validator;

  static const dbFile = 'content.db';

  Future<BuiltPack> build({
    required PipelineBundle bundle,
    required Directory outDir,
    required DateTime builtAt,
    String minAppVersion = '0.1.0',
    List<int>? signingSeed,
    ContentBundle? previous,
  }) async {
    final report = ValidationReport([
      ...validator.validate(bundle.content).issues,
      // FE027: ko‘rib chiqilgan ma’lumot jimgina almashtirilmaydi.
      if (previous != null)
        ...ReviewRegressionGuard.compare(previous, bundle.content).issues,
    ]);
    if (!report.isValid) throw PipelineValidationError(report);

    final channel = PackChannel.values.byName(bundle.channel.name);
    if (channel == PackChannel.production && signingSeed == null) {
      throw StateError('Production pack requires an external signing key.');
    }

    if (outDir.existsSync()) await outDir.delete(recursive: true);
    await outDir.create(recursive: true);
    final dbPath = File('${outDir.path}/$dbFile');

    final database = db.ContentDatabase(NativeDatabase(dbPath));
    try {
      await ContentDbWriter(database).write(bundle, builtAt: builtAt);
      if (!await database.integrityOk()) {
        throw StateError('integrity_check failed');
      }
      await database.customStatement('VACUUM');
    } finally {
      await database.close();
    }

    final algorithm = Ed25519();
    final keyPair = signingSeed == null
        ? await algorithm.newKeyPair()
        : await algorithm.newKeyPairFromSeed(signingSeed);
    final publicKey = (await keyPair.extractPublicKey()).bytes;
    final keyId =
        '${channel.name}-'
        '${crypto.sha256.convert(publicKey).toString().substring(0, 12)}';

    final dbBytes = await dbPath.readAsBytes();
    final manifest = PackManifest(
      packVersion: PackVersion.parse(bundle.packVersion),
      schemaVersion: db.ContentDatabase.contentSchemaVersion,
      minAppVersion: AppVersion.parse(minAppVersion),
      channel: channel,
      createdAt: builtAt,
      keyId: keyId,
      files: [PackSigner.describeFile(dbFile, dbBytes)],
    );
    final signed = await PackSigner(keyPair, keyId).sign(manifest);
    await File('${outDir.path}/manifest.json')
        .writeAsBytes(signed.manifestBytes, flush: true);
    await File('${outDir.path}/manifest.sig')
        .writeAsBytes(signed.signature, flush: true);
    await File('${outDir.path}/signing_public_key.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'key_id': keyId,
        'algorithm': 'Ed25519',
        'public_key_base64': base64Encode(publicKey),
        'channel': channel.name,
      }),
    );
    return BuiltPack(
      directory: outDir,
      manifest: manifest,
      keyId: keyId,
      publicKey: publicKey,
      report: report,
    );
  }
}
