import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_bank.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/class_quiz/class_topic_catalog.dart';
import 'package:forensic_expert/features/class_quiz/presentation/class_topic_groups.dart';

/// «Test o‘tkazish» mavzu ro‘yxati: bitta ro‘yxat, har fakultet/fan bir
/// marta, takrorsiz. Fixture — production `class_topics()` javobining
/// nusxasi (topic_id, title, count, course; 2026-11-07).
void main() {
  final bank = ClassQuizBank.parse(File(classQuizBankAsset).readAsStringSync());
  final server = [
    for (final j in jsonDecode(
      File('test/fixtures/class_topics_server.json').readAsStringSync(),
    ) as List)
      ClassTopic.fromJson((j as Map).cast<String, Object?>()),
  ];
  const other = 'Boshqa mavzular';
  const forbidden = ['kurs', 'toifa', '2026', 'KTP', 'курс', 'course'];

  Map<String, int> counts(List<ClassTopicGroupData> gs) => {
    for (final g in gs) g.title: g.items.length,
  };

  for (final lang in ['uz', 'ru', 'en']) {
    test('$lang: bitta ro‘yxat — guruh nomlari va mavzu id’lari takrorsiz', () {
      final gs = groupClassTopics(server, bank, lang, other, '');
      final titles = gs.map((g) => g.title).toList();
      expect(titles.toSet().length, titles.length, reason: '$titles');
      final ids = [
        for (final g in gs)
          for (final x in g.items) ClassQuizBank.baseId(x.topic.id),
      ];
      expect(ids.toSet().length, ids.length);
      // Bir guruh ichida bir xil nomli mavzu ikki marta yo‘q.
      for (final g in gs) {
        final names = g.items.map((x) => x.title.trim()).toList();
        expect(names.toSet().length, names.length, reason: g.title);
      }
      // Ilova tilidagi variant tanlanadi (~ru/~en bitta qatorga yig‘ilgan).
      for (final g in gs) {
        for (final x in g.items) {
          final vl = ClassQuizBank.variantLang(x.topic.id);
          expect(vl == lang || vl == 'uz', isTrue, reason: x.topic.id);
        }
      }
      // «Boshqa mavzular» yo‘q — har mavzu fakultet/fanga tegishli.
      expect(titles, isNot(contains(other)));
      expect(gs.length, 8, reason: '$titles');
      for (final t in titles) {
        for (final w in forbidden) {
          expect(
            t.toLowerCase().contains(w.toLowerCase()),
            isFalse,
            reason: '$t ⊃ $w',
          );
        }
      }
    });
  }

  test('uz: yakuniy guruhlar va sonlari (bank + server birlashgan)', () {
    final gs = groupClassTopics(server, bank, 'uz', other, '');
    final c = counts(gs);
    expect(c.keys.toList(), [
      'Bioetika',
      'Davolash ishi',
      'Pediatriya',
      'Tibbiy profilaktika',
      'Stomatologiya',
      'Sud-tibbiy toksikologiya',
      'Toksikologik kimyo',
      'Apparatlar bilan ishlash',
    ]);
    expect(c['Bioetika'], 18);
    expect(c['Toksikologik kimyo'], 81);
    expect(c['Sud-tibbiy toksikologiya'], 9);
    expect(c['Apparatlar bilan ishlash'], 3);
    expect(c['Stomatologiya'], 57);
    expect(c['Tibbiy profilaktika'], 17);
    // Davolash: KTP (60) + 4-kurs (19) + 6-kurs (7) − «Darslar»da yashirin
    // takror (6-kurs-davolash-10) − bir xil nomli 6-kurs-davolash-03.
    expect(c['Davolash ishi'], 84);
    // Pediatriya: KTP (61) + 4-kurs (19) − 8 ta yashirin takror; «Amaliy
    // mashg‘ulot» deb qolgan nomlar o‘quv rejadagi to‘liq nom bilan.
    expect(c['Pediatriya'], 72);
    final all = {
      for (final g in gs)
        for (final x in g.items) ClassQuizBank.baseId(x.topic.id),
    };
    // Yashirin takrorlar va ktp26-u-* (fakultet nusxasi bor) ko‘rinmaydi.
    expect(all.any((id) => id.startsWith('ktp26-u-')), isFalse);
    expect(all, isNot(contains('4-kurs-pediatriya-04')));
    expect(all, isNot(contains('6-kurs-davolash-10')));
    expect(all, contains('ktp26-pediatriya-M2'));
    expect(all, isNot(contains('6-kurs-davolash-03')));
    final ped = gs.firstWhere((g) => g.title == 'Pediatriya');
    expect(
      ped.items.where(
        (x) => RegExp(
          r'^\W*amaliy\s+mashg.?ulot\W*$',
          caseSensitive: false,
        ).hasMatch(x.title),
      ),
      isEmpty,
    );
    // Kod emas, nom: «Transplantologiya (A7)» → «Transplantologiya».
    final bio = gs.firstWhere((g) => g.title == 'Bioetika');
    expect(bio.items.map((x) => x.title), contains('Transplantologiya'));
    // Joriy reja birinchi: Davolash ishi ma’ruza 1 dan boshlanadi.
    final dav = gs.firstWhere((g) => g.title == 'Davolash ishi');
    expect(ClassQuizBank.baseId(dav.items.first.topic.id), 'ktp26-davolash-M1');
  });

  test('ru/en: guruh nomlari tarjimada', () {
    expect(
      counts(groupClassTopics(server, bank, 'ru', other, '')).keys,
      containsAll(['Биоэтика', 'Лечебное дело', 'Педиатрия']),
    );
    expect(
      counts(groupClassTopics(server, bank, 'en', other, '')).keys,
      containsAll(['Bioethics', 'General Medicine', 'Toxicological chemistry']),
    );
  });

  test('bank va server bir xil id: bitta qator, bitta guruh', () {
    final topics = [
      for (final m in bank.topics)
        ClassTopic(id: m.id, title: m.title('uz'), count: 10),
      // Server nusxasi (kurs bilan) — o‘sha id’lar.
      for (final m in bank.topics)
        ClassTopic(
          id: m.id,
          title: m.title('uz'),
          count: 10,
          course: 'Davolash ishi fakulteti',
        ),
    ];
    final gs = groupClassTopics(topics, bank, 'uz', other, '');
    final ids = [
      for (final g in gs)
        for (final x in g.items) x.topic.id,
    ];
    expect(ids.toSet().length, ids.length);
    expect(ids.length, bank.topics.length);
    expect(gs.map((g) => g.title).toSet().length, gs.length);
  });

  test('faqat bank (oflayn): guruhlar takrorsiz, «Boshqa» yo‘q', () {
    final topics = [
      for (final v in classQuizLocalTopics(bank, includeDemo: false))
        ClassTopic(id: v.id, title: v.title, count: v.questions.length),
    ];
    final gs = groupClassTopics(topics, bank, 'uz', other, '');
    final titles = gs.map((g) => g.title).toList();
    expect(titles.toSet().length, titles.length);
    expect(titles, isNot(contains(other)));
  });

  test('ktp26-u-*: fakultet nusxasi bo‘lmasa — «Sud tibbiyoti (umumiy)»', () {
    const u = ClassTopic(
      id: 'ktp26-u-08',
      title: 'Sud tibbiyoti fani',
      count: 20,
    );
    const dav = ClassTopic(
      id: 'ktp26-davolash-A1',
      title: 'Sud tibbiyoti fani',
      count: 20,
    );
    final alone = groupClassTopics(const [u], bank, 'uz', other, '');
    expect(alone.single.title, 'Sud tibbiyoti (umumiy mavzular)');
    final both = groupClassTopics(const [u, dav], bank, 'uz', other, '');
    expect(both.single.title, 'Davolash ishi');
    expect(both.single.items.single.topic.id, 'ktp26-davolash-A1');
  });

  test('noma’lum id: server kursi bo‘yicha (nomi normallashtirilib)', () {
    expect(
      classTopicGroupOf('x-1', course: 'Davolash ishi fakulteti'),
      'sud-tibbiyoti-4-davolash',
    );
    expect(
      classTopicGroupOf('x-1', course: 'Sud-tibbiy toksikologiya'),
      'sud-toksikologiya',
    );
    expect(
      classTopicGroupOf('x-1', course: 'Toksikologik kimyo'),
      'toksikologik-kimyo',
    );
    expect(classTopicGroupOf('ktp26-davolash-A3'), 'sud-tibbiyoti-4-davolash');
    expect(
      classTopicGroupOf(
        '5-kurs-tibbiy-profilaktika-14',
        course: 'Davolash ishi fakulteti',
      ),
      'sud-tibbiyoti-5-tibbiy-profilaktika',
    );
    expect(classTopicGroupOf('x-1'), isNull);
    final gs = groupClassTopics(
      const [
        ClassTopic(id: 'a-1', title: 'A', count: 5),
        ClassTopic(
          id: 'b-1',
          title: 'B',
          count: 5,
          course: 'Pediatriya fakulteti',
        ),
      ],
      ClassQuizBank.empty,
      'uz',
      other,
      '',
    );
    expect(gs.map((g) => g.title), ['Pediatriya', other]);
  });

  test('qidiruv guruh nomi bo‘yicha ham ishlaydi', () {
    final gs = groupClassTopics(server, bank, 'uz', other, 'stomatolog');
    final st = gs.firstWhere((g) => g.title == 'Stomatologiya');
    expect(st.items.length, 57);
    expect(gs.first.items.length, lessThan(st.items.length));
  });
}
