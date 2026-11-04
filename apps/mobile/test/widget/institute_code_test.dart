// «Institut kodi / promokod» (profil) va qurilmalar limiti — fake bilan.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/app/promo.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/plan/fake_plan_service.dart';
import 'package:forensic_expert/data/plan/fake_promo_service.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/plan/promo_models.dart';
import 'package:forensic_expert/domain/ports/plan_ports.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

final _hash = 'a' * 64;

void main() {
  late FakePlanService plan;

  Future<FakePromoService> open(
    WidgetTester tester, {
    Map<String, PromoOutcome>? codes,
    List<DeviceRecord>? devices,
    String location = Routes.instituteCode,
    bool proEnabled = false,
    bool configured = true,
    PlanFailure? failure,
  }) async {
    plan = FakePlanService();
    final promo = FakePromoService(
      codes: codes,
      devices: devices,
      configured: configured,
      failure: failure,
      onRedeemed: (o) => plan.entitlements = Entitlements(
        plan: o.plan,
        source: PlanSource.admin,
        expiresAt: o.until,
        label: o.label,
      ),
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: location,
      proEnabled: proEnabled,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        planServiceProvider.overrideWithValue(plan),
        promoServiceProvider.overrideWithValue(promo),
        deviceHashProvider.overrideWith((ref) async => _hash),
        devicePlatformLabelProvider.overrideWithValue('Android'),
      ],
    );
    return promo;
  }

  Future<void> submit(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('promo.field')), text);
    await tester.pump();
    await tester.tap(find.byKey(const Key('promo.submit')));
    await tester.pumpAndSettle();
  }

  group('profil qatori', () {
    testWidgets('Pro o‘chiq: «Institut kodi» ko‘rinadi, «Pro rejasi» yo‘q', (
      tester,
    ) async {
      await open(tester, location: Routes.profile);
      expect(find.byKey(const Key('profile.instituteCode')), findsOneWidget);
      expect(find.text('Institut kodi / promokod'), findsOneWidget);
      expect(find.byKey(const Key('profile.plan')), findsNothing);
      expect(find.textContaining(RegExp(r'\bPro\b')), findsNothing);
      await tester.tap(find.byKey(const Key('profile.instituteCode')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('promo.field')), findsOneWidget);
    });

    testWidgets('xizmat ulanmagan: qator yo‘q', (tester) async {
      await open(tester, location: Routes.profile, configured: false);
      expect(find.byKey(const Key('profile.instituteCode')), findsNothing);
    });

    testWidgets('faol institut: profilda nomi va sana', (tester) async {
      await open(tester, location: Routes.profile);
      plan.entitlements = Entitlements(
        plan: Plan.teacher,
        source: PlanSource.admin,
        expiresAt: DateTime(2027, 3, 1),
        label: 'institut: ADTI',
      );
      // Reja qayta o‘qiladi (ilova fondan qaytganda ham shunday).
      final c = ProviderScope.containerOf(
        tester.element(find.byKey(const Key('profile.instituteCode'))),
      );
      await c.read(entitlementsProvider.notifier).refresh();
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Institut: ADTI, 2027-yil 1-mart gacha'),
        findsOneWidget,
      );
    });
  });

  group('kod kiritish', () {
    testWidgets('OK: katta harf, bo‘shliq/defis tashlanadi, reja yangilanadi', (
      tester,
    ) async {
      final promo = await open(
        tester,
        codes: {'A1B2C3D4E5': promoOk(until: DateTime(2027, 3, 1))},
      );
      await submit(tester, ' a1b2-c3 d4e5 ');
      expect(promo.calls, contains('redeem:A1B2C3D4E5'));
      expect(
        find.text(
          'Ustoz Pro ochildi: institut: Test instituti, 2027-yil 1-mart gacha',
        ),
        findsOneWidget,
      );
      // Entitlements yangilandi: faol label bannerda.
      expect(plan.calls.where((c) => c == 'myPlan').length, greaterThan(1));
      expect(find.byKey(const Key('promo.active')), findsOneWidget);
      expect(
        find.textContaining('Institut: Test instituti, 2027-yil 1-mart gacha'),
        findsOneWidget,
      );
    });

    testWidgets('maydon kiritilganda katta harfga aylanadi', (tester) async {
      await open(tester);
      await tester.enterText(find.byKey(const Key('promo.field')), 'ab-cd 12');
      await tester.pump();
      expect(find.text('ABCD12'), findsOneWidget);
    });

    testWidgets('INVALID: «Kod noto‘g‘ri»', (tester) async {
      await open(tester);
      await submit(tester, 'XXXX');
      expect(find.text('Kod noto‘g‘ri'), findsOneWidget);
    });

    testWidgets('USED: «Kod ishlatilgan»', (tester) async {
      await open(
        tester,
        codes: {'USED1': const PromoOutcome(PromoResult.used)},
      );
      await submit(tester, 'used1');
      expect(find.text('Kod ishlatilgan'), findsOneWidget);
    });

    testWidgets('EXPIRED / REVOKED / TOO_MANY xabarlari', (tester) async {
      await open(
        tester,
        codes: {
          'EXP': const PromoOutcome(PromoResult.expired),
          'REV': const PromoOutcome(PromoResult.revoked),
          'MANY': const PromoOutcome(PromoResult.tooMany),
        },
      );
      await submit(tester, 'exp');
      expect(find.text('Kodning muddati tugagan'), findsOneWidget);
      await submit(tester, 'rev');
      expect(find.text('Kod bekor qilingan'), findsOneWidget);
      await submit(tester, 'many');
      expect(
        find.text('Juda ko‘p urinish. Keyinroq qayta urinib ko‘ring.'),
        findsOneWidget,
      );
    });

    testWidgets('bo‘sh kod: serverga so‘rov yo‘q', (tester) async {
      final promo = await open(tester);
      await submit(tester, ' - ');
      expect(find.text('Kodni kiriting.'), findsOneWidget);
      expect(promo.calls.where((c) => c.startsWith('redeem')), isEmpty);
    });

    testWidgets('tarmoq yo‘q: tushunarli xato', (tester) async {
      await open(tester, failure: PlanFailure.offline);
      await submit(tester, 'abc');
      expect(
        find.text('Internet yo‘q. Aloqani tekshirib, qayta urinib ko‘ring.'),
        findsOneWidget,
      );
    });
  });

  group('qurilmalar limiti', () {
    final three = [
      DeviceRecord(hash: 'h1', label: 'iOS', lastSeen: DateTime(2026, 11, 1)),
      DeviceRecord(
        hash: 'h2',
        label: 'Android',
        lastSeen: DateTime(2026, 10, 20),
      ),
      const DeviceRecord(hash: 'h3'),
    ];

    testWidgets(
      'joy bor: oyna yo‘q, qurilma yorlig‘i bilan ro‘yxatga olinadi',
      (tester) async {
        final promo = await open(tester, location: Routes.home);
        expect(find.byKey(const Key('devLimit.dialog')), findsNothing);
        expect(promo.calls, contains('register:$_hash:Android'));
      },
    );

    testWidgets('to‘lgan: oyna, ro‘yxat va «Chiqarish»', (tester) async {
      final promo = await open(
        tester,
        location: Routes.home,
        devices: [...three],
      );
      expect(find.byKey(const Key('devLimit.dialog')), findsOneWidget);
      expect(
        find.text('Bu hisob 3 ta qurilmada ishlatilmoqda'),
        findsOneWidget,
      );
      expect(find.text('iOS'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget);
      expect(find.text('Qurilma'), findsOneWidget);
      await tester.tap(find.byKey(const Key('devLimit.remove.h2')));
      await tester.pumpAndSettle();
      expect(promo.calls, contains('remove:h2'));
      expect(promo.registered, contains(_hash));
      expect(find.byKey(const Key('devLimit.dialog')), findsNothing);
    });

    testWidgets('bekor qilinsa ilova ishlashda davom etadi', (tester) async {
      await open(tester, location: Routes.home, devices: [...three]);
      await tester.tap(find.byKey(const Key('devLimit.later')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('devLimit.dialog')), findsNothing);
      expect(find.byKey(const Key('home.core')), findsOneWidget);
    });

    testWidgets('server xatosi: jim, oyna yo‘q', (tester) async {
      await open(
        tester,
        location: Routes.home,
        devices: [...three],
        failure: PlanFailure.server,
      );
      expect(find.byKey(const Key('devLimit.dialog')), findsNothing);
    });

    testWidgets('xizmat ulanmagan: so‘rov yo‘q', (tester) async {
      final promo = await open(
        tester,
        location: Routes.home,
        devices: [...three],
        configured: false,
      );
      expect(promo.calls, isEmpty);
      expect(find.byKey(const Key('devLimit.dialog')), findsNothing);
    });
  });
}
