// REAL-ILOVA QA — milliy amaliyot yo‘riqnomasidan (ABY, 2025) olingan yozuvlar.
//
// Tekshiriladi: o‘zbek tilida mavzular ro‘yxatda va sahifada ko‘rinadi,
// manba nomi va aniq joyi yozilgan; rus/ingliz tilida esa yozuv ham, mavzu
// ham, qidiruvda ham umuman chiqmaydi (bo‘sh sahifa qolmaydi).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy kontent paketi, Linux desktop.
// Akkaunt — MOCK, Pro YO‘Q (ABY bepul bo‘lishi kerak), tarmoq — o‘chirilgan.
//
// Muhit: QA_LANG=uz|ru|en  QA_MODE=student|professional  QA_SHOTS=0
//   QA_OUT=/tmp/t xvfb-run -a flutter test integration_test/qa_aby_test.dart \
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
  final role = 'aby-$lang-$mode';
  final tag = '$lang ${mode == 'student' ? 'student' : 'expert'}';
  final uz = lang == 'uz';

  testWidgets('QA real app — ABY records ($role)', (tester) async {
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

    const topic = 'aby-tox-opiates';
    const claim = 'C-ABY-TOX-OPI-01';

    Future<void> open(String route) async {
      goTo(tester, route);
      await qa.settle(maxMs: 6000);
      await qa.scrollToTop();
    }

    bool has(String key) => find.byKey(Key(key)).evaluate().isNotEmpty;

    void expectKey(String key, QaStep s, {bool present = true}) {
      if (has(key) != present) {
        s.passed = false;
        s.notes.add(present ? 'KUTILGAN ELEMENT YO‘Q: $key' : 'ORTIQCHA: $key');
      }
    }

    // ---------------------------------------------- Toksikologiya → Mavzular
    await qa.step('$tag toxicology hub topics link', shot: shots, (s) async {
      await open(Routes.module('toxicology'));
      // Mavzular havolasi yozuv bo‘lganda ko‘rsatiladi. Har uch tilda ham
      // kamida bitta mavzu bor (o‘limdan keyingi qayta taqsimlanish), ABY
      // mavzulari esa faqat o‘zbekchada qo‘shiladi — ro‘yxat keyingi qadamda
      // tekshiriladi.
      expectKey('moduleHub.topics', s);
    });

    await qa.step('$tag toxicology topics list', shot: shots, (s) async {
      await open(Routes.area('toxicology'));
      if (uz) {
        await qa.scrollUntil(find.byKey(const Key('knowledge.$topic')));
      }
      expectKey('knowledge.$topic', s, present: uz);
    });

    // --------------------------------------------------------- Mavzu sahifasi
    await qa.step('$tag topic page', shot: shots, (s) async {
      await open(Routes.knowledgeEntry(topic));
      if (uz) {
        await qa.scrollUntil(find.byKey(const Key('claim.statement.$claim')));
        expectKey('claim.statement.$claim', s);
        expectKey('claim.locator.$claim', s);
        // Manba ochiq keltiriladi va bepul (paywall yo‘q).
        qa.expectText('ABY', s, why: 'manba nomi ko‘rinishi kerak');
        expectKey('claim.withheld.$claim', s, present: false);
      } else {
        // Boshqa tilda sahifa ochilmaydi: bo‘sh holat, matn yo‘q.
        expectKey('claim.statement.$claim', s, present: false);
        if (find.textContaining('ABY').evaluate().isNotEmpty) {
          s.passed = false;
          s.notes.add('ABY matni $lang tilida ko‘rinmoqda');
        }
      }
    });

    // --------------------------------------------------------------- Qidiruv
    await qa.step('$tag search opiatlar', shot: shots, (s) async {
      await open(Routes.searchWith('opiatlar'));
      await qa.settle(maxMs: 4000);
      final found = find
          .textContaining('biologik suyuqliklarda sud-kimyoviy')
          .evaluate()
          .isNotEmpty;
      if (found != uz) {
        s.passed = false;
        s.notes.add(
          uz ? 'qidiruvda ABY mavzusi topilmadi' : 'qidiruvda ABY mavzusi $lang tilida chiqdi',
        );
      }
    });

    // --------------------------------------- Minnatdorchilik (faqat o‘zbekcha)
    await qa.step('$tag sources and authors', shot: shots, (s) async {
      await open(Routes.aboutSources);
      expectKey('sourcesAuthors.list', s, present: uz);
      if (uz) {
        qa.expectText('Sh.I. Ro‘ziev', s, why: 'ABY tuzuvchilari');
        qa.expectText('Respublika sud-tibbiy ekspertiza', s);
      }
    });

    // --------------------------------------------- 320 dp, katta matn (uz)
    if (uz) {
      await qa.setSize(const Size(320, 640));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await qa.step('$tag 320 2x topic page', shot: shots, (s) async {
        await open(Routes.knowledgeEntry(topic));
        await qa.scrollUntil(find.byKey(const Key('claim.statement.$claim')));
        expectKey('claim.statement.$claim', s);
      });
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    }

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
