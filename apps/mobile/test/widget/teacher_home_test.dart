import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/dna.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/home_desk_world.dart';

/// Ustoz bosh sahifasi «Ustoz minbari» (egasi qarori, 2026-11-04): banner,
/// tartib, «Ustoz stolim» marshrutlari (rol bor/yo‘q), hech bir funksiya
/// yo‘qolmagani, overflow yo‘qligi (uz/ru/en × 320/360/390 dp × 1x/2x ×
/// oq/qora tema) va pastki menyu oxirgi kartani yopmasligi.
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
    bool isTeacher = true,
  }) => pumpHome(
    t,
    mode: UserMode.teacher,
    lang: lang,
    size: size,
    textScale: textScale,
    theme: theme,
    catalog: catalog,
    extra: [
      dnaLoaderProvider.overrideWithValue(() async => dnaJson),
      classIsTeacherProvider.overrideWith((ref) async => isTeacher),
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
      maxScrolls: 120,
    );
    await t.pumpAndSettle();
  }

  group('ustoz bosh sahifasi: tuzilma', () {
    testWidgets('«USTOZ MINBARI» banneri, emblema va shior', (t) async {
      await open(t);
      expect(find.text('USTOZ MINBARI'), findsOneWidget);
      expect(find.text('Ta’lim • Tajriba • Mahorat'), findsOneWidget);
      expect(k('ustoz.banner'), findsOneWidget);
      expect(k('ustoz.emblem'), findsOneWidget);
      // Emblema chapda, matn o‘ngda.
      expect(
        t.getTopLeft(k('ustoz.emblem')).dx,
        lessThan(t.getTopLeft(find.text('USTOZ MINBARI')).dx),
      );
      expect(k('home.header'), findsOneWidget);
      // Qo‘ng‘iroqcha yo‘q.
      expect(find.byIcon(Icons.notifications_none), findsNothing);
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('bo‘limlar tartibi (yuqoridan pastga)', (t) async {
      await open(t);
      final order = [
        'ustoz.banner',
        'home.search',
        'desk.teacher',
        'desk.dailyQuestion',
        'home.core',
        'home.teacherLibrary',
        'home.guidelines',
        'home.module.substances',
        'home.courtPrep',
        'home.catalog',
        'home.new',
        'home.invite',
      ];
      var prev = -1.0;
      for (final key in order) {
        await reveal(t, key);
        // Hujjat koordinatasi: ro‘yxat siljiganini hisobga olmaslik uchun
        // har bir kalit alohida, kontent boshidan (scroll offset bilan).
        final sc = t.state<ScrollableState>(find.byType(Scrollable).first);
        final y = t.getTopLeft(k(key)).dy + sc.position.pixels;
        expect(y, greaterThan(prev), reason: key);
        prev = y;
      }
    });

    testWidgets('Kutubxona kartasi va «Barcha fanlar» takrorlanmaydi', (
      t,
    ) async {
      await open(t);
      await reveal(t, 'home.core');
      expect(find.text('Materiallar va manbalar'), findsOneWidget);
      expect(find.text('Sud tibbiyoti'), findsOneWidget);
      expect(find.text('Sud-kimyoviy ekspertiza'), findsOneWidget);
      await reveal(t, 'home.invite');
      expect(k('home.allDisciplines'), findsNothing);
    });

    testWidgets('«USTOZ MINBARI» Talaba va Mutaxassisda yo‘q', (t) async {
      for (final m in [UserMode.student, UserMode.professional]) {
        await pumpHome(t, mode: m, catalog: catalog);
        expect(find.text('USTOZ MINBARI'), findsNothing);
        expect(k('ustoz.banner'), findsNothing);
        expect(k('desk.teacher'), findsNothing);
      }
    });
  });

  group('ustoz bosh sahifasi: Ustoz stolim marshrutlari', () {
    for (final (key, expected) in [
      ('teachLessons', Routes.lessons),
      ('teachRun', Routes.classNew),
      ('teachOral', Routes.teacherOral),
      ('teachGroups', Routes.groups),
      ('teachResults', Routes.teacherResults),
    ]) {
      testWidgets('ustoz roli: $key → $expected', (t) async {
        final c = await open(t);
        await reveal(t, 'workbench.$key');
        await t.tap(k('workbench.$key'));
        await t.pumpAndSettle();
        expect(path(c), expected);
      });
    }

    for (final key in [
      'teachLessons',
      'teachRun',
      'teachOral',
      'teachResults',
    ]) {
      testWidgets('rolsiz (oldingi xulq): $key → Ustoz paneli', (t) async {
        final c = await open(t, isTeacher: false);
        await reveal(t, 'workbench.$key');
        await t.tap(k('workbench.$key'));
        await t.pumpAndSettle();
        expect(path(c), Routes.teacher);
      });
    }

    testWidgets('rolsiz: Guruhlar baribir guruhlar ekraniga', (t) async {
      final c = await open(t, isTeacher: false);
      await reveal(t, 'workbench.teachGroups');
      await t.tap(k('workbench.teachGroups'));
      await t.pumpAndSettle();
      expect(path(c), Routes.groups);
    });

    testWidgets('Bugungi savol: javob beriladi', (t) async {
      await open(t);
      await reveal(t, 'desk.dailyQuestion.option.0');
      expect(find.text('Bugungi savol'), findsOneWidget);
      await t.tap(k('desk.dailyQuestion.option.0'));
      await t.pumpAndSettle();
      expect(k('desk.dailyQuestion.feedback'), findsOneWidget);
    });
  });

  group('ustoz bosh sahifasi: mavjud funksiyalar saqlangan', () {
    testWidgets('barcha asosiy kartalar mavjud', (t) async {
      await open(t);
      for (final key in [
        'home.search',
        'desk.teacher',
        'home.core',
        'home.module.forensicMedicine',
        'home.module.toxicology',
        'home.teacherLibrary',
        'home.guidelines',
        'home.module.substances',
        'home.module.methods',
        'home.tools',
        'home.module.ai',
        'home.courtPrep',
        'home.catalog',
        'home.new.dna',
        'home.new.virtopsy',
        'home.new.equipment',
        'home.invite',
      ]) {
        await reveal(t, key);
        expect(k(key), findsOneWidget, reason: key);
      }
      expect(t.takeException(), isNull);
    });

    for (final (key, expected) in [
      ('home.teacherLibrary', Routes.library),
      ('home.guidelines', Routes.guidelines),
      ('home.tools', Routes.tools),
      ('home.module.ai', Routes.ai),
      ('home.courtPrep', Routes.courtPrep),
      ('home.catalog', Routes.catalog),
      ('home.invite', Routes.referral),
    ]) {
      testWidgets('$key → $expected', (t) async {
        final c = await open(t);
        await reveal(t, key);
        await t.tap(k(key));
        await t.pump(const Duration(milliseconds: 500));
        expect(path(c), expected);
      });
    }

    testWidgets('qidiruv ochiladi', (t) async {
      final c = await open(t);
      await t.tap(k('home.search'));
      await t.pump(const Duration(milliseconds: 500));
      expect(path(c), Routes.search);
    });
  });

  group('ustoz bosh sahifasi: ekranlar matritsasi', () {
    for (final lang in ['uz', 'ru', 'en']) {
      for (final w in [320.0, 360.0, 390.0]) {
        for (final scale in [1.0, 2.0]) {
          for (final theme in [ThemeMode.light, ThemeMode.dark]) {
            final name =
                '$lang ${w.toInt()} dp ×$scale ${theme.name}: overflow yo‘q, '
                'banner, oxirgi karta menyu ustida';
            testWidgets(name, (t) async {
              await open(
                t,
                lang: lang,
                size: Size(w, 700),
                textScale: scale,
                theme: theme,
              );
              final l = lookupAppLocalizations(Locale(lang));
              expect(find.text(l.teacherBannerTitle), findsOneWidget);
              expect(find.text(l.teacherBannerTagline), findsOneWidget);
              expect(t.takeException(), isNull);
              await reveal(t, 'home.invite');
              await t.drag(
                find.byType(Scrollable).first,
                const Offset(0, -3000),
              );
              await t.pumpAndSettle();
              expect(t.takeException(), isNull);
              final last = t.getBottomLeft(k('home.invite')).dy;
              final nav = t.getTopLeft(k('nav.ai')).dy;
              expect(last, lessThanOrEqualTo(nav + 8));
            });
          }
        }
      }
    }
  });
}
