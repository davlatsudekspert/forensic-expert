import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/offline/offline_backend.dart';
import 'package:forensic_expert/data/remote/http_auth_repository.dart';
import 'package:forensic_expert/domain/auth/auth_models.dart';

const _pw = 'TestPassw0rd!';
const _other = 'Other1234567';

void main() {
  group('email', () {
    test('normallashtirish va tekshiruv', () {
      expect(
        EmailAddress.normalize('  Expert@Example.UZ '),
        'expert@example.uz',
      );
      for (final ok in ['a@b.co', 'first.last+tag@lab.example.org']) {
        expect(EmailAddress.isValid(ok), isTrue, reason: ok);
      }
      for (final bad in [
        '',
        'plain',
        'a@b',
        'a@@b.com',
        'a b@c.com',
        '.a@b.com',
        'a..b@c.com',
        'a.@b.com',
        '${'x' * 65}@b.com',
        'a@${'d' * 250}.com',
      ]) {
        expect(EmailAddress.isValid(bad), isFalse, reason: bad);
      }
    });
  });

  group('parol siyosati', () {
    test('qoidalar', () {
      expect(PasswordPolicy.isAcceptable(_pw), isTrue);
      expect(
        PasswordPolicy.violations('short1'),
        contains(PasswordRule.minLength),
      );
      expect(
        PasswordPolicy.violations('onlyletterslong'),
        contains(PasswordRule.digit),
      );
      expect(
        PasswordPolicy.violations('1234567890123'),
        contains(PasswordRule.letter),
      );
      expect(
        PasswordPolicy.violations('expert12345', email: 'expert12345@lab.uz'),
        contains(PasswordRule.notEmail),
      );
      expect(
        PasswordPolicy.violations('a1${'x' * 200}'),
        contains(PasswordRule.maxLength),
      );
      // Kirill/lotin harflari ham harf hisoblanadi.
      expect(PasswordPolicy.isAcceptable('экспертиза2026'), isTrue);
    });

    test('ro‘yxatdan o‘tish kiritmasi', () {
      AuthFailure? r(String e, String p, String c, bool t) =>
          AuthInput.registration(
            email: e,
            password: p,
            confirmPassword: c,
            termsAccepted: t,
          );
      expect(r('bad', _pw, _pw, true), AuthFailure.invalidEmail);
      expect(r('a@b.co', 'weak', 'weak', true), AuthFailure.weakPassword);
      expect(r('a@b.co', _pw, '${_pw}x', true), AuthFailure.passwordMismatch);
      expect(r('a@b.co', _pw, _pw, false), AuthFailure.termsNotAccepted);
      expect(r('a@b.co', _pw, _pw, true), isNull);
    });
  });

  group('MOCK backend (server kontrakti)', () {
    late DateTime now;
    late InMemorySessionStore session;
    late MockAuthRepository auth;

    setUp(() {
      now = DateTime.utc(2026, 10, 5, 12);
      session = InMemorySessionStore();
      auth = MockAuthRepository(clock: () => now, sessionStore: session);
    });

    String lastCode(String kind) =>
        auth.outbox.lastWhere((m) => m.kind == kind).code!;

    Future<void> registerAndVerify(String email) async {
      await auth.register(
        email: email,
        password: _pw,
        acceptedTermsVersion: 'v',
      );
      await auth.verifyEmail(email: email, code: lastCode('verify'));
    }

    test('ro‘yxat → tasdiqlash → sessiya; sessiyasiz kirish yo‘q', () async {
      final r = await auth.register(
        email: ' New@Lab.UZ ',
        password: _pw,
        acceptedTermsVersion: '2026-10',
      );
      expect(r.ok, isTrue);
      expect(auth.current.signedIn, isFalse);
      expect(auth.outbox.single.to, 'new@lab.uz');
      expect(
        (await auth.signIn(email: 'new@lab.uz', password: _pw)).failure,
        AuthFailure.emailNotVerified,
      );
      expect(
        (await auth.verifyEmail(email: 'new@lab.uz', code: '000000')).failure,
        AuthFailure.codeInvalid,
      );
      final ok = await auth.verifyEmail(
        email: 'new@lab.uz',
        code: lastCode('verify'),
      );
      expect(ok.ok, isTrue);
      expect(auth.current.verified, isTrue);
      expect(await session.read(), isNotNull);
      expect(
        (await auth.verifyEmail(email: 'new@lab.uz', code: '123456')).failure,
        AuthFailure.alreadyVerified,
      );
    });

    test('band email — bir xil javob (enumeratsiya yo‘q)', () async {
      await registerAndVerify('a@lab.uz');
      final again = await auth.register(
        email: 'A@lab.uz',
        password: _other,
        acceptedTermsVersion: 'v',
      );
      expect(again.ok, isTrue);
      expect(auth.outbox.last.kind, 'already_registered');
      expect(auth.outbox.last.code, isNull);
    });

    test('kod muddati tugaydi; qayta yuborish oralig‘i', () async {
      await auth.register(
        email: 'x@lab.uz',
        password: _pw,
        acceptedTermsVersion: 'v',
      );
      final code = lastCode('verify');
      expect(
        (await auth.resendVerification('x@lab.uz')).failure,
        AuthFailure.tooManyRequests,
      );
      now = now.add(AuthCodePolicy.verificationTtl);
      expect(
        (await auth.verifyEmail(email: 'x@lab.uz', code: code)).failure,
        AuthFailure.codeExpired,
      );
      expect((await auth.resendVerification('x@lab.uz')).ok, isTrue);
      expect(
        (await auth.verifyEmail(
          email: 'x@lab.uz',
          code: lastCode('verify'),
        )).ok,
        isTrue,
      );
      // Mavjud bo‘lmagan email uchun ham bir xil javob.
      now = now.add(const Duration(minutes: 5));
      expect((await auth.resendVerification('ghost@lab.uz')).ok, isTrue);
    });

    test(
      'kirish: noto‘g‘ri parol va mavjud bo‘lmagan email — bir xil xato',
      () async {
        await registerAndVerify('u@lab.uz');
        await auth.signOut();
        expect(
          (await auth.signIn(
            email: 'u@lab.uz',
            password: 'Wrong123456',
          )).failure,
          AuthFailure.invalidCredentials,
        );
        expect(
          (await auth.signIn(email: 'nobody@lab.uz', password: _pw)).failure,
          AuthFailure.invalidCredentials,
        );
        expect(
          (await auth.signIn(email: 'U@LAB.uz', password: _pw)).ok,
          isTrue,
        );
      },
    );

    test('sessiya tiklanadi; chiqishda token o‘chadi', () async {
      await registerAndVerify('s@lab.uz');
      final restarted = MockAuthRepository(
        clock: () => now,
        sessionStore: session,
      );
      // Yangi ilova instansiyasi boshqa xotirada — server sessiyani tanimaydi.
      await restarted.restoreSession();
      expect(restarted.current.signedIn, isFalse);
      expect(await session.read(), isNull);

      await auth.signIn(email: 's@lab.uz', password: _pw);
      await auth.restoreSession();
      expect(auth.current.signedIn, isTrue);
      await auth.signOut();
      expect(auth.current.signedIn, isFalse);
      expect(await session.read(), isNull);
      expect(await auth.accessToken(), isNull);
    });

    test('parolni tiklash: enumeratsiya yo‘q, bir martalik kod, sessiyalar '
        'bekor', () async {
      await registerAndVerify('r@lab.uz');
      expect((await auth.requestPasswordReset('ghost@lab.uz')).ok, isTrue);
      expect(auth.outbox.where((m) => m.to == 'ghost@lab.uz'), isEmpty);
      now = now.add(const Duration(minutes: 2));
      expect((await auth.requestPasswordReset('r@lab.uz')).ok, isTrue);
      final code = lastCode('reset');
      expect(
        (await auth.resetPassword(
          email: 'r@lab.uz',
          code: code,
          newPassword: 'weak',
        )).failure,
        AuthFailure.weakPassword,
      );
      expect(
        (await auth.resetPassword(
          email: 'r@lab.uz',
          code: '999999',
          newPassword: 'NewPassw0rd2',
        )).failure,
        AuthFailure.codeInvalid,
      );
      final ok = await auth.resetPassword(
        email: 'r@lab.uz',
        code: code,
        newPassword: 'NewPassw0rd2',
      );
      expect(ok.ok, isTrue);
      expect(auth.current.signedIn, isFalse);
      expect(
        (await auth.resetPassword(
          email: 'r@lab.uz',
          code: code,
          newPassword: 'NewPassw0rd3',
        )).failure,
        AuthFailure.codeInvalid,
      );
      expect(
        (await auth.signIn(email: 'r@lab.uz', password: _pw)).failure,
        AuthFailure.invalidCredentials,
      );
      expect(
        (await auth.signIn(email: 'r@lab.uz', password: 'NewPassw0rd2')).ok,
        isTrue,
      );
    });

    test('tiklash kodi muddati', () async {
      await registerAndVerify('e@lab.uz');
      now = now.add(const Duration(minutes: 2));
      await auth.requestPasswordReset('e@lab.uz');
      final code = lastCode('reset');
      now = now.add(AuthCodePolicy.resetTtl);
      expect(
        (await auth.resetPassword(
          email: 'e@lab.uz',
          code: code,
          newPassword: 'NewPassw0rd2',
        )).failure,
        AuthFailure.codeExpired,
      );
    });

    test('akkauntni o‘chirish: parol talab qilinadi, so‘ng hammasi '
        'o‘chadi', () async {
      expect(
        (await auth.deleteAccount(password: _pw)).failure,
        AuthFailure.notSignedIn,
      );
      await registerAndVerify('d@lab.uz');
      expect(
        (await auth.deleteAccount(password: 'Wrong123456')).failure,
        AuthFailure.requiresRecentLogin,
      );
      expect(auth.current.signedIn, isTrue);
      expect((await auth.deleteAccount(password: _pw)).ok, isTrue);
      expect(auth.current.signedIn, isFalse);
      expect(auth.hasAccount('d@lab.uz'), isFalse);
      expect(await session.read(), isNull);
      expect(
        (await auth.signIn(email: 'd@lab.uz', password: _pw)).failure,
        AuthFailure.invalidCredentials,
      );
    });
  });

  test('backend ulanmagan: hech qachon muvaffaqiyat yo‘q', () async {
    const a = OfflineAuthRepository();
    expect(a.isConfigured, isFalse);
    for (final r in [
      await a.register(
        email: 'a@b.co',
        password: _pw,
        acceptedTermsVersion: 'v',
      ),
      await a.signIn(email: 'a@b.co', password: _pw),
      await a.verifyEmail(email: 'a@b.co', code: '123456'),
      await a.resendVerification('a@b.co'),
      await a.requestPasswordReset('a@b.co'),
      await a.resetPassword(email: 'a@b.co', code: '1', newPassword: _pw),
      await a.deleteAccount(password: _pw),
    ]) {
      expect(r.failure, AuthFailure.backendNotConfigured);
    }
    expect(a.current.signedIn, isFalse);
  });

  group('HTTP adapter kontrakti (lokal server)', () {
    late HttpServer server;
    late List<(String, String, Map<String, Object?>, String?)> calls;
    late Map<String, (int, Object?)> replies;
    late InMemorySessionStore store;

    setUp(() async {
      calls = [];
      replies = {};
      store = InMemorySessionStore();
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        final text = await utf8.decoder.bind(req).join();
        calls.add((
          req.method,
          req.uri.path,
          text.isEmpty ? {} : (jsonDecode(text) as Map).cast(),
          req.headers.value(HttpHeaders.authorizationHeader),
        ));
        final (status, body) =
            replies[req.uri.path] ?? (200, <String, Object?>{});
        req.response.statusCode = status;
        if (body != null) req.response.write(jsonEncode(body));
        await req.response.close();
      });
    });
    tearDown(() => server.close(force: true));

    HttpAuthRepository repo() => HttpAuthRepository(
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}/'),
      sessionStore: store,
    );

    const session = {
      'access_token': 'TEST-ACCESS',
      'refresh_token': 'TEST-REFRESH',
      'user': {'id': 'u1', 'email': 'a@lab.uz', 'email_verified': true},
    };

    test('so‘rov maydonlari; parol faqat tanada; sessiya qo‘llanadi', () async {
      final a = repo();
      replies['/v1/auth/register'] = (202, {});
      expect(
        (await a.register(
          email: ' A@Lab.UZ',
          password: _pw,
          acceptedTermsVersion: '2026-10',
        )).ok,
        isTrue,
      );
      expect(calls.last.$3, {
        'email': 'a@lab.uz',
        'password': _pw,
        'accepted_terms_version': '2026-10',
      });
      expect(a.current.signedIn, isFalse);

      replies['/v1/auth/login'] = (200, session);
      expect((await a.signIn(email: 'a@lab.uz', password: _pw)).ok, isTrue);
      expect(a.current.verified, isTrue);
      expect(await store.read(), 'TEST-REFRESH');
      expect(await a.accessToken(), 'TEST-ACCESS');
      for (final c in calls) {
        expect(c.$4 ?? '', isNot(contains(_pw)));
      }

      replies['/v1/account'] = (204, null);
      expect((await a.deleteAccount(password: _pw)).ok, isTrue);
      expect(calls.last.$1, 'DELETE');
      expect(calls.last.$4, 'Bearer TEST-ACCESS');
      expect(a.current.signedIn, isFalse);
      expect(await store.read(), isNull);
    });

    test('xato kodlari xaritasi', () async {
      final a = repo();
      Future<AuthFailure?> login(int status, Object? body) async {
        replies['/v1/auth/login'] = (status, body);
        return (await a.signIn(email: 'a@lab.uz', password: _pw)).failure;
      }

      expect(await login(401, {}), AuthFailure.invalidCredentials);
      expect(
        await login(403, {'error': 'email_not_verified'}),
        AuthFailure.emailNotVerified,
      );
      expect(await login(429, {}), AuthFailure.tooManyRequests);
      expect(await login(503, {}), AuthFailure.server);
      // Buzilgan sessiya javobi — muvaffaqiyat deb hisoblanmaydi.
      expect(await login(200, {'access_token': 'x'}), AuthFailure.server);
      expect(a.current.signedIn, isFalse);
    });

    test(
      'sessiyani tiklash: rad — token o‘chadi; tarmoq yo‘q — saqlanadi',
      () async {
        await store.write('OLD');
        replies['/v1/auth/session/refresh'] = (401, {});
        await repo().restoreSession();
        expect(await store.read(), isNull);

        await store.write('OLD');
        final dead = HttpAuthRepository(
          baseUrl: Uri.parse('http://127.0.0.1:1/'),
          sessionStore: store,
        );
        await dead.restoreSession();
        expect(await store.read(), 'OLD');
        expect(
          (await dead.signIn(email: 'a@lab.uz', password: _pw)).failure,
          AuthFailure.offline,
        );

        replies['/v1/auth/session/refresh'] = (200, session);
        final ok = repo();
        await ok.restoreSession();
        expect(ok.current.signedIn, isTrue);
      },
    );

    test('URL berilmagan / https emas — HTTP adapter yaratilmaydi', () {
      expect(HttpAuthRepository.fromEnvironment(store), isNull);
    });
  });

  test('auth kodida parol/token jurnalga yozilmaydi', () {
    final offenders = <String>[];
    for (final dir in [
      'lib/data/auth',
      'lib/data/remote',
      'lib/features/account',
    ]) {
      for (final f in Directory(dir).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final src = f.readAsStringSync();
        if (RegExp(r'\b(print|debugPrint|log)\(').hasMatch(src)) {
          offenders.add(f.path);
        }
        if (src.contains('package:shared_preferences')) offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
