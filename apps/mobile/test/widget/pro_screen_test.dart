// Pro sahifasi (0.4.0): holatlar — bepul / sinov / faol / do‘kon ulanmagan /
// mehmon; sotib olish, tiklash, sinov oqimi. Narx faqat (soxta) do‘kondan.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/widgets/pro_lock_card.dart';
import 'package:forensic_expert/data/plan/fake_plan_service.dart';
import 'package:forensic_expert/data/store/fake_store_service.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/ports/plan_ports.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

void main() {
  late FakePlanService plan;
  late FakeStoreService store;

  Future<ProviderContainer> open(
    WidgetTester tester, {
    Entitlements ent = const Entitlements(trialAvailable: true),
    bool signedIn = true,
    bool storeOn = true,
    UserMode mode = UserMode.student,
    String location = Routes.pro,
    Size size = const Size(390, 844),
  }) async {
    plan = FakePlanService(entitlements: ent);
    store = FakeStoreService(available: storeOn);
    return pumpApp(
      tester,
      settings: completedSettings(lang: 'en', mode: mode),
      size: size,
      initialLocation: location,
      overrides: [
        if (signedIn)
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        planServiceProvider.overrideWithValue(plan),
        storeServiceProvider.overrideWithValue(store),
        deviceHashProvider.overrideWith((ref) async => 'a' * 64),
      ],
    );
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
  }

  testWidgets('bepul: rejimga mos reja, do‘kondan narx, sinov, shartlar', (
    tester,
  ) async {
    await open(tester);
    expect(find.byKey(const Key('pro.state.free')), findsOneWidget);
    // Talaba rejimi → Talaba Pro.
    expect(find.byKey(const Key('pro.includes.student')), findsOneWidget);
    expect(find.byKey(const Key('pro.includes.teacher')), findsNothing);
    // Narx kodda emas — soxta do‘kon matni ko‘rinadi.
    expect(find.byKey(const Key('pro.price.monthly')), findsOneWidget);
    expect(find.text(r'$0.00 m'), findsOneWidget);
    expect(find.text(r'$0.00 y'), findsOneWidget);
    expect(find.byKey(const Key('pro.buy.monthly')), findsOneWidget);
    expect(find.byKey(const Key('pro.buy.yearly')), findsOneWidget);
    expect(find.byKey(const Key('pro.trial')), findsOneWidget);
    expect(find.byKey(const Key('pro.restore')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('pro.terms')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('pro.terms')), findsOneWidget);
    expect(find.byKey(const Key('pro.cancelHow')), findsOneWidget);
    expect(find.byKey(const Key('pro.manage')), findsOneWidget);
    expect(find.byKey(const Key('pro.termsLink')), findsOneWidget);
    expect(find.byKey(const Key('pro.privacyLink')), findsOneWidget);
    expect(find.byKey(const Key('pro.freeAlways')), findsOneWidget);
  });

  testWidgets('Routes.proFor(plan) aniq rejani ko‘rsatadi', (tester) async {
    await open(tester, location: Routes.proFor(Plan.expert));
    expect(find.byKey(const Key('pro.includes.expert')), findsOneWidget);
    expect(find.byKey(const Key('pro.includes.student')), findsNothing);
  });

  testWidgets('sinov faqat trialAvailable bo‘lsa ko‘rinadi', (tester) async {
    await open(tester, ent: const Entitlements());
    expect(find.byKey(const Key('pro.trial')), findsNothing);
    expect(find.byKey(const Key('pro.buy.monthly')), findsOneWidget);
  });

  testWidgets('sinovni boshlash: server beradi, holat «sinov» bo‘ladi', (
    tester,
  ) async {
    await open(tester);
    await tapKey(tester, 'pro.trial');
    await tester.pumpAndSettle();
    expect(plan.calls, contains('claimTrial:student'));
    expect(find.byKey(const Key('pro.state.trial')), findsOneWidget);
    expect(find.byKey(const Key('pro.flow.success')), findsOneWidget);
    // Sinov faol — tugma yo‘q.
    expect(find.byKey(const Key('pro.trial')), findsNothing);
  });

  testWidgets('sinov: qurilmada ishlatilgan — halol xabar', (tester) async {
    await open(tester);
    plan.trialResult = TrialResult.alreadyUsedDevice;
    await tapKey(tester, 'pro.trial');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pro.flow.trialUsedDevice')), findsOneWidget);
    expect(find.byKey(const Key('pro.state.free')), findsOneWidget);
  });

  testWidgets('Pro faol: muddat, manba va avto-uzayish ko‘rinadi', (
    tester,
  ) async {
    await open(
      tester,
      ent: Entitlements(
        plan: Plan.student,
        source: PlanSource.store,
        expiresAt: DateTime.now().add(const Duration(days: 20)),
        autoRenew: true,
      ),
    );
    expect(find.byKey(const Key('pro.state.active')), findsOneWidget);
    expect(find.textContaining('Student Pro is active'), findsOneWidget);
    expect(find.textContaining('Auto-renews'), findsOneWidget);
    expect(find.byKey(const Key('pro.state.source')), findsOneWidget);
    expect(find.byKey(const Key('pro.alreadyActive')), findsOneWidget);
    expect(find.byKey(const Key('pro.buy.monthly')), findsNothing);
  });

  testWidgets('muddati tugagan reja faol sanalmaydi', (tester) async {
    await open(
      tester,
      ent: Entitlements(
        plan: Plan.student,
        source: PlanSource.admin,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
    expect(find.byKey(const Key('pro.state.free')), findsOneWidget);
  });

  testWidgets('do‘kon yo‘q: halol izoh, xarid tugmalari yo‘q', (tester) async {
    await open(tester, storeOn: false);
    expect(find.byKey(const Key('pro.storeUnavailable')), findsOneWidget);
    expect(find.byKey(const Key('pro.buy.monthly')), findsNothing);
    expect(find.byKey(const Key('pro.restore')), findsOneWidget);
  });

  testWidgets('mehmon: kirishga taklif, xarid yo‘q', (tester) async {
    await open(tester, signedIn: false);
    expect(find.byKey(const Key('pro.guest')), findsOneWidget);
    expect(find.byKey(const Key('pro.guest.signIn')), findsOneWidget);
    expect(find.byKey(const Key('pro.buy.monthly')), findsNothing);
    expect(find.byKey(const Key('pro.freeAlways')), findsOneWidget);
  });

  testWidgets('sotib olish: server NOT_CONFIGURED — halol holat', (
    tester,
  ) async {
    await open(tester);
    await tapKey(tester, 'pro.buy.monthly');
    await tester.pump();
    expect(store.calls, ['buy:fe_student_monthly']);
    store.emit(
      const StorePurchase(
        productId: 'fe_student_monthly',
        status: StorePurchaseStatus.purchased,
        proof: 'jws',
        transactionId: '1',
      ),
    );
    await tester.pumpAndSettle();
    expect(plan.calls, contains('verify:fe_student_monthly'));
    expect(
      find.byKey(const Key('pro.flow.storeNotConfigured')),
      findsOneWidget,
    );
    // Tasdiqlanmagan xarid yopilmaydi (keyin qayta tekshiriladi).
    expect(store.completed, isEmpty);
    expect(find.byKey(const Key('pro.state.free')), findsOneWidget);
  });

  testWidgets('sotib olish: server tasdiqlasa reja faol bo‘ladi', (
    tester,
  ) async {
    await open(tester);
    plan.verifyResult = VerifyOutcome(
      VerifyResult.applied,
      plan: Plan.student,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    store.emit(
      const StorePurchase(
        productId: 'fe_student_yearly',
        status: StorePurchaseStatus.purchased,
        proof: 'jws',
      ),
    );
    await tester.pumpAndSettle();
    expect(store.completed, hasLength(1));
    expect(find.byKey(const Key('pro.state.active')), findsOneWidget);
    expect(find.byKey(const Key('pro.flow.success')), findsOneWidget);
  });

  testWidgets('xarid bekor qilindi — pul yechilmadi xabari', (tester) async {
    await open(tester);
    store.emit(
      const StorePurchase(
        productId: 'fe_student_monthly',
        status: StorePurchaseStatus.canceled,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pro.flow.canceled')), findsOneWidget);
  });

  testWidgets('xaridlarni tiklash: hech narsa topilmasa xabar', (tester) async {
    await open(tester);
    await tapKey(tester, 'pro.restore');
    await tester.pump();
    expect(store.calls, contains('restore'));
    await tester.pump(const Duration(seconds: 9));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pro.flow.restoreNothing')), findsOneWidget);
  });

  testWidgets('320 dp ekranda sig‘adi (overflow yo‘q)', (tester) async {
    await open(tester, size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byKey(const Key('pro.list')),
      const Offset(0, -2000),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profil: «Reja» qatori Pro sahifasini ochadi', (tester) async {
    await open(tester, location: Routes.profile);
    final row = find.byKey(const Key('profile.plan'), skipOffstage: false);
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(of: row, matching: find.text('Free plan')),
      findsOneWidget,
    );
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pro.list')), findsOneWidget);
  });

  testWidgets('birinchi taklif: bir marta, rejimga mos, popup emas', (
    tester,
  ) async {
    final offers = InMemoryProOfferStore();
    Future<void> home(UserMode mode) => pumpApp(
      tester,
      settings: completedSettings(lang: 'en', mode: mode),
      overrides: [
        proOfferStoreProvider.overrideWithValue(offers),
        planServiceProvider.overrideWithValue(FakePlanService()),
      ],
    );
    await home(UserMode.teacher);
    final card = find.byKey(const Key('pro.firstOffer'));
    expect(card, findsOneWidget);
    expect(find.text('Teach with more tools'), findsOneWidget);
    expect(offers.firstOfferShown, isTrue);
    // Yopiladi.
    await tapKey(tester, 'pro.firstOffer.dismiss');
    await tester.pumpAndSettle();
    expect(card, findsNothing);
    // Keyingi ishga tushirishda (yangi sessiya) ko‘rinmaydi.
    await home(UserMode.teacher);
    expect(find.byKey(const Key('pro.firstOffer')), findsNothing);
  });

  testWidgets('birinchi taklif: Pro sahifasiga olib boradi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'en', mode: UserMode.student),
      overrides: [
        proOfferStoreProvider.overrideWithValue(InMemoryProOfferStore()),
      ],
    );
    expect(find.text('Study without limits'), findsOneWidget);
    await tapKey(tester, 'pro.firstOffer.open');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pro.includes.student')), findsOneWidget);
  });

  testWidgets('ProLockCard: qulf belgisi, foyda va «Pro bilan ochish»', (
    tester,
  ) async {
    var tapped = 0;
    Widget host(bool compact) => MaterialApp(
      theme: FeThemeBuilder.light(),
      locale: const Locale('uz'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ProLockCard(
          benefit: 'Barcha 211 ta ma’ruza prezentatsiyasi',
          planName: 'Ustoz Pro',
          compact: compact,
          onUnlock: () => tapped++,
        ),
      ),
    );
    await tester.pumpWidget(host(false));
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Barcha 211 ta ma’ruza prezentatsiyasi'), findsOneWidget);
    expect(find.text('Ustoz Pro'), findsOneWidget);
    await tester.tap(find.text('Pro bilan ochish'));
    expect(tapped, 1);
    // Ixcham ko‘rinish: kartaning o‘zi bosiladi.
    await tester.pumpWidget(host(true));
    await tester.tap(find.text('Barcha 211 ta ma’ruza prezentatsiyasi'));
    expect(tapped, 2);
  });
}
