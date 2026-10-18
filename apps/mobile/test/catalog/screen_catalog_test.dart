@Tags(['catalog'])
library;

// EKRANLAR KATALOGI (2026-10-17, premium dizayn tekshiruvi).
//
// Ilovadagi har bir marshrut va asosiy holatni haqiqiy shriftlar va yoqilgan
// soyalar bilan chizadi: uz 390 dp yorug‘ + qorong‘i; muhimlari ru/en va
// 320 dp ham. Natija: `docs/qa/screen_catalog_20261017/*.png` + `index.md`.
// Ma’lumot — pilot kontent paketi va TEST soxta xizmatlari (MOCK akkaunt,
// demo sinf serveri, soxta murojaatlar). Tarmoq yo‘q.
//
// Yaratish (CI’da o‘tkazib yuboriladi):
//   flutter test --tags catalog --run-skipped test/catalog
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/court_prep.dart';
import 'package:forensic_expert/app/glossary.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/publications.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/support.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/catalog/tools_catalog.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/support/support_models.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';
import '../helpers/support_fakes.dart';

const _out = '../../docs/qa/screen_catalog_20261017';

enum Persona { student, expert, admin, guestOnboarding }

enum V {
  uzLight('uz', ThemeMode.light, Size(390, 844)),
  uzDark('uz', ThemeMode.dark, Size(390, 844)),
  ruLight('ru', ThemeMode.light, Size(390, 844)),
  enLight('en', ThemeMode.light, Size(390, 844)),
  uz320('uz', ThemeMode.light, Size(320, 640));

  const V(this.lang, this.theme, this.size);
  final String lang;
  final ThemeMode theme;
  final Size size;
}

typedef Act = Future<void> Function(WidgetTester t, ProviderContainer c);

class Shot {
  const Shot(
    this.id,
    this.title,
    this.route, {
    this.state = 'standart',
    this.persona = Persona.student,
    this.act,
    this.important = false,
    this.settings,
    this.classWorld = false,
  });

  final String id;
  final String title;
  final String route;
  final String state;
  final Persona persona;
  final Act? act;
  final bool important;

  /// Onboarding uchun maxsus sozlamalar.
  final AppSettings Function(V v)? settings;

  /// Sinfda test: ustoz/talaba soxta serveri (demo emas).
  final bool classWorld;
}

// ------------------------------------------------------------------ yordamchi

Future<void> _frames(WidgetTester t, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
}

Finder _prefix(String p) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(p) &&
      !(w.key! as ValueKey<String>).value.endsWith('.list'),
);

Future<void> _tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f.first);
  await t.pumpAndSettle();
  await t.tap(f.first, warnIfMissed: false);
  await t.pumpAndSettle();
}

Act tapKey(String key) =>
    (t, c) => _tap(t, find.byKey(Key(key)));

Act tapPrefix(String p) =>
    (t, c) => _tap(t, _prefix(p));

Act seq(List<Act> acts) => (t, c) async {
  for (final a in acts) {
    await a(t, c);
  }
};

Act scrollTo(String key) => (t, c) async {
  final f = find.byKey(Key(key));
  await t.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 80,
  );
  await t.pumpAndSettle();
};

Act scrollBy(double dy) => (t, c) async {
  final s = find.byType(Scrollable).first;
  final st = t.state<ScrollableState>(s);
  st.position.jumpTo(
    (st.position.pixels + dy).clamp(0, st.position.maxScrollExtent),
  );
  await t.pumpAndSettle();
};

Act enterAll(String text) => (t, c) async {
  final fields = find.byType(EditableText);
  for (var i = 0; i < fields.evaluate().length; i++) {
    await t.ensureVisible(fields.at(i));
    await t.enterText(fields.at(i), text);
  }
  await t.pumpAndSettle();
};

Act enterKey(String key, String text) => (t, c) async {
  final f = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(EditableText),
  );
  final target = f.evaluate().isEmpty ? find.byKey(Key(key)) : f;
  await t.ensureVisible(target.first);
  await t.enterText(target.first, text);
  await t.pumpAndSettle();
};

/// Hisoblash tugmasi, so‘ng natija (yoki xato) ekranga keltiriladi.
Act _calculateAndShow() => seq([
  (t, c) async {
    final b = find.byKey(const Key('calc.calculate'));
    if (b.evaluate().isNotEmpty) await _tap(t, b);
  },
  (t, c) async {
    for (final k in ['calc.error', 'calc.result']) {
      final f = find.byKey(Key(k));
      if (f.evaluate().isNotEmpty) {
        await t.ensureVisible(f.first);
        await t.pumpAndSettle();
        return;
      }
    }
  },
]);

/// Xato kiritish: har maydonga bir xil qiymat.
Act calc(String fill) => seq([enterAll(fill), _calculateAndShow()]);

