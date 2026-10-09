import 'dart:io';

import 'package:drift/native.dart';
import 'package:fe_database/fe_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/content/bundled_pack.dart';
import 'package:forensic_expert/data/content/content_provenance.dart';

import '../helpers/pilot_content.dart';

void main() {
  test('egasi ruxsati bilan olingan manba «Litsenziya kerak» emas', () async {
    final root = Directory.systemTemp.createTempSync('fe_perm');
    await BundledPackInstaller(
      root: root,
      assets: DiskAssetBundle(),
      acceptedChannel: 'development',
    ).ensureInstalled();
    final db = ContentDatabase(
      NativeDatabase(File('${root.path}/active/content.db')),
    );
    final prov = await ContentProvenance.load(db);
    final owner = prov.source('SRC-OWNER-REAGENTS', null);
    expect(owner.licenseAgreementId, 'OWNER-PERMISSION-2026-10-09');
    expect(owner.usedWithPermission, isTrue);
    await db.close();
    root.deleteSync(recursive: true);
  });
}
