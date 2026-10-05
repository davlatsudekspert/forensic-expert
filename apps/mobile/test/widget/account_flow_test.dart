import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/user_data.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

import '../helpers/fake_store.dart';
import '../helpers/pump_app.dart';

const _pw = 'TestPassw0rd!';

/// Akkaunt va obuna UI oqimlari (MOCK backend; haqiqiy xat yuborilmaydi).
void main() {
  Future<void> show(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await show(tester, f);
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String text) async {
    final f = find.byKey(Key(key));
    await show(tester, f);
    await tester.enterText(f, text);
    await tester.pumpAndSettle();
  }

  testWidgets('mehmon rejimi: akkaunt ixtiyoriy, backend ulanmagani ochiq '
      'aytiladi, kirish tugmasi o‘chiq', (tester) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
    );
    await show(tester, find.byKey(const Key('profile.accountOptional')));
    expect(
      find.byKey(const Key('profile.accountNotConnected')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('profile.deleteAccount')), findsNothing);
    expect(find.byKey(const Key('profile.signOut')), findsNothing);
    c.read(routerProvider).go(Routes.accountRegister);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth.notConfigured')), findsOneWidget);
    final submit = find.byKey(const Key('auth.submit'));
    await show(tester, submit);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    // Oflayn ilmiy funksiyalar akkauntsiz ochiq.
    c.read(routerProvider).go(Routes.search);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth.notConfigured')), findsNothing);
  });

  testWidgets('ro‘yxat → email kodi → faol akkaunt → chiqish', (tester) async {
    final auth = MockAuthRepository();
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.accountRegister,
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    expect(find.byKey(const Key('auth.testBackend')), findsOneWidget);
    expect(find.byKey(const Key('auth.minimalData')), findsOneWidget);

    await enter(tester, 'auth.email', 'bad-email');
    await tapKey(tester, 'auth.submit');
    expect(find.byKey(const Key('auth.error.invalidEmail')), findsOneWidget);

    await enter(tester, 'auth.email', 'New.User@Lab.uz');
    await enter(tester, 'auth.password', 'short');
    expect(find.byKey(const Key('auth.rule.minLength.todo')), findsOneWidget);
    await enter(tester, 'auth.password', _pw);
    for (final r in ['minLength', 'letter', 'digit', 'notEmail']) {
      expect(find.byKey(Key('auth.rule.$r.ok')), findsOneWidget, reason: r);
    }
    await enter(tester, 'auth.confirm', 'different1A');
    await tapKey(tester, 'auth.submit');
    expect(
      find.byKey(const Key('auth.error.passwordMismatch')),
      findsOneWidget,
    );
    await enter(tester, 'auth.confirm', _pw);
    await tapKey(tester, 'auth.submit');
    expect(
      find.byKey(const Key('auth.error.termsNotAccepted')),
      findsOneWidget,
    );
    await tapKey(tester, 'auth.terms');
    await tapKey(tester, 'auth.submit');

    expect(find.byKey(const Key('screen.verify')), findsOneWidget);
    expect(find.textContaining('new.user@lab.uz'), findsOneWidget);
    await enter(tester, 'auth.code', '000000');
    await tapKey(tester, 'auth.submit');
    expect(find.byKey(const Key('auth.error.codeInvalid')), findsOneWidget);
    await enter(tester, 'auth.code', auth.outbox.last.code!);
    await tapKey(tester, 'auth.submit');

    expect(auth.current.verified, isTrue);
    expect(c.read(routerProvider).state.uri.path, Routes.profile);
    final email = find.byKey(const Key('profile.accountEmail'));
    await show(tester, email);
    expect(
      find.descendant(of: email, matching: find.text('Email verified')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('profile.deleteAccount')), findsOneWidget);
    await tapKey(tester, 'profile.signOut');
    expect(auth.current.signedIn, isFalse);
    await show(tester, find.byKey(const Key('profile.signIn')));
  });

  testWidgets('kirish: noto‘g‘ri parol; tasdiqlanmagan → kod ekrani', (
    tester,
  ) async {
    final auth = MockAuthRepository();
    await auth.register(
      email: 'u@lab.uz',
      password: _pw,
      acceptedTermsVersion: 'v',
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.accountSignIn,
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    await enter(tester, 'auth.email', 'u@lab.uz');
    await enter(tester, 'auth.password', 'Wrong123456');
    await tapKey(tester, 'auth.submit');
    expect(
      find.byKey(const Key('auth.error.invalidCredentials')),
      findsOneWidget,
    );
    await enter(tester, 'auth.password', _pw);
    await tapKey(tester, 'auth.submit');
    expect(find.byKey(const Key('screen.verify')), findsOneWidget);
  });

  testWidgets('parolni unutdim → kod → yangi parol → kirish', (tester) async {
    var now = DateTime.utc(2026, 10, 5);
    final auth = MockAuthRepository(clock: () => now);
    await auth.register(
      email: 'r@lab.uz',
      password: _pw,
      acceptedTermsVersion: 'v',
    );
    await auth.verifyEmail(email: 'r@lab.uz', code: auth.outbox.last.code!);
    await auth.signOut();
    now = now.add(const Duration(minutes: 5));
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.accountSignIn,
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    await tapKey(tester, 'auth.toForgot');
    await enter(tester, 'auth.email', 'r@lab.uz');
    await tapKey(tester, 'auth.submit');
    expect(find.byKey(const Key('screen.reset')), findsOneWidget);
    expect(find.byKey(const Key('auth.resetSent')), findsOneWidget);
    await enter(tester, 'auth.code', auth.outbox.last.code!);
    await enter(tester, 'auth.password', 'NewPassw0rd2');
    await enter(tester, 'auth.confirm', 'NewPassw0rd2');
    await tapKey(tester, 'auth.submit');
    expect(find.byKey(const Key('screen.signIn')), findsOneWidget);
    expect(
      (await auth.signIn(email: 'r@lab.uz', password: 'NewPassw0rd2')).ok,
      isTrue,
    );
    expect(c.read(routerProvider).state.uri.path, Routes.accountSignIn);
  });

  testWidgets('akkauntni o‘chirish: jiddiy tasdiq; lokal ma’lumot alohida', (
    tester,
  ) async {
    final auth = MockAuthRepository();
    await auth.register(
      email: 'd@lab.uz',
      password: _pw,
      acceptedTermsVersion: 'v',
    );
    await auth.verifyEmail(email: 'd@lab.uz', code: auth.outbox.last.code!);
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    await c.read(userDataProvider.notifier).toggleFavorite('morphine');
    await tapKey(tester, 'profile.deleteAccount');
    expect(find.byKey(const Key('screen.deleteAccount')), findsOneWidget);
    expect(find.byKey(const Key('auth.delete.storeNote')), findsOneWidget);
    expect(find.byKey(const Key('auth.delete.localNote')), findsOneWidget);
    final submit = find.byKey(const Key('auth.delete.submit'));
    await show(tester, submit);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    await enter(tester, 'auth.password', 'Wrong123456');
    await tapKey(tester, 'auth.delete.understand');
    await tapKey(tester, 'auth.delete.submit');
    await tester.tap(find.byKey(const Key('auth.delete.final')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('auth.error.requiresRecentLogin')),
      findsOneWidget,
    );
    expect(auth.hasAccount('d@lab.uz'), isTrue);

    await enter(tester, 'auth.password', _pw);
    await tapKey(tester, 'auth.delete.submit');
    await tester.tap(find.byKey(const Key('auth.delete.final')));
    await tester.pumpAndSettle();
    expect(auth.hasAccount('d@lab.uz'), isFalse);
    expect(auth.current.signedIn, isFalse);
    // Akkauntni o‘chirish qurilmadagi saralanganlarni o‘chirmaydi.
    expect(c.read(userDataProvider).favorites, contains('morphine'));
  });

  testWidgets('profil: obuna holati, restore va boshqarish', (tester) async {
    final store = FakeStore(
      tier: PlanTier.studentPro,
      status: EntitlementStatus.cancelledActiveUntilExpiry,
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
      overrides: [entitlementServiceProvider.overrideWithValue(store)],
    );
    final plan = find.byKey(const Key('profile.purchase'));
    await show(tester, plan);
    expect(
      find.descendant(of: plan, matching: find.text('Student Pro')),
      findsOneWidget,
    );
    final status = find.byKey(const Key('profile.subscriptionStatus'));
    expect(
      find.descendant(
        of: status,
        matching: find.textContaining('Cancelled — active until'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('profile.manage')), findsOneWidget);
    await tapKey(tester, 'profile.restore');
    expect(store.restoreCalls, 1);
    expect(find.text('Your subscription is active'), findsOneWidget);
    await show(tester, find.byKey(const Key('profile.aiDisclaimer')));
  });

  testWidgets('restore: faol obuna yo‘q — halol xabar', (tester) async {
    final store = FakeStore();
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.purchase,
      overrides: [entitlementServiceProvider.overrideWithValue(store)],
    );
    await tapKey(tester, 'purchase.restore');
    expect(store.restoreCalls, 1);
    expect(find.text('No active subscriptions to restore.'), findsOneWidget);
  });
}
