import 'dart:io';

import 'package:drift/native.dart';
import 'package:fe_database/fe_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/data/content/bundled_pack.dart';
import 'package:forensic_expert/data/content/content_evidence_loader.dart';
import 'package:forensic_expert/data/content/content_knowledge_repository.dart';
import 'package:forensic_expert/data/content/content_library_repository.dart';
import 'package:forensic_expert/data/content/content_provenance.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';

import '../helpers/pilot_content.dart';

/// PHASE 5 unumdorligi (host VM, JIT; qurilma o‘lchovi EMAS).
/// Chegaralar keng — regressiyani ushlash uchun, benchmark emas.
void main() {
  test('paket o‘rnatish, yuklash va qidiruv — o‘lchov', () async {
    String ms(Stopwatch s) => '${s.elapsedMicroseconds / 1000} ms';
    final out = <String>[];

    final root = Directory.systemTemp.createTempSync('fe_perf');
    var sw = Stopwatch()..start();
    await BundledPackInstaller(
      root: root,
      assets: DiskAssetBundle(),
      acceptedChannel: 'development',
    ).ensureInstalled();
    out.add('install (imzo + SHA-256): ${ms(sw)}');

    final db = ContentDatabase(
      NativeDatabase(File('${root.path}/active/content.db')),
    );
    sw = Stopwatch()..start();
    final library = await ContentLibraryRepository.load(db);
    out.add('kutubxona yuklash: ${ms(sw)}');
    sw = Stopwatch()..start();
    final prov = await ContentProvenance.load(db);
    final knowledge = await ContentKnowledgeLoader.load(db, provenance: prov);
    out.add('bilim obyektlari: ${ms(sw)}');
    sw = Stopwatch()..start();
    final ev = await ContentEvidenceLoader.load(db);
    out.add(
      'evidence (research ${ev.research.length}, link ${ev.links.length}, '
      'rasm meta ${ev.images.length}): ${ms(sw)}',
    );
    sw = Stopwatch()..start();
    final img = await DbImageBytesLoader(db).load(ev.images.first.id);
    out.add('bitta rasm baytlari (${img!.length} B): ${ms(sw)}');

    sw = Stopwatch()..start();
    final search = AppSearchService.build(
      library: library,
      learn: const EmptyLearnRepository(),
      knowledge: knowledge,
      research: ev.research,
    );
    out.add('qidiruv indeksi: ${ms(sw)}');
    final times = <double>[];
    for (final q in [
      'fentanyl',
      'фентанил',
      'morfin',
      'postmortem redistribution',
      'LC-MS/MS',
      'benzodiazepine',
      'fentanil test',
      'vitreous potassium',
    ]) {
      sw = Stopwatch()..start();
      await search.search(q);
      times.add(sw.elapsedMicroseconds / 1000);
    }
    times.sort();
    out.add(
      'qidiruv (8 so‘rov): min ${times.first} ms, '
      'median ${times[times.length ~/ 2]} ms, max ${times.last} ms',
    );
    await db.close();

    // ignore: avoid_print
    print('PHASE5 PERF\n${out.join('\n')}');
    expect(times.last, lessThan(2000));
  });
}
