import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_ai_provider.dart';
import 'package:forensic_expert/data/remote/supabase_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/ai/ai_architecture.dart';
import 'package:forensic_expert/domain/auth/auth_models.dart';
import 'package:forensic_expert/domain/ports/ai_ports.dart';

/// Soxta transport: so‘rovlarni yozib oladi, oldindan berilgan javoblarni
/// qaytaradi. Haqiqiy tarmoq yo‘q — hech qanday xat yuborilmaydi.
class FakeTransport implements RestTransport {
  FakeTransport(this.handler);

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

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);

Map<String, Object?> _session(String email) => {
  'access_token': 'access-1',
  'refresh_token': 'refresh-1',
  'user': {'id': 'uid-1', 'email': email, 'email_confirmed_at': '2026-10-05'},
};

void main() {
  group('Supabase email OTP', () {
    test('kod so‘rash: functions/v1/email-otp, til, normalizatsiya', () async {
      final t = FakeTransport((m, u, b) => const RestResponse(200, {}));
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: InMemorySessionStore(),
        transport: t,
      );
      final r = await repo.requestEmailCode(
        ' Expert@Example.ORG ',
        locale: 'uz',
      );
      expect(r.ok, isTrue);
      final (method, uri, headers, body) = t.calls.single;
      expect(method, 'POST');
      expect(uri.path, '/functions/v1/email-otp');
      expect(headers['apikey'], 'anon-public-test-key');
      expect(body, {
        'action': 'request',
        'email': 'expert@example.org',
        'locale': 'uz',
      });
      // Kod/parol hech qachon so‘rashda yo‘q.
      expect('$body', isNot(contains('token')));
    });

    test('noto‘g‘ri email — tarmoqqa chiqmaydi', () async {
      final t = FakeTransport((m, u, b) => const RestResponse(200, {}));
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: InMemorySessionStore(),
        transport: t,
      );
      final r = await repo.requestEmailCode('not-an-email');
      expect(r.failure, AuthFailure.invalidEmail);
      expect(t.calls, isEmpty);
    });

    test('to‘g‘ri kod → sessiya; refresh token xavfsiz saqlanadi', () async {
      final store = InMemorySessionStore();
      final t = FakeTransport(
        (m, u, b) => RestResponse(200, _session('expert@example.org')),
      );
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: store,
        transport: t,
      );
      final r = await repo.verifyEmailCode(
        email: 'expert@example.org',
        code: '123456',
      );
      expect(r.ok, isTrue);
      expect(t.calls.single.$2.path, '/functions/v1/email-otp');
      expect((t.calls.single.$4! as Map)['action'], 'verify');
      expect(repo.current.signedIn, isTrue);
      expect(await store.read(), 'refresh-1');
      expect(await repo.accessToken(), 'access-1');
    });

    test('noto‘g‘ri kod (403) / muddati o‘tgan / limit (429)', () async {
      for (final (resp, failure) in [
        (
          const RestResponse(403, {'error_code': 'bad_code'}),
          AuthFailure.codeInvalid,
        ),
        (
          const RestResponse(403, {'error_code': 'otp_expired'}),
          AuthFailure.codeExpired,
        ),
        (const RestResponse(429, {}), AuthFailure.tooManyRequests),
        (
          const RestResponse(400, {'error_code': 'over_email_send_rate_limit'}),
          AuthFailure.tooManyRequests,
        ),
        (const RestResponse(503, {}), AuthFailure.server),
      ]) {
        final repo = SupabaseAuthRepository(
          config: _cfg,
          sessionStore: InMemorySessionStore(),
          transport: FakeTransport((m, u, b) => resp),
        );
        final r = await repo.verifyEmailCode(
          email: 'expert@example.org',
          code: '654321',
        );
        expect(r.failure, failure, reason: '${resp.status} ${resp.json}');
        expect(repo.current.signedIn, isFalse);
      }
    });

    test('jo‘natuvchi sozlanmagan (503) — «ulanmagan», xato emas', () async {
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: InMemorySessionStore(),
        transport: FakeTransport(
          (m, u, b) =>
              const RestResponse(503, {'error_code': 'email_not_configured'}),
        ),
      );
      final r = await repo.requestEmailCode('expert@example.org');
      expect(r.failure, AuthFailure.backendNotConfigured);
    });

    test('6 xonali bo‘lmagan kod — serverga yuborilmaydi', () async {
      final t = FakeTransport((m, u, b) => const RestResponse(200, {}));
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: InMemorySessionStore(),
        transport: t,
      );
      final r = await repo.verifyEmailCode(email: 'a@b.org', code: '12ab');
      expect(r.failure, AuthFailure.codeInvalid);
      expect(t.calls, isEmpty);
    });

    test('oflayn — offline xatosi, sessiya buzilmaydi', () async {
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: InMemorySessionStore(),
        transport: FakeTransport(
          (m, u, b) => throw const SocketException('offline'),
        ),
      );
      final r = await repo.requestEmailCode('expert@example.org');
      expect(r.failure, AuthFailure.offline);
    });

    test('sessiyani tiklash (refresh) va chiqish', () async {
      final store = InMemorySessionStore();
      await store.write('refresh-0');
      final t = FakeTransport((m, u, b) {
        if (u.path.endsWith('/logout')) return const RestResponse(204, null);
        return RestResponse(200, _session('expert@example.org'));
      });
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: store,
        transport: t,
      );
      await repo.restoreSession();
      expect(repo.current.signedIn, isTrue);
      expect(t.calls.first.$2.query, 'grant_type=refresh_token');
      await repo.signOut();
      expect(repo.current.signedIn, isFalse);
      expect(await store.read(), isNull);
      expect(t.calls.last.$3['Authorization'], 'Bearer access-1');
    });

    test('access token muddati tugaganda refresh bilan yangilanadi', () async {
      String jwt(DateTime exp) =>
          'h.${base64Url.encode(utf8.encode(jsonEncode({'exp': exp.millisecondsSinceEpoch ~/ 1000}))).replaceAll('=', '')}.s';
      var now = DateTime.utc(2026, 10, 6, 10, 53);
      final first = jwt(now.add(const Duration(hours: 1)));
      final second = jwt(now.add(const Duration(hours: 2)));
      final t = FakeTransport((m, u, b) {
        final s = _session('e@x.org');
        s['access_token'] = u.query.contains('refresh_token') ? second : first;
        return RestResponse(200, s);
      });
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: InMemorySessionStore(),
        transport: t,
        clock: () => now,
      );
      await repo.verifyEmailCode(email: 'e@x.org', code: '123456');
      expect(await repo.accessToken(), first);
      expect(t.calls, hasLength(1));
      // 59 daqiqadan keyin (muddatga < 60 s) — refresh.
      now = now.add(const Duration(minutes: 59, seconds: 30));
      expect(await repo.accessToken(), second);
      expect(t.calls.last.$2.query, 'grant_type=refresh_token');
      expect(repo.current.signedIn, isTrue);
    });

    test('bekor qilingan refresh token — lokal sessiya tozalanadi', () async {
      final store = InMemorySessionStore();
      await store.write('revoked');
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: store,
        transport: FakeTransport(
          (m, u, b) => const RestResponse(400, {'error_code': 'invalid_grant'}),
        ),
      );
      await repo.restoreSession();
      expect(repo.current.signedIn, isFalse);
      expect(await store.read(), isNull);
    });
  });

  group('Gemini (server orqali)', () {
    const prompt = AiPrompt(
      question: AiQuestion(text: 'Morphine metabolites?', languageCode: 'en'),
      experience: AiExperience.professional,
      chunks: [
        RetrievedChunk(
          chunkId: 'c1',
          entityId: 'morphine',
          text: 'Chunk text',
          sourceIds: ['SRC-1'],
          tier: AiEvidenceTier.internalReviewed,
          score: 1,
        ),
      ],
    );

    Future<SupabaseAuthRepository> signedIn(FakeTransport t) async {
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: InMemorySessionStore(),
        transport: t,
      );
      await repo.verifyEmailCode(email: 'e@x.org', code: '123456');
      return repo;
    }

    test(
      'faqat bo‘laklar yuboriladi; kalit ilovada yo‘q; iqtiboslar',
      () async {
        final t = FakeTransport((m, u, b) {
          if (u.path.contains('/functions/v1/ai-answer')) {
            return const RestResponse(200, {
              'text': 'Answer',
              'cited': ['c1', 42],
            });
          }
          return RestResponse(200, _session('e@x.org'));
        });
        final ai = SupabaseAiProvider(
          config: _cfg,
          auth: await signedIn(t),
          transport: t,
        );
        final d = await ai.generate(prompt);
        expect(d.text, 'Answer');
        expect(d.citedChunkIds, ['c1']);
        final call = t.calls.last;
        expect(call.$3['Authorization'], 'Bearer access-1');
        expect('${call.$3}', isNot(contains('GEMINI')));
        expect((call.$4! as Map)['chunks'], [
          {'id': 'c1', 'title': '', 'text': 'Chunk text'},
        ]);
      },
    );

    test('bir savol — server bir marta (router + RAG umumiy)', () async {
      final t = FakeTransport((m, u, b) {
        if (u.path.contains('/functions/v1/ai-answer')) {
          return const RestResponse(200, {
            'text': 'A',
            'cited': ['c1'],
          });
        }
        return RestResponse(200, _session('e@x.org'));
      });
      final auth = await signedIn(t);
      final ai = SupabaseAiProvider(config: _cfg, auth: auth, transport: t);
      await ai.generate(prompt);
      await ai.generate(prompt);
      expect(t.calls.where((c) => c.$2.path.contains('ai-answer')).length, 1);
      // Beta: kirgan foydalanuvchiga AI ochiq, kirmaganga yo‘q.
      expect(
        (await SignedInBetaAiEntitlementService(auth).current()).canAsk,
        isTrue,
      );
      expect(RemoteAiAssistant(auth).availability, AiAvailability.available);
      await auth.signOut();
      expect(
        (await SignedInBetaAiEntitlementService(auth).current()).canAsk,
        isFalse,
      );
    });

    test('kirmagan foydalanuvchi / server xatosi — AiUnavailable', () async {
      final t = FakeTransport((m, u, b) => const RestResponse(429, {}));
      final notSigned = SupabaseAiProvider(
        config: _cfg,
        auth: SupabaseAuthRepository(
          config: _cfg,
          sessionStore: InMemorySessionStore(),
          transport: t,
        ),
        transport: t,
      );
      expect(notSigned.generate(prompt), throwsA(isA<AiUnavailable>()));
    });
  });
}
