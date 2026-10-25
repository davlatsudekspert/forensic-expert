@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/plan_fakes.dart';
import '../helpers/pump_app.dart';

/// «Bosib chiqish» tekshiruvi: har rejimda Asosiydan boshlab har bir bosiladigan
/// elementni bosadi (chuqurlik 2), ochilgan sahifa sarlavhasi va xatolarni
/// `CRAWL_OUT` fayliga yozadi. Maqsad — «bosilgan joy ≠ ochilgan sahifa»,
/// toshib ketish va xatolarni topish.
/// Ishga tushirish: CRAWL_OUT=/tmp/crawl.tsv flutter test --tags screenshots \
///   --run-skipped test/screenshots/crawl_test.dart
void main() {
  final out = Platform.environment['CRAWL_OUT'] ?? '/tmp/crawl.tsv';
  final rows = <String>[];
  tearDownAll(() => File(out).writeAsStringSync(rows.join('\n')));

  String titleOf(WidgetTester t) {
    final bars = find.byType(AppBar);
    if (bars.evaluate().isNotEmpty) {
      final texts = find.descendant(of: bars.last, matching: find.byType(Text));
      if (texts.evaluate().isNotEmpty) {
        return (t.widget<Text>(texts.first).data ?? '').replaceAll('\n', ' ');
      }
    }
    return '(sarlavhasiz)';
  }

  String labelOf(WidgetTester t, Finder f) {
    final texts = find.descendant(of: f, matching: find.byType(Text));
    for (final e in texts.evaluate()) {
      final d = (e.widget as Text).data;
      if (d != null && d.trim().isNotEmpty) return d.replaceAll('\n', ' ');
    }
    final tip = f.evaluate().isEmpty ? null : f.evaluate().first.widget;
    if (tip is IconButton) return 'ikonka:${tip.tooltip ?? '?'}';
    return '(matnsiz)';
  }

  final tappable = find.byWidgetPredicate(
    (w) =>
        w is InkWell ||
        w is ListTile ||
        w is IconButton ||
        w is FilledButton ||
        w is OutlinedButton ||
        w is TextButton,
    description: 'tappable',
  );

  for (final mode in UserMode.values) {
    testWidgets('crawl ${mode.name}', (tester) async {
      final decks = {for (final e in sampleLessonDecks.entries) e.key: e.value};
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: mode),
        overrides: [
          classQuizServiceProvider.overrideWithValue(
            FakeClassQuizService(
              FakeClassQuizBackend(teachers: {'t1'}),
              userId: 't1',
              demo: false,
            ),
          ),
          lessonsServiceProvider.overrideWithValue(
            FakeLessonsService(demo: false, decks: decks),
          ),
          ...planOverrides(Plan.premium),
        ],
      );
      final router = c.read(routerProvider);

      Future<void> openTrail(List<int> trail) async {
        router.go('/home');
        await tester.pumpAndSettle();
        for (final idx in trail) {
          final all = tappable.evaluate().toList();
          if (idx >= all.length) return;
          final f = find.byWidget(all[idx].widget);
          if (f.evaluate().isEmpty) return;
          await tester.ensureVisible(f.first);
          await tester.tap(f.first, warnIfMissed: false);
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          tester.takeException();
        }
      }

      Future<void> visit(List<int> trail, String path, int depth) async {
        await openTrail(trail);
        final startTitle = titleOf(tester);
        final n = tappable.evaluate().length;
        final limit = n > (depth == 0 ? 45 : 22) ? (depth == 0 ? 45 : 22) : n;
        for (var i = 0; i < limit; i++) {
          if (i > 0) await openTrail(trail);
          final all = tappable.evaluate().toList();
          if (i >= all.length) break;
          final f = find.byWidget(all[i].widget);
          if (f.evaluate().isEmpty) continue;
          final label = labelOf(tester, f);
          try {
            await tester.ensureVisible(f.first);
            await tester.tap(f.first, warnIfMissed: false);
            await tester.pumpAndSettle(const Duration(milliseconds: 100));
          } on Object catch (e) {
            rows.add('${mode.name}\tERR\t$path\t[$label]\t$e');
            continue;
          }
          final ex = tester.takeException();
          final dest = titleOf(tester);
          final changed = dest != startTitle;
          rows.add(
            '${mode.name}\t${ex == null ? 'ok' : 'EXC'}\t$path\t[$label]'
            '\t-> $dest${changed ? '' : ' (o‘zgarmadi)'}'
            '${ex == null ? '' : '\t$ex'}',
          );
          if (changed && depth < 1 && ex == null) {
            await visit([...trail, i], '$path > $label', depth + 1);
            await openTrail(trail);
          }
        }
      }

      await visit([], mode.name, 0);
    }, timeout: const Timeout(Duration(minutes: 20)));
  }
}
