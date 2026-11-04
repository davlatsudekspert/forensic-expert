import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/dna.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/home_desk_world.dart';

/// Talaba bosh sahifasi «Mening akademiyam» (egasi qarori, 2026-11-04):
/// tartib, marshrutlar, overflow yo‘qligi (uz/ru/en × 320/360/390 dp ×
/// 1x/2x × oq/qora tema) va pastki menyu oxirgi kartani yopmasligi.
void main() {
  Finder k(String key) => find.byKey(Key(key));

  final items = [for (var i = 1; i <= 4; i++) deskQuestionItem(i)];
  final catalog = deskCatalog(items);
  final dnaJson = File('assets/content/dna/dna_v1.json').readAsStringSync();

  Future<ProviderContainer> open(
    WidgetTester t, {
    String lang = 'uz',
    Size size = const Size(390, 844),
    double textScale = 1,
    ThemeMode theme = ThemeMode.light,
    bool withDna = true,
  }) => pumpHome(
    t,
    mode: UserMode.student,
    lang: lang,
    size: size,
    textScale: textScale,
    theme: theme,
    catalog: catalog,
    extra: [
      if (withDna) dnaLoaderProvider.overrideWithValue(() async => dnaJson),
    ],
  );

  String path(ProviderContainer c) => c
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .last
      .matchedLocation;

  Future<void> reveal(WidgetTester t, String key) async {
    await t.scrollUntilVisible(
      k(key),
      200,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 80,
    );
    await t.pumpAndSettle();
  }

  group('talaba bosh sahifasi: tuzilma', () {
    testWidgets('sarlavha, banner, tartib va «Asosiy fanlar» yo‘q', (t) async {
      await open(t);
      expect(find.text('Mening akademiyam'), findsOneWidget);
      expect(find.text('Bugun nimani o‘rganamiz?'), findsOneWidget);
      expect(find.text('Asosiy fanlar'), findsNothing);
      expect(k('home.core'), findsNothing);
      expect(k('home.header'), findsOneWidget);
      // Qo‘ng‘iroqcha yo‘q.
      expect(find.byIcon(Icons.notifications_none), findsNothing);
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
      // Tartib (yuqoridan pastga).
      double y(String key) => t.getTopLeft(k(key)).dy;
      expect(y('desk.student'), lessThan(y('home.search')));
      expect(y('home.search'), lessThan(y('desk.dailyQuestion')));
      expect(y('desk.dailyQuestion'), lessThan(y('workbench.deskLessons')));
      expect(y('workbench.deskLessons'), lessThan(y('workbench.deskExam')));
      expect(y('workbench.deskExam'), lessThan(y('learn.classQuiz')));
      expect(find.text('O‘quv mashg‘ulotlari'), findsOneWidget);
      // Talabada bittadan: eski takror (stol ichidagi Asbob/DNK) yo‘q.
      expect(k('desk.equipment'), findsNothing);
      expect(k('desk.dna'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('«Mening akademiyam» faqat talabada', (t) async {
      await pumpHome(t, mode: UserMode.professional, catalog: catalog);
      expect(find.text('Mening akademiyam'), findsNothing);
      expect(k('desk.student'), findsNothing);
      await pumpHome(t, mode: UserMode.teacher, catalog: catalog);
      expect(find.text('Mening akademiyam'), findsNothing);
    });

    testWidgets('4 ta o‘quv kartasi teng balandlikda', (t) async {
      await open(t);
      final h = [
        for (final id in ['deskLessons', 'deskTests', 'deskExam', 'deskGroup'])
          t.getSize(k('workbench.$id')).height,
      ];
      expect(h[0], h[1]);
      expect(h[2], h[3]);
      // 2×2: birinchi qatorda yonma-yon.
      expect(
        t.getTopLeft(k('workbench.deskLessons')).dy,
        t.getTopLeft(k('workbench.deskTests')).dy,
      );
    });

    for (final (key, expected) in [
      ('deskLessons', '/home/teacher/lessons'),
      ('deskTests', '/home/learn/study'),
      ('deskExam', '/home/learn/exam'),
      ('deskGroup', '/home/learn/groups'),
    ]) {
      testWidgets('o‘quv kartasi $key marshrutga olib boradi', (t) async {
        final c = await open(t);
        await reveal(t, 'workbench.$key');
        await t.tap(k('workbench.$key'));
        await t.pumpAndSettle();
        expect(path(c), expected);
      });
    }

    testWidgets('Guruh testi (jonli) ochiladi', (t) async {
      final c = await open(t);
      await reveal(t, 'learn.classQuiz');
      expect(find.text('Guruh testi (jonli)'), findsOneWidget);
      await t.tap(k('learn.classQuiz'));
      await t.pumpAndSettle();
      expect(path(c), '/home/learn/class');
    });

    testWidgets('Bugungi savol: javob beriladi, strelka mashqqa o‘tadi', (
      t,
    ) async {
      final c = await open(t);
      expect(find.text('Bugungi savol'), findsOneWidget);
      await t.tap(k('desk.dailyQuestion.option.0'));
      await t.pumpAndSettle();
      expect(k('desk.dailyQuestion.feedback'), findsOneWidget);
      await t.tap(k('student.dailyQuestion.open'));
      await t.pumpAndSettle();
      expect(path(c), contains('/quiz'));
    });

    testWidgets(
      'ilmiy kartalar gorizontal aylanadi va marshrutga olib boradi',
      (t) async {
        final c = await open(t, size: const Size(360, 780));
        await reveal(t, 'home.new');
        final scroll = k('student.science.scroll');
        final sv = t.widget<SingleChildScrollView>(scroll);
        expect(sv.scrollDirection, Axis.horizontal);
        expect(k('home.new.dna'), findsOneWidget);
        expect(k('home.new.virtopsy'), findsOneWidget);
        // Uchala karta bir xil balandlikda; rasm kesilmaydi (contain).
        final hs = [
          for (final id in ['dna', 'virtopsy', 'equipment'])
            t.getSize(k('home.new.$id')).height,
        ];
        expect(hs[0], hs[1]);
        expect(hs[1], hs[2]);
        // Uchinchi karta dastlab ekran chetida/tashqarida; aylantirilgach ko‘rinadi.
        await t.drag(scroll, const Offset(-300, 0));
        await t.pumpAndSettle();
        final eq = t.getTopRight(k('home.new.equipment')).dx;
        expect(eq, lessThanOrEqualTo(360));
        await t.tap(k('home.new.equipment'));
        await t.pumpAndSettle();
        expect(path(c), '/home/equipment');
      },
    );

    testWidgets('DNK kartasi: paket bo‘lmasa yo‘q, qolgan ikkitasi bor', (
      t,
    ) async {
      await open(t, withDna: false);
      await reveal(t, 'home.new');
      expect(k('home.new.dna'), findsNothing);
      expect(k('home.new.virtopsy'), findsOneWidget);
      expect(k('home.new.equipment'), findsOneWidget);
    });

    testWidgets('Virtual autopsiya va Ustozlar kartasi marshrutlari', (
      t,
    ) async {
      final c = await open(t);
      await reveal(t, 'home.new.virtopsy');
      await t.tap(k('home.new.virtopsy'));
      // Ochiladigan ekran yuklanish animatsiyasi — settle kutilmaydi.
      await t.pump(const Duration(milliseconds: 400));
      expect(path(c), '/home/equipment/item/virtopsy');
    });

    testWidgets('Ustozlar va mutaxassislar kartasi ochiladi', (t) async {
      final c = await open(t);
      await reveal(t, 'home.catalog');
      await t.tap(k('home.catalog'));
      await t.pump(const Duration(milliseconds: 400));
      expect(path(c), '/home/catalog');
    });
  });

  group('talaba bosh sahifasi: ekranlar matritsasi', () {
    for (final lang in ['uz', 'ru', 'en']) {
      for (final w in [320.0, 360.0, 390.0]) {
        for (final scale in [1.0, 2.0]) {
          for (final theme in [ThemeMode.light, ThemeMode.dark]) {
            final name =
                '$lang ${w.toInt()} dp ×$scale ${theme.name}: overflow yo‘q, '
                'oxirgi karta menyu ustida';
            testWidgets(name, (t) async {
              await open(
                t,
                lang: lang,
                size: Size(w, 700),
                textScale: scale,
                theme: theme,
              );
              final l = lookupAppLocalizations(Locale(lang));
              expect(find.text(l.studentDeskTitle), findsOneWidget);
              expect(find.text(l.homeCoreTitle), findsNothing);
              // Eng pastgacha aylantiriladi (barcha bo‘limlar quriladi).
              await reveal(t, 'home.allDisciplines');
              await t.drag(
                find.byType(Scrollable).first,
                const Offset(0, -2000),
              );
              await t.pumpAndSettle();
              expect(t.takeException(), isNull);
              // Pastki menyu oxirgi kartani yopmaydi.
              final last = t.getBottomLeft(k('home.allDisciplines')).dy;
              final nav = t.getTopLeft(k('nav.ai')).dy;
              expect(last, lessThanOrEqualTo(nav + 8));
            });
          }
        }
      }
    }
  });
}
