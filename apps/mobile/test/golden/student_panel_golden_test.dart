import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/tts.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';

import '../helpers/pump_app.dart';
import '../helpers/tts_fakes.dart';

/// «Talaba paneli» (egasi so‘rovi, 2026-11-02): talaba HAQIQIY server
/// mavzulari bilan — ro‘yxat (fakultet tanlovi, raqam, «Ma’ruza/Amaliy»),
/// dars (ustoz eslatmalarisiz, «Tinglash» bilan) va fan sahifasi.
/// Namuna: `test/fixtures/lesson_*_sample.json` (server `lesson_get` talaba
/// javobi, 2026-11-02). Yangilash: `--update-goldens`.
void main() {
  Map<String, Map<String, Object?>> decks() {
    final out = <String, Map<String, Object?>>{};
    final rows = (jsonDecode(
      File('test/fixtures/lesson_list_sample.json').readAsStringSync(),
    ) as List).cast<Map<String, Object?>>();
    for (final r in rows) {
      final id = r['t']! as String;
      out[id] = {
        'ok': true,
        'topic_id': id,
        'title': r['n'],
        'course': r['c'],
        'deck_id': id,
        'source_lang': 'uz',
        'deck': {
          'topic': r['n'],
          'slides': [
            for (var i = 0; i < 38; i++) {'title': 'Slayd ${i + 1}'},
          ],
        },
      };
    }
    final real = jsonDecode(
      File('test/fixtures/lesson_deck_student_sample.json').readAsStringSync(),
    ) as Map<String, Object?>;
    out[real['topic_id']! as String] = real;
    return out;
  }

  Future<void> shot(
    WidgetTester t,
    String name,
    String location, {
    Size size = const Size(390, 1400),
    Future<void> Function(WidgetTester)? act,
  }) async {
    final backend = FakeClassQuizBackend();
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz', mode: UserMode.student),
      size: size,
      pixelRatio: 1.5,
      proEnabled: false,
      initialLocation: location,
      overrides: [
        classQuizServiceProvider.overrideWithValue(
          FakeClassQuizService(backend, userId: 's1', demo: false),
        ),
        lessonsServiceProvider.overrideWithValue(
          FakeLessonsService(isTeacher: false, demo: false, decks: decks()),
        ),
        ttsServiceProvider.overrideWithValue(FakeTtsService()),
        classLandscapePromptEnabledProvider.overrideWithValue(false),
      ],
    );
    await t.pumpAndSettle();
    if (act != null) await act(t);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('student_lessons_all_uz', (t) async {
    await shot(t, 'student_lessons_all_uz', Routes.lessons);
  });

  testWidgets('student_lessons_davolash_uz', (t) async {
    await shot(
      t,
      'student_lessons_davolash_uz',
      Routes.lessons,
      act: (t) async {
        // Tuzilma: Sud tibbiyoti → Davolash fakulteti → mavzular.
        await t.tap(find.byKey(const Key('lessons.subject.forensic')));
        await t.pumpAndSettle();
        await t.tap(
          find.byKey(const Key('lessons.faculty.Davolash ishi fakulteti')),
        );
        await t.pumpAndSettle();
        expect(find.text('Apparatlar bilan ishlash'), findsNothing);
      },
    );
  });

  testWidgets('student_lessons_forensic_uz', (t) async {
    await shot(
      t,
      'student_lessons_forensic_uz',
      Routes.lessons,
      act: (t) async {
        await t.tap(find.byKey(const Key('lessons.subject.forensic')));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('student_lesson_viewer_uz', (t) async {
    await shot(
      t,
      'student_lesson_viewer_uz',
      Routes.lesson('ktp26-davolash-M1'),
      size: const Size(390, 844),
    );
  });

  testWidgets('student_discipline_fm_uz', (t) async {
    await shot(
      t,
      'student_discipline_fm_uz',
      Routes.discipline('forensic_medicine'),
      size: const Size(390, 2400),
    );
  });
}
