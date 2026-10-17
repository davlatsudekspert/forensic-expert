import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/auth/auth_models.dart';
import 'package:forensic_expert/domain/auth/social_sign_in.dart';

class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(String method, Uri uri, Object? body) handler;
  final calls = <(String, Uri, Map<String, String>, Object?)>[];

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls.add((method, uri, headers, jsonBody));
    return handler(method, uri, jsonBody);
  }
}

class _Source implements SocialCredentialSource {
  _Source(this.result);

  final SocialCredentialResult result;
  SocialProvider? asked;

  @override
  Future<SocialCredentialResult> obtain(SocialProvider provider) async {
    asked = provider;
    return result;
  }
}

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);

Map<String, Object?> _session(String provider) => {
  'access_token': 'access-1',
  'refresh_token': 'refresh-1',
  'user': {
    'id': 'uid-1',
    'email': 'a@privaterelay.appleid.com',
    'email_confirmed_at': '2026-10-17',
    'app_metadata': {'provider': provider},
  },
};

SupabaseAuthRepository _repo(_Transport t, [InMemorySessionStore? store]) =>
    SupabaseAuthRepository(
      config: _cfg,
      sessionStore: store ?? InMemorySessionStore(),
      transport: t,
    );

void main() {
  group('SocialNonce', () {
    test('sha256Hex: ma’lum vektor (abc)', () {
      expect(
        SocialNonce.sha256Hex('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('generate: uzunlik, alifbo, har safar boshqa', () {
      final a = SocialNonce.generate();
      final b = SocialNonce.generate();
      expect(a.length, 32);
      expect(RegExp(r'^[0-9A-Za-z._-]+$').hasMatch(a), isTrue);
      expect(a, isNot(b));
      expect(SocialNonce.generate(length: 64, random: Random(1)).length, 64);
    });

    test('xeshi xom nonce’dan farq qiladi va 64 belgili hex', () {
      final raw = SocialNonce.generate();
      final h = SocialNonce.sha256Hex(raw);
      expect(h, isNot(raw));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(h), isTrue);
    });
  });

  group('visibleSocialProviders', () {
    List<SocialProvider> v(
      TargetPlatform p, {
      bool on = true,
      bool web = false,
    }) => visibleSocialProviders(enabled: on, platform: p, isWeb: web);

    test('bayroq o‘chiq — hech narsa', () {
      expect(v(TargetPlatform.iOS, on: false), isEmpty);
      expect(v(TargetPlatform.android, on: false), isEmpty);
    });

    test('iOS: Apple birinchi, keyin Google', () {
      expect(v(TargetPlatform.iOS), [
        SocialProvider.apple,
        SocialProvider.google,
      ]);
    });

    test('Android: faqat Google (Apple yashirin)', () {
      expect(v(TargetPlatform.android), [SocialProvider.google]);
    });

    test('desktop va web: yo‘q', () {
      expect(v(TargetPlatform.linux), isEmpty);
      expect(v(TargetPlatform.iOS, web: true), isEmpty);
    });
  });

  group('SupabaseAuthRepository.signInWithIdToken', () {
    test(
      'Apple muvaffaqiyat: id_token grant, nonce, sessiya, ism saqlanadi',
      () async {
        final store = InMemorySessionStore();
        final t = _Transport(
          (m, u, b) => u.path.endsWith('/token')
              ? RestResponse(200, _session('apple'))
              : const RestResponse(200, {}),
        );
        final repo = _repo(t, store);
        final r = await repo.signInWithIdToken(
          provider: SocialProvider.apple,
          idToken: 'apple.jwt',
          nonce: 'raw-nonce',
          fullName: ' Ali Valiyev ',
          acceptedTermsVersion: '2026-10',
        );
        expect(r.ok, isTrue);
        final (method, uri, headers, body) = t.calls.first;
        expect(method, 'POST');
        expect(uri.path, '/auth/v1/token');
        expect(uri.queryParameters['grant_type'], 'id_token');
        expect(headers['apikey'], 'anon-public-test-key');
        expect(body, {
          'provider': 'apple',
          'id_token': 'apple.jwt',
          'nonce': 'raw-nonce',
        });
        expect(repo.current.signedIn, isTrue);
        expect(repo.current.account!.provider, 'apple');
        expect(repo.current.account!.isSocial, isTrue);
        expect(await store.read(), 'refresh-1');
        // Ism va shartlar versiyasi user_metadata’ga (Authorization bilan).
        final (m2, u2, h2, b2) = t.calls[1];
        expect(m2, 'PUT');
        expect(u2.path, '/auth/v1/user');
        expect(h2['Authorization'], 'Bearer access-1');
        expect(b2, {
          'data': {
            'full_name': 'Ali Valiyev',
            'accepted_terms_version': '2026-10',
          },
        });
      },
    );

    test('Google muvaffaqiyat: nonce yo‘q, ism yozilmaydi', () async {
      final t = _Transport((m, u, b) => RestResponse(200, _session('google')));
      final repo = _repo(t);
      final r = await repo.signInWithIdToken(
        provider: SocialProvider.google,
        idToken: 'g.jwt',
      );
      expect(r.ok, isTrue);
      expect(t.calls.single.$4, {'provider': 'google', 'id_token': 'g.jwt'});
      expect(repo.current.account!.provider, 'google');
    });

    test('profil yozuvi xato bo‘lsa ham kirish saqlanadi', () async {
      final t = _Transport(
        (m, u, b) => m == 'PUT'
            ? const RestResponse(500, {})
            : RestResponse(200, _session('apple')),
      );
      final repo = _repo(t);
      final r = await repo.signInWithIdToken(
        provider: SocialProvider.apple,
        idToken: 't',
        fullName: 'Ali',
      );
      expect(r.ok, isTrue);
      expect(repo.current.signedIn, isTrue);
    });

    test('xato: yomon token → socialUnavailable, sessiya ochilmaydi', () async {
      final t = _Transport(
        (m, u, b) => const RestResponse(400, {'error_code': 'bad_id_token'}),
      );
      final repo = _repo(t);
      final r = await repo.signInWithIdToken(
        provider: SocialProvider.apple,
        idToken: 'bad',
        nonce: 'n',
      );
      expect(r.failure, AuthFailure.socialUnavailable);
      expect(repo.current.signedIn, isFalse);
    });

    test('xato: provayder yoqilmagan → backendNotConfigured', () async {
      final t = _Transport(
        (m, u, b) =>
            const RestResponse(400, {'error_code': 'validation_failed'}),
      );
      final r = await _repo(t)
          .signInWithIdToken(provider: SocialProvider.google, idToken: 'x');
      expect(r.failure, AuthFailure.backendNotConfigured);
    });

    test('xato: 429 va 5xx va oflayn', () async {
      expect(
        (await _repo(
              _Transport((m, u, b) => const RestResponse(429, {})),
            ).signInWithIdToken(provider: SocialProvider.google, idToken: 'x'))
            .failure,
        AuthFailure.tooManyRequests,
      );
      expect(
        (await _repo(
              _Transport((m, u, b) => const RestResponse(503, {})),
            ).signInWithIdToken(provider: SocialProvider.google, idToken: 'x'))
            .failure,
        AuthFailure.server,
      );
      expect(
        (await _repo(
              _Transport((m, u, b) => throw const SocketException('x')),
            ).signInWithIdToken(provider: SocialProvider.google, idToken: 'x'))
            .failure,
        AuthFailure.offline,
      );
    });

    test('bo‘sh token so‘rovsiz rad etiladi', () async {
      final t = _Transport((m, u, b) => const RestResponse(200, {}));
      final r = await _repo(t)
          .signInWithIdToken(provider: SocialProvider.google, idToken: '');
      expect(r.failure, AuthFailure.socialUnavailable);
      expect(t.calls, isEmpty);
    });

    test('mock backend ijtimoiy kirishni soxtalashtirmaydi', () async {
      final r = await MockAuthRepository().signInWithIdToken(
        provider: SocialProvider.google,
        idToken: 'x',
      );
      expect(r.failure, AuthFailure.backendNotConfigured);
    });
  });

  group('SocialSignInService', () {
    Future<AuthOutcome> exchange(SocialCredential c) async =>
        const AuthOutcome.ok();

    test(
      'foydalanuvchi bekor qildi → cancelled, almashuv chaqirilmaydi',
      () async {
        var called = false;
        final s = SocialSignInService(
          _Source(const SocialCredentialResult.fail(AuthFailure.cancelled)),
        );
        final r = await s.signIn(
          SocialProvider.google,
          exchange: (c) async {
            called = true;
            return const AuthOutcome.ok();
          },
        );
        expect(r.failure, AuthFailure.cancelled);
        expect(called, isFalse);
      },
    );

    test('token olindi → almashuv natijasi qaytadi', () async {
      final src = _Source(
        const SocialCredentialResult.ok(
          SocialCredential(provider: SocialProvider.apple, idToken: 't'),
        ),
      );
      final r = await SocialSignInService(src)
          .signIn(SocialProvider.apple, exchange: exchange);
      expect(r.ok, isTrue);
      expect(src.asked, SocialProvider.apple);
    });

    test('manba istisno tashlasa → socialUnavailable', () async {
      final r = await SocialSignInService(_Throwing())
          .signIn(SocialProvider.google, exchange: exchange);
      expect(r.failure, AuthFailure.socialUnavailable);
    });
  });
}

class _Throwing implements SocialCredentialSource {
  @override
  Future<SocialCredentialResult> obtain(SocialProvider provider) =>
      throw StateError('plugin');
}
