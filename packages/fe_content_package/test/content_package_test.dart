import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:fe_content_package/fe_content_package.dart';
import 'package:test/test.dart';

// Har bir test vaqtinchalik Ed25519 kalit juftligini yaratadi.
// Repozitoriyda hech qanday maxfiy kalit saqlanmaydi.
void main() {
  late SimpleKeyPair keyPair;
  late PackSigner signer;
  late PackVerifier verifier;
  late SimpleKeyPair otherKeyPair;

  final dbBytes = utf8.encode('TEST DATA — not a real content database');

  PackManifest manifest({
    String version = '2026.10.1',
    PackChannel channel = PackChannel.production,
    String keyId = 'test-key',
    String minApp = '1.0.0',
    int schema = 1,
    List<int>? bytes,
  }) => PackManifest(
    packVersion: PackVersion.parse(version),
    schemaVersion: schema,
    minAppVersion: AppVersion.parse(minApp),
    channel: channel,
    createdAt: DateTime.utc(2026, 10, 4),
    keyId: keyId,
    files: [PackSigner.describeFile('content.db', bytes ?? dbBytes)],
  );

  const context = InstallContext(
    currentPackVersion: PackVersion(2026, 10),
    appVersion: AppVersion(1, 0, 0),
    acceptedChannel: PackChannel.production,
    supportedSchemaVersions: {1},
  );

  setUp(() async {
    keyPair = await Ed25519().newKeyPair();
    otherKeyPair = await Ed25519().newKeyPair();
    signer = PackSigner(keyPair, 'test-key');
    final pub = await keyPair.extractPublicKey();
    verifier = PackVerifier(TrustedKeys({'test-key': pub.bytes}));
  });

  Future<PackVerification> verifySigned(
    PackManifest m, {
    Map<String, List<int>>? files,
    InstallContext ctx = context,
  }) async {
    final s = await signer.sign(m);
    return verifier.verify(
      manifestBytes: s.manifestBytes,
      signature: s.signature,
      files: files ?? {'content.db': dbBytes},
      context: ctx,
    );
  }

  test('to‘g‘ri imzolangan paket qabul qilinadi', () async {
    final r = await verifySigned(manifest());
    expect(r.isValid, isTrue, reason: '$r');
  });

  test('imzo boshqa kalit bilan — rad etiladi', () async {
    final m = manifest();
    final bytes = m.encode();
    final sig = await Ed25519().sign(bytes, keyPair: otherKeyPair);
    final r = await verifier.verify(
      manifestBytes: bytes,
      signature: sig.bytes,
      files: {'content.db': dbBytes},
      context: context,
    );
    expect(r.rejection, PackRejection.badSignature);
  });

  test('manifest imzodan keyin o‘zgartirilsa — rad etiladi', () async {
    final s = await signer.sign(manifest());
    final tampered = List<int>.of(s.manifestBytes);
    final idx = utf8.decode(tampered).indexOf('2026.10.1');
    tampered[idx + 8] = '9'.codeUnitAt(0); // 2026.10.1 → 2026.10.9
    final r = await verifier.verify(
      manifestBytes: tampered,
      signature: s.signature,
      files: {'content.db': dbBytes},
      context: context,
    );
    expect(r.rejection, PackRejection.badSignature);
  });

  test('imzosiz (bo‘sh imzo) — rad etiladi', () async {
    final r = await verifier.verify(
      manifestBytes: manifest().encode(),
      signature: const [],
      files: {'content.db': dbBytes},
      context: context,
    );
    expect(r.isValid, isFalse);
  });

  test('noma’lum yoki bekor qilingan kalit', () async {
    final unknown = await verifySigned(
      manifest(keyId: 'test-key'),
      ctx: context,
    );
    expect(unknown.isValid, isTrue);
    final pub = await keyPair.extractPublicKey();
    final revoked = PackVerifier(
      TrustedKeys({'test-key': pub.bytes}, revokedKeyIds: {'test-key'}),
    );
    final s = await signer.sign(manifest());
    final r = await revoked.verify(
      manifestBytes: s.manifestBytes,
      signature: s.signature,
      files: {'content.db': dbBytes},
      context: context,
    );
    expect(r.rejection, PackRejection.unknownKey);
  });

  test('buzilgan fayl (hash mos emas) — rad etiladi', () async {
    final corrupted = List<int>.of(dbBytes)..[0] ^= 0xFF;
    final r = await verifySigned(manifest(), files: {'content.db': corrupted});
    expect(r.rejection, PackRejection.hashMismatch);
  });

  test('yetishmayotgan, ortiqcha fayl va hajm farqi', () async {
    expect(
      (await verifySigned(manifest(), files: {})).rejection,
      PackRejection.missingFile,
    );
    expect(
      (await verifySigned(
        manifest(),
        files: {
          'content.db': dbBytes,
          'evil.so': [1],
        },
      )).rejection,
      PackRejection.unexpectedFile,
    );
    expect(
      (await verifySigned(
        manifest(),
        files: {
          'content.db': [...dbBytes, 0],
        },
      )).rejection,
      PackRejection.sizeMismatch,
    );
  });

  test('downgrade va replay — rad etiladi', () async {
    expect(
      (await verifySigned(manifest(version: '2026.10'))).rejection,
      PackRejection.notNewer,
    );
    expect(
      (await verifySigned(manifest(version: '2026.09.5'))).rejection,
      PackRejection.notNewer,
    );
  });

  test('test/development paket production ilovaga tushmaydi', () async {
    expect(
      (await verifySigned(manifest(channel: PackChannel.test))).rejection,
      PackRejection.wrongChannel,
    );
  });

  test('ilova eski yoki sxema qo‘llab-quvvatlanmaydi', () async {
    expect(
      (await verifySigned(manifest(minApp: '2.0.0'))).rejection,
      PackRejection.appTooOld,
    );
    expect(
      (await verifySigned(manifest(schema: 99))).rejection,
      PackRejection.unsupportedSchema,
    );
  });

  test('PackVersion CalVer tartibi va validatsiyasi', () {
    expect(
      PackVersion.parse('2026.10.1') > PackVersion.parse('2026.10'),
      isTrue,
    );
    expect(
      PackVersion.parse('2027.01') > PackVersion.parse('2026.12.9'),
      isTrue,
    );
    expect(() => PackVersion.parse('2026.13'), throwsFormatException);
    expect(() => PackVersion.parse('v1'), throwsFormatException);
  });

  group('PackInstaller', () {
    late Directory root;
    setUp(() async {
      root = await Directory.systemTemp.createTemp('fe_pack_test_');
    });
    tearDown(() async => root.delete(recursive: true));

    PackInstaller installer({bool healthy = true}) => PackInstaller(
      root: root,
      verifier: verifier,
      healthCheck: (_) async => healthy,
    );

    Future<InstallReport> install(
      PackInstaller i,
      String version, {
      List<int>? bytes,
      PackVersion? current,
    }) async {
      final b = bytes ?? utf8.encode('TEST DATA $version');
      final s = await signer.sign(manifest(version: version, bytes: b));
      return i.install(
        manifestBytes: s.manifestBytes,
        signature: s.signature,
        files: {'content.db': b},
        context: InstallContext(
          currentPackVersion: current,
          appVersion: const AppVersion(1, 0, 0),
          acceptedChannel: PackChannel.production,
          supportedSchemaVersions: const {1},
        ),
      );
    }

    test('o‘rnatish, yangilash va rollback', () async {
      final i = installer();
      expect((await install(i, '2026.10')).outcome, InstallOutcome.installed);
      expect(
        (await install(
          i,
          '2026.11',
          current: PackVersion.parse('2026.10'),
        )).outcome,
        InstallOutcome.installed,
      );
      expect(
        File('${i.activeDir.path}/content.db').readAsStringSync(),
        'TEST DATA 2026.11',
      );
      expect((await i.rollback()).outcome, InstallOutcome.rolledBack);
      expect(
        File('${i.activeDir.path}/content.db').readAsStringSync(),
        'TEST DATA 2026.10',
      );
    });

    test('sog‘lomlik tekshiruvidan o‘tmagan paket faol bo‘lmaydi', () async {
      final good = installer();
      await install(good, '2026.10');
      final bad = installer(healthy: false);
      final r = await install(
        bad,
        '2026.11',
        current: PackVersion.parse('2026.10'),
      );
      expect(r.outcome, InstallOutcome.failedHealthCheck);
      expect(
        File('${good.activeDir.path}/content.db').readAsStringSync(),
        'TEST DATA 2026.10',
      );
    });

    test('rad etilgan paket faol bazaga tegmaydi', () async {
      final i = installer();
      await install(i, '2026.10');
      final s = await signer.sign(manifest(version: '2026.11'));
      final r = await i.install(
        manifestBytes: s.manifestBytes,
        signature: s.signature,
        files: {'content.db': utf8.encode('tampered')},
        context: context,
      );
      expect(r.outcome, InstallOutcome.rejectedByVerifier);
      expect(
        File('${i.activeDir.path}/content.db').readAsStringSync(),
        'TEST DATA 2026.10',
      );
    });

    test('rollback uchun oldingi versiya yo‘q', () async {
      expect(
        (await installer().rollback()).outcome,
        InstallOutcome.nothingToRollBack,
      );
    });
  });
}
