import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/avatar.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/support.dart';
import 'package:forensic_expert/app/teacher_card.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/data/teacher_card/fake_teacher_card_service.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/teacher_card/teacher_card.dart';
import 'package:forensic_expert/features/teacher_card/teacher_card_image.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

/// Server qoidalari nusxasi: rol — GroupsWorld ustozi, a’zolik — guruh.
class _Cards {
  _Cards(this.w)
    : backend = FakeTeacherCardBackend(
        isTeacher: (u) => u == 'teacher',
        teacherOf: w.backend.teacherIdFor,
      );

  final GroupsWorld w;
  final FakeTeacherCardBackend backend;
  final opened = <Uri>[];
  late FakeTeacherCardService svc;

  List<Override> overrides(String? uid, {bool openOk = true}) => [
    teacherCardServiceProvider.overrideWith((ref) {
      svc = FakeTeacherCardService(backend, userIdOf: () => uid);
      return svc;
    }),
    teacherLinkOpenerProvider.overrideWithValue((uri) async {
      opened.add(uri);
      return openOk;
    }),
  ];
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
  await _scrollTo(tester, const Key('tc.list'), Key(key));
  await tester.enterText(find.byKey(Key(key)), text);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, String key) async {
  // Pastdagi SnackBar tugmani to‘sib qo‘ymasin (sinov yordamchisi).
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
      .clearSnackBars();
  await tester.pumpAndSettle();
  await _scrollTo(tester, const Key('tc.list'), Key(key));
  await tester.tap(find.byKey(Key(key)));
  await frames(tester);
}

