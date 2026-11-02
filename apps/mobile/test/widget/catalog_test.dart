// «Ustozlar va mutaxassislar» katalogi: ro‘yxat, yulduzcha (bitta hisob —
// bitta), o‘ziga bosib bo‘lmaydi, kirmagan foydalanuvchi ko‘rmaydi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/catalog.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart' show UserMode;
import 'package:forensic_expert/data/catalog/fake_catalog_service.dart';
import 'package:forensic_expert/domain/catalog/catalog.dart';
import 'package:forensic_expert/domain/ports/backend_ports.dart';
import 'package:forensic_expert/domain/teacher_card/teacher_card.dart';

import '../helpers/class_groups_world.dart' show TestAuth, signedInAs;
import '../helpers/pump_app.dart';

void main() {
  const entries = [
    CatalogEntry(
      id: 't1',
      kind: CatalogKind.teacher,
      name: 'Qutbiddin Siddiqov',
      subtitle: 'Sud tibbiyoti kafedrasi',
      category: TeacherCategory.higher,
      stars: 4,
    ),
    CatalogEntry(
      id: 'x1',
      kind: CatalogKind.expert,
      name: 'Tasdiqlangan Ekspert',
      subtitle: 'Toksikolog',
      verified: true,
    ),
    CatalogEntry(
      id: 'x3',
      kind: CatalogKind.expert,
      name: 'Asoschi Ekspert',
      founder: true,
    ),
    CatalogEntry(
      id: 'x2',
      kind: CatalogKind.expert,
      name: 'Tasdiqlanmagan Ekspert',
    ),
    CatalogEntry(
      id: 'me',
      kind: CatalogKind.teacher,
      name: 'Men o‘zim',
      stars: 2,
      mine: true,
    ),
  ];

  Future<FakeCatalogService> open(
    WidgetTester tester, {
    String? uid,
    UserMode mode = UserMode.student,
  }) async {
    final svc = FakeCatalogService(userIdOf: () => uid, entries: entries);
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: mode),
      initialLocation: Routes.catalog,
      overrides: [
        authStateProvider.overrideWith(
          () => TestAuth(uid == null ? AuthState.signedOut : signedInAs(uid)),
        ),
        catalogServiceProvider.overrideWithValue(svc),
      ],
    );
    return svc;
  }

  testWidgets('ustozlar ro‘yxati; yulduzcha bosiladi va qaytariladi', (
    tester,
  ) async {
    final svc = await open(tester, uid: 'me');
    expect(find.text('Qutbiddin Siddiqov'), findsOneWidget);
    expect(find.text('Oliy toifa'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cat.star.t1')));
    await tester.pumpAndSettle();
    expect(svc.calls, contains('star:t1'));
    expect(find.text('5'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cat.star.t1')));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
    // O‘z yozuvida bosiladigan tugma yo‘q.
    expect(find.byKey(const Key('cat.star.me')), findsNothing);
  });

  testWidgets('talaba: ikkala yorliq; mutaxassislar yorlig‘ida belgi', (
    tester,
  ) async {
    await open(tester, uid: 'me');
    expect(find.byKey(const Key('cat.tab.teacher')), findsOneWidget);
    expect(find.byKey(const Key('cat.tab.expert')), findsOneWidget);
    await tester.tap(find.byKey(const Key('cat.tab.expert')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tasdiqlangan Ekspert', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Tasdiqlanmagan Ekspert'), findsOneWidget);
    // Belgi faqat tasdiqlanganda.
    expect(find.byKey(const Key('cat.verifiedBadge')), findsOneWidget);
    final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));
    expect(find.byTooltip(l.catVerifiedExpert), findsOneWidget);
    // To‘liq ko‘rinishda ham belgi.
    await tester.tap(find.byKey(const Key('cat.item.x1')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('cat.sheet')),
        matching: find.byKey(const Key('cat.verifiedBadge')),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'asoschi belgisi: ro‘yxatda va to‘liq ko‘rinishda, faqat asoschida',
    (tester) async {
      await open(tester, uid: 'me');
      await tester.tap(find.byKey(const Key('cat.tab.expert')));
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      );
      expect(find.byKey(const Key('founder.badge')), findsOneWidget);
      // Ko‘rinadigan matn — ilova nomi + yulduzcha; ma’nosi Semantics’da.
      expect(
        find.descendant(
          of: find.byKey(const Key('founder.badge')),
          matching: find.text(l.appTitle),
        ),
        findsOneWidget,
      );
      expect(l.catFounder, 'Forensic Expert asoschisi');
      await tester.tap(find.byKey(const Key('cat.item.x3')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const Key('cat.sheet')),
          matching: find.byKey(const Key('founder.badge')),
        ),
        findsOneWidget,
      );
    },
  );

  test('founder: tryParse va TeacherCard.fromJson, yo‘q bo‘lsa false', () {
    expect(
      CatalogEntry.tryParse({'id': 'a', 'name': 'A', 'founder': true})!.founder,
      isTrue,
    );
    expect(CatalogEntry.tryParse({'id': 'a', 'name': 'A'})!.founder, isFalse);
    expect(TeacherCard.fromJson({'founder': true}).founder, isTrue);
    expect(TeacherCard.fromJson({}).founder, isFalse);
  });

  testWidgets('Ustoz rejimi: ikkala yorliq, «Ustozlar» birinchi', (
    tester,
  ) async {
    await open(tester, uid: 'me', mode: UserMode.teacher);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Qutbiddin Siddiqov'), findsOneWidget);
    expect(
      find.textContaining('Tasdiqlangan Ekspert', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('Mutaxassis rejimi: ikkala yorliq, «Mutaxassislar» birinchi', (
    tester,
  ) async {
    await open(tester, uid: 'me', mode: UserMode.professional);
    expect(find.byType(TabBar), findsOneWidget);
    expect(
      find.textContaining('Tasdiqlangan Ekspert', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Tasdiqlanmagan Ekspert'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cat.tab.teacher')));
    await tester.pumpAndSettle();
    expect(find.text('Qutbiddin Siddiqov'), findsOneWidget);
  });

  testWidgets(
    'ustozlar kartasida fon rasmi bo‘lsa to‘liq ko‘rinishda chiqadi',
    (tester) async {
      await open(tester, uid: 'me');
      await tester.tap(find.byKey(const Key('cat.item.t1')));
      await tester.pumpAndSettle();
      // Fon yo‘q (yuklanmagan) — odatiy tasma, xato yo‘q.
      expect(find.byKey(const Key('cat.sheet')), findsOneWidget);
      expect(find.byKey(const Key('tc.coverImage')), findsNothing);
    },
  );

  test(
    'CatalogEntry.tryParse: verified/cover_path; eski javob — null/false',
    () {
      final a = CatalogEntry.tryParse({
        'id': 'a',
        'name': 'A',
        'kind': 'expert',
        'verified': true,
        'cover_path': 'u/cover-1.jpg',
      })!;
      expect(a.verified, isTrue);
      expect(a.coverPath, 'u/cover-1.jpg');
      final b = CatalogEntry.tryParse({'id': 'b', 'name': 'B'})!;
      expect(b.verified, isFalse);
      expect(b.coverPath, isNull);
      expect(
        CatalogMe.fromJson({'expert_eligible': true}).expertVerified,
        false,
      );
      expect(
        CatalogMe.fromJson({'expert_verified': true}).expertVerified,
        isTrue,
      );
    },
  );

  test('mutaxassis yozuvi ustoz kartasi maydonlarini ham o‘qiydi', () {
    final e = CatalogEntry.tryParse({
      'id': 'e',
      'name': 'E',
      'kind': 'expert',
      'verified': true,
      'category': 'higher',
      'photo_path': 'u/photo-1.png',
      'cover_path': 'u/cover-1.png',
      'socials': {'telegram': 'https://t.me/e'},
    })!;
    expect(e.kind, CatalogKind.expert);
    expect(e.category, TeacherCategory.higher);
    expect(e.photoPath, 'u/photo-1.png');
    expect(e.coverPath, 'u/cover-1.png');
    expect(e.socials, {TeacherSocial.telegram: 'https://t.me/e'});
  });

  testWidgets('profil: tasdiqlanmagan kasbiy profilda ham katalog kaliti', (
    tester,
  ) async {
    final svc = FakeCatalogService(
      userIdOf: () => 'me',
      me0: const CatalogMe(expertEligible: true),
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
      initialLocation: Routes.profile,
      overrides: [
        authStateProvider.overrideWith(() => TestAuth(signedInAs('me'))),
        catalogServiceProvider.overrideWithValue(svc),
      ],
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('catalog.toggle.expert')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));
    expect(find.text(l.catShowMeExperts), findsOneWidget);
    expect(find.byKey(const Key('catalog.unverifiedHint')), findsOneWidget);
    expect(
      find.text('Tasdiqlangandan keyin ismingiz yonida belgi chiqadi'),
      findsOneWidget,
    );
  });

  testWidgets('mutaxassislar bo‘sh: tushunarli matn', (tester) async {
    final svc = FakeCatalogService(userIdOf: () => 'me');
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.student),
      initialLocation: Routes.catalog,
      overrides: [
        authStateProvider.overrideWith(() => TestAuth(signedInAs('me'))),
        catalogServiceProvider.overrideWithValue(svc),
      ],
    );
    await tester.tap(find.byKey(const Key('cat.tab.expert')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cat.empty.expert')), findsOneWidget);
  });

  testWidgets('kirmagan: kirish taklifi', (tester) async {
    await open(tester);
    expect(find.byKey(const Key('cat.signIn')), findsOneWidget);
    expect(find.text('Qutbiddin Siddiqov'), findsNothing);
  });
}
