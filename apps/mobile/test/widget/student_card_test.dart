import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/student_card.dart';
import 'package:forensic_expert/app/support.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/student_card/fake_student_card_service.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/student_card/student_card.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

/// Guruh (ustoz `teacher`; a’zolar `s1`/`s2`/`s3`) + karta serveri nusxasi.
class _World {
  _World() : w = GroupsWorld() {
    final g = w.backend.create('teacher', 'Guruh A').value!;
    groupId = g.id;
    for (final (uid, nick) in [('s1', 'Bir'), ('s2', 'Ikki'), ('s3', 'Uch')]) {
      w.backend.join(uid, code: g.code!, nickname: nick);
    }
    final members = w.backend.detail('teacher', g.id).value!.members;
    String mid(String nick) => members.firstWhere((m) => m.nickname == nick).id;
    memberOf = {'s1': mid('Bir'), 's2': mid('Ikki'), 's3': mid('Uch')};
    backend = FakeStudentCardBackend(
      groups: {
        groupId: FakeStudentGroup(
          teacherId: 'teacher',
          members: {for (final e in memberOf.entries) e.value: e.key},
        ),
      },
    );
  }

  final GroupsWorld w;
  late final String groupId;
  late final Map<String, String> memberOf;
  late final FakeStudentCardBackend backend;
  late FakeStudentCardService svc;

  List<Override> overrides(String? uid) => [
    studentCardServiceProvider.overrideWith((ref) {
      svc = FakeStudentCardService(backend, userIdOf: () => uid);
      return svc;
    }),
    supportServiceProvider.overrideWithValue(InMemorySupportService()),
  ];

  Future<void> card(
    String uid,
    String name, {
    bool visible = true,
    String bio = '',
  }) async {
    final r = await FakeStudentCardService(
      backend,
      userIdOf: () => uid,
    ).save(StudentCardDraft(displayName: name, bio: bio, visible: visible));
    expect(r.ok, isTrue);
  }

  Future<ProviderContainer> open(
    WidgetTester tester,
    String uid, {
    String? location,
    Size size = const Size(390, 844),
    double textScale = 1.0,
  }) => w.open(
    tester,
    uid: uid,
    size: size,
    textScale: textScale,
    location: location ?? Routes.group(groupId),
    extra: overrides(uid),
  );
}

Future<void> _scrollTo(WidgetTester tester, Key list, Key target) async {
  await tester.scrollUntilVisible(
    find.byKey(target),
    150,
    scrollable: find
        .descendant(of: find.byKey(list), matching: find.byType(Scrollable))
        .first,
  );
  await tester.ensureVisible(find.byKey(target));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String text) async {
  await _scrollTo(tester, const Key('scd.list'), Key(key));
  await tester.enterText(find.byKey(Key(key)), text);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, String key) async {
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
      .clearSnackBars();
  await tester.pumpAndSettle();
  await _scrollTo(tester, const Key('scd.list'), Key(key));
  await tester.tap(find.byKey(Key(key)));
  await frames(tester);
}

String? _fieldError(WidgetTester tester, String key) =>
    tester.widget<TextField>(find.byKey(Key(key))).decoration!.errorText;