/// To‘g‘ri kiritish: har kalkulyator uchun ma’lum javobli namuna qiymatlar
/// (o‘nlik vergul bilan — uz klaviaturasi). Maydon kaliti → qiymat.
/// Kutilgan javoblar `test/widget/calc_correct_input_test.dart` da.
const calcSamples = <String, List<(String, String)>>{
  'tool.fm.pmi_henssge': [
    ('calc.rectal', '30'),
    ('calc.ambient', '15'),
    ('calc.weight', '70'),
  ],
  'tool.tox.widmark': [
    ('calc.weight', '70'),
    ('calc.drink.0.volume', '100'),
    ('calc.drink.0.abv', '40'),
    ('calc.hours', '1'),
  ],
  'tool.tox.back_calculation': [('calc.bac', '0,5'), ('calc.hours', '2')],
  'tool.lab.dilution': [
    ('calc.field.c1', '10'),
    ('calc.field.c2', '1'),
    ('calc.field.v2', '100'),
  ],
  'tool.lab.solution': [
    ('calc.solution.conc', '10'),
    ('calc.solution.vol', '100'),
  ],
  'tool.lab.percent': [('calc.percent', '5'), ('calc.total', '200')],
  'tool.lab.molarity': [
    ('calc.mass', '584,4'),
    ('calc.mm', '58,44'),
    ('calc.volume', '100'),
  ],
  'tool.lab.calibration': [
    ('calc.points', '0 0,02\n1 0,21\n2 0,39\n5 1,01\n10 1,98'),
  ],
  'tool.lab.lod_loq': [
    ('calc.points', '0 0,02\n1 0,21\n2 0,39\n5 1,01\n10 1,98'),
  ],
  'tool.lab.descriptive_stats': [('calc.values', '0,52 0,49 0,55 0,51 0,50')],
  'tool.conv.concentration_units': [('calc.value', '1,5')],
  'tool.conv.ethanol_units': [('calc.value', '0,8')],
  'tool.lab.beer_lambert': [
    ('calc.absorbance', '0,45'),
    ('calc.absorptivity', '15000'),
    ('calc.path', '1'),
  ],
};

Act calcSample(String toolId) => seq([
  for (final (k, v) in calcSamples[toolId]!) enterKey(k, v),
  if (toolId == 'tool.lab.lod_loq') tapKey('calc.regress'),
  _calculateAndShow(),
]);

// ---------------------------------------------------------- sinf «serveri»

class _Share implements ClassFileShare {
  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  }) async {}
}

class ClassWorld {
  ClassWorld() {
    // Haqiqiy savollar banki (ilova asseti); DEMO to‘plam yo‘q.
    backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(5),
      teachers: {'t1'},
      topics: const [],
      topicLoader: () async =>
          ClassQuizBank.parse(File(classQuizBankAsset).readAsStringSync())
              .variants,
    );
    teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
    student = FakeClassQuizService(backend, userId: 'stu', demo: false);
  }
  var now = DateTime(2026, 10, 17, 10);
  late final FakeClassQuizBackend backend;
  late final FakeClassQuizService teacher;
  late final FakeClassQuizService student;
}

ClassWorld? _world;

Future<ClassSessionInfo> _session({int students = 3}) async {
  final w = _world!;
  final s = (await w.teacher.createSession(
    // Sud-tibbiy toksikologiya (4-kurs, davolash) — ilova tilidagi variant.
    topicId: ClassQuizBank.variantId('4-kurs-davolash-10', _lang),
    settings: const ClassQuizSettings(questionCount: 5, studentLimit: 30),
  )).value!;
  for (final n in ['Ali', 'Gulnora', 'Bekzod'].take(students)) {
    final svc = n == 'Ali'
        ? w.student
        : FakeClassQuizService(w.backend, userId: n, demo: false);
    await svc.join(code: s.code, nickname: n);
  }
  return s;
}

/// Ustoz/talaba ko‘rinishi: `asStudent` bo‘lsa talaba xizmati provayderda.
bool _asStudent = false;

/// Joriy variant tili (sinf mavzusi shu tildagi varianti tanlanadi).
String _lang = 'uz';

// ------------------------------------------------------------------ katalog

