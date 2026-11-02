// «Ustozlar va mutaxassislar» katalogi: ro‘yxat, yulduzcha (bitta hisob —
// bitta), o‘ziga bosib bo‘lmaydi, kirmagan foydalanuvchi ko‘rmaydi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/catalog.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/catalog/fake_catalog_service.dart';
import 'package:forensic_expert/domain/ports/backend_ports.dart';
import 'package:forensic_expert/domain/catalog/catalog.dart';
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
      id: 'me',
      kind: CatalogKind.teacher,
      name: 'Men o‘zim',
      stars: 2,
      mine: true,
    ),
  ];

  Future<FakeCatalogService> open(WidgetTester tester, {String? uid}) async {
    final svc = FakeCatalogService(userIdOf: () => uid, entries: entries);
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
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

  testWidgets('mutaxassislar bo‘sh: tushunarli matn', (tester) async {
    await open(tester, uid: 'me');
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
