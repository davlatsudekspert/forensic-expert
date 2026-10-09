// REAL-ILOVA QA — «ILMIY LUG‘AT» (uz/ru/en atamalar, term_translations)
// va toks kartalaridagi «Atamalar» bo‘limi.
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy kontent paketi (content.db) va
// yo‘riqnoma asset’i, Linux desktop. Akkaunt — MOCK, Pro YO‘Q, tarmoq —
// o‘chirilgan.
//
// Muhit: QA_MODE=student|professional  QA_LANG=uz|ru|en  QA_SHOTS=0 (skrinshotsiz)
//   QA_OUT=/tmp/t xvfb-run -a flutter test integration_test/qa_glossary_test.dart \
//     -d linux --dart-define=FE_AUTH_MODE=mock
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final env = Platform.environment;
  final lang = env['QA_LANG'] ?? 'uz';
  final mode = env['QA_MODE'] ?? 'student';
  final shots = env['QA_SHOTS'] != '0';
  final role = 'glossary-$lang-$mode';
  // Skrinshot nomlari bitta katalogda to‘qnashmasin.
  final tag = '$lang ${mode == 'student' ? 'student' : 'expert'}';

  testWidgets('QA real app — scientific glossary ($role)', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      role: role,
      prefs: {
        'fe.settings.locale': lang,
        'fe.settings.theme': 'light',
        'fe.settings.mode': mode,
        'fe.settings.disclaimer_version': 1,
      },
    );
    qa.lang = lang;
    await qa.setSize(const Size(390, 844));

    final (title, badge, steamLocal) = switch (lang) {
      'ru' => (
        'Научный словарь',
        'Машинный перевод — не проверен',
        'перегонка с водяным паром',
      ),
      'en' => (
        'Scientific glossary',
        'Machine translation — not verified',
        'steam distillation',
      ),
      _ => (
        'Ilmiy lug‘at',
        'Mashina tarjimasi — tekshirilmagan',
        'suv bug‘i bilan haydash',
      ),
    };
    const steam = 'T-TOKS-STEAM-DISTILLATION';
    const isolation = 'guideline.chem.toks_isolation';

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    bool has(String key) => find.byKey(Key(key)).evaluate().isNotEmpty;

    void expectKey(String key, QaStep s) {
      if (!has(key)) {
        s.passed = false;
        s.notes.add('KUTILGAN ELEMENT YO‘Q: $key');
      }
    }

    Future<void> tapKey(String key) => qa.tapFinder(find.byKey(Key(key)));

    Future<void> filter(String q) async {
      await qa.enterText(find.byKey(const Key('glossary.filter')), q);
      await qa.scrollToTop();
    }

    // ------------------------------------------- Kutubxona → Ilmiy lug‘at
    await qa.step('$tag library hub glossary tile', shot: shots, (s) async {
      await open(Routes.library);
      await qa.scrollUntil(find.byKey(const Key('library.hub.terms')));
      expectKey('library.hub.terms', s);
      qa.expectText(title, s);
    });
    await qa.step('$tag glossary list', shot: shots, (s) async {
      await tapKey('library.hub.terms');
      expectKey('glossary.list', s);
      expectKey('glossary.filter', s);
      qa.expectText(title, s);
    });

    // ------------------------------------------------ 320 dp: qidiruv
    await qa.setSize(const Size(320, 640));
    await qa.step('$tag 320 filter russian', shot: shots, (s) async {
      await filter('дитизон');
      expectKey('glossary.term.T-TOKS-DITHIZONE', s);
      if (has('glossary.term.$steam')) {
        s.passed = false;
        s.notes.add('filtr ishlamadi: $steam ko‘rinmoqda');
      }
    });
    await qa.step('$tag 320 filter english', shot: shots, (s) async {
      await filter('steam distillation');
      expectKey('glossary.term.$steam', s);
    });
    await qa.step('$tag 320 term detail', shot: shots, (s) async {
      await tapKey('glossary.term.$steam');
      expectKey('glossary.detail', s);
      expectKey('glossary.badge.machineDraft', s);
      expectKey('glossary.machineDraftNote', s);
      qa.expectText(badge, s, why: 'mashina tarjimasi belgisi');
      for (final code in ['uz', 'ru', 'en']) {
        expectKey('glossary.lang.$code', s);
      }
      qa.expectText('перегонка с водяным паром', s);
      qa.expectText('steam distillation', s);
      qa.expectText('suv bug‘i bilan haydash', s);
    });
    await qa.step('$tag 320 term linked cards', shot: shots, (s) async {
      await qa.scrollUntil(find.byKey(const Key('glossary.card.$isolation')));
      expectKey('glossary.card.$isolation', s);
      expectKey('glossary.card.guideline.chem.toks_volatile_poisons', s);
    });
    await qa.step('$tag 320 open linked card', shot: shots, (s) async {
      await tapKey('glossary.card.$isolation');
      expectKey('guideline.detail', s);
      expectKey('guideline.toksAttribution', s);
      expectKey('guideline.index.terms', s);
    });
    await qa.step('$tag 320 card terms section', shot: shots, (s) async {
      await qa.scrollUntil(find.byKey(const Key('guideline.term.$steam')));
      expectKey('guideline.terms', s);
      expectKey('guideline.term.$steam', s);
      final chip = find.byKey(const Key('guideline.term.$steam'));
      if (chip.evaluate().isNotEmpty) {
        await tester.ensureVisible(chip);
        await qa.settle();
      }
    });
    await qa.step('$tag 320 card term sheet', shot: shots, (s) async {
      await tapKey('guideline.term.$steam');
      expectKey('glossary.sheet', s);
      expectKey('glossary.badge.machineDraft', s);
      qa.expectText(badge, s);
    });
    await qa.step('$tag back to term and list', shot: shots, (s) async {
      await qa.back(); // varaq yopiladi
      if (has('glossary.sheet')) {
        s.passed = false;
        s.notes.add('varaq yopilmadi');
      }
      await qa.back(); // karta → atama
      expectKey('glossary.detail', s);
      await qa.back(); // atama → ro‘yxat
      expectKey('glossary.list', s);
      if (!has('glossary.detail') && has('glossary.list')) return;
      s.passed = false;
      s.notes.add('orqaga qaytish noto‘g‘ri');
    });

    // ------------------------------------------- global qidiruv (uch tilda)
    for (final (q, id) in [
      ('перегонка с водяным паром', steam),
      ('dithizone', 'T-TOKS-DITHIZONE'),
      ('suv bug‘i bilan haydash', steam),
    ]) {
      await qa.step('$tag search $q', shot: shots && q == 'dithizone', (
        s,
      ) async {
        await open(Routes.searchWith(q));
        // Bir xil sahifa qayta ochilganda so‘rov maydon orqali yangilanadi.
        await qa.enterText(find.byKey(const Key('search.field')), q);
        await qa.settle(maxMs: 3000);
        await qa.scrollToTop();
        await qa.scrollUntil(find.byKey(Key('search.hit.$id')));
        expectKey('search.hit.$id', s);
        qa.expectText(title, s, why: 'natija turi — lug‘at');
      });
    }
    await qa.step('$tag search opens glossary entry', shot: shots, (s) async {
      const q = 'перегонка с водяным паром';
      await open(Routes.searchWith(q));
      await qa.enterText(find.byKey(const Key('search.field')), q);
      await qa.settle(maxMs: 3000);
      await qa.scrollToTop();
      await qa.scrollUntil(find.byKey(const Key('search.hit.$steam')));
      await tapKey('search.hit.$steam');
      expectKey('glossary.detail', s);
      qa.expectText(steamLocal, s);
      qa.expectText(badge, s);
      await qa.back();
      expectKey('search.hit.$steam', s);
    });

    // ------------------------------------------- 320 dp, katta matn
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await qa.step('$tag 320 2x term detail', shot: shots, (s) async {
      await open(Routes.glossaryTerm(steam));
      expectKey('glossary.badge.machineDraft', s);
    });
    await qa.step('$tag 320 2x glossary list', shot: shots, (s) async {
      await open(Routes.glossary);
      expectKey('glossary.filter', s);
    });
    tester.platformDispatcher.clearTextScaleFactorTestValue();

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
