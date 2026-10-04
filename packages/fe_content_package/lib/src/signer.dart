import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';

import 'manifest.dart';

/// Paket imzolovchi — **faqat** CI yoki offline imzolash muhitida ishlatiladi.
///
/// Maxfiy kalit tashqaridan (KMS, xavfsiz fayl) beriladi; bu sinf uni
/// hech qayerga saqlamaydi. Repozitoriyda hech qanday maxfiy kalit yo‘q —
/// testlar har safar vaqtinchalik kalit juftligini yaratadi.
class PackSigner {
  PackSigner(this._keyPair, this.keyId);

  final SimpleKeyPair _keyPair;
  final String keyId;
  final _ed25519 = Ed25519();

  static PackFile describeFile(String path, List<int> bytes) => PackFile(
    path: path,
    sha256: crypto.sha256.convert(bytes).toString(),
    size: bytes.length,
  );

  /// Manifest baytlari va imzo.
  Future<({List<int> manifestBytes, List<int> signature})> sign(
    PackManifest manifest,
  ) async {
    if (manifest.keyId != keyId) {
      throw ArgumentError('Manifest key_id does not match signer key.');
    }
    final bytes = manifest.encode();
    final sig = await _ed25519.sign(bytes, keyPair: _keyPair);
    return (manifestBytes: bytes, signature: sig.bytes);
  }
}
