import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/widgets/common.dart';
import 'package:forensic_expert/features/placeholder/presentation/in_development_view.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Real-device polish regressiyasi: ichki/dev so‘zlar foydalanuvchi UI’da
/// yo‘q; bo‘sh holatlar, AI preview, konsentratsiya ogohlantirishi,
/// ixcham holat belgilari va kalkulyator statuslari.
void main() {
  // Foydalanuvchi UI’da chiqmasligi kerak bo‘lgan ichki atamalar.
  final internal = RegExp(
    r'\bPHASE\b|\bpilot\b|curated|fixture|\bmock\b|placeholder|\bTODO\b|'
    r'test data|developer|\bseeded\b|migration|\bschema\b|\bdebug\b|'
    r'staging|заглушк|прототип|пилот|prototip|ishlab chiqilmoqda|'
    r'в разработке|\bphase\s*\d',
    caseSensitive: false,
  );
  // Faqat debug/test yig‘masida ko‘rinadigan kalitlar.
  const devOnlyKeys = {'accountTestBackend', 'aiLimMock'};

  group('ichki/dev atamalari', () {
    for (final code in ['en', 'ru', 'uz']) {
      test('app_$code.arb — foydalanuvchi matnlarida ichki atama yo‘q', () {
        final arb = jsonDecode(
          File('lib/core/l10n/arb/app_$code.arb').readAsStringSync(),
        ) as Map<String, Object?>;
        final offenders = <String>[];
        for (final e in arb.entries) {
          if (e.key.startsWith('@') || devOnlyKeys.contains(e.key)) continue;
          if (e.key.startsWith('diag')) continue; // faqat debug diagnostika
          final v = e.value;
          if (v is String && internal.hasMatch(v)) offenders.add(e.key);
        }
        expect(offenders, isEmpty, reason: offenders.join(', '));
      });
    }

    test('kontent paketi: UI ko‘rsatadigan maydonlarda ichki atama yo‘q', () {
      final b = jsonDecode(
        File('../../content/pilot/bundle.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final offenders = <String>[];
      for (final c in (b['claims']! as List).cast<Map<String, Object?>>()) {
        final ctx = (c['value'] as Map?)?['context_strict'] as Map?;
        for (final l in (ctx?['limitations'] as List? ?? const [])) {
          if (RegExp(r'PHASE|pilot covers|curated').hasMatch('$l')) {
            offenders.add('${c['claim_id']}');
          }
        }
      }
      for (final s in (b['sources']! as List).cast<Map<String, Object?>>()) {
        if (RegExp(r'PHASE \d|\.py\b').hasMatch('${s['notes'] ?? ''}')) {
          offenders.add('${s['source_id']}');
        }
      }
      expect(offenders, isEmpty, reason: offenders.take(5).join(', '));
    });
  });

  group('ekranlar (haqiqiy pilot paket)', () {
    late PilotContent pilot;
    setUpAll(() async => pilot = await loadPilotContent());

    Future<void> open(
      WidgetTester tester,
      String location, {
      String lang = 'en',
      FakeStore? store,
    }) => pumpApp(
      tester,
      settings: completedSettings(lang: lang),
      initialLocation: location,
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(
          store ?? FakeStore(owned: true),
        ),
      ],
    );

    Future<void> see(WidgetTester tester, Finder f) async {
      await tester.scrollUntilVisible(
        f.first,
        300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.pumpAndSettle();
    }

    List<String> visibleTexts(WidgetTester tester) => [
      for (final w in tester.widgetList<Text>(find.byType(Text)))
        w.data ?? w.textSpan?.toPlainText() ?? '',
    ];

    for (final lang in ['en', 'ru', 'uz']) {
      for (final route in [
        Routes.home,
        Routes.library,
        Routes.librarySection('substances'),
        Routes.librarySection('references'),
        Routes.specimen('serum-plasma'),
        Routes.tools,
        Routes.ai,
        Routes.profile,
        Routes.purchase,
        Routes.libraryEntry('brodifacoum'),
      ]) {
        testWidgets('$lang $route — ichki atama ko‘rinmaydi', (tester) async {
          await open(tester, route, lang: lang);
          final s = find.byType(Scrollable).hitTestable();
          for (var i = 0; i < 6 && s.evaluate().isNotEmpty; i++) {
            final bad = visibleTexts(tester).where(internal.hasMatch).toList();
            expect(bad, isEmpty, reason: bad.join(' | '));
            await tester.drag(s.first, const Offset(0, -500));
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('namuna sahifasi: har bir konsentratsiyada universal chegara '
        'emasligi va metadata qatorlari; yo‘q ma’lumot to‘qilmaydi', (
      tester,
    ) async {
      await open(tester, Routes.specimen('serum-plasma'), lang: 'uz');
      const id = 'C-BRODIFACOUM-REPORTED_CONCENTRATION-P5';
      await see(tester, find.byKey(const Key('claim.context.$id')));
      final card = find.byKey(const Key('claim.context.$id'));
      expect(
        find.descendant(
          of: card,
          matching: find.byKey(const Key('claim.concWarning.$id')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.textContaining('Universal toksik'),
        ),
        findsOneWidget,
      );
      for (final label in [
        'Modda',
        'Qiymat va birlik',
        'Namuna',
        'Tirik / o‘limdan keyin',
        'Manba turi',
        'Holat / tadqiqot konteksti',
        'Dalil darajasi',
        'Tekshiruv holati',
        'Manba',
      ]) {
        expect(
          find.descendant(of: card, matching: find.text(label)),
          findsOneWidget,
          reason: label,
        );
      }
      // Kuratsiya qilinmagan kontekst — «Ma’lumot mavjud emas», taxmin yo‘q.
      expect(
        find.descendant(of: card, matching: find.text('Ma’lumot mavjud emas')),
        findsWidgets,
      );
      expect(
        find.descendant(of: card, matching: find.text('Holat tavsifi')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('claim.contextUnavailable.$id')),
        findsOneWidget,
      );
    });

    testWidgets('AI: ulanmagan holat yuqorida, yuborish o‘chiq, namuna '
        'NAMOYISH deb belgilangan; oflayn qidiruv ishlaydi', (tester) async {
      await open(tester, Routes.ai);
      expect(find.byKey(const Key('ai.previewState')), findsOneWidget);
      expect(find.text('Preview · not connected'), findsOneWidget);
      final send = find.byKey(const Key('ai.send'));
      expect(tester.widget<ButtonStyleButton>(send).onPressed, isNull);
      expect(find.byKey(const Key('ai.sendUnavailable')), findsOneWidget);
      await see(tester, find.byKey(const Key('ai.demoLabel')));
      expect(find.textContaining('DEMONSTRATION'), findsWidgets);
      await tester.enterText(find.byKey(const Key('ai.input')), 'morphine');
      await tester.pumpAndSettle();
      final find0 = find.byKey(const Key('ai.findSources'));
      expect(tester.widget<ButtonStyleButton>(find0).onPressed, isNotNull);
    });

    testWidgets('kutubxona: ixcham holat belgisi, nom → guruh → holat', (
      tester,
    ) async {
      await open(tester, Routes.librarySection('substances'));
      expect(find.byKey(const Key('status.compact.needsReview')), findsWidgets);
      // Ro‘yxatda katta (to‘liq) holat belgisi yo‘q.
      final full = tester
          .widgetList<ReviewStatusBadge>(find.byType(ReviewStatusBadge))
          .where((b) => !b.compact);
      expect(full, isEmpty);
    });

    testWidgets('kalkulyator: modul / formula manbasi / talqin alohida', (
      tester,
    ) async {
      await open(tester, Routes.tool('tool.lab.dilution'));
      await see(tester, find.byKey(const Key('calc.statusPanel')));
      expect(find.byKey(const Key('calc.status.engine')), findsOneWidget);
      expect(find.byKey(const Key('calc.status.reference')), findsOneWidget);
      expect(
        find.byKey(const Key('calc.status.interpretation')),
        findsOneWidget,
      );
      expect(
        find.textContaining('this is not a scientific review'),
        findsOneWidget,
      );
      final ref = tester.widget<ReviewStatusBadge>(
        find.byKey(const Key('calc.status.reference')),
      );
      expect(ref.status, ScientificStatus.needsReview);
    });

    testWidgets('kalkulyator plitkasi: «modul sinovdan o‘tgan» va formula '
        'holati alohida', (tester) async {
      await open(tester, Routes.tools);
      expect(
        find.byKey(const Key('tool.engineTested.tool.lab.dilution')),
        findsOneWidget,
      );
    });

    testWidgets('bo‘sh holat: tugallangan ko‘rinish va amallar', (
      tester,
    ) async {
      await open(tester, Routes.librarySection('references'), lang: 'uz');
      expect(find.byType(AvailabilityStateView), findsOneWidget);
      expect(find.text('Qidirish'), findsWidgets);
      expect(find.text('Barcha yozuvlarni ko‘rish'), findsOneWidget);
      expect(find.textContaining('Ishlab chiqilmoqda'), findsNothing);
    });
  });

  testWidgets('profil: akkaunt xizmati ulanmaganda ishlamaydigan kirish '
      'tugmalari yo‘q', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile.accountNotConnected')),
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.byKey(const Key('profile.signIn')), findsNothing);
    expect(find.byKey(const Key('profile.register')), findsNothing);
  });
}
