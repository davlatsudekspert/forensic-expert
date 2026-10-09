import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/court_prep.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

import '../helpers/pump_app.dart';

/// Haqiqiy kontent paketi (ilova asset’i) — fake-async zonadan tashqarida
/// o‘qiladi.
final _court = File('assets/content/court_prep/court_prep_v1.json')
    .readAsStringSync();
final _guidelines = File('assets/content/guidelines/guidelines_v1.json')
    .readAsStringSync();

const _pro = Entitlements(
  tier: PlanTier.professionalPro,
  status: EntitlementStatus.active,
  source: EntitlementSource.promo,
  verification: EntitlementVerification.serverVerified,
);

List<Override> _overrides({bool pro = false}) => [
  courtPrepLoaderProvider.overrideWithValue(() async => _court),
  guidelineBundleLoaderProvider.overrideWithValue(() async => _guidelines),
  if (pro) accessProvider.overrideWithValue(_pro),
];

Finder _key(String k) => find.byKey(Key(k));
Finder _row(String id) => _key('court.q.$id');

Future<void> _scrollTo(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Clipboard’ga yozilgan oxirgi matn.
String? _mockClipboard(WidgetTester tester) {
  String? copied;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String?;
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

void main() {
  testWidgets('mutaxassis (bepul): Home → bo‘lim, ogohlantirish; har bir '
      'karta to‘liq (A–I, manbalar bilan); Pro faqat kengaytirilgan mashq', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      overrides: _overrides(),
    );
    final tile = _key('home.courtPrep');
    await _scrollTo(tester, tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Tayyorgarlik materiali; yuridik maslahat emas; xulosa faqat '
        'ekspertning o‘z tadqiqotiga asoslanadi.',
      ),
      findsOne,
    );
    expect(_key('court.locked'), findsOne);
    expect(_key('court.principles'), findsOne);
    expect(_key('court.simulator'), findsOne);
    // Standart yurisdiksiya — xalqaro.
    expect(_key('court.jurisdiction.intl'), findsOne);

    // Pro imkoniyatlari bepul foydalanuvchiga tariflar sahifasini ochadi.
    for (final k in ['court.drill', 'court.stats']) {
      await _scrollTo(tester, _key(k));
      await tester.tap(_key(k));
      await tester.pumpAndSettle();
      expect(_key('paywall.list'), findsOne, reason: k);
      c.read(routerProvider).go(Routes.courtPrep);
      await tester.pumpAndSettle();
    }

    final topic = _key('court.topic.court.topic.qualification');
    await _scrollTo(tester, topic);
    await tester.tap(topic);
    await tester.pumpAndSettle();
    final row = _row('court.q.qual_competence');
    await _scrollTo(tester, row);
    await tester.tap(row);
    await tester.pumpAndSettle();
    // I. holat belgisi, «Sud nimani tekshiradi», B qisqa javob.
    expect(_key('court.status'), findsOne);
    expect(_key('court.tests'), findsOne);
    await _scrollTo(tester, _key('court.shortAnswer'));
    // C asos va D «Qaysi manbada yozilgan?» — aniq joy bilan.
    await _scrollTo(tester, _key('court.block.explain'));
    await _scrollTo(tester, _key('court.loc.court_uz_cpc'));
    expect(find.textContaining('78-modda, 2-qism'), findsOne);
    // E/F qo‘shimcha savol ochiladi.
    await _scrollTo(tester, _key('court.followup.0'));
    await tester.tap(_key('court.followup.0'));
    await tester.pumpAndSettle();
    // G cheklovlar, tayyorgarlik, H eksport.
    await _scrollTo(tester, _key('court.limitations'));
    await _scrollTo(tester, _key('court.block.documents'));
    await _scrollTo(tester, _key('court.block.pitfalls'));
    await _scrollTo(tester, _key('court.export'));

    // Boshqa (ilgari Pro bo‘lgan) karta ham bepul — to‘liq mazmun bilan.
    c
        .read(routerProvider)
        .go(Routes.courtPrepQuestion('court.q.method_validation'));
    await tester.pumpAndSettle();
    expect(_key('court.locked'), findsNothing);
    expect(_key('court.tests'), findsOne);
    await _scrollTo(tester, _key('court.loc.ich_q2r2_2023'));
  });

  testWidgets('«Manba tekshirilmagan»: joyi tasdiqlanmagan manba '
      'bibliografiya o‘rniga belgi bilan', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepQuestion('court.q.qa_accreditation'),
      overrides: _overrides(pro: true),
    );
    final f = _key('court.unverified.court_iso17025_2017');
    await _scrollTo(tester, f);
    expect(
      find.descendant(of: f, matching: find.text('Manba tekshirilmagan')),
      findsOne,
    );
    // Tekshirilgan manba esa joyi bilan.
    expect(_key('court.loc.court_ilac_g19_2022'), findsOne);
  });

  testWidgets('Pro: belgilash, bog‘liq material, iqtibos va eksport', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'en'),
      initialLocation: Routes.courtPrepQuestion('court.q.method_lod'),
      overrides: _overrides(pro: true),
    );
    expect(_key('court.locked'), findsNothing);
    expect(_key('court.draftTranslation'), findsOne);
    expect(find.textContaining('[court_armbruster2008]'), findsNothing);

    final item = _key('court.block.documents.0');
    await _scrollTo(tester, item);
    await tester.tap(item);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(item).value, isTrue);

    final copy = _key('court.copy.court_armbruster2008');
    await _scrollTo(tester, copy);
    await tester.tap(copy);
    await tester.pumpAndSettle();
    expect(copied, contains('Armbruster DA'));
    expect(copied, contains('Abstract'));

    await _scrollTo(tester, _key('court.related'));
    final bib = _key('court.export.bibtex');
    await _scrollTo(tester, bib);
    await tester.tap(bib);
    await tester.pumpAndSettle();
    expect(copied, contains('@article{court_armbruster2008'));
  });

  testWidgets('yurisdiksiya: O‘zbekiston tanlansa — JPK huquqlari', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz').copyWith(jurisdictionId: 'UZ'),
      initialLocation: Routes.courtPrepTopic('court.topic.rights'),
      overrides: _overrides(pro: true),
    );
    expect(_row('court.q.rights_uz'), findsOne);
    expect(_row('court.q.duties_uz'), findsOne);
    expect(_row('court.q.rights_intl'), findsNothing);
    c.read(routerProvider).go(Routes.courtPrepQuestion('court.q.rights_uz'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, _key('court.loc.court_uz_expertise_law'));
    expect(find.textContaining('15-modda'), findsWidgets);
    expect(find.textContaining('lex.uz'), findsWidgets);
  });

  testWidgets('yurisdiksiya: xalqaro — umumiy tamoyillar', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepTopic('court.topic.rights'),
      overrides: _overrides(pro: true),
    );
    expect(_row('court.q.rights_intl'), findsOne);
    expect(_row('court.q.rights_uz'), findsNothing);
  });

  testWidgets('tayyorlanayotgan mavzu: savolsiz, aniq belgi bilan', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepTopic('court.topic.histology'),
      overrides: _overrides(pro: true),
    );
    expect(_key('court.topicPending'), findsOne);
    expect(find.text('Tayyorlanmoqda — manbalar tekshirilmoqda'), findsOne);
  });

  testWidgets('halollik tamoyillari — bepul foydalanuvchiga ham ochiq', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepPrinciples,
      overrides: _overrides(),
    );
    expect(_key('court.principles.intro'), findsOne);
    expect(_key('court.principle.court.p.all_findings'), findsOne);
    await _scrollTo(tester, _key('court.principle.court.p.no_overstatement'));
    expect(_key('court.locked'), findsNothing);
  });

  testWidgets('simulyator (Pro): variant tanlash, 4 mezon bo‘yicha baho, '
      'namunaviy javob; erkin matn baholanadi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepScenario('court.sim.colour_test'),
      overrides: _overrides(pro: true),
    );
    expect(_key('court.sim.prompt'), findsOne);
    // Erkin matn: mutlaq ibora — ogohlantirish.
    await tester.enterText(
      _key('court.sim.text'),
      'Ha, 100 foiz albatta bu giyohvand modda.',
    );
    await tester.tap(_key('court.sim.evaluateText'));
    await tester.pumpAndSettle();
    expect(_key('court.sim.freeResult'), findsOne);
    expect(find.textContaining('Mutlaq ibora topildi'), findsOne);

    // Noto‘g‘ri variant → baho past, namunaviy javob ko‘rsatiladi.
    await _scrollTo(tester, _key('court.sim.option.0'));
    await tester.tap(_key('court.sim.option.0'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, _key('court.sim.check'));
    await tester.tap(_key('court.sim.check'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, _key('court.sim.best'));
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: _key('court.sim.result'),
              matching: _key('court.sim.score.accuracy'),
            ),
          )
          .data,
      '0/2',
    );

    // To‘g‘ri variant → 8/8, namunaviy javob kartasi kerak emas.
    await _scrollTo(tester, _key('court.sim.option.1'));
    await tester.tap(_key('court.sim.option.1'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, _key('court.sim.check'));
    await tester.tap(_key('court.sim.check'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, _key('court.sim.result'));
    expect(find.text('Jami: 8/8'), findsOne);
    expect(_key('court.sim.best'), findsNothing);
  });

  testWidgets('simulyator (bepul): faqat namunaviy ssenariylar', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepSimulator,
      overrides: _overrides(),
    );
    expect(_key('court.scenario.court.sim.colour_test'), findsOne);
    // Asosiy ssenariy bepul ochiladi; AI tahlili — Pro.
    c
        .read(routerProvider)
        .go(Routes.courtPrepScenario('court.sim.colour_test'));
    await tester.pumpAndSettle();
    expect(_key('court.sim.prompt'), findsOne);
    await tester.tap(_key('court.sim.ai'));
    await tester.pumpAndSettle();
    expect(_key('paywall.list'), findsOne);
    c.read(routerProvider).go(Routes.courtPrepSimulator);
    await tester.pumpAndSettle();
    final locked = _key('court.scenario.court.sim.redistribution');
    await _scrollTo(tester, locked);
    await tester.tap(locked);
    await tester.pumpAndSettle();
    expect(_key('paywall.list'), findsOne);
    c
        .read(routerProvider)
        .go(Routes.courtPrepScenario('court.sim.redistribution'));
    await tester.pumpAndSettle();
    expect(_key('court.locked'), findsOne);
    expect(_key('court.sim.prompt'), findsNothing);
  });

  testWidgets('qidiruv: uch tilda; topilmasa — tushunarli xabar', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.courtPrep,
      overrides: _overrides(pro: true),
    );
    await tester.enterText(_key('court.search'), 'LOQ');
    await tester.pumpAndSettle();
    expect(_row('court.q.method_lod'), findsOne);
    await tester.enterText(_key('court.search'), 'proficiency');
    await tester.pumpAndSettle();
    expect(_row('court.q.qa_proficiency'), findsOne);
    await tester.enterText(_key('court.search'), 'zzqqxx');
    await tester.pumpAndSettle();
    expect(_key('court.noResults'), findsOne);
  });

  testWidgets('mashq rejimi (Pro): savol → qisqa javob → karta → keyingi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepPractice,
      overrides: _overrides(pro: true),
    );
    expect(_key('court.practice.question'), findsOne);
    expect(_key('court.practice.think'), findsOne);
    final first = tester.widget<Text>(_key('court.practice.question')).data;
    await tester.tap(_key('court.practice.reveal'));
    await tester.pumpAndSettle();
    expect(_key('court.practice.think'), findsNothing);
    await _scrollTo(tester, _key('court.block.pitfalls'));
    final next = _key('court.practice.next');
    await _scrollTo(tester, next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text('Mashq qilingan savollar: 1'), findsOne);
    expect(
      tester.widget<Text>(_key('court.practice.question')).data,
      isNot(first),
    );
  });

  testWidgets('mashq rejimi (bepul): to‘liq ochiq', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepPractice,
      overrides: _overrides(),
    );
    expect(_key('court.practice.question'), findsOne);
    await tester.tap(_key('court.practice.reveal'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, _key('court.sources'));
    expect(_key('court.locked'), findsNothing);
  });

  testWidgets('Pro: AI tahlili — halol «tez orada»; rol mashqi va shaxsiy '
      'statistika (faqat lokal)', (tester) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.courtPrepScenario('court.sim.certainty'),
      overrides: _overrides(pro: true),
    );
    await tester.tap(_key('court.sim.ai'));
    await tester.pumpAndSettle();
    expect(_key('court.sim.aiUnavailable'), findsOne);
    expect(find.textContaining('tez orada'), findsOne);

    c.read(routerProvider).go(Routes.courtPrepDrill);
    await tester.pumpAndSettle();
    expect(find.text('1-qadam / 4'), findsOne);
    for (var step = 0; step < 4; step++) {
      // Har qadamda eng kuchli variantni topib tekshiramiz.
      final best = _key('court.sim.option.1');
      await _scrollTo(tester, best);
      await tester.tap(best);
      await tester.pumpAndSettle();
      await _scrollTo(tester, _key('court.sim.check'));
      await tester.tap(_key('court.sim.check'));
      await tester.pumpAndSettle();
      await _scrollTo(tester, _key('court.sim.next'));
      await tester.tap(_key('court.sim.next'));
      await tester.pumpAndSettle();
    }
    expect(_key('court.drill.done'), findsOne);
    expect(c.read(courtHistoryProvider), hasLength(4));
    expect(c.read(courtHistoryProvider).every((a) => a.drill), isTrue);

    c.read(routerProvider).go(Routes.courtPrepStats);
    await tester.pumpAndSettle();
    expect(find.text('Urinishlar: 4'), findsOne);
    expect(_key('court.stats.average'), findsOne);
    await _scrollTo(tester, _key('court.stats.clear'));
    await tester.tap(_key('court.stats.clear'));
    await tester.pumpAndSettle();
    expect(c.read(courtHistoryProvider), isEmpty);
  });

  testWidgets('talaba: Home’da yo‘q, Kutubxonada bor (bepul — qulf bilan)', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.student),
      overrides: _overrides(),
    );
    expect(_key('home.courtPrep'), findsNothing);
    c.read(routerProvider).go(Routes.library);
    await tester.pumpAndSettle();
    final tile = _key('library.hub.court');
    await _scrollTo(tester, tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(_key('court.locked'), findsOne);
    expect(_mockClipboard(tester), isNull);
  });
}
