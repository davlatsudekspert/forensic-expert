import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/programs.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/programs/program_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

/// «Toksikologik kimyo» ixtisoslashtirish kursi (egasi, 2026-11-05): 62 mavzu,
/// asl tartib, haqiqiy holatlar, uch rolda kirish, davomiylik yo‘qligi.
void main() {
  Finder k(String key) => find.byKey(Key(key));

  Program load() => Program.fromJson(
    (jsonDecode(File(toxChemProgramAsset).readAsStringSync()) as Map)
        .cast<String, Object?>(),
  );

  group('katalog (JSON)', () {
    test('62 asosiy mavzu asl tartibda + 2 ta yangi (ma’ruza rejasidan)', () {
      final p = load();
      expect(p.topics.length, 64);
      expect(
        [for (final t in p.topics) t.number],
        [for (var i = 1; i <= 64; i++) i],
      );
      expect({for (final t in p.topics) t.id}.length, 64);
      expect(p.module, 'Modul: Toksikologik kimyo');
      expect(p.groupIds, ['g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7']);
      // Har mavzu bitta guruhda: guruhlar yig‘indisi 64.
      expect(p.groupIds.fold<int>(0, (a, g) => a + p.inGroup(g).length), 64);
    });

    test('holatlar haqiqiy: mavjud 2, qisman 43, tayyorlanmoqda 19', () {
      final p = load();
      expect(p.count(ProgramTopicStatus.available), 2);
      expect(p.count(ProgramTopicStatus.partial), 43);
      expect(p.count(ProgramTopicStatus.preparing), 19);
      // Havolasi yo‘q mavzu — albatta «tayyorlanmoqda»; havolasi bor — yo‘q.
      for (final t in p.topics) {
        expect(
          t.links.isEmpty,
          t.status == ProgramTopicStatus.preparing,
          reason: t.id,
        );
      }
    });

    test('birinchi va oxirgi mavzu asl hujjatdagidek', () {
      final p = load();
      expect(
        p.topics.first.title,
        startsWith('O‘zbekiston Respublikasi Sog‘liqni saqlash vazirligi'),
      );
      expect(
        p.topics[61].title,
        'Alohida usullar yordamida tahlil qilinadigan moddalar',
      );
    });

    test(
      'interfeys matnlarida kurs davomiyligi (oy, hafta, soat, sana) yo‘q',
      () {
        final bad = RegExp(
          r'davomiy|hafta|\bsoat|\boy\b|oylik|duration|week|month|hours?\b|'
          r'длительн|недел|месяц|\bчас',
          caseSensitive: false,
        );
        for (final lang in ['uz', 'ru', 'en']) {
          final arb = (jsonDecode(
            File('lib/core/l10n/arb/app_$lang.arb').readAsStringSync(),
          ) as Map).cast<String, Object?>();
          for (final e in arb.entries) {
            if (e.key.startsWith('prog') && e.value is String) {
              expect(
                bad.hasMatch(e.value! as String),
                isFalse,
                reason: '$lang ${e.key}',
              );
            }
          }
        }
      },
    );
  });

  group('ekranlar', () {
    Future<void> open(
      WidgetTester t,
      String route, {
      UserMode mode = UserMode.professional,
      String lang = 'uz',
      Size size = const Size(390, 2800),
    }) async {
      final c = await pumpApp(
        t,
        settings: completedSettings(lang: lang, mode: mode),
        size: size,
        // Katalogni fayldan to‘g‘ridan-to‘g‘ri o‘qiydi (rootBundle keshiga
        // bog‘liq emas).
        overrides: [
          programLoaderProvider.overrideWithValue(
            () async => File(toxChemProgramAsset).readAsStringSync(),
          ),
        ],
      );
      c.read(routerProvider).go(route);
      await t.pumpAndSettle();
    }

    testWidgets('kurs sahifasi: 64 ta mavzu, xulosa, davomiylik yo‘q', (
      t,
    ) async {
      await open(t, Routes.program(toxChemProgramId));
      expect(find.text('Toksikologik kimyo'), findsWidgets);
      expect(k('program.count'), findsOneWidget);
      expect(find.text('64 ta mavzu'), findsOneWidget);
      expect(
        find.text('Mavjud: 2 · Qisman: 43 · Tayyorlanmoqda: 19'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          RegExp(r'hafta|davomiy|soat', caseSensitive: false),
        ),
        findsNothing,
      );
      expect(k('program.tests'), findsOneWidget); // faqat Mutaxassisga
    });

    testWidgets('qidiruv va dastur tartibi; mavjud mavzu havolalar ochadi', (
      t,
    ) async {
      await open(t, Routes.program(toxChemProgramId));
      await t.enterText(k('program.search'), 'ultrabinafsha');
      await t.pumpAndSettle();
      expect(k('program.topic.tk-20'), findsOneWidget);
      expect(k('program.topic.tk-01'), findsNothing);
      await t.tap(k('program.topic.tk-20'));
      await t.pumpAndSettle();
      expect(k('program.sheet'), findsOneWidget);
    });

    testWidgets('qidiruv: mavzu topilmasa xabar chiqadi', (t) async {
      await open(t, Routes.program(toxChemProgramId));
      await t.enterText(k('program.search'), 'yo‘q-bunaqa-mavzu');
      await t.pumpAndSettle();
      expect(k('program.empty'), findsOneWidget);
    });

    testWidgets('mavjud bo‘lmagan mavzu: «Tayyorlanmoqda», bosilmaydi', (
      t,
    ) async {
      await open(t, Routes.program(toxChemProgramId));
      await t.enterText(k('program.search'), 'Soch namunalarida');
      await t.pumpAndSettle();
      expect(k('program.topic.tk-48'), findsOneWidget);
      expect(find.text('Tayyorlanmoqda'), findsOneWidget);
    });

    testWidgets('ru: interfeys rus tilida, mavzu nomlari asl dasturda (uz)', (
      t,
    ) async {
      await open(t, Routes.program(toxChemProgramId), lang: 'ru');
      expect(find.text('Токсикологическая химия'), findsWidgets);
      expect(k('program.uzOnly'), findsOneWidget);
    });

    testWidgets('en: interfeys inglizcha', (t) async {
      await open(t, Routes.program(toxChemProgramId), lang: 'en');
      expect(find.text('Toxicological chemistry'), findsWidgets);
      expect(k('program.uzOnly'), findsOneWidget);
    });

    for (final w in [320.0, 360.0, 390.0]) {
      testWidgets('kurs sahifasi ${w.toInt()} dp: overflow yo‘q', (t) async {
        await open(t, Routes.program(toxChemProgramId), size: Size(w, 844));
        expect(t.takeException(), isNull);
        await t.drag(k('program.list'), const Offset(0, -3000));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      });
    }

    for (final m in [UserMode.student, UserMode.teacher]) {
      testWidgets('${m.name}: «O‘quv dasturlari» → kurs', (t) async {
        await open(t, Routes.home, mode: m);
        await t.tap(k('home.programs'));
        await t.pumpAndSettle();
        expect(k('programs.toxChem'), findsOneWidget);
        await t.tap(k('programs.toxChem'));
        await t.pumpAndSettle();
        expect(k('program.count'), findsOneWidget);
      });
    }

    testWidgets('Mutaxassis: Ekspertiza yo‘nalishlari → Sud-kimyoviy → '
        'Kasbiy tayyorgarlik → Toksikologik kimyo', (t) async {
      await open(t, Routes.home);
      await t.tap(k('home.areas'));
      await t.pumpAndSettle();
      expect(k('areas.chemistry'), findsOneWidget);
      // Materiali yo‘q yo‘nalish — «Tayyorlanmoqda».
      expect(find.text('Tayyorlanmoqda'), findsWidgets);
      await t.tap(k('areas.chemistry'));
      await t.pumpAndSettle();
      await t.tap(k('moduleHub.program.toxChem'));
      await t.pumpAndSettle();
      expect(k('program.count'), findsOneWidget);
    });

    testWidgets('Mutaxassis Asosiy: baholash kartasi yagona; kursga alohida '
        'katta karta yo‘q', (t) async {
      await open(t, Routes.home);
      expect(k('home.assessment'), findsOneWidget);
      expect(k('home.programs'), findsNothing);
      expect(k('home.new'), findsNothing);
      expect(k('home.catalog'), findsOneWidget);
    });

    testWidgets('Usullar va apparatlar: mavjud sahifalarga havolalar', (
      t,
    ) async {
      await open(t, Routes.methodsDevices);
      for (final id in [
        'md.methods',
        'md.reagents',
        'md.spectro',
        'md.ms',
        'md.equipment',
        'md.virtopsy',
      ]) {
        expect(k(id), findsOneWidget, reason: id);
      }
    });
  });

  testWidgets('Ish stoli ko‘rinishi saqlanadi (keyingi kirishda tiklanadi)', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues({'fe.workbench.view': 'chemistry'});
    final c = await pumpApp(
      t,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
    );
    c.read(routerProvider).go(Routes.home);
    await t.pumpAndSettle();
    expect(k('workbench.chemistry'), findsOneWidget);
  });
}
