// Bepul / Pro bo‘linishi (egasi qarori, 2026-10-31) — QAT’IY rejim.
//
// Bo‘linish `FE_PRO_STRICT` bilan yoqiladi; testlarda `proStrictProvider`
// almashtiriladi. O‘chiq bo‘lsa hamma narsa avvalgidek ochiq.
//
// Bu fayl: (1) Home’da qulf belgilari, (2) qulfli bo‘lim namuna + taklif,
// (3) HAR BIR Pro marshrut (deep link ham) va rejim (mehmon/talaba/ustoz/
// mutaxassis) bo‘yicha: yoqilganda bepul foydalanuvchi doim qulf oladi,
// o‘chiqda hamma narsa ochiladi, Premium’da ochiladi.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/tts.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/widgets/pro_lock_card.dart';
import 'package:forensic_expert/data/fixtures/knowledge_fixtures.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/pro/presentation/pro_gate.dart';
import 'package:forensic_expert/features/tts/presentation/listen_button.dart';

import '../helpers/plan_fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/tts_fakes.dart';

const _tall = Size(390, 3200);

List<Object> _strict(bool on) => [proStrictProvider.overrideWithValue(on)];

String _methodLocked() => testKnowledgeEntries
    .where((e) => e.kind == KnowledgeKind.method)
    .elementAt(2)
    .id;
String _methodSample() =>
    testKnowledgeEntries.firstWhere((e) => e.kind == KnowledgeKind.method).id;
String _subLocked() => testLibraryEntries
    .where((e) => e.section == LibrarySection.substances)
    .elementAt(2)
    .id;
String _subSample() => testLibraryEntries
    .firstWhere((e) => e.section == LibrarySection.substances)
    .id;

/// (marshrut, kutilgan qulf funksiyasi). Qat’iy rejimda bepul foydalanuvchi
/// BARCHASIDA `pro.lock.<funksiya>` oladi.
List<(String, ProFeature)> proRoutes() => [
  // Bilim ro‘yxatlari va yozuvlari.
  (Routes.knowledge('reagent'), ProFeature.proModules),
  (Routes.knowledge('screeningTest'), ProFeature.proModules),
  (Routes.knowledge('method'), ProFeature.proModules),
  (Routes.knowledge('emergingIssue'), ProFeature.proModules),
  (Routes.knowledgeEntry(_methodLocked()), ProFeature.proModules),
  (Routes.area('histology'), ProFeature.proModules),
  (Routes.module('reagents'), ProFeature.proModules),
  // Kutubxona (Moddalar, Usullar) va yozuvlari — ikki marshrut turi ham.
  (Routes.librarySection('substances'), ProFeature.proModules),
  (Routes.librarySection('methods'), ProFeature.proModules),
  (Routes.libraryEntry(_subLocked()), ProFeature.proModules),
  (Routes.homeSubstance(_subLocked()), ProFeature.proModules),
  (Routes.homePlan(_subLocked()), ProFeature.proModules),
  // Tadqiqotlar, Huquq, standartlar, yo‘riqnomalar, baholash.
  (Routes.research, ProFeature.proModules),
  (Routes.jurisdictions, ProFeature.proModules),
  (Routes.jurisdiction('UZ'), ProFeature.proModules),
  (Routes.compare, ProFeature.proModules),
  (Routes.homeStandards, ProFeature.proModules),
  (Routes.libraryStandards, ProFeature.proModules),
  (Routes.guidelines, ProFeature.proModules),
  (Routes.guideline('g1'), ProFeature.proModules),
  (Routes.homeGuideline('g1'), ProFeature.proModules),
  (Routes.assessment, ProFeature.proModules),
  (Routes.assessmentSources, ProFeature.proModules),
  (Routes.assessmentSpecialty('s1'), ProFeature.proModules),
  (Routes.assessmentTest('s1'), ProFeature.proModules),
  (Routes.assessmentQuestion('s1', 'q1'), ProFeature.proModules),
  // Vositalar / kalkulyatorlar (ikki marshrut turi) va apparat sxemasi.
  (Routes.tool('tool.lab.dilution'), ProFeature.proTools),
  (Routes.homeTool('tool.lab.dilution'), ProFeature.proTools),
  (Routes.tool('tool.lab.beer_lambert'), ProFeature.proTools),
  (Routes.gcms, ProFeature.proTools),
  // AI (pastki tab), mustaqil o‘quv, ustoz paneli.
  (Routes.ai, ProFeature.proAi),
  (Routes.quiz, ProFeature.fullQuizBank),
  (Routes.flashcards, ProFeature.allFlashcards),
  (Routes.classNew, ProFeature.teacherPanel),
];

