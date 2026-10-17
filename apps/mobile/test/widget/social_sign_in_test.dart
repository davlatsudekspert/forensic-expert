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

  /// Social akkaunt bilan kirgan repo + o‘chirish ekrani; `bodies` — server
  /// `delete-account` ga yuborilgan JSON.
  Future<List<Object?>> deleteFlow(
    WidgetTester tester, {
    required String provider,
    required SocialCredentialSource source,
    List<Uri>? calls,
  }) async {
    final bodies = <Object?>[];
    final repo = SupabaseAuthRepository(
      config: SupabaseConfig(
        url: Uri.parse('https://fe-test.supabase.co/'),
        anonKey: 'anon-public-test-key',
      ),
      sessionStore: InMemorySessionStore(),
      transport: _FakeTransport((m, u, body) {
        calls?.add(u);
        if (u.path.endsWith('delete-account')) bodies.add(body);
        return u.path.endsWith('/token')
            ? RestResponse(200, {
                'access_token': 'a',
                'refresh_token': 'r',
                'user': {
                  'id': 'u1',
                  'email': 'x@privaterelay.appleid.com',
                  'app_metadata': {'provider': provider},
                },
              })
            : const RestResponse(200, {'ok': true});
      }),
    );
    await repo.signInWithIdToken(
      provider: provider == 'apple'
          ? SocialProvider.apple
          : SocialProvider.google,
      idToken: 't',
      nonce: 'n',
    );
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.profile,
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        socialCredentialSourceProvider.overrideWithValue(source),
      ],
    );
    c.read(routerProvider).go(Routes.accountDelete);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth.password')), findsNothing);
    await show(tester, find.byKey(const Key('auth.delete.understand')));
    await tester.tap(find.byKey(const Key('auth.delete.understand')));
    await tester.pumpAndSettle();
    await show(tester, find.byKey(const Key('auth.delete.submit')));
    await tester.tap(find.byKey(const Key('auth.delete.submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auth.delete.final')));
    await tester.pumpAndSettle();
    return bodies;
  }

  testWidgets(
    'Google akkauntini o‘chirish: parol ham, Apple qayta tasdig‘i ham yo‘q',
    (tester) async {
      final src = _CodeSource.ok('should-not-be-used');
      final calls = <Uri>[];
      final bodies = await deleteFlow(
        tester,
        provider: 'google',
        source: src,
        calls: calls,
      );
      expect(find.byKey(const Key('auth.delete.socialNote')), findsNothing);
      expect(src.asked, isEmpty);
      expect(calls.any((u) => u.path.endsWith('delete-account')), isTrue);
      expect(bodies.single, {'confirm': true});
    },
  );

  testWidgets(
    'Apple akkaunti: qayta tasdiqlanadi va authorizationCode yuboriladi',
    (tester) async {
      final src = _CodeSource.ok('fresh-apple-code');
      final bodies = await deleteFlow(tester, provider: 'apple', source: src);
      expect(src.asked, [SocialProvider.apple]);
      expect(bodies.single, {
        'confirm': true,
        'apple_authorization_code': 'fresh-apple-code',
      });
    },
  );

  testWidgets('Apple qayta tasdiqlashni bekor qilsa: akkaunt o‘chirilmaydi', (
    tester,
  ) async {
    final src = _CodeSource.fail(AuthFailure.cancelled);
    final bodies = await deleteFlow(tester, provider: 'apple', source: src);
    expect(src.asked, [SocialProvider.apple]);
    expect(bodies, isEmpty);
    expect(find.byKey(const Key('screen.deleteAccount')), findsOneWidget);
  });

  testWidgets('Apple oynasi ishlamasa: o‘chirish kodsiz davom etadi', (
    tester,
  ) async {
    final src = _CodeSource.fail(AuthFailure.socialUnavailable);
    final bodies = await deleteFlow(tester, provider: 'apple', source: src);
    expect(bodies.single, {'confirm': true});
  });

  testWidgets('Apple akkaunt uchun maxsus izoh ko‘rsatiladi', (tester) async {
    final src = _CodeSource.ok('c');
    final repo = SupabaseAuthRepository(
      config: SupabaseConfig(
        url: Uri.parse('https://fe-test.supabase.co/'),
        anonKey: 'anon-public-test-key',
      ),
      sessionStore: InMemorySessionStore(),
      transport: _FakeTransport(
        (m, u, b) => const RestResponse(200, {
          'access_token': 'a',
          'refresh_token': 'r',
          'user': {
            'id': 'u1',
            'email': 'x@y.z',
            'app_metadata': {'provider': 'apple'},
          },
        }),
      ),
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
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        socialCredentialSourceProvider.overrideWithValue(src),
      ],
    );
    c.read(routerProvider).go(Routes.accountDelete);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth.delete.socialNote')), findsOneWidget);
    expect(
      find.textContaining('Apple o‘zingizni tasdiqlashni'),
      findsOneWidget,
    );
  });
}

class _CodeSource implements SocialCredentialSource {
  _CodeSource.ok(String code)
    : _result = SocialCredentialResult.ok(
        SocialCredential(
          provider: SocialProvider.apple,
          idToken: 'id',
          authorizationCode: code,
        ),
      );
  _CodeSource.fail(AuthFailure f) : _result = SocialCredentialResult.fail(f);

  final SocialCredentialResult _result;
  final asked = <SocialProvider>[];

  @override
  Future<SocialCredentialResult> obtain(SocialProvider provider) async {
    asked.add(provider);
    return _result;
  }
}

class _FakeTransport implements RestTransport {
  _FakeTransport(this.handler);

  final RestResponse Function(String method, Uri uri, Object? body) handler;

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async => handler(method, uri, jsonBody);
}
