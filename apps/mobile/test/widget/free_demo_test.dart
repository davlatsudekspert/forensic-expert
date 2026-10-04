import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/features/profile/presentation/purchase_screen.dart';

import '../helpers/fake_store.dart';
import '../helpers/pump_app.dart';

/// Bepul demo chegarasi: 3 ta yozuv + 1 kurs + 1 vosita, qidiruv cheklovi.
void main() {
  Future<void> search(WidgetTester tester, {required bool owned}) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.searchWith('testalpha'),
      testFixtures: false,
      overrides: [
        libraryRepositoryProvider.overrideWithValue(const _ManyEntries()),
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: owned)),
      ],
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('qidiruv: bepul foydalanuvchiga cheklangan, soni ko‘rsatiladi', (
    tester,
  ) async {
    await search(tester, owned: false);
    expect(find.byKey(const Key('search.more.substances')), findsOneWidget);
    await tester.tap(find.byKey(const Key('search.more.substances')));
    await tester.pumpAndSettle();
    expect(find.byType(PurchaseScreen), findsOneWidget);
  });

  testWidgets('qidiruv: Lifetime egasi — cheklovsiz', (tester) async {
    await search(tester, owned: true);
    expect(find.byKey(const Key('search.more.substances')), findsNothing);
  });

  testWidgets('Learn: 1 ta kurs bepul, keyingisi Lifetime', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(mode: UserMode.student),
      initialLocation: Routes.learn,
    );
    expect(find.byKey(const Key('learn.locked.TEST-COURSE-TOX')), findsNothing);
    expect(
      find.byKey(const Key('learn.locked.TEST-COURSE-FM')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('learn.course.TEST-COURSE-FM')));
    await tester.pumpAndSettle();
    expect(find.byType(PurchaseScreen), findsOneWidget);
  });

  testWidgets('Tools: C₁V₁ bepul demoda ochiq', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.tools,
    );
    expect(
      find.byKey(const Key('tool.locked.tool.lab.dilution')),
      findsNothing,
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.tool('tool.lab.dilution'),
    );
    expect(find.byKey(const Key('tool.lockedCard')), findsNothing);
    expect(find.byKey(const Key('calc.calculate')), findsOneWidget);
  });

  testWidgets('xarid → huquq UI’da darhol yangilanadi (Profil «Lifetime»)', (
    tester,
  ) async {
    final store = FakeStore(owned: true);
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
      overrides: [entitlementServiceProvider.overrideWithValue(store)],
    );
    final row = find.byKey(const Key('profile.purchase'));
    await tester.ensureVisible(row);
    expect(
      find.descendant(of: row, matching: find.text('Lifetime')),
      findsOneWidget,
    );
  });
}

/// TEST: qidiruv cheklovini sinash uchun 6 ta sun’iy yozuv (ilmiy emas).
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
