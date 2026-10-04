import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:meta/meta.dart';

import 'manifest.dart';

/// Ilovaga o‘rnatilgan ishonchli **ochiq** kalitlar (Ed25519, 32 bayt).
/// Maxfiy kalit hech qachon ilovada yoki repozitoriyda bo‘lmaydi.
@immutable
class TrustedKeys {
  const TrustedKeys(this._keys, {this.revokedKeyIds = const {}});

  final Map<String, List<int>> _keys;
  final Set<String> revokedKeyIds;

  List<int>? publicKeyFor(String keyId) =>
      revokedKeyIds.contains(keyId) ? null : _keys[keyId];
}

/// Rad etish sababi — har biri alohida test bilan qoplangan.
enum PackRejection {
  malformedManifest,
  unknownKey,
  badSignature,
  wrongChannel,
  notNewer,
  appTooOld,
  unsupportedSchema,
  missingFile,
  sizeMismatch,
  hashMismatch,
  unexpectedFile,
}

@immutable
class PackVerification {
  const PackVerification.ok(PackManifest this.manifest) : rejection = null;
  const PackVerification.rejected(PackRejection this.rejection)
    : manifest = null;

  final PackManifest? manifest;
  final PackRejection? rejection;

  bool get isValid => rejection == null;

  @override
  String toString() => isValid
      ? 'PackVerification.ok(${manifest!.packVersion})'
      : 'PackVerification.rejected($rejection)';
}

/// Qurilma holati — paket shu bilan solishtiriladi.
@immutable
class InstallContext {
  const InstallContext({
    required this.currentPackVersion,
    required this.appVersion,
    required this.acceptedChannel,
    required this.supportedSchemaVersions,
  });

  final PackVersion? currentPackVersion;
  final AppVersion appVersion;
  final PackChannel acceptedChannel;
  final Set<int> supportedSchemaVersions;
}

/// Kontent paketini tekshiruvchi (24.2-bo‘lim, 1–4-qadamlar).
///
/// Tartib muhim: avval imzo, keyin manifest mazmuni. Imzosiz yoki
/// buzilgan manifestga hech qachon ishonilmaydi.
class PackVerifier {
  PackVerifier(this._trustedKeys);

  final TrustedKeys _trustedKeys;
  final _ed25519 = Ed25519();

  Future<PackVerification> verify({
    required List<int> manifestBytes,
    required List<int> signature,
    required Map<String, List<int>> files,
    required InstallContext context,
  }) async {
    // 1. Manifestni faqat kalit ID’sini o‘qish uchun parse qilamiz.
    PackManifest manifest;
    try {
      final json = jsonDecode(utf8.decode(manifestBytes));
      if (json is! Map<String, Object?>) {
        return const PackVerification.rejected(PackRejection.malformedManifest);
      }
      manifest = PackManifest.fromJson(json);
    } on Object {
      return const PackVerification.rejected(PackRejection.malformedManifest);
    }

    // 2. Imzo.
    final key = _trustedKeys.publicKeyFor(manifest.keyId);
    if (key == null) {
      return const PackVerification.rejected(PackRejection.unknownKey);
    }
    if (signature.length != 64 || key.length != 32) {
      return const PackVerification.rejected(PackRejection.badSignature);
    }
    bool ok;
    try {
      ok = await _ed25519.verify(
        manifestBytes,
        signature: Signature(
          signature,
          publicKey: SimplePublicKey(key, type: KeyPairType.ed25519),
        ),
      );
    } on Object {
      ok = false;
    }
    if (!ok) return const PackVerification.rejected(PackRejection.badSignature);

    // 3. Kanal, versiya monotonligi, moslik.
    if (manifest.channel != context.acceptedChannel) {
      return const PackVerification.rejected(PackRejection.wrongChannel);
    }
    final current = context.currentPackVersion;
    if (current != null && !(manifest.packVersion > current)) {
      return const PackVerification.rejected(PackRejection.notNewer);
    }
    if (context.appVersion.compareTo(manifest.minAppVersion) < 0) {
      return const PackVerification.rejected(PackRejection.appTooOld);
    }
    if (!context.supportedSchemaVersions.contains(manifest.schemaVersion)) {
      return const PackVerification.rejected(PackRejection.unsupportedSchema);
    }

    // 4. Fayllar yaxlitligi.
    final declared = {for (final f in manifest.files) f.path};
    for (final path in files.keys) {
      if (!declared.contains(path)) {
        return const PackVerification.rejected(PackRejection.unexpectedFile);
      }
    }
    for (final f in manifest.files) {
      final bytes = files[f.path];
      if (bytes == null) {
        return const PackVerification.rejected(PackRejection.missingFile);
      }
      if (bytes.length != f.size) {
        return const PackVerification.rejected(PackRejection.sizeMismatch);
      }
      if (crypto.sha256.convert(bytes).toString() != f.sha256.toLowerCase()) {
        return const PackVerification.rejected(PackRejection.hashMismatch);
      }
    }
    return PackVerification.ok(manifest);
  }
}
