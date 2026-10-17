import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

import '../helpers/pump_app.dart';

/// Egasi qarori (2026-10-17): to‘lov/Pro qatlami ilovada yo‘q — hamma funksiya
/// bepul va ochiq. Bu testlar «qulf», «Pro», «tarif» va bepul-demo chegaralari
/// qaytib kelmasligini kafolatlaydi.
void main() {
  Future<void> search(WidgetTester tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.searchWith('testalpha'),
      testFixtures: false,
      overrides: [
        libraryRepositoryProvider.overrideWithValue(const _ManyEntries()),
      ],
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('qidiruv: barcha natijalar ko‘rinadi, «yana N ta» qulfi yo‘q', (
    tester,
  ) async {
    await search(tester);
    // Barcha 6 ta natija ko‘rinadi (bepul-demo chegarasi — 3 ta — yo‘q).
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    for (var i = 1; i <= 6; i++) {
      expect(find.text('Testalpha $i'), findsWidgets, reason: 'natija $i');
    }
    expect(find.byKey(const Key('search.more.substances')), findsNothing);
    expect(find.byKey(const Key('search.hit.locked')), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });

  testWidgets('O‘quv: barcha kurslar ochiq, qulf belgisi yo‘q', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(mode: UserMode.student),
      initialLocation: Routes.learn,
    );
    for (final id in ['TEST-COURSE-TOX', 'TEST-COURSE-FM']) {
      expect(find.byKey(Key('learn.locked.$id')), findsNothing);
    }
    await tester.tap(find.byKey(const Key('learn.course.TEST-COURSE-FM')));
    await tester.pumpAndSettle();
    // Dars ro‘yxati ochiladi (tariflar sahifasi emas).
    expect(find.text('Plans'), findsNothing);
  });

  testWidgets('Vositalar: hamma kalkulyator ochiq', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.tools,
    );
    expect(
      find.byKey(const Key('tool.locked.tool.lab.dilution')),
      findsNothing,
    );
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.tool('tool.lab.lod_loq'),
    );
    expect(find.byKey(const Key('tool.lockedCard')), findsNothing);
    expect(find.byKey(const Key('locked.unlock')), findsNothing);
  });

  testWidgets('Profil: obuna, tarif, restore qatorlari yo‘q', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
    );
    for (final k in [
      'profile.purchase',
      'profile.subscriptionStatus',
      'profile.restore',
      'profile.manage',
    ]) {
      expect(find.byKey(Key(k), skipOffstage: false), findsNothing);
    }
    for (final w in ['Restore purchases', 'Subscription']) {
      expect(find.textContaining(w, skipOffstage: false), findsNothing);
    }
    expect(
      find.textContaining(RegExp(r'\bPro\b'), skipOffstage: false),
      findsNothing,
    );
  });

  testWidgets('/profile/purchase yo‘li endi mavjud emas', (tester) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
    );
    c.read(routerProvider).go('/profile/purchase');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('purchase.restore')), findsNothing);
    expect(find.byKey(const Key('paywall.tier.professionalPro')), findsNothing);
  });
}

/// TEST: qidiruv natijalari to‘liq ko‘rinishini sinash uchun 6 ta sun’iy
/// yozuv (ilmiy emas).
class _ManyEntries implements LibraryRepository {
  const _ManyEntries();

  static final _all = [
    for (var i = 1; i <= 6; i++)
      LibraryEntry(
        id: 'TEST-ALPHA-$i',
        section: LibrarySection.substances,
        name: LocalizedText({'en': 'Testalpha $i'}),
        status: ScientificStatus.needsReview,
        isTestData: true,
      ),
  ];

  @override
  List<LibraryEntry> entries(LibrarySection section) =>
      section == LibrarySection.substances ? _all : const [];

  @override
  LibraryEntry? byId(String id) => _all.where((e) => e.id == id).firstOrNull;
}