final shots = <Shot>[
  // --- Onboarding
  Shot(
    'onboarding_til',
    'Onboarding: til tanlash',
    Routes.language,
    persona: Persona.guestOnboarding,
    important: true,
    settings: (v) => AppSettings(themeMode: v.theme),
  ),
  Shot(
    'onboarding_ogohlantirish',
    'Onboarding: ilmiy ogohlantirish',
    Routes.disclaimer,
    persona: Persona.guestOnboarding,
    important: true,
    settings: (v) => AppSettings(locale: Locale(v.lang), themeMode: v.theme),
  ),
  Shot(
    'onboarding_rejim',
    'Onboarding: rejim (talaba/mutaxassis)',
    Routes.mode,
    persona: Persona.guestOnboarding,
    important: true,
    settings: (v) => AppSettings(
      locale: Locale(v.lang),
      themeMode: v.theme,
      acceptedDisclaimerVersion: currentDisclaimerVersion,
    ),
  ),
  Shot(
    'onboarding_hisob',
    'Onboarding: hisob taklifi',
    Routes.welcomeAccount,
    persona: Persona.guestOnboarding,
    settings: (v) => AppSettings(
      locale: Locale(v.lang),
      themeMode: v.theme,
      userMode: UserMode.student,
      acceptedDisclaimerVersion: currentDisclaimerVersion,
    ),
  ),
  // --- Asosiy
  const Shot('asosiy_talaba', 'Asosiy (talaba)', Routes.home, important: true),
  Shot(
    'asosiy_talaba',
    'Asosiy (talaba)',
    Routes.home,
    state: 'pastki qism',
    act: scrollBy(5000),
  ),
  const Shot(
    'asosiy_mutaxassis',
    'Asosiy (mutaxassis)',
    Routes.home,
    persona: Persona.expert,
    important: true,
  ),
  Shot(
    'asosiy_mutaxassis',
    'Asosiy (mutaxassis)',
    Routes.home,
    persona: Persona.expert,
    state: 'pastki qism',
    act: scrollBy(5000),
  ),
  // --- Ustoz paneli va sinfda test
  const Shot('ustoz_paneli', 'Ustoz paneli', Routes.teacher, important: true),
  const Shot(
    'ustoz_natijalar',
    'Ustoz: natijalar va CSV',
    Routes.teacherResults,
    state: 'bo‘sh',
  ),
  const Shot(
    'sinfda_test',
    'Sinfda test (qo‘shilish)',
    Routes.classQuiz,
    important: true,
  ),
  Shot(
    'sinfda_test',
    'Sinfda test (qo‘shilish)',
    Routes.classQuiz,
    state: 'noto‘g‘ri kod xatosi',
    act: seq([enterKey('class.codeField', '12'), tapKey('class.joinButton')]),
  ),
  const Shot(
    'sinf_yaratish',
    'Ustoz: test yaratish (mavzu tanlash)',
    Routes.classNew,
    classWorld: true,
    important: true,
  ),
  Shot(
    'sinf_yaratish',
    'Ustoz: test yaratish (mavzu tanlash)',
    Routes.classNew,
    state: 'qidiruv «toksik» + mavzu tanlangan',
    classWorld: true,
    important: true,
    act: seq([
      (t, c) async {
        await enterKey('class.topicSearch', switch (_lang) {
          'ru' => 'токсик',
          'en' => 'toxic',
          _ => 'toksik',
        })(t, c);
      },
      tapPrefix('class.topic.4-kurs-davolash-10'),
      scrollTo('class.createSubmit'),
    ]),
  ),
  Shot(
    'sinf_kod_qr',
    'Ustoz: kod va QR (kutish zali)',
    '/class-host',
    classWorld: true,
    important: true,
    act: (t, c) async {
      final s = await _session();
      c.read(routerProvider).go(Routes.classHost(s.id));
      await _frames(t);
    },
  ),
  Shot(
    'sinf_savol_ustoz',
    'Ustoz: savol jarayoni',
    '/class-host',
    classWorld: true,
    act: (t, c) async {
      final s = await _session();
      await _world!.teacher.start(s.id);
      c.read(routerProvider).go(Routes.classHost(s.id));
      await _frames(t);
    },
  ),
  Shot(
    'sinf_natija_ustoz',
    'Ustoz: yakuniy natija va CSV',
    '/class-host',
    classWorld: true,
    act: (t, c) async {
      final s = await _session();
      await _world!.teacher.start(s.id);
      await _world!.teacher.finish(s.id);
      c.read(routerProvider).go(Routes.classHost(s.id));
      await _frames(t);
    },
  ),
  Shot(
    'sinf_natijalar_royxat',
    'Ustoz: natijalar ro‘yxati (tugagan sinf, CSV tugmasi)',
    '/class-host',
    classWorld: true,
    act: (t, c) async {
      final s = await _session();
      await _world!.teacher.start(s.id);
      await _world!.teacher.finish(s.id);
      c.read(routerProvider).go(Routes.teacherResults);
      await _frames(t);
    },
  ),
  Shot(
    'sinf_qoshilish_talaba',
    'Talaba: kod + laqab',
    '/class-join',
    classWorld: true,
    important: true,
    act: (t, c) async {
      _asStudent = true;
      final s = await _session(students: 0);
      c.read(routerProvider).go(Routes.classJoinWith(s.code));
      await _frames(t);
    },
  ),
  Shot(
    'sinf_savol_talaba',
    'Talaba: savolga javob',
    '/class-play',
    classWorld: true,
    act: (t, c) async {
      _asStudent = true;
      final s = await _session();
      await _world!.teacher.start(s.id);
      c.read(routerProvider).go(Routes.classPlay(s.id));
      await _frames(t);
    },
  ),
  Shot(
    'sinf_natija_talaba',
    'Talaba: yakuniy natija',
    '/class-play',
    classWorld: true,
    act: (t, c) async {
      _asStudent = true;
      final s = await _session();
      await _world!.teacher.start(s.id);
      await _world!.teacher.finish(s.id);
      c.read(routerProvider).go(Routes.classPlay(s.id));
      await _frames(t);
    },
  ),
  // --- O‘qish
  const Shot('oqish', 'O‘qish', Routes.learn, important: true),
  Shot(
    'oqish_kurs',
    'O‘qish: kurs/dars',
    Routes.learn,
    state: 'dars ochilgan',
    act: tapPrefix('learn.course.'),
  ),
  const Shot('mashqlar', 'Mashqlar (to‘plamlar)', Routes.study),
  Shot(
    'mashq_kartochka',
    'Mashq: kartochka',
    Routes.study,
    act: seq([tapPrefix('study.cards.')]),
  ),
  Shot(
    'mashq_test',
    'Mashq: test savoli',
    Routes.study,
    act: tapPrefix('study.quiz.'),
  ),
  Shot(
    'mashq_test',
    'Mashq: test savoli',
    Routes.study,
    state: 'javob tekshirildi',
    act: seq([
      tapPrefix('study.quiz.'),
      tapPrefix('study.quiz.option.'),
      tapKey('study.quiz.check'),
    ]),
  ),
  Shot('imtihon', 'Imtihon', Routes.study, act: tapPrefix('study.exam.')),
  // --- Qidiruv
  const Shot(
    'qidiruv',
    'Qidiruv',
    Routes.search,
    state: 'bo‘sh',
    important: true,
  ),
  Shot(
    'qidiruv',
    'Qidiruv',
    Routes.searchWith('etanol'),
    state: 'natijalar',
    important: true,
  ),
  Shot('qidiruv', 'Qidiruv', Routes.searchWith('zzqxw'), state: 'natija yo‘q'),
  Shot(
    'kengaytirilgan_qidiruv',
    'Kengaytirilgan qidiruv',
    Routes.proSearchWith('morfin'),
    persona: Persona.expert,
  ),
  // --- Kutubxona va kontent
  const Shot('kutubxona', 'Kutubxona', Routes.library, important: true),
  Shot('moddalar', 'Moddalar ro‘yxati', Routes.librarySection('substances')),
  Shot(
    'modda_etanol',
    'Modda: Etanol',
    Routes.libraryEntry('ethanol'),
    important: true,
  ),
  Shot(
    'modda_etanol',
    'Modda: Etanol',
    Routes.libraryEntry('ethanol'),
    state: 'Tahlil bo‘limi',
    act: tapKey('entry.index.analysis'),
  ),
  Shot(
    'modda_etanol',
    'Modda: Etanol',
    Routes.libraryEntry('ethanol'),
    state: 'yurisdiksiya qatlami',
    act: tapKey('entry.index.jurisdiction'),
  ),
  Shot(
    'modda_etanol',
    'Modda: Etanol',
    Routes.libraryEntry('ethanol'),
    state: 'bog‘liq materiallar',
    act: tapKey('entry.index.related'),
  ),
  Shot(
    'modda_etanol',
    'Modda: Etanol',
    Routes.libraryEntry('ethanol'),
    state: 'manbalar',
    act: tapKey('entry.index.sources'),
  ),
  Shot(
    'modda_etanol',
    'Modda: Etanol',
    Routes.libraryEntry('ethanol'),
    state: 'provenance bottom sheet',
    act: tapPrefix('claim.provenance.'),
  ),
  Shot(
    'modda_morfin',
    'Modda: Morfin',
    Routes.libraryEntry('morphine'),
    important: true,
  ),
  Shot('tahlil_rejasi', 'Tahlil rejasi', Routes.homePlan('morphine')),
  Shot('usullar', 'Usullar va SOP', Routes.knowledge('method')),
  Shot(
    'usul',
    'Usul sahifasi',
    Routes.knowledge('method'),
    act: tapPrefix('knowledge.'),
  ),
  Shot('reagentlar', 'Reagentlar', Routes.knowledge('reagent')),
  Shot(
    'reagent',
    'Reagent sahifasi',
    Routes.knowledge('reagent'),
    act: tapPrefix('knowledge.'),
  ),
  Shot('skrining', 'Skrining testlari', Routes.knowledge('screeningTest')),
  Shot(
    'skrining_test',
    'Skrining test sahifasi',
    Routes.knowledge('screeningTest'),
    act: tapPrefix('knowledge.'),
  ),
  const Shot(
    'yoriqnomalar',
    'Yo‘riqnomalar',
    Routes.guidelines,
    important: true,
  ),
  Shot(
    'yoriqnoma',
    'Yo‘riqnoma kartasi',
    Routes.guidelines,
    act: tapPrefix('guidelines.card.'),
  ),
  const Shot('manbalar', 'Manbalar ro‘yxati', Routes.sources),
  Shot(
    'manba',
    'Manba sahifasi',
    Routes.sources,
    act: tapPrefix('sources.item.'),
  ),
  const Shot('lugat', 'Ilmiy lug‘at', Routes.glossary),
  Shot(
    'lugat_termin',
    'Lug‘at: termin',
    Routes.glossary,
    act: tapPrefix('glossary.term.'),
  ),
  const Shot('namunalar', 'Biologik namunalar', Routes.specimens),
  Shot(
    'namuna',
    'Namuna sahifasi',
    Routes.specimens,
    act: tapPrefix('specimens.'),
  ),
  const Shot('ziddiyatlar', 'Ziddiyatlar', Routes.conflicts),
  const Shot('tekshiruv_holati', 'Tekshiruv holati', Routes.reviewStatus),
  const Shot('tadqiqotlar', 'Tadqiqotlar va dalillar', Routes.research),
  Shot(
    'tadqiqot',
    'Tadqiqot sahifasi',
    Routes.research,
    act: tapPrefix('research.'),
  ),
  const Shot('standartlar', 'Standartlar', Routes.libraryStandards),
  const Shot('fanlar', 'Barcha fanlar', Routes.disciplines),
  Shot(
    'fan',
    'Fan sahifasi',
    Routes.discipline('forensic_chemistry'),
    important: true,
  ),
  const Shot('sud_tibbiyoti', 'Sud tibbiyoti', Routes.forensicMedicine),
  const Shot('biokimyo', 'Biokimyo', Routes.biochemistry),
  const Shot('gistologiya', 'Gistologiya', Routes.histology),
  const Shot(
    'yurisdiksiyalar',
    'Huquq va yurisdiksiyalar',
    Routes.jurisdictions,
  ),
  Shot('yurisdiksiya', 'Yurisdiksiya: O‘zbekiston', Routes.jurisdiction('UZ')),
  const Shot('solishtirish', 'Yurisdiksiyalarni solishtirish', Routes.compare),
  // --- Sudda so‘roq
  const Shot(
    'sudda_soroq',
    'Sudda so‘roq',
    Routes.courtPrep,
    persona: Persona.expert,
    important: true,
  ),
  const Shot(
    'sudda_soroq_mashq',
    'Sudda so‘roq: mashq',
    Routes.courtPrepPractice,
    persona: Persona.expert,
  ),
  const Shot(
    'sudda_soroq_tamoyillar',
    'Sudda so‘roq: tamoyillar',
    Routes.courtPrepPrinciples,
    persona: Persona.expert,
  ),
  const Shot(
    'sudda_soroq_simulyator',
    'Sudda so‘roq: simulyator',
    Routes.courtPrepSimulator,
    persona: Persona.expert,
  ),
  Shot(
    'sudda_soroq_ssenariy',
    'Sudda so‘roq: ssenariy',
    Routes.courtPrepSimulator,
    persona: Persona.expert,
    act: tapPrefix('court.scenario.'),
  ),
  const Shot(
    'sudda_soroq_drill',
    'Sudda so‘roq: tezkor mashq',
    Routes.courtPrepDrill,
    persona: Persona.expert,
  ),
  const Shot(
    'sudda_soroq_statistika',
    'Sudda so‘roq: statistika',
    Routes.courtPrepStats,
    persona: Persona.expert,
  ),
  Shot(
    'sudda_soroq_mavzu',
    'Sudda so‘roq: mavzu',
    Routes.courtPrep,
    persona: Persona.expert,
    act: tapPrefix('court.topic.'),
  ),
  // --- Vositalar
  const Shot(
    'vositalar',
    'Vositalar',
    Routes.tools,
    persona: Persona.expert,
    important: true,
  ),
  for (final tool in ToolsCatalog.all) ...[
    Shot(
      'kalk_${tool.id.split('.').last}',
      'Kalkulyator: ${tool.id}',
      Routes.tool(tool.id),
      persona: Persona.expert,
      state: 'bo‘sh',
      important: tool.id == 'tool.tox.widmark',
    ),
    Shot(
      'kalk_${tool.id.split('.').last}',
      'Kalkulyator: ${tool.id}',
      Routes.tool(tool.id),
      persona: Persona.expert,
      state: 'to‘g‘ri kiritish (namuna qiymatlar)',
      act: calcSample(tool.id),
    ),
    Shot(
      'kalk_${tool.id.split('.').last}',
      'Kalkulyator: ${tool.id}',
      Routes.tool(tool.id),
      persona: Persona.expert,
      state: 'xato kiritish (har maydon «0»)',
      act: calc('0'),
    ),
  ],
  const Shot(
    'ish_daftari',
    'Ekspert ish daftari',
    Routes.casebook,
    persona: Persona.expert,
    state: 'bo‘sh',
  ),
  Shot(
    'ish_daftari',
    'Ekspert ish daftari',
    Routes.casebook,
    persona: Persona.expert,
    state: 'yangi yozuv',
    act: tapKey('casebook.new'),
  ),
  // --- AI
  const Shot('ai', 'Forensic AI', Routes.ai, state: 'bo‘sh', important: true),
  Shot(
    'ai',
    'Forensic AI',
    Routes.ai,
    state: 'savol + oflayn manbalar (AI serveri yo‘q)',
    important: true,
    act: seq([
      enterKey('ai.input', 'Etanolni qonda qanday aniqlash mumkin?'),
      tapKey('ai.findSources'),
    ]),
  ),
  Shot(
    'ai',
    'Forensic AI',
    Routes.ai,
    state: 'javob uslubi (Qisqa / Batafsil)',
    important: true,
    act: scrollTo('ai.experience'),
  ),
  Shot(
    'ai',
    'Forensic AI',
    Routes.ai,
    state: 'shaxsiy ma’lumot ogohlantirishi',
    act: enterKey('ai.input', 'Bemor Aliyev Vali, tel +998901234567'),
  ),
  // --- Profil va sozlamalar
  const Shot('profil', 'Profil (mehmon)', Routes.profile, important: true),
  Shot(
    'profil',
    'Profil (mehmon)',
    Routes.profile,
    state: 'pastki qism',
    act: scrollBy(5000),
  ),
  const Shot(
    'profil_admin',
    'Profil (kirgan admin)',
    Routes.profile,
    persona: Persona.admin,
  ),
  const Shot('sozlama_til', 'Sozlama: til', Routes.profileLanguage),
  const Shot('sozlama_rejim', 'Sozlama: rejim', Routes.profileMode),
  const Shot(
    'sozlama_yurisdiksiya',
    'Sozlama: yurisdiksiya',
    Routes.profileJurisdiction,
  ),
  const Shot(
    'sozlama_ogohlantirish',
    'Ilmiy ogohlantirish',
    Routes.profileDisclaimer,
  ),
  const Shot('profil_tahrir', 'Profilni tahrirlash', Routes.profileEdit),
  const Shot('maxfiylik', 'Maxfiylik siyosati', Routes.privacy),
  const Shot('shartlar', 'Foydalanish shartlari', Routes.terms),
  const Shot('ilova_haqida', 'Ilova haqida', Routes.about),
  const Shot(
    'manbalar_mualliflar',
    'Manbalar va mualliflar',
    Routes.aboutSources,
  ),
  const Shot('ai_ogohlantirish', 'AI ogohlantirishi', Routes.aiDisclaimer),
  const Shot(
    'tasdiqlash',
    'Professional tasdiqlash',
    Routes.verification,
    persona: Persona.expert,
  ),
  const Shot(
    'tasdiqlash_hujjatlar',
    'Tasdiqlash: hujjatlar',
    Routes.verificationDocuments,
    persona: Persona.expert,
  ),
  const Shot(
    'taqriz_paneli',
    'Taqriz ish joyi',
    Routes.reviewDashboard,
    persona: Persona.expert,
  ),
  const Shot('taklif', 'Hamkasbni taklif qilish', Routes.referral),
  const Shot(
    'murojaatlar',
    'Taklif va murojaatlar',
    Routes.support,
    persona: Persona.admin,
  ),
  const Shot(
    'murojaat_yozish',
    'Yangi murojaat',
    Routes.supportNew,
    persona: Persona.admin,
  ),
  Shot(
    'murojaat_suhbat',
    'Murojaat suhbati',
    Routes.supportThread('thread-1'),
    persona: Persona.admin,
  ),
  const Shot('shikoyat', 'Shikoyat yuborish', Routes.report),
  // --- Kirish va hisob
  const Shot(
    'kirish_email_kod',
    'Kirish: email kod (Google/Apple tugmalari)',
    Routes.accountEmailCode,
    important: true,
  ),
  Shot(
    'kirish_email_kod',
    'Kirish: email kod',
    Routes.accountEmailCode,
    state: 'noto‘g‘ri email xatosi',
    act: seq([
      enterAll('abc'),
      (t, c) async {
        // Maydondan chiqish — inline xato shu paytda ko‘rinadi.
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pumpAndSettle();
      },
      tapKey('emailCode.send'),
    ]),
  ),
  const Shot('kirish_parol', 'Kirish (parol)', Routes.accountSignIn),
  const Shot('royxatdan_otish', 'Ro‘yxatdan o‘tish', Routes.accountRegister),
  const Shot('parol_tiklash', 'Parolni tiklash', Routes.accountForgot),
  const Shot(
    'hisobni_ochirish',
    'Hisobni o‘chirish',
    Routes.accountDelete,
    persona: Persona.admin,
  ),
  // --- Maqolalar
  const Shot(
    'maqolalar',
    'Ekspert maqolalari',
    Routes.publications,
    persona: Persona.expert,
    state: 'server ulanmagan',
  ),
  const Shot(
    'maqola_yuborish',
    'Maqola yuborish',
    Routes.publicationSubmit,
    persona: Persona.expert,
  ),
  const Shot(
    'maqolalarim',
    'Mening maqolalarim',
    Routes.publicationsMine,
    persona: Persona.expert,
  ),
  // --- Admin
  const Shot(
    'admin_panel',
    'Boshqaruv paneli',
    Routes.admin,
    persona: Persona.admin,
    important: true,
  ),
  const Shot(
    'admin_murojaatlar',
    'Admin: murojaatlar qutisi',
    Routes.adminInbox,
    persona: Persona.admin,
  ),
  Shot(
    'admin_suhbat',
    'Admin: murojaat',
    Routes.adminThread('thread-3'),
    persona: Persona.admin,
  ),
  const Shot(
    'admin_foydalanuvchilar',
    'Admin: foydalanuvchilar',
    Routes.adminUsers,
    persona: Persona.admin,
  ),
  const Shot(
    'admin_jurnal',
    'Admin: amallar jurnali',
    Routes.adminAudit,
    persona: Persona.admin,
  ),
  const Shot(
    'admin_shikoyatlar',
    'Admin: shikoyatlar',
    Routes.adminReports,
    persona: Persona.admin,
  ),
  const Shot(
    'admin_tasdiqlash',
    'Admin: tasdiqlash arizalari',
    Routes.adminVerifications,
    persona: Persona.admin,
  ),
  const Shot(
    'admin_moderatsiya',
    'Admin: maqolalar moderatsiyasi',
    Routes.publicationsModeration,
    persona: Persona.admin,
  ),
  // --- Dialog / sheet / snackbar
  Shot(
    'dialog_daftar_tozalash',
    'Dialog: ish daftarini tozalash',
    Routes.casebook,
    persona: Persona.expert,
    act: seq([
      tapKey('casebook.new'),
      enterKey('casebook.field.title', 'Namuna'),
      tapKey('casebook.save'),
      (t, c) async {
        c.read(routerProvider).go(Routes.casebook);
        await t.pumpAndSettle();
      },
      tapKey('casebook.menu'),
      tapKey('casebook.clearAll'),
    ]),
  ),
  Shot(
    'sheet_iqtibos',
    'Bottom sheet: iqtibos (ГОСТ/APA)',
    Routes.libraryEntry('ethanol'),
    act: seq([tapPrefix('claim.provenance.'), tapPrefix('provenance.cite.')]),
  ),
  Shot(
    'snackbar_nusxa',
    'Snackbar: natija nusxalandi',
    Routes.tool('tool.lab.dilution'),
    persona: Persona.expert,
    act: seq([
      calcSample('tool.lab.dilution'),
      (t, c) async {
        // Testda platforma kanaliga javob beruvchi yo‘q: Clipboard.setData
        // kutib qolardi va snackbar chiqmasdi (avvalgi katalogda 163 bo‘sh).
        t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
      },
      tapKey('calc.copy'),
      (t, c) async {
        await t.pump(const Duration(milliseconds: 400));
        t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      },
    ]),
  ),
  Shot(
    'dialog_ustoz_tugatish',
    'Dialog: sinfni tugatish',
    '/class-host',
    classWorld: true,
    act: (t, c) async {
      final s = await _session();
      c.read(routerProvider).go(Routes.classHost(s.id));
      await _frames(t);
      await t.tap(find.byKey(const Key('class.endButton')));
      await _frames(t);
    },
  ),
];

