import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../domain/auth/auth_models.dart';
import '../../domain/ports/backend_ports.dart';

/// MOCK email (haqiqiy xat yuborilmaydi). Faqat testlar va
/// `--dart-define=FE_AUTH_MODE=mock` dev yig‘masi uchun.
class MockEmail {
  const MockEmail({required this.to, required this.kind, required this.code});

  final String to;

  /// `verify`, `reset`, `already_registered`.
  final String kind;
  final String? code;
}

class _User {
  _User(this.id, this.email, this.salt, this.hash);

  final String id;
  final String email;
  String salt;
  String hash;
  bool verified = false;
}

class _Code {
  _Code(this.code, this.expiresAt);

  final String code;
  final DateTime expiresAt;
  bool used = false;
}

/// **MOCK** akkaunt backend’i — xotirada, tarmoqsiz, haqiqiy email
/// yetkazilmaydi. Server kontraktini (`docs/AUTH_AND_SUBSCRIPTIONS.md`)
/// aynan takrorlaydi: tuzlangan va ko‘p marta xeshlangan parol, bir
/// martalik muddatli kodlar, email mavjudligini oshkor qilmaslik, qayta
/// yuborish oralig‘i. Production’da ishlatilmaydi (UI «MOCK» belgisini
/// ko‘rsatadi).
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    DateTime Function()? clock,
    Random? random,
    SessionStore? sessionStore,
  }) : _now = clock ?? DateTime.now,
       _rng = random ?? Random.secure(),
       _session = sessionStore ?? InMemorySessionStore();

  final DateTime Function() _now;
  final Random _rng;
  final SessionStore _session;
  final _users = <String, _User>{};
  final _verify = <String, _Code>{};
  final _reset = <String, _Code>{};
  final _lastSent = <String, DateTime>{};
  final _refresh = <String, String>{};
  final _changes = StreamController<AuthState>.broadcast();

  /// Yuborilgan bo‘lardi xatlar (dev ekrani va testlar o‘qiydi).
  final outbox = <MockEmail>[];

  AuthState _state = AuthState.signedOut;

  @override
  bool get isConfigured => true;

  @override
  bool get isTestBackend => true;

  @override
  AuthState get current => _state;

  @override
  Stream<AuthState> watch() async* {
    yield _state;
    yield* _changes.stream;
  }

  void _set(AuthState s) {
    _state = s;
    _changes.add(s);
  }

  String _token(int bytes) =>
      base64Url.encode(List.generate(bytes, (_) => _rng.nextInt(256)));

  String _code() =>
      List.generate(AuthCodePolicy.codeLength, (_) => _rng.nextInt(10)).join();

  static String _hash(String salt, String password) {
    List<int> d = utf8.encode('$salt:$password');
    for (var i = 0; i < 10000; i++) {
      d = sha256.convert(d).bytes;
    }
    return base64.encode(d);
  }

  AuthAccount _account(_User u) =>
      AuthAccount(userId: u.id, email: u.email, emailVerified: u.verified);

  Future<void> _startSession(_User u) async {
    final rt = _token(32);
    _refresh[rt] = u.email;
    await _session.write(rt);
    _set(AuthState(AuthStatus.signedIn, account: _account(u)));
  }

  bool _cooling(String email) {
    final last = _lastSent[email];
    return last != null &&
        _now().difference(last) < AuthCodePolicy.resendCooldown;
  }

  void _sendVerify(_User u) {
    final c = _code();
    _verify[u.email] = _Code(c, _now().add(AuthCodePolicy.verificationTtl));
    _lastSent[u.email] = _now();
    outbox.add(MockEmail(to: u.email, kind: 'verify', code: c));
  }

  @override
  Future<void> restoreSession() async {
    final rt = await _session.read();
    final email = rt == null ? null : _refresh[rt];
    final u = email == null ? null : _users[email];
    if (u == null) {
      if (rt != null) await _session.clear();
      return;
    }
    _set(AuthState(AuthStatus.signedIn, account: _account(u)));
  }

  @override
  Future<AuthOutcome> register({
    required String email,
    required String password,
    required String acceptedTermsVersion,
  }) async {
    final e = EmailAddress.normalize(email);
    if (!EmailAddress.isValid(e)) {
      return const AuthOutcome.fail(AuthFailure.invalidEmail);
    }
    if (!PasswordPolicy.isAcceptable(password, email: e)) {
      return const AuthOutcome.fail(AuthFailure.weakPassword);
    }
    if (acceptedTermsVersion.isEmpty) {
      return const AuthOutcome.fail(AuthFailure.termsNotAccepted);
    }
    if (_users.containsKey(e)) {
      // Enumeratsiyaga qarshi: javob bir xil; egasiga xabar xati.
      outbox.add(MockEmail(to: e, kind: 'already_registered', code: null));
      return const AuthOutcome.ok();
    }
    final salt = _token(16);
    final u = _User('mock-${_token(9)}', e, salt, _hash(salt, password));
    _users[e] = u;
    _sendVerify(u);
    return const AuthOutcome.ok();
  }

  @override
  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) async {
    final u = _users[EmailAddress.normalize(email)];
    if (u == null || _hash(u.salt, password) != u.hash) {
      return const AuthOutcome.fail(AuthFailure.invalidCredentials);
    }
    if (!u.verified) {
      return const AuthOutcome.fail(AuthFailure.emailNotVerified);
    }
    await _startSession(u);
    return const AuthOutcome.ok();
  }

  @override
  Future<AuthOutcome> resendVerification(String email) async {
    final e = EmailAddress.normalize(email);
    if (!EmailAddress.isValid(e)) {
      return const AuthOutcome.fail(AuthFailure.invalidEmail);
    }
    if (_cooling(e)) return const AuthOutcome.fail(AuthFailure.tooManyRequests);
    final u = _users[e];
    // Akkaunt yo‘q yoki allaqachon tasdiqlangan — xat yo‘q, javob bir xil.
    if (u != null && !u.verified) _sendVerify(u);
    return const AuthOutcome.ok();
  }

  @override
  Future<AuthOutcome> verifyEmail({
    required String email,
    required String code,
  }) async {
    final u = _users[EmailAddress.normalize(email)];
    if (u == null) return const AuthOutcome.fail(AuthFailure.codeInvalid);
    if (u.verified) return const AuthOutcome.fail(AuthFailure.alreadyVerified);
    final c = _verify[u.email];
    if (c == null || c.used || c.code != code.trim()) {
      return const AuthOutcome.fail(AuthFailure.codeInvalid);
    }
    if (!_now().isBefore(c.expiresAt)) {
      return const AuthOutcome.fail(AuthFailure.codeExpired);
    }
    c.used = true;
    u.verified = true;
    await _startSession(u);
    return const AuthOutcome.ok();
  }

  @override
  Future<AuthOutcome> requestPasswordReset(String email) async {
    final e = EmailAddress.normalize(email);
    if (!EmailAddress.isValid(e)) {
      return const AuthOutcome.fail(AuthFailure.invalidEmail);
    }
    final u = _users[e];
    // Akkaunt yo‘q bo‘lsa ham bir xil javob (enumeratsiya yo‘q).
    if (u != null && !_cooling(e)) {
      final c = _code();
      _reset[e] = _Code(c, _now().add(AuthCodePolicy.resetTtl));
      _lastSent[e] = _now();
      outbox.add(MockEmail(to: e, kind: 'reset', code: c));
    }
    return const AuthOutcome.ok();
  }

  @override
  Future<AuthOutcome> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final e = EmailAddress.normalize(email);
    final c = _reset[e];
    final u = _users[e];
    if (u == null || c == null || c.used || c.code != code.trim()) {
      return const AuthOutcome.fail(AuthFailure.codeInvalid);
    }
    if (!_now().isBefore(c.expiresAt)) {
      return const AuthOutcome.fail(AuthFailure.codeExpired);
    }
    if (!PasswordPolicy.isAcceptable(newPassword, email: e)) {
      return const AuthOutcome.fail(AuthFailure.weakPassword);
    }
    c.used = true;
    u.salt = _token(16);
    u.hash = _hash(u.salt, newPassword);
    // Parol almashganda barcha sessiyalar bekor; email ham tasdiqlangan
    // (kod shu emailga kelgan).
    u.verified = true;
    _refresh.removeWhere((_, v) => v == e);
    if (_state.account?.email == e) {
      await _session.clear();
      _set(AuthState.signedOut);
    }
    return const AuthOutcome.ok();
  }

  @override
  Future<void> signOut() async {
    final rt = await _session.read();
    if (rt != null) _refresh.remove(rt);
    await _session.clear();
    _set(AuthState.signedOut);
  }

  @override
  Future<AuthOutcome> deleteAccount({required String password}) async {
    final a = _state.account;
    if (a == null) return const AuthOutcome.fail(AuthFailure.notSignedIn);
    final u = _users[a.email]!;
    if (_hash(u.salt, password) != u.hash) {
      return const AuthOutcome.fail(AuthFailure.requiresRecentLogin);
    }
    _users.remove(u.email);
    _verify.remove(u.email);
    _reset.remove(u.email);
    _refresh.removeWhere((_, v) => v == u.email);
    await _session.clear();
    _set(AuthState.signedOut);
    return const AuthOutcome.ok();
  }

  @override
  Future<String?> accessToken() async =>
      _state.signedIn ? 'mock-access-${_state.userId}' : null;

  /// Test yordamchisi: akkaunt bormi.
  bool hasAccount(String email) =>
      _users.containsKey(EmailAddress.normalize(email));
}

/// Xotiradagi sessiya ombori (testlar va mock).
class InMemorySessionStore implements SessionStore {
  String? _v;

  @override
  Future<String?> read() async => _v;

  @override
  Future<void> write(String refreshToken) async => _v = refreshToken;

  @override
  Future<void> clear() async => _v = null;
}