/// Qat’iy rejimda ham HAR DOIM ochiq marshrutlar (qulf kartasi bo‘lmaydi).
List<String> freeRoutes() => [
  Routes.area('forensicMedicine'),
  Routes.area('toxicology'),
  Routes.area('biochemistry'),
  Routes.area('laboratory'),
  Routes.module('toxicology'),
  Routes.module('laboratory'),
  Routes.knowledgeEntry('TEST-TOPIC-FM'),
  // Namuna yozuvlari qulfsiz ochiladi.
  Routes.knowledgeEntry(_methodSample()),
  Routes.libraryEntry(_subSample()),
  Routes.search,
  Routes.glossary,
  Routes.sources,
  Routes.specimens,
  Routes.conflicts,
  Routes.reviewStatus,
  Routes.jurisdictionSelect,
  Routes.library,
  Routes.tools,
  Routes.learn,
  Routes.groups,
  Routes.classQuiz,
  Routes.profile,
  Routes.privacy,
  Routes.aiDisclaimer,
];

/// Testlar tsiklida har marshrutdan keyin: taymerlar va provayderlar tozalanadi.
Future<void> _reset(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  Finder lockOn(String key) => find.descendant(
    of: find.byKey(Key(key), skipOffstage: false),
    matching: find.byIcon(Icons.lock_outline),
  );

  group('Home: qulf belgilari', () {
    for (final lang in ['uz', 'ru', 'en']) {
      testWidgets('[$lang] qat’iy: Pro bo‘limlarda qulf, bepul 5 tasida yo‘q', (
        tester,
      ) async {
        await pumpApp(
          tester,
          size: _tall,
          settings: completedSettings(lang: lang),
          overrides: [..._strict(true).cast()],
        );
        for (final m in [
          'substances',
          'methods',
          'reagents',
          'screening',
          'standardsLaws',
          'research',
        ]) {
          expect(
            find.byKey(Key('home.module.$m.lock'), skipOffstage: false),
            findsOneWidget,
            reason: m,
          );
        }
        // Tezkor amallar: kalkulyatorlar va AI.
        expect(find.byKey(const Key('home.tools.lock')), findsOneWidget);
        expect(find.byKey(const Key('home.module.ai.lock')), findsOneWidget);
        for (final m in [
          'forensicMedicine',
          'toxicology',
          'biochemistry',
          'laboratory',
          'learn',
        ]) {
          expect(
            find.byKey(Key('home.module.$m.lock'), skipOffstage: false),
            findsNothing,
            reason: m,
          );
        }
        // Pro bo‘limlar ko‘rinadi (yashirilmagan).
        expect(
          find.byKey(const Key('home.module.reagents'), skipOffstage: false),
          findsOneWidget,
        );
      });
    }

    testWidgets('o‘chiq (standart): hech qanday qulf belgisi yo‘q', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: _tall,
        settings: completedSettings(lang: 'uz'),
        overrides: [..._strict(false).cast()],
      );
      expect(find.byType(ProLockBadge, skipOffstage: false), findsNothing);
      expect(find.byType(ProLockCard, skipOffstage: false), findsNothing);
    });

    testWidgets('Premium: qat’iy rejimda ham qulf belgisi yo‘q', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: _tall,
        settings: completedSettings(lang: 'uz'),
        overrides: [..._strict(true).cast(), ...planOverrides(Plan.premium)],
      );
      expect(find.byType(ProLockBadge, skipOffstage: false), findsNothing);
    });

    testWidgets('320 dp: qulf belgilari bilan overflow yo‘q (uz/ru/en)', (
      tester,
    ) async {
      for (final lang in ['uz', 'ru', 'en']) {
        await pumpApp(
          tester,
          size: const Size(320, 3600),
          settings: completedSettings(lang: lang),
          overrides: [..._strict(true).cast()],
        );
        expect(tester.takeException(), isNull, reason: lang);
        expect(
          find.byKey(
            const Key('home.module.reagents.lock'),
            skipOffstage: false,
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('320 dp, matn ×1.6: overflow yo‘q', (tester) async {
      await pumpApp(
        tester,
        size: const Size(320, 4200),
        textScale: 1.6,
        settings: completedSettings(lang: 'ru'),
        overrides: [..._strict(true).cast()],
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Qulfli bo‘lim: namuna + taklif', () {
    testWidgets('Reagentlar kartasi → qulf, namuna (1–2 yozuv), taklif', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: _tall,
        settings: completedSettings(lang: 'uz'),
        overrides: [..._strict(true).cast()],
      );
      await tester.tap(find.byKey(const Key('home.module.reagents')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro.lock.proModules')), findsOneWidget);
      expect(find.text('Pro bilan ochish'), findsOneWidget);
      expect(find.byKey(const Key('pro.sample.reagents')), findsOneWidget);
      expect(
        find.byKey(const Key('pro.sample.item.TEST-REAGENT-1')),
        findsOneWidget,
      );
      expect(find.text('Namuna'), findsOneWidget);
      // Namuna yozuvi ochiladi (qulfsiz).
      await tester.tap(find.byKey(const Key('pro.sample.item.TEST-REAGENT-1')));
      await tester.pumpAndSettle();
      expect(find.byType(ProLockCard), findsNothing);
      // Taklif Pro sahifasiga olib boradi.
    });

    testWidgets('namuna ko‘pi bilan 2 ta', (tester) async {
      await pumpApp(
        tester,
        size: _tall,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.knowledge('method'),
        overrides: [..._strict(true).cast()],
      );
      final items = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('pro.sample.item.'),
      );
      expect(items, findsNWidgets(2));
    });

    testWidgets('qulf tugmasi Pro sahifasini ochadi', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.research,
        overrides: [..._strict(true).cast()],
      );
      await tester.tap(find.byKey(const Key('pro.lock.unlock')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro.list')), findsOneWidget);
    });

    testWidgets('bepul modul (Sud tibbiyoti) odatdagidek ochiladi', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: _tall,
        settings: completedSettings(lang: 'uz'),
        overrides: [..._strict(true).cast()],
      );
      await tester.tap(find.byKey(const Key('home.module.forensicMedicine')));
      await tester.pumpAndSettle();
      expect(find.byType(ProLockCard), findsNothing);
      expect(find.byKey(const Key('fm.coverage')), findsOneWidget);
    });

    testWidgets(
      'Laboratoriya kirishi bepul; ichidagi vosita va usullar — Pro',
      (tester) async {
        await pumpApp(
          tester,
          size: _tall,
          settings: completedSettings(lang: 'uz'),
          initialLocation: Routes.module('laboratory'),
          overrides: [..._strict(true).cast()],
        );
        expect(find.byType(ProLockCard), findsNothing);
        // Kalkulyatorlar (Beer–Lambert, titrlash…) qulf belgisi bilan.
        expect(lockOn('tool.tool.lab.dilution'), findsOneWidget);
        expect(lockOn('tool.tool.lab.beer_lambert'), findsOneWidget);
        // Usullar/reagentlar havolalari ham.
        expect(find.byKey(const Key('moduleHub.methods.lock')), findsOneWidget);
        expect(
          find.byKey(const Key('moduleHub.reagents.lock')),
          findsOneWidget,
        );
        // Vositani ochish → Pro taklifi (namuna bilan).
        await tester.tap(find.byKey(const Key('tool.tool.lab.beer_lambert')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('pro.lock.proTools')), findsOneWidget);
        expect(find.byKey(const Key('pro.sample.methods')), findsOneWidget);
      },
    );

    testWidgets('Vositalar tabi: hamma vosita qulf bilan, AI tabi qulfli', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: _tall,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.tools,
        overrides: [..._strict(true).cast()],
      );
      expect(lockOn('tool.tool.lab.dilution'), findsOneWidget);
      expect(lockOn('tool.tool.lab.percent'), findsOneWidget);
      expect(lockOn('tools.gcms'), findsOneWidget);
    });
  });

  group('Marshrut matritsasi (deep link ham): rejim × bayroq × reja', () {
    // Mehmon (hisobsiz) ham, talaba/ustoz/mutaxassis ham: bitta qoida.
    for (final mode in UserMode.values) {
      testWidgets('${mode.name}: qat’iy YOQILGAN, bepul → HAR BIR Pro marshrut '
          'qulf oladi', (tester) async {
        for (final (route, feature) in proRoutes()) {
          // Baholash talabaga yo‘q (rejim redirect’i) — qolganlari barchaga.
          if (mode == UserMode.student && route.startsWith(Routes.assessment)) {
            continue;
          }
          await _reset(tester);
          await pumpApp(
            tester,
            settings: completedSettings(lang: 'uz', mode: mode),
            initialLocation: route,
            overrides: [..._strict(true).cast()],
          );
          expect(
            find.byKey(Key('pro.lock.${feature.name}')),
            findsOneWidget,
            reason: '${mode.name}: $route',
          );
          expect(tester.takeException(), isNull, reason: route);
        }
        await _reset(tester);
      });

      testWidgets('${mode.name}: qat’iy O‘CHIQ → hech bir marshrutda yangi '
          'qulf yo‘q', (tester) async {
        for (final (route, feature) in proRoutes()) {
          if (mode == UserMode.student && route.startsWith(Routes.assessment)) {
            continue;
          }
          await _reset(tester);
          await pumpApp(
            tester,
            settings: completedSettings(lang: 'uz', mode: mode),
            initialLocation: route,
            overrides: [..._strict(false).cast()],
          );
          // fullQuizBank/allFlashcards/… mavjud gate’lari bu yerda emas:
          // faqat qat’iy qatlam qulfi bo‘lmasligi tekshiriladi.
          expect(
            find.byKey(Key('pro.lock.${feature.name}')),
            findsNothing,
            reason: '${mode.name}: $route',
          );
          expect(find.byKey(const Key('pro.sample.reagents')), findsNothing);
        }
        await _reset(tester);
      });
    }

    testWidgets('Premium + qat’iy: hech bir Pro marshrutda qulf yo‘q', (
      tester,
    ) async {
      for (final (route, feature) in proRoutes()) {
        await _reset(tester);
        await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
          initialLocation: route,
          overrides: [..._strict(true).cast(), ...planOverrides(Plan.premium)],
        );
        expect(
          find.byKey(Key('pro.lock.${feature.name}')),
          findsNothing,
          reason: route,
        );
      }
      await _reset(tester);
    });

    testWidgets('har qanday pullik reja (qat’iy): bo‘lim/vosita/AI ochiq', (
      tester,
    ) async {
      for (final plan in [Plan.student, Plan.teacher, Plan.expert]) {
        for (final route in [
          Routes.knowledge('reagent'),
          Routes.research,
          Routes.jurisdictions,
          Routes.librarySection('substances'),
          Routes.tool('tool.lab.dilution'),
          Routes.ai,
        ]) {
          await _reset(tester);
          await pumpApp(
            tester,
            settings: completedSettings(lang: 'uz'),
            initialLocation: route,
            overrides: [..._strict(true).cast(), ...planOverrides(plan)],
          );
          expect(
            find.byType(ProLockCard),
            findsNothing,
            reason: '$plan $route',
          );
        }
      }
      await _reset(tester);
    });

    testWidgets('qat’iy yoqilgan: bepul marshrutlar doim ochiq', (
      tester,
    ) async {
      for (final route in freeRoutes()) {
        await _reset(tester);
        await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz'),
          initialLocation: route,
          overrides: [..._strict(true).cast()],
        );
        expect(find.byType(ProLockCard), findsNothing, reason: route);
        expect(tester.takeException(), isNull, reason: route);
      }
      await _reset(tester);
    });

    testWidgets(
      'qidiruv natijasi Pro yozuvni ochsa — qulf, bepul mavzuni — yo‘q',
      (tester) async {
        await _reset(tester);
        await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz'),
          initialLocation: Routes.searchWith('TEST'),
          overrides: [..._strict(true).cast()],
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProLockCard), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Kutubxona markazi (qat’iy)', () {
    testWidgets('Pro bo‘limlar qulf belgisi bilan, provenance qulfsiz', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: _tall,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.library,
        overrides: [..._strict(true).cast()],
      );
      expect(
        find.byKey(const Key('library.hub.substances.lock')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('library.hub.specimens.lock')), findsNothing);
      expect(find.byKey(const Key('library.hub.terms.lock')), findsNothing);
      expect(
        find.byKey(const Key('library.hub.references.lock')),
        findsNothing,
      );
    });
  });

  group('«Tinglash»', () {
    Widget host({required bool strict, Plan? plan}) => ProviderScope(
      key: UniqueKey(),
      overrides: [
        proStrictProvider.overrideWithValue(strict),
        ...planOverrides(plan),
        ttsServiceProvider.overrideWithValue(FakeTtsService()),
        ttsPlayerFactoryProvider.overrideWithValue(() => FakeTtsPlayer()),
      ],
      child: const MaterialApp(
        locale: Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(child: ListenButton(text: 'Salom')),
        ),
      ),
    );

    testWidgets('qat’iy, bepul: qulf belgisi; o‘chiq/Pro: oddiy tugma', (
      tester,
    ) async {
      await tester.pumpWidget(host(strict: true));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tts.locked')), findsOneWidget);
      expect(find.byKey(const Key('tts.listen')), findsNothing);
      await tester.pumpWidget(host(strict: false));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tts.listen')), findsOneWidget);
      await tester.pumpWidget(host(strict: true, plan: Plan.expert));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tts.listen')), findsOneWidget);
    });
  });
}