// ------------------------------------------------------------- yozuvchi

class _Writer extends GoldenFileComparator {
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    File('$_out/${golden.path}')
      ..createSync(recursive: true)
      ..writeAsBytesSync(imageBytes);
    return true;
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async =>
      compare(imageBytes, golden);
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('SourceSerif4', [
    'assets/fonts/source_serif_4/SourceSerif4-Regular.ttf',
    'assets/fonts/source_serif_4/SourceSerif4-SemiBold.ttf',
    'assets/fonts/source_serif_4/SourceSerif4-Bold.ttf',
  ]);
  await load('Inter', [
    'assets/fonts/inter/Inter-Regular.ttf',
    'assets/fonts/inter/Inter-Medium.ttf',
    'assets/fonts/inter/Inter-SemiBold.ttf',
    'assets/fonts/inter/Inter-Bold.ttf',
  ]);
  await load('JetBrainsMono', [
    'assets/fonts/jetbrains_mono/JetBrainsMono-Regular.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

InMemorySupportService _support() {
  final s = InMemorySupportService(isAdmin: true, stats: fixtureAdminStats)
    ..users.addAll(fixtureAdminUsers);
  final a = s.seedThread(
    category: SupportCategory.scientificError,
    subject: 'Morfin: yarim chiqarilish davri',
    body: 'Kartadagi qiymat keltirilgan manbadagidan farq qiladi.',
    relatedEntity: 'substance:morphine',
    mine: true,
  );
  s.simulateAdminReply(a, 'Rahmat! Manbani tekshirdik — tuzatiladi.');
  s.seedThread(
    category: SupportCategory.suggestion,
    subject: 'Tungi navbat uchun qorong‘i mavzu',
    body: 'Laboratoriyada kechasi ishlash uchun to‘qroq mavzu kerak.',
    mine: true,
  );
  s.seedThread(
    category: SupportCategory.bug,
    subject: 'Qidiruvda ilova yopilib qoladi',
    body: '«morfin» yozilganda ilova yopiladi (Android 14).',
    authorEmail: 'student@univ.test',
  );
  return s;
}

void main() {
  late PilotContent pilot;
  final rows = <String>[];
  var n = 0;

  setUpAll(() async {
    await _loadFonts();
    pilot = await loadPilotContent();
    goldenFileComparator = _Writer();
    final dir = Directory(_out);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
  });

  tearDownAll(() {
    File('$_out/index.md').writeAsStringSync('''
# Ekranlar katalogi — 2026-10-17 (premium dizayn)

Yaratilgan: `flutter test --tags catalog --run-skipped test/catalog`
(haqiqiy shriftlar, soyalar yoqilgan, 1x — 390 px kenglik; 320 dp — 320 px),
so‘ng `python3 tool/compress_catalog_png.py` (256 rang, hajm kichik).
Ma’lumot: ilovadagi pilot kontent paketi; akkaunt MOCK; sinf serveri, murojaatlar
va admin statistikasi — TEST soxta xizmatlari (FIXTURE). Tarmoq yo‘q, AI serveri
ulanmagan (AI oflayn holati ko‘rsatiladi). Real iOS/Android qurilma emas.

Variantlar: `uz` — o‘zbekcha 390 dp yorug‘, `uzdark` — qorong‘i, `ru`/`en` —
yorug‘ 390 dp, `uz320` — 320 dp. «Xato» ustuni — chizishda ushlangan Flutter
xatosi (masalan, overflow); bo‘sh bo‘lsa — xato yo‘q.

| # | Ekran | Marshrut | Holat | Persona | Fayllar | Xato |
|---|---|---|---|---|---|---|
${rows.join('\n')}
''');
  });

  for (final shot in shots) {
    n++;
    final num = n.toString().padLeft(3, '0');
    final variants = [
      V.uzLight,
      V.uzDark,
      if (shot.important) ...[V.ruLight, V.enLight, V.uz320],
    ];
    final stateSlug = shot.state == 'standart'
        ? ''
        : '_${shot.state.split(' ').first.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}';
    final files = <String>[];
    final errors = <String>[];
    for (final v in variants) {
      final file =
          '${num}_${shot.id}${stateSlug}_${switch (v) {
            V.uzLight => 'uz',
            V.uzDark => 'uzdark',
            V.ruLight => 'ru',
            V.enLight => 'en',
            V.uz320 => 'uz320',
          }}.png';
      testWidgets('$num ${shot.title} · ${shot.state} · ${v.name}', (t) async {
        debugDisableShadows = false;
        _asStudent = false;
        _lang = v.lang;
        _world = shot.classWorld ? ClassWorld() : null;
        final settings =
            shot.settings?.call(v) ??
            completedSettings(
              lang: v.lang,
              theme: v.theme,
              mode: shot.persona == Persona.student
                  ? UserMode.student
                  : UserMode.professional,
            );
        final admin = shot.persona == Persona.admin;
        final overrides = <Override>[
          ...pilot.overrides,
          guidelineBundleLoaderProvider.overrideWithValue(
            () async =>
                File('assets/content/guidelines/guidelines_v1.json')
                    .readAsStringSync(),
          ),
          courtPrepLoaderProvider.overrideWithValue(
            () async => File(courtPrepAsset).readAsStringSync(),
          ),
          abbreviationNotesLoaderProvider.overrideWithValue(
            () async => File(abbreviationGlossaryAsset).readAsStringSync(),
          ),
          supportServiceProvider.overrideWithValue(_support()),
          classQuizBankLoaderProvider.overrideWithValue(
            () async => File(classQuizBankAsset).readAsStringSync(),
          ),
          publicationsFlagProvider.overrideWithValue(true),
          if (admin) ...[
            authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
            accountServiceProvider.overrideWithValue(
              FakeAccountService(access: const ServerAccess(isAdmin: true)),
            ),
          ],
          if (_world != null) ...[
            classQuizServiceProvider.overrideWith(
              (ref) => _asStudent ? _world!.student : _world!.teacher,
            ),
            classQuizPollIntervalProvider.overrideWithValue(
              const Duration(milliseconds: 100),
            ),
            classFileShareProvider.overrideWithValue(_Share()),
            classScannerAvailableProvider.overrideWithValue(false),
            classLandscapePromptEnabledProvider.overrideWithValue(false),
          ],
        ];
        // Sinf: talaba ko‘rinishi act ichida tanlanadi — provayder o‘qilishidan
        // oldin bayroq qo‘yiladi.
        if (shot.classWorld &&
            (shot.id.contains('talaba') || shot.id.contains('qoshilish'))) {
          _asStudent = true;
        }
        final c = await pumpApp(
          t,
          settings: settings,
          size: v.size,
          pixelRatio: 1,
          testFixtures: false,
          platformBrightness: v.theme == ThemeMode.dark
              ? Brightness.dark
              : Brightness.light,
          overrides: overrides,
        );
        if (!shot.route.startsWith('/class-') &&
            shot.persona != Persona.guestOnboarding) {
          c.read(routerProvider).go(shot.route);
          await t.pumpAndSettle();
        } else if (shot.persona == Persona.guestOnboarding) {
          c.read(routerProvider).go(shot.route);
          await t.pumpAndSettle();
        }
        try {
          if (shot.act != null) await shot.act!(t, c);
        } on Object catch (e) {
          errors.add('amal: ${'$e'.split('\n').first}');
        }
        if (shot.classWorld) {
          await _frames(t, 4);
        } else {
          await t.pumpAndSettle();
        }
        await settleImagesSafe(t);
        final ex = t.takeException();
        if (ex != null) errors.add('${v.name}: ${'$ex'.split('\n').first}');
        await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
        debugDisableShadows = true;
        files.add(file);
        if (v == variants.last) {
          rows.add(
            '| $num | ${shot.title} | `${shot.route}` | ${shot.state} | '
            '${shot.persona.name} | ${files.map((f) => '[${f.split('_').last}]($f)').join(' ')} | '
            '${errors.join('; ')} |',
          );
        }
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(seconds: 1));
      });
    }
  }
}

/// Rasmlarni yuklash — xato bo‘lsa e’tiborsiz (katalog to‘xtamasin).
Future<void> settleImagesSafe(WidgetTester t) async {
  try {
    await t.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await t.pump();
  } on Object {
    // e’tiborsiz
  }
}
