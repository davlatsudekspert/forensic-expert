import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/social_sign_in_flag.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/auth/auth_models.dart';
import 'package:forensic_expert/domain/auth/social_sign_in.dart';

import '../helpers/pump_app.dart';

class _Source implements SocialCredentialSource {
  _Source(this.failure);

  final AuthFailure failure;
  final asked = <SocialProvider>[];

  @override
  Future<SocialCredentialResult> obtain(SocialProvider provider) async {
    asked.add(provider);
    return SocialCredentialResult.fail(failure);
  }
}

/// Google/Apple tugmalari: bayroq va platforma qoidalari (haqiqiy native
/// oqim bu yerda sinalmaydi).
void main() {
  /// Platforma/bayroqni o‘rnatadi va test tanasi tugagach (invariantlar
  /// tekshirilishidan oldin) tiklaydi.
  Future<void> scenario(
    TargetPlatform platform,
    bool enabled,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    socialSignInEnabled = enabled;
    try {
      await body();
    } finally {
      socialSignInEnabled = kSocialSignIn;
      debugDefaultTargetPlatformOverride = null;
    }
  }

  Future<ProviderContainer> open(
    WidgetTester tester, {
    String route = Routes.accountSignIn,
    SocialCredentialSource? source,
  }) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.profile,
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        if (source != null)
          socialCredentialSourceProvider.overrideWithValue(source),
      ],
    );
    c.read(routerProvider).go(route);
    await tester.pumpAndSettle();
    return c;
  }

  Future<void> show(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.pumpAndSettle();
  }

  test('bayroq standart holatda o‘chiq', () {
    expect(kSocialSignIn, isFalse);
  });

  for (final route in [
    Routes.accountSignIn,
    Routes.accountRegister,
    Routes.accountEmailCode,
  ]) {
    testWidgets('bayroq o‘chiq: $route da tugmalar yo‘q', (tester) async {
      await scenario(TargetPlatform.iOS, false, () async {
        await open(tester, route: route);
        expect(find.byKey(const Key('social.google')), findsNothing);
        expect(find.byKey(const Key('social.apple')), findsNothing);
        expect(find.byKey(const Key('social.buttons')), findsNothing);
      });
    });
  }

  testWidgets('bayroq yoniq + iOS: Apple va Google ikkalasi, o‘zbekcha matn', (
    tester,
  ) async {
    await scenario(TargetPlatform.iOS, true, () async {
      await open(tester);
      await show(tester, find.byKey(const Key('social.google')));
      expect(find.byKey(const Key('social.apple')), findsOneWidget);
      expect(find.byKey(const Key('social.google')), findsOneWidget);
      expect(find.text('Google bilan davom etish'), findsOneWidget);
      expect(find.text('Apple bilan davom etish'), findsOneWidget);
      // Apple Google’dan yuqorida (HIG: kam ko‘rinmasin).
      expect(
        tester.getTopLeft(find.byKey(const Key('social.apple'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('social.google'))).dy),
      );
      // Email kirish saqlanadi.
      expect(find.byKey(const Key('auth.submit')), findsOneWidget);
    });
  });

  testWidgets('bayroq yoniq + Android: faqat Google', (tester) async {
    await scenario(TargetPlatform.android, true, () async {
      await open(tester);
      await show(tester, find.byKey(const Key('social.google')));
      expect(find.byKey(const Key('social.google')), findsOneWidget);
      expect(find.byKey(const Key('social.apple')), findsNothing);
    });
  });

  testWidgets('email kodi ekranida ham ko‘rinadi (iOS)', (tester) async {
    await scenario(TargetPlatform.iOS, true, () async {
      await open(tester, route: Routes.accountEmailCode);
      await show(tester, find.byKey(const Key('social.google')));
      expect(find.byKey(const Key('social.apple')), findsOneWidget);
    });
  });

  testWidgets('foydalanuvchi bekor qildi: xato ko‘rsatilmaydi', (tester) async {
    await scenario(TargetPlatform.android, true, () async {
      final src = _Source(AuthFailure.cancelled);
      await open(tester, source: src);
      await show(tester, find.byKey(const Key('social.google')));
      await tester.tap(find.byKey(const Key('social.google')));
      await tester.pumpAndSettle();
      expect(src.asked, [SocialProvider.google]);
      expect(
        find.text(
          'Bu usulda kirish hozir mavjud emas. Qayta urinib ko‘ring yoki email orqali kiring.',
        ),
        findsNothing,
      );
      expect(find.byKey(const Key('screen.signIn')), findsOneWidget);
    });
  });

  testWidgets('xato: tushunarli o‘zbekcha xabar', (tester) async {
    await scenario(TargetPlatform.android, true, () async {
      await open(tester, source: _Source(AuthFailure.socialUnavailable));
      await show(tester, find.byKey(const Key('social.google')));
      await tester.tap(find.byKey(const Key('social.google')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Bu usulda kirish hozir mavjud emas. Qayta urinib ko‘ring yoki email orqali kiring.',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('Google/Apple akkauntini o‘chirish: parol so‘ralmaydi', (
    tester,
  ) async {
    final calls = <Uri>[];
    final repo = SupabaseAuthRepository(
      config: SupabaseConfig(
        url: Uri.parse('https://fe-test.supabase.co/'),
        anonKey: 'anon-public-test-key',
      ),
      sessionStore: InMemorySessionStore(),
      transport: _FakeTransport((m, u) {
        calls.add(u);
        return u.path.endsWith('/token')
            ? const RestResponse(200, {
                'access_token': 'a',
                'refresh_token': 'r',
                'user': {
                  'id': 'u1',
                  'email': 'x@privaterelay.appleid.com',
                  'app_metadata': {'provider': 'apple'},
                },
              })
            : const RestResponse(200, {'ok': true});
      }),
    );
    await repo.signInWithIdToken(
      provider: SocialProvider.apple,
      idToken: 't',
      nonce: 'n',
    );
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.profile,
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    c.read(routerProvider).go(Routes.accountDelete);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth.password')), findsNothing);
    expect(find.byKey(const Key('auth.delete.socialNote')), findsOneWidget);
    await show(tester, find.byKey(const Key('auth.delete.understand')));
    await tester.tap(find.byKey(const Key('auth.delete.understand')));
    await tester.pumpAndSettle();
    await show(tester, find.byKey(const Key('auth.delete.submit')));
    await tester.tap(find.byKey(const Key('auth.delete.submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auth.delete.final')));
    await tester.pumpAndSettle();
    expect(calls.any((u) => u.path.endsWith('delete-account')), isTrue);
  });
}

class _FakeTransport implements RestTransport {
  _FakeTransport(this.handler);

  final RestResponse Function(String method, Uri uri) handler;

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async => handler(method, uri);
}