Future<void> _scrollGroup(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets(
    'Profil: «Talaba kartam» har qanday kirgan hisobda; kirmaganda yo‘q',
    (tester) async {
      final s = _World();
      await s.open(tester, 's1', location: Routes.profile);
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile.studentCard')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('profile.studentCard')), findsOneWidget);
      expect(find.text(_l(tester).scdProfileHint), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile.studentCard')));
      await frames(tester);
      expect(find.byKey(const Key('scd.save')), findsOneWidget);
      await closeApp(tester);

      final s2 = _World();
      await s2.open(tester, 'teacher', location: Routes.profile);
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile.studentCard')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const Key('profile.studentCard')),
        findsOneWidget,
        reason: 'ustoz ham o‘z talaba kartasini to‘ldira oladi',
      );
      await closeApp(tester);
    },
  );

  testWidgets(
    'Tahrirlash: rozilik DEFAULT o‘chiq; havola/aloqa maydoni YO‘Q; aloqa '
    'ma’lumoti saqlashni to‘xtatadi',
    (tester) async {
      final s = _World();
      await s.open(tester, 's1', location: Routes.studentCard);
      final l = _l(tester);
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const Key('scd.visible')))
            .value,
        isFalse,
        reason: 'DEFAULT — hech kimga ko‘rsatilmaydi',
      );
      expect(find.text(l.scdVisibleOff), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('scd.consent'))).data,
        l.scdConsent,
      );
      expect(
        l.scdConsent,
        contains('guruhlarning boshqa a’zolari va ustoziga'),
      );
      expect(l.scdVisibleTitle, 'Guruhdoshlarimga va ustozimga ko‘rsatish');
      expect(find.byKey(const Key('scd.noContact')), findsOneWidget);
      expect(l.scdNoContact, contains('aloqa ma’lumotini ulashmang'));
      // Faqat ikki matn maydoni: ism va «o‘zim haqimda»; URL klaviaturali maydon yo‘q.
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields.length, 2);
      expect(
        fields.any((f) => f.keyboardType == TextInputType.url),
        isFalse,
        reason: 'havola maydoni yo‘q',
      );
      expect(find.textContaining('Telegram'), findsNothing);
      expect(find.textContaining('Instagram'), findsNothing);

      await _type(tester, 'scd.field.name', 'Dilshod');
      await _type(
        tester,
        'scd.field.bio',
        'yoz @dilshod yoki +998 90 123 45 67',
      );
      expect(_fieldError(tester, 'scd.field.bio'), l.scdErrContact);
      await _tap(tester, 'scd.save');
      expect(
        s.svc.calls.contains('save'),
        isFalse,
        reason: 'filtr serverga yubormaydi',
      );
      await _type(tester, 'scd.field.bio', 'Kimyo 2-kurs');
      expect(_fieldError(tester, 'scd.field.bio'), isNull);
      await _type(tester, 'scd.field.name', 't.me/dilshod');
      expect(_fieldError(tester, 'scd.field.name'), l.scdErrContact);
      await _type(tester, 'scd.field.name', 'Dilshod');
      await _tap(tester, 'scd.save');
      expect(s.svc.calls.contains('save'), isTrue);
      final saved = s.backend.cards['s1']!;
      expect(saved.visible, isFalse, reason: 'rozilik berilmagan');
      expect(saved.bio, 'Kimyo 2-kurs');
      expect(find.text(l.scdSaved), findsOneWidget);

      await _tap(tester, 'scd.visible');
      expect(find.text(l.scdVisibleOn), findsOneWidget);
      await _tap(tester, 'scd.save');
      expect(s.backend.cards['s1']!.visible, isTrue);
      await closeApp(tester);
    },
  );

  testWidgets(
    'Tahrirlash: «Ko‘rish» ko‘ruvchi ko‘rinishini ochadi; o‘chirish',
    (tester) async {
      final s = _World();
      await s.open(tester, 's1', location: Routes.studentCard);
      final l = _l(tester);
      await _type(tester, 'scd.field.name', 'Dilshod');
      await _type(tester, 'scd.field.bio', 'Kimyo');
      await _tap(tester, 'scd.preview');
      expect(find.byKey(const Key('scd.previewTitle')), findsOneWidget);
      expect(find.text(l.scdPreviewTitle), findsOneWidget);
      expect(find.byKey(const Key('scd.card')), findsOneWidget);
      expect(find.byKey(const Key('scd.report')), findsNothing);
      expect(s.svc.calls.contains('save'), isFalse);
      await tester.tapAt(const Offset(10, 10));
      await frames(tester);
      await _tap(tester, 'scd.save');
      expect(s.backend.cards, isNotEmpty);
      await _tap(tester, 'scd.delete');
      await tester.tap(find.byKey(const Key('scd.deleteYes')));
      await frames(tester);
      expect(s.backend.cards, isEmpty);
      await closeApp(tester);
    },
  );

  testWidgets(
    'Tahrirlash: ustoz kartani guruhdan yashirgani va admin yashirishi ko‘rinadi',
    (tester) async {
      final s = _World();
      await s.card('s1', 'Dilshod');
      s.backend.groupHides[s.groupId] = {'s1'};
      await s.open(tester, 's1', location: Routes.studentCard);
      expect(find.byKey(const Key('scd.teacherHiddenBanner')), findsOneWidget);
      expect(find.byKey(const Key('scd.hiddenBanner')), findsNothing);
      await closeApp(tester);

      final s2 = _World();
      await s2.card('s1', 'Dilshod');
      s2.backend.adminHidden.add('s1');
      await s2.open(tester, 's1', location: Routes.studentCard);
      expect(find.byKey(const Key('scd.hiddenBanner')), findsOneWidget);
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const Key('scd.visible')))
            .onChanged,
        isNull,
        reason: 'admin yashirgan kartani egasi qayta yoqa olmaydi',
      );
      await closeApp(tester);
    },
  );

  group('guruhdosh ko‘rinishi', () {
    testWidgets(
      'faqat ko‘rinadigan kartalar chiqadi; kartasizlar o‘zgarmaydi',
      (tester) async {
        final s = _World();
        await s.card('s1', 'Dilshod', bio: 'Kimyo');
        await s.card('s3', 'Yashirin odam', visible: false);
        await s.open(tester, 's2');
        expect(find.byKey(const Key('grp.myNickname')), findsOneWidget);
        expect(find.byKey(const Key('scd.mate.s1')), findsOneWidget);
        expect(find.text('Dilshod'), findsOneWidget);
        expect(
          find.text('Yashirin odam'),
          findsNothing,
          reason: 'visible=false',
        );
        expect(find.byKey(const Key('scd.mate.s3')), findsNothing);
        await closeApp(tester);
      },
    );

    testWidgets('admin yashirgan karta ko‘rinmaydi', (tester) async {
      final s = _World();
      await s.card('s1', 'Dilshod');
      s.backend.adminHidden.add('s1');
      await s.open(tester, 's2');
      expect(find.byKey(const Key('scd.mate.s1')), findsNothing);
      await closeApp(tester);
    });

    testWidgets('hech kimda karta yo‘q — sahifa avvalgidek (bo‘lim yo‘q)', (
      tester,
    ) async {
      final s = _World();
      await s.open(tester, 's2');
      expect(find.text(_l(tester).scdGroupSection), findsNothing);
      expect(find.byKey(const Key('grp.myNickname')), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('karta bosilsa kichik oyna: faqat o‘qiladi, havola yo‘q', (
      tester,
    ) async {
      final s = _World();
      await s.card('s1', 'Dilshod', bio: 'Kimyo');
      await s.open(tester, 's2');
      await tester.tap(find.byKey(const Key('scd.mate.s1')));
      await frames(tester);
      expect(find.byKey(const Key('scd.sheet')), findsOneWidget);
      expect(find.byKey(const Key('scd.name')), findsOneWidget);
      expect(find.byKey(const Key('scd.bio')), findsOneWidget);
      expect(find.byKey(const Key('scd.report')), findsOneWidget);
      expect(find.byKey(const Key('scd.hideForMe')), findsOneWidget);
      expect(
        find.byKey(const Key('scd.groupHide')),
        findsNothing,
        reason: 'talabada ustoz amali yo‘q',
      );
      expect(find.byType(TextField), findsNothing);
      await closeApp(tester);
    });

    testWidgets(
      '«Shikoyat qilish» mavjud murojaat oqimiga o‘tadi (student_card:<id>)',
      (tester) async {
        final s = _World();
        await s.card('s1', 'Dilshod');
        final c = await s.open(tester, 's2');
        await tester.tap(find.byKey(const Key('scd.mate.s1')));
        await frames(tester);
        await tester.tap(find.byKey(const Key('scd.report')));
        await frames(tester);
        expect(find.byKey(const Key('supportNew.related')), findsOneWidget);
        expect(find.byKey(const Key('supportNew.subject')), findsOneWidget);
        expect(
          find.textContaining('Dilshod'),
          findsWidgets,
          reason: 'sarlavhada karta egasining ismi',
        );
        expect(c, isNotNull);
        await closeApp(tester);
      },
    );

    testWidgets(
      '«Bu kartani yashirish»: darhol yo‘qoladi; «Yashirilgan kartalar»dan qaytadi',
      (tester) async {
        final s = _World();
        await s.card('s1', 'Dilshod');
        await s.open(tester, 's2');
        final l = _l(tester);
        await tester.tap(find.byKey(const Key('scd.mate.s1')));
        await frames(tester);
        await tester.tap(find.byKey(const Key('scd.hideForMe')));
        await frames(tester);
        expect(s.backend.hides['s2'], {'s1'});
        expect(find.text(l.scdHiddenToast), findsOneWidget);
        expect(find.byKey(const Key('scd.mate.s1')), findsNothing);
        expect(
          find.text('Dilshod'),
          findsNothing,
          reason: 'mazmun ko‘rsatilmaydi',
        );
        await _scrollGroup(tester, find.byKey(const Key('scd.hidden.s1')));
        expect(find.text(l.scdHiddenItem), findsOneWidget);
        await tester.tap(find.byKey(const Key('scd.restore.s1')));
        await frames(tester);
        expect(s.backend.hides['s2'], isEmpty);
        expect(find.byKey(const Key('scd.mate.s1')), findsOneWidget);
        expect(find.byKey(const Key('scd.hidden.s1')), findsNothing);
        await closeApp(tester);
      },
    );

    testWidgets('boshqa guruhdosh uchun yashirilmagan (har kim o‘zi uchun)', (
      tester,
    ) async {
      final s = _World();
      await s.card('s1', 'Dilshod');
      s.backend.hides['s2'] = {'s1'};
      await s.open(tester, 's3');
      expect(find.byKey(const Key('scd.mate.s1')), findsOneWidget);
      await closeApp(tester);
    });

    for (final (size, scale) in [
      (const Size(320, 568), 1.0),
      (const Size(320, 568), 1.6),
      (const Size(390, 844), 1.3),
    ]) {
      testWidgets(
        'to‘lib ketmaydi: ${size.width.toInt()}×${size.height.toInt()}, ${scale}x',
        (tester) async {
          final s = _World();
          await s.card(
            's1',
            'Juda uzun taxallus Dilshod Karimov Ugli',
            bio: 'Men toksikologiya va kimyo fanlarini yaxshi ko‘raman, ikkinchi kursda o‘qiyman.',
          );
          await s.open(tester, 's2', size: size, textScale: scale);
          await _scrollGroup(tester, find.byKey(const Key('scd.mate.s1')));
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const Key('scd.mate.s1')));
          await frames(tester);
          expect(find.byKey(const Key('scd.sheet')), findsOneWidget);
          expect(tester.takeException(), isNull);
          final box = tester.getRect(find.byKey(const Key('scd.card')));
          expect(box.right, lessThanOrEqualTo(size.width));
          expect(box.left, greaterThanOrEqualTo(0));
          await tester.scrollUntilVisible(
            find.byKey(const Key('scd.hideForMe')),
            80,
            scrollable: find
                .descendant(
                  of: find.byKey(const Key('scd.sheet')),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          expect(tester.takeException(), isNull);
          await closeApp(tester);
        },
      );
    }
  });

  group('ustoz ko‘rinishi', () {
    testWidgets('kartali a’zo rasm/ism bilan; kartasiz a’zo avvalgidek', (
      tester,
    ) async {
      final s = _World();
      await s.card('s1', 'Dilshod');
      await s.open(tester, 'teacher');
      final withCard = find.byKey(Key('grp.member.${s.memberOf['s1']}'));
      final without = find.byKey(Key('grp.member.${s.memberOf['s2']}'));
      await _scrollGroup(tester, withCard);
      expect(
        find.byKey(Key('grp.memberCard.${s.memberOf['s1']}')),
        findsOneWidget,
      );
      expect(find.text('Dilshod'), findsOneWidget);
      expect(
        find.descendant(
          of: without,
          matching: find.byIcon(Icons.person_outline),
        ),
        findsOneWidget,
        reason: 'kartasiz a’zo avvalgidek',
      );
      expect(
        find.byKey(Key('grp.memberCard.${s.memberOf['s2']}')),
        findsNothing,
      );
      await closeApp(tester);
    });

    testWidgets(
      'a’zoga bosilsa karta oynasi; «Guruhdan yashirish» → talaba ko‘rmaydi, '
      'ustoz «Guruhdan yashirilgan» belgisini ko‘radi va qaytara oladi',
      (tester) async {
        final s = _World();
        await s.card('s1', 'Dilshod');
        await s.open(tester, 'teacher');
        final l = _l(tester);
        final tile = find.byKey(Key('grp.member.${s.memberOf['s1']}'));
        await _scrollGroup(tester, tile);
        await tester.tap(tile);
        await frames(tester);
        expect(find.byKey(const Key('scd.sheet')), findsOneWidget);
        expect(find.byKey(const Key('scd.groupHide')), findsOneWidget);
        await tester.tap(find.byKey(const Key('scd.groupHide')));
        await frames(tester);
        expect(s.backend.groupHides[s.groupId], {'s1'});
        expect(find.text(l.scdGroupHiddenToast), findsOneWidget);
        // Ustoz hamon ko‘radi, belgi bilan.
        await _scrollGroup(tester, tile);
        expect(find.textContaining(l.scdGroupHiddenLabel), findsOneWidget);
        // Talaba ko‘rmaydi.
        expect(
          (await FakeStudentCardService(
            s.backend,
            userIdOf: () => 's2',
          ).forGroup(s.groupId)).value!.cards,
          isEmpty,
        );
        tester
            .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
            .clearSnackBars();
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await frames(tester);
        expect(find.byKey(const Key('scd.groupHiddenLabel')), findsOneWidget);
        await tester.tap(find.byKey(const Key('scd.groupHide')));
        await frames(tester);
        expect(s.backend.groupHides[s.groupId], isEmpty);
        expect(find.text(l.scdGroupShownToast), findsOneWidget);
        await closeApp(tester);
      },
    );

    testWidgets(
      'ustoz kartani shikoyat qila oladi va o‘zi uchun yashira oladi',
      (tester) async {
        final s = _World();
        await s.card('s1', 'Dilshod');
        await s.open(tester, 'teacher');
        final tile = find.byKey(Key('grp.member.${s.memberOf['s1']}'));
        await _scrollGroup(tester, tile);
        await tester.tap(tile);
        await frames(tester);
        expect(find.byKey(const Key('scd.report')), findsOneWidget);
        await tester.tap(find.byKey(const Key('scd.hideForMe')));
        await frames(tester);
        expect(s.backend.hides['teacher'], {'s1'});
        await closeApp(tester);
      },
    );
  });

  for (final (size, scale) in [
    (const Size(320, 568), 1.0),
    (const Size(320, 568), 1.5),
  ]) {
    testWidgets(
      'Tahrirlash ekrani ${size.width.toInt()}×${size.height.toInt()}, '
      '${scale}x: to‘lib ketmaydi, saqlash tugmasiga yetiladi',
      (tester) async {
        final s = _World();
        await s.open(
          tester,
          's1',
          size: size,
          textScale: scale,
          location: Routes.studentCard,
        );
        await _type(tester, 'scd.field.name', 'Dilshod');
        await _scrollTo(tester, const Key('scd.list'), const Key('scd.save'));
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const Key('scd.save')));
        await frames(tester);
        expect(s.backend.cards['s1'], isNotNull);
        expect(tester.takeException(), isNull);
        await closeApp(tester);
      },
    );
  }
}
