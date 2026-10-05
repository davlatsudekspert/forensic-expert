import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/auth/auth_models.dart';
import '../../domain/ports/backend_ports.dart';

/// Akkaunt backend’ining HTTP adapteri (REST kontrakti:
/// `docs/AUTH_AND_SUBSCRIPTIONS.md`). Bazaviy URL
/// `--dart-define=FE_AUTH_BASE_URL=https://...`; bo‘lmasa ilova
/// `OfflineAuthRepository` bilan ishlaydi (akkaunt xizmati ulanmagan).
///
/// Xavfsizlik: faqat HTTPS; parol faqat so‘rov tanasida; javob tanasi va
/// sarlavhalar jurnalga yozilmaydi; refresh token [SessionStore] da,
/// access token faqat xotirada.
class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({
    required this.baseUrl,
    required SessionStore sessionStore,
    HttpClient? client,
    this.timeout = const Duration(seconds: 15),
  }) : _session = sessionStore,
       _client = client ?? HttpClient();

  final Uri baseUrl;
  final Duration timeout;
  final SessionStore _session;
  final HttpClient _client;
  final _changes = StreamController<AuthState>.broadcast();

  AuthState _state = AuthState.signedOut;
  String? _access;

  static AuthRepository? fromEnvironment(SessionStore store) {
    const url = String.fromEnvironment('FE_AUTH_BASE_URL');
    final uri = Uri.tryParse(url);
    if (url.isEmpty || uri == null || uri.scheme != 'https') return null;
    return HttpAuthRepository(baseUrl: uri, sessionStore: store);
  }

  @override
  bool get isConfigured => true;

  @override
  bool get isTestBackend => false;

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

  Future<(int, Map<String, Object?>)> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool auth = false,
  }) async {
    final req = await _client
        .openUrl(method, baseUrl.resolve(path))
        .timeout(timeout);
    req.headers.contentType = ContentType.json;
    if (auth && _access != null) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_access');
    }
    if (body != null) req.write(jsonEncode(body));
    final res = await req.close().timeout(timeout);
    final text = await res.transform(utf8.decoder).join().timeout(timeout);
    Map<String, Object?> json = const {};
    if (text.isNotEmpty) {
      final v = jsonDecode(text);
      if (v is Map) json = v.cast<String, Object?>();
    }
    return (res.statusCode, json);
  }

  /// Javob kodi → natija. Server xabar matni ko‘rsatilmaydi.
  static AuthFailure? failureFor(int status, Map<String, Object?> json) {
    if (status >= 200 && status < 300) return null;
    if (status == 429) return AuthFailure.tooManyRequests;
    if (status >= 500) return AuthFailure.server;
    return switch (json['error']) {
      'invalid_email' => AuthFailure.invalidEmail,
      'weak_password' => AuthFailure.weakPassword,
      'terms_not_accepted' => AuthFailure.termsNotAccepted,
      'invalid_credentials' => AuthFailure.invalidCredentials,
      'email_not_verified' => AuthFailure.emailNotVerified,
      'code_invalid' => AuthFailure.codeInvalid,
      'code_expired' => AuthFailure.codeExpired,
      'already_verified' => AuthFailure.alreadyVerified,
      'requires_recent_login' => AuthFailure.requiresRecentLogin,
      _ =>
        status == 401
            ? AuthFailure.invalidCredentials
            : status == 403
            ? AuthFailure.requiresRecentLogin
            : AuthFailure.server,
    };
  }

  Future<AuthOutcome> _call(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool auth = false,
    bool opensSession = false,
  }) async {
    try {
      final (status, json) = await _send(method, path, body: body, auth: auth);
      final f = failureFor(status, json);
      if (f != null) return AuthOutcome.fail(f);
      if (opensSession && !await _applySession(json)) {
        return const AuthOutcome.fail(AuthFailure.server);
      }
      return const AuthOutcome.ok();
    } on SocketException {
      return const AuthOutcome.fail(AuthFailure.offline);
    } on TimeoutException {
      return const AuthOutcome.fail(AuthFailure.offline);
    } on HandshakeException {
      return const AuthOutcome.fail(AuthFailure.offline);
    } on FormatException {
      return const AuthOutcome.fail(AuthFailure.server);
    }
  }

  /// `{access_token, refresh_token, user: {id, email, email_verified}}`.
  Future<bool> _applySession(Map<String, Object?> json) async {
    final access = json['access_token'];
    final refresh = json['refresh_token'];
    final user = json['user'];
    if (access is! String || refresh is! String || user is! Map) return false;
    final id = user['id'];
    final email = user['email'];
    if (id is! String || email is! String) return false;
    _access = access;
    await _session.write(refresh);
    _set(
      AuthState(
        AuthStatus.signedIn,
        account: AuthAccount(
          userId: id,
          email: email,
          emailVerified: user['email_verified'] == true,
        ),
      ),
    );
    return true;
  }

  Future<void> _dropSession() async {
    _access = null;
    await _session.clear();
    _set(AuthState.signedOut);
  }

  @override
  Future<void> restoreSession() async {
    final rt = await _session.read();
    if (rt == null) return;
    final r = await _call(
      'POST',
      'v1/auth/session/refresh',
      body: {'refresh_token': rt},
      opensSession: true,
    );
    // Tarmoq yo‘q — token saqlanadi (keyinroq qayta urinish); rad
    // etilgan — sessiya o‘chiriladi.
    if (!r.ok && r.failure != AuthFailure.offline) await _dropSession();
  }

  @override
  Future<AuthOutcome> requestEmailCode(String email, {String? locale}) => _call(
    'POST',
    'v1/auth/otp/request',
    body: {'email': EmailAddress.normalize(email), 'locale': ?locale},
  );

  @override
  Future<AuthOutcome> verifyEmailCode({
    required String email,
    required String code,
  }) => _call(
    'POST',
    'v1/auth/otp/verify',
    body: {'email': EmailAddress.normalize(email), 'code': code.trim()},
    opensSession: true,
  );

  @override
  Future<AuthOutcome> register({
    required String email,
    required String password,
    required String acceptedTermsVersion,
  }) => _call(
    'POST',
    'v1/auth/register',
    body: {
      'email': EmailAddress.normalize(email),
      'password': password,
      'accepted_terms_version': acceptedTermsVersion,
    },
  );

  @override
  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) => _call(
    'POST',
    'v1/auth/login',
    body: {'email': EmailAddress.normalize(email), 'password': password},
    opensSession: true,
  );

  @override
  Future<AuthOutcome> resendVerification(String email) => _call(
    'POST',
    'v1/auth/verify-email/resend',
    body: {'email': EmailAddress.normalize(email)},
  );

  @override
  Future<AuthOutcome> verifyEmail({
    required String email,
    required String code,
  }) => _call(
    'POST',
    'v1/auth/verify-email',
    body: {'email': EmailAddress.normalize(email), 'code': code.trim()},
    opensSession: true,
  );

  @override
  Future<AuthOutcome> requestPasswordReset(String email) => _call(
    'POST',
    'v1/auth/password/forgot',
    body: {'email': EmailAddress.normalize(email)},
  );

  @override
  Future<AuthOutcome> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final r = await _call(
      'POST',
      'v1/auth/password/reset',
      body: {
        'email': EmailAddress.normalize(email),
        'code': code.trim(),
        'new_password': newPassword,
      },
    );
    // Server barcha sessiyalarni bekor qiladi.
    if (r.ok && _state.account?.email == EmailAddress.normalize(email)) {
      await _dropSession();
    }
    return r;
  }

  @override
  Future<void> signOut() async {
    final rt = await _session.read();
    if (rt != null) {
      await _call(
        'POST',
        'v1/auth/logout',
        body: {'refresh_token': rt},
        auth: true,
      );
    }
    await _dropSession();
  }

  @override
  Future<AuthOutcome> deleteAccount({required String password}) async {
    if (!_state.signedIn) {
      return const AuthOutcome.fail(AuthFailure.notSignedIn);
    }
    final r = await _call(
      'DELETE',
      'v1/account',
      body: {'password': password},
      auth: true,
    );
    if (r.ok) await _dropSession();
    return r;
  }

  @override
  Future<String?> accessToken() async => _access;
}
