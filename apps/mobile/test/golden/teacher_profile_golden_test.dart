import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/teacher_card.dart';
import 'package:forensic_expert/data/teacher_card/fake_teacher_card_service.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/teacher_card/teacher_card.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

/// Ustoz profili boshi: rasm, ism, ish joyi, toifa, «Ustoz Pro» belgisi,
/// qisqa ma’lumot, tarmoqlar (egasi so‘rovi, 2026-11-02).
/// Yangilash: `flutter test test/golden/teacher_profile_golden_test.dart
/// --update-goldens`
void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);

  testWidgets('teacher_profile_header_uz', (tester) async {
    final w = GroupsWorld();
    final backend = FakeTeacherCardBackend(
      isTeacher: (u) => u == 'teacher',
      teacherOf: w.backend.teacherIdFor,
    );
    backend.cards['teacher'] = const TeacherCard(
      teacherId: 'teacher',
      displayName: 'Qutbiddin Siddiqov',
      workplace: 'Toshkent tibbiyot akademiyasi, sud tibbiyoti kafedrasi',
      category: TeacherCategory.higher,
      bio:
          'Sud-tibbiy ekspert, dotsent. Talabalarga sud tibbiyoti va '
          'toksikologiyadan dars beraman.',
      socials: {
        TeacherSocial.telegram: 'https://t.me/sudtibbiyot',
        TeacherSocial.instagram: 'https://instagram.com/sudtibbiyot',
        TeacherSocial.youtube: 'https://youtube.com/@sudtibbiyot',
      },
      visible: true,
    );
    final ProviderContainer _ = await w.open(
      tester,
      uid: 'teacher',
      location: Routes.profile,
      size: const Size(390, 1000),
      extra: [
        teacherCardServiceProvider.overrideWith(
          (ref) => FakeTeacherCardService(backend, userIdOf: () => 'teacher'),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile.teacherHeader')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/teacher_profile_header_uz.png'),
    );
  });
}