/// Tasodifiy piksellar — siqilmaydigan PNG (hajmni kamaytirish sinovi).
Future<Uint8List> _noisePng(int side) async {
  final rnd = Random(7);
  final px = Uint8List(side * side * 4);
  for (var i = 0; i < px.length; i++) {
    px[i] = i % 4 == 3 ? 255 : rnd.nextInt(256);
  }
  final buf = await ui.ImmutableBuffer.fromUint8List(px);
  final desc = ui.ImageDescriptor.raw(
    buf,
    width: side,
    height: side,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await desc.instantiateCodec();
  final img = (await codec.getNextFrame()).image;
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets('Profil: «Ustoz kartam» faqat ustoz roli bor hisobda', (
    tester,
  ) async {
    final w = GroupsWorld();
    final cards = _Cards(w);
    await w.open(
      tester,
      uid: 'stu',
      location: Routes.profile,
      extra: cards.overrides('stu'),
    );
    expect(find.byKey(const Key('profile.teacherCard')), findsNothing);
    await closeApp(tester);

    final w2 = GroupsWorld();
    final cards2 = _Cards(w2);
    await w2.open(
      tester,
      uid: 'teacher',
      location: Routes.profile,
      extra: cards2.overrides('teacher'),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile.teacherCard')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('profile.teacherCard')), findsOneWidget);
    expect(find.text(_l(tester).tcProfileHint), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile.teacherCard')));
    await frames(tester);
    expect(find.byKey(const Key('tc.save')), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets(
    'Tahrirlash: rozilik kaliti DEFAULT o‘chiq; @username normallashadi; '
    'yaroqsiz havola saqlashni to‘xtatadi',
    (tester) async {
      final w = GroupsWorld();
      final cards = _Cards(w);
      await w.open(
        tester,
        uid: 'teacher',
        location: Routes.teacherCard,
        extra: cards.overrides('teacher'),
      );
      final l = _l(tester);
      final sw = tester.widget<SwitchListTile>(
        find.byKey(const Key('tc.visible')),
      );
      expect(sw.value, isFalse, reason: 'DEFAULT — talabalarga ko‘rsatilmaydi');
      expect(find.text(l.tcVisibleOff), findsOneWidget);
      expect(find.byKey(const Key('tc.consent')), findsOneWidget);
      expect(
        find.text(
          'Your photo and details are visible only to members of your '
          'groups. You can turn this off at any time or delete the card '
          'completely.',
        ),
        findsNothing,
        reason: 'uz tilida',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('tc.consent'))).data,
        l.tcConsent,
      );
      expect(l.tcConsent, contains('guruhlaringiz a’zolariga'));

      await _type(tester, 'tc.field.name', 'Dilshod Karimov');
      await _type(tester, 'tc.field.workplace', 'Sud ekspertizasi markazi');
      await _type(tester, 'tc.field.bio', 'Toksikologiya ustozi');
      await _type(tester, 'tc.field.social.telegram', '@dkarimov');
      await _type(tester, 'tc.field.social.website', 'forensic.uz');
      await _type(tester, 'tc.field.social.instagram', 'javascript:alert(1)');
      expect(find.text(l.tcSocialInvalid), findsOneWidget);
      await _tap(tester, 'tc.save');
      expect(cards.svc.calls.contains('save'), isFalse, reason: 'xato havola');
      expect(find.text(l.tcErrSocial), findsOneWidget);

      await _type(
        tester,
        'tc.field.social.instagram',
        'http://instagram.com/x',
      );
      expect(find.text(l.tcSocialInvalid), findsOneWidget, reason: 'http rad');
      await _type(tester, 'tc.field.social.instagram', '@forensic.uz');
      expect(find.text(l.tcSocialInvalid), findsNothing);
      await _tap(tester, 'tc.save');
      expect(cards.svc.calls.contains('save'), isTrue);
      final saved = cards.backend.cards['teacher']!;
      expect(saved.visible, isFalse, reason: 'rozilik berilmagan');
      expect(saved.displayName, 'Dilshod Karimov');
      expect(saved.socials[TeacherSocial.telegram], 'https://t.me/dkarimov');
      expect(saved.socials[TeacherSocial.website], 'https://forensic.uz');
      expect(
        saved.socials[TeacherSocial.instagram],
        'https://instagram.com/forensic.uz',
      );
      expect(find.text(l.tcSaved), findsOneWidget);
      // Maydon normallashgan havola bilan yangilandi.
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('tc.field.social.telegram')),
            )
            .controller!
            .text,
        'https://t.me/dkarimov',
      );

      // Rozilik: kalitni yoqib saqlash.
      await _tap(tester, 'tc.visible');
      expect(find.text(l.tcVisibleOn), findsOneWidget);
      await _tap(tester, 'tc.save');
      expect(cards.backend.cards['teacher']!.visible, isTrue);
      await closeApp(tester);
    },
  );

  testWidgets('Tahrirlash: «Ko‘rish» talaba ko‘rinishini ochadi; o‘chirish', (
    tester,
  ) async {
    final w = GroupsWorld();
    final cards = _Cards(w);
    await w.open(
      tester,
      uid: 'teacher',
      location: Routes.teacherCard,
      extra: cards.overrides('teacher'),
    );
    final l = _l(tester);
    await _type(tester, 'tc.field.name', 'Dilshod Karimov');
    await _type(tester, 'tc.field.social.telegram', '@dkarimov');
    await _tap(tester, 'tc.preview');
    expect(find.byKey(const Key('tc.previewTitle')), findsOneWidget);
    expect(find.text(l.tcPreviewTitle), findsOneWidget);
    expect(find.byKey(const Key('tc.card')), findsOneWidget);
    expect(find.text('Dilshod Karimov'), findsWidgets);
    expect(find.byKey(const Key('tc.social.telegram')), findsOneWidget);
    expect(
      find.byKey(const Key('tc.report')),
      findsNothing,
      reason: 'ustoz o‘z kartasiga shikoyat qilmaydi',
    );
    expect(
      cards.svc.calls.contains('save'),
      isFalse,
      reason: 'ko‘rish serverga hech narsa yubormaydi',
    );
    await tester.tapAt(const Offset(10, 10));
    await frames(tester);

    await _tap(tester, 'tc.save');
    expect(cards.backend.cards, isNotEmpty);
    await _tap(tester, 'tc.delete');
    await tester.tap(find.byKey(const Key('tc.deleteYes')));
    await frames(tester);
    expect(cards.backend.cards, isEmpty);
    await closeApp(tester);
  });

  testWidgets('Tahrirlash: rasm tanlash → moslash → saqlash → serverda', (
    tester,
  ) async {
    final w = GroupsWorld();
    final cards = _Cards(w);
    final png = await tester.runAsync(() => _noisePng(64));
    await w.open(
      tester,
      uid: 'teacher',
      location: Routes.teacherCard,
      extra: [
        ...cards.overrides('teacher'),
        avatarPickerProvider.overrideWithValue(_Picker(png!)),
      ],
    );
    await _type(tester, 'tc.field.name', 'Dilshod Karimov');
    await _tap(tester, 'tc.photoRow.choose');
    expect(find.byKey(const Key('avatar.crop')), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('avatar.save')));
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await frames(tester);
    // fitTeacherImage (dart:ui kodek) haqiqiy asinxron ishni kutadi.
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await _scrollTo(tester, const Key('tc.list'), const Key('tc.save'));
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('tc.save')));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await frames(tester);
    final c = cards.backend.cards['teacher']!;
    expect(c.photoPath, isNotNull);
    expect(cards.backend.files[c.photoPath], isNotNull);
    expect(
      cards.backend.files[c.photoPath]!.length,
      lessThanOrEqualTo(TeacherCardLimits.imageBytes),
    );
    expect(c.visible, isFalse);
    await closeApp(tester);
  });

  testWidgets('fitTeacherImage: 1 MB dan katta rasm siqiladi', (tester) async {
    final big = await tester.runAsync(() => _noisePng(1024));
    expect(big!.length, greaterThan(TeacherCardLimits.imageBytes));
    final out = await tester.runAsync(() => fitTeacherImage(big));
    expect(out, isNotNull);
    expect(out!.length, lessThanOrEqualTo(TeacherCardLimits.imageBytes));
    expect(TeacherImageKind.of(out), TeacherImageKind.png);
    // O‘qib bo‘lmaydigan baytlar — null (ilova xato matnini ko‘rsatadi).
    final junk = await tester.runAsync(
      () => fitTeacherImage(Uint8List.fromList([1, 2, 3])),
    );
    expect(junk, isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  group('talaba ko‘rinishi (guruh sahifasi)', () {
    Future<(GroupsWorld, _Cards, String, ProviderContainer)> setup(
      WidgetTester tester, {
      bool visible = true,
      Map<TeacherSocial, String>? socials,
      Size size = const Size(390, 844),
      double textScale = 1.0,
      bool openOk = true,
      List<Override> more = const [],
    }) async {
      final w = GroupsWorld();
      final g = w.backend.create('teacher', 'Guruh A').value!;
      w.backend.join('stu', code: g.code!, nickname: 'Talaba');
      final cards = _Cards(w);
      final tc = FakeTeacherCardService(
        cards.backend,
        userIdOf: () => 'teacher',
      );
      await tc.save(
        TeacherCardDraft(
          displayName: 'Dilshod Karimov',
          workplace: 'Sud ekspertizasi markazi',
          bio: 'Toksikologiya bo‘yicha ustoz',
          visible: visible,
          socials:
              socials ??
              {
                TeacherSocial.telegram: 'https://t.me/dkarimov',
                TeacherSocial.instagram: 'https://instagram.com/dk',
                TeacherSocial.youtube: 'https://youtube.com/@dk',
                TeacherSocial.facebook: 'https://facebook.com/dk',
                TeacherSocial.linkedin: 'https://www.linkedin.com/in/dk',
                TeacherSocial.tiktok: 'https://www.tiktok.com/@dk',
                TeacherSocial.website: 'https://forensic.uz',
              },
        ),
      );
      final c = await w.open(
        tester,
        uid: 'stu',
        size: size,
        textScale: textScale,
        location: Routes.group(g.id),
        extra: [
          ...cards.overrides('stu', openOk: openOk),
          ...more,
        ],
      );
      return (w, cards, g.id, c);
    }

    testWidgets(
      'karta ko‘rinadi; belgi bosilsa havola tashqi ilovada ochiladi',
      (tester) async {
        final (_, cards, _, _) = await setup(tester);
        expect(find.byKey(const Key('tc.card')), findsOneWidget);
        expect(find.byKey(const Key('tc.name')), findsOneWidget);
        expect(find.text('Dilshod Karimov'), findsOneWidget);
        expect(find.text('Sud ekspertizasi markazi'), findsOneWidget);
        for (final s in TeacherSocial.values) {
          expect(
            find.byKey(Key('tc.social.${s.key}')),
            findsOneWidget,
            reason: s.key,
          );
        }
        expect(find.byKey(const Key('tc.report')), findsOneWidget);
        await tester.tap(find.byKey(const Key('tc.social.telegram')));
        await frames(tester);
        expect(cards.opened, [Uri.parse('https://t.me/dkarimov')]);
        await tester.tap(find.byKey(const Key('tc.social.website')));
        await frames(tester);
        expect(cards.opened.last, Uri.parse('https://forensic.uz'));
        await closeApp(tester);
      },
    );

    testWidgets('ochilmasa — tushunarli xabar', (tester) async {
      await setup(tester, openOk: false);
      await tester.tap(find.byKey(const Key('tc.social.telegram')));
      await frames(tester);
      expect(find.text(_l(tester).tcLinkOpenFailed), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('ruxsat etilmagan havola ikonkasi ko‘rinmaydi va ochilmaydi', (
      tester,
    ) async {
      // Server (yoki buzilgan javob) noto‘g‘ri havola bergan hol: karta
      // JSON’i TeacherLinks.safe orqali o‘tadi, mijoz ham tekshiradi.
      final (_, cards, _, _) = await setup(
        tester,
        socials: const {
          TeacherSocial.telegram: 'https://t.me/dkarimov',
          TeacherSocial.instagram: 'javascript:alert(1)',
          TeacherSocial.website: 'http://forensic.uz',
          TeacherSocial.youtube: 'https://evil.example/x',
        },
      );
      // Fake backend draft.error orqali ularni rad etadi → karta saqlanmagan.
      // Shuning uchun to‘g‘ridan-to‘g‘ri JSON yo‘li ham alohida tekshiriladi:
      expect(
        TeacherCard.fromJson({
          'teacher_id': 'x',
          'display_name': 'X',
          'socials': {
            'telegram': 'https://t.me/dkarimov',
            'instagram': 'javascript:alert(1)',
            'website': 'http://forensic.uz',
            'youtube': 'https://evil.example/x',
          },
        }).socials.keys,
        [TeacherSocial.telegram],
      );
      expect(
        find.byKey(const Key('tc.card')),
        findsNothing,
        reason: 'noto‘g‘ri havolali karta serverda saqlanmaydi',
      );
      expect(cards.opened, isEmpty);
      await closeApp(tester);
    });

    testWidgets('visible=false: talaba kartani ko‘rmaydi', (tester) async {
      await setup(tester, visible: false);
      expect(find.byKey(const Key('tc.card')), findsNothing);
      expect(find.byKey(const Key('grp.myNickname')), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('admin yashirgan karta ko‘rinmaydi', (tester) async {
      final (_, cards, gid, c) = await setup(tester);
      cards.backend.hidden.add('teacher');
      c.invalidate(groupTeacherCardProvider(gid));
      await frames(tester);
      expect(find.byKey(const Key('tc.card')), findsNothing);
      await closeApp(tester);
    });

    testWidgets('«Shikoyat qilish» mavjud murojaat oqimiga o‘tadi', (
      tester,
    ) async {
      await setup(
        tester,
        more: [
          supportServiceProvider.overrideWithValue(InMemorySupportService()),
        ],
      );
      await tester.tap(find.byKey(const Key('tc.report')));
      await frames(tester);
      expect(find.byKey(const Key('supportNew.related')), findsOneWidget);
      expect(find.byKey(const Key('supportNew.subject')), findsOneWidget);
      await closeApp(tester);
    });

    for (final (size, scale) in [
      (const Size(320, 568), 1.0),
      (const Size(320, 568), 1.6),
      (const Size(390, 844), 1.3),
    ]) {
      testWidgets(
        'to‘lib ketmaydi: ${size.width.toInt()}×${size.height.toInt()}, '
        '${scale}x',
        (tester) async {
          await setup(tester, size: size, textScale: scale);
          expect(find.byKey(const Key('tc.card')), findsOneWidget);
          expect(tester.takeException(), isNull);
          final box = tester.getRect(find.byKey(const Key('tc.card')));
          expect(box.right, lessThanOrEqualTo(size.width));
          for (final s in TeacherSocial.values) {
            await tester.ensureVisible(find.byKey(Key('tc.social.${s.key}')));
            final r = tester.getRect(find.byKey(Key('tc.social.${s.key}')));
            expect(r.width, greaterThanOrEqualTo(44));
            expect(r.height, greaterThanOrEqualTo(44));
            expect(r.right, lessThanOrEqualTo(size.width));
          }
          expect(tester.takeException(), isNull);
          await closeApp(tester);
        },
      );
    }
  });

  for (final (size, scale) in [
    (const Size(320, 568), 1.0),
    (const Size(320, 568), 1.5),
  ]) {
    testWidgets(
      'Tahrirlash ekrani ${size.width.toInt()}×${size.height.toInt()}, '
      '${scale}x: to‘lib ketmaydi, saqlash tugmasiga yetiladi',
      (tester) async {
        final w = GroupsWorld();
        final cards = _Cards(w);
        await w.open(
          tester,
          uid: 'teacher',
          size: size,
          textScale: scale,
          location: Routes.teacherCard,
          extra: cards.overrides('teacher'),
        );
        await _type(tester, 'tc.field.name', 'Dilshod Karimov');
        await _scrollTo(tester, const Key('tc.list'), const Key('tc.save'));
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const Key('tc.save')));
        await frames(tester);
        expect(cards.backend.cards['teacher'], isNotNull);
        expect(tester.takeException(), isNull);
        await closeApp(tester);
      },
    );
  }

  testWidgets('Ustoz emas hisobda server rad etadi — tushunarli xato', (
    tester,
  ) async {
    final w = GroupsWorld();
    final cards = _Cards(w);
    await w.open(
      tester,
      uid: 'stu',
      location: Routes.teacherCard,
      extra: cards.overrides('stu'),
    );
    await _type(tester, 'tc.field.name', 'Talaba');
    await _tap(tester, 'tc.save');
    expect(find.text(_l(tester).tcErrForbidden), findsOneWidget);
    expect(cards.backend.cards, isEmpty);
    await closeApp(tester);
  });
}

class _Picker implements AvatarPicker {
  _Picker(this.bytes);
  final Uint8List bytes;
  @override
  Future<Uint8List?> pick() async => bytes;
}
