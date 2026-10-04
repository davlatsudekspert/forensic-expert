// Host benchmark: content.db ochish (schema v2) va FTS5 qidiruv.
//
// Ishga tushirish: `dart run tool/bench.dart`
//
// Diqqat: bu **host VM** (desktop/server CPU) o‘lchovi, mobil qurilma
// emas. Terminlar SINTETIK (`TEST-SYN-*`, ma’nosiz so‘zlar) — ilmiy
// ma’lumot yo‘q; faqat indeks hajmiga nisbatan tezlikni ko‘rsatadi.
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:fe_database/fe_database.dart';
import 'package:fe_search_core/fe_search_core.dart';

Future<void> main() async {
  final rnd = Random(42);
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  const cyr = 'абвгдежзиклмнопрстуфхцчшэюя';
  String word(String alphabet, int n) => String.fromCharCodes(
    List.generate(n, (_) => alphabet.codeUnitAt(rnd.nextInt(alphabet.length))),
  );

  List<SearchTerm> synthetic(int entities) => [
    for (var i = 0; i < entities; i++) ...[
      SearchTerm(
        entityId: 'TEST-SYN-$i',
        category: SearchCategory.substance,
        term: word(letters, 6 + rnd.nextInt(8)),
        kind: TermKind.canonical,
        lang: 'en',
      ),
      SearchTerm(
        entityId: 'TEST-SYN-$i',
        category: SearchCategory.substance,
        term: word(cyr, 6 + rnd.nextInt(8)),
        kind: TermKind.localized,
        lang: 'ru',
      ),
      SearchTerm(
        entityId: 'TEST-SYN-$i',
        category: SearchCategory.substance,
        term: word(letters, 6 + rnd.nextInt(8)),
        kind: TermKind.localized,
        lang: 'uz',
      ),
    ],
  ];

  double median(List<int> xs) {
    final s = [...xs]..sort();
    return s[s.length ~/ 2] / 1000;
  }

  double p95(List<int> xs) {
    final s = [...xs]..sort();
    return s[(s.length * 0.95).floor().clamp(0, s.length - 1)] / 1000;
  }

  final tmp = Directory.systemTemp.createTempSync('fe_bench');
  stdout.writeln(
    'host: ${Platform.operatingSystem} '
    '${Platform.numberOfProcessors} CPU, Dart ${Platform.version.split(' ').first}',
  );

  for (final entities in [500, 5000]) {
    final terms = synthetic(entities);
    final file = File('${tmp.path}/content_$entities.db');

    // 1) Bo‘sh bazani yaratish (schema v2) va indekslash.
    var sw = Stopwatch()..start();
    var db = ContentDatabase(NativeDatabase(file));
    await db.integrityOk();
    final createMs = sw.elapsedMicroseconds / 1000;
    sw = Stopwatch()..start();
    await db.insertSearchTerms(terms);
    await db.rebuildSearchIndex();
    final indexMs = sw.elapsedMicroseconds / 1000;
    await db.close();

    // 2) Mavjud bazani ochish (ilova startup’dan keyin shunday ochadi).
    final opens = <int>[];
    for (var i = 0; i < 10; i++) {
      sw = Stopwatch()..start();
      db = ContentDatabase(NativeDatabase(file));
      await db.metaValue('pack_version');
      opens.add(sw.elapsedMicroseconds);
      await db.close();
    }

    // 3) FTS qidiruv (to‘g‘ri, xatoli, kirill, natijasiz).
    db = ContentDatabase(NativeDatabase(file));
    final fts = FtsSearchIndex(db);
    final queries = [
      terms[10].term,
      terms[11].term,
      terms[30].term.substring(0, 4),
      '${terms[60].term.substring(0, 3)}x${terms[60].term.substring(4)}',
      'zzzzqq',
    ];
    await fts.search(SearchQuery(queries.first)); // isitish
    final times = <int>[];
    for (var r = 0; r < 40; r++) {
      for (final q in queries) {
        sw = Stopwatch()..start();
        await fts.search(SearchQuery(q));
        times.add(sw.elapsedMicroseconds);
      }
    }
    await db.close();

    stdout.writeln(
      'entities=$entities terms=${terms.length} '
      'create_schema_ms=${createMs.toStringAsFixed(1)} '
      'index_ms=${indexMs.toStringAsFixed(1)} '
      'open_existing_median_ms=${median(opens).toStringAsFixed(2)} '
      'fts_search_median_ms=${median(times).toStringAsFixed(2)} '
      'fts_search_p95_ms=${p95(times).toStringAsFixed(2)} '
      '(n=${times.length})',
    );
  }
  tmp.deleteSync(recursive: true);
}
