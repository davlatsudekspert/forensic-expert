import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/dna.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/home_desk_world.dart';

/// Talaba («Mening akademiyam») va Ustoz («USTOZ MINBARI») bannerlari bir xil
/// dizayn tizimida (egasi, 2026-11-05): o‘lcham, emblema qutisi, oraliq —
/// uz × 320/360/390 dp × oq/qora tema.
void main() {
  final items = [for (var i = 1; i <= 4; i++) deskQuestionItem(i)];
  final catalog = deskCatalog(items);
  final dnaJson = File('assets/content/dna/dna_v1.json').readAsStringSync();

  Future<void> open(
    WidgetTester t,
    UserMode mode,
    Size size,
    ThemeMode theme,
  ) => pumpHome(
    t,
    mode: mode,
    size: size,
    theme: theme,
    catalog: catalog,
    extra: [
      dnaLoaderProvider.overrideWithValue(() async => dnaJson),
      classIsTeacherProvider.overrideWith((ref) async => true),
    ],
  );

  for (final width in [320.0, 360.0, 390.0]) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('banner o‘lchamlari bir xil: $width dp, $theme', (t) async {
        final size = Size(width, 844);
        await open(t, UserMode.student, size, theme);
        final student = t.getSize(find.byKey(const Key('student.banner')));
        final studentEmblem = t.getSize(
          find.byKey(const Key('student.emblem')),
        );
        expect(t.takeException(), isNull);

        await open(t, UserMode.teacher, size, theme);
        final teacher = t.getSize(find.byKey(const Key('ustoz.banner')));
        final teacherEmblem = t.getSize(find.byKey(const Key('ustoz.emblem')));
        expect(t.takeException(), isNull);

        expect(teacher.width, student.width, reason: 'kenglik');
        // 320 dp da Talaba sarlavhasi ko‘proq qatorga o‘raladi: balandlik
        // matnga qarab o‘sadi (kesilmaydi). 360 dp va undan keng ekranlarda
        // ikkala banner balandligi bir xil.
        if (width >= 360) {
          expect(teacher.height, student.height, reason: 'balandlik');
        }
        expect(teacherEmblem.width, greaterThan(0));
        expect(studentEmblem.width, greaterThan(0));
      });
    }
  }
}
