import 'dart:async';
import 'dart:io';

import '../../domain/auth/auth_models.dart';
import '../../domain/ports/backend_ports.dart';
import 'supabase_rest.dart';

/// Supabase Auth (GoTrue REST) adapteri.
///
/// * Parolsiz: `POST /auth/v1/otp` (6 xonali kod emailga; Supabase email
///   shablonida `{{ .Token }}` bo‘lishi kerak) → `POST /auth/v1/verify`
///   (`type: email`) → sessiya.
/// * Parolli oqim ham qo‘llab-quvvatlanadi (signup / password / recover).
/// * Refresh token — [SessionStore] (Keychain / Keystore); access token faqat
///   xotirada. Kod, token va server xabar matni jurnalga yozilmaydi.
/// * Rate limit — server tomonida (Supabase Auth limitlari); mijoz ham
///   qayta yuborish oralig‘ini ushlaydi.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required SupabaseConfig config,
    required SessionStore sessionStore,
    RestTransport? transport,
  }) : _cfg = config,
       _session = sessionStore,
       _http = transport ?? HttpClientTransport();

  final SupabaseConfig _cfg;
  final SessionStore _session;
  final RestTransport _http;
  final _changes = StreamController<AuthState>.broadcast();

  AuthState _state = AuthState.signedOut;
  String? _access;

  static AuthRepository? fromEnvironment(SessionStore store) {
    final cfg = SupabaseConfig.fromEnvironment();
    return cfg == null
        ? null
        : SupabaseAuthRepository(config: cfg, sessionStore: store);
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

  Uri _u(String path) => _cfg.url.resolve('auth/v1/$path');

  Map<String, String> _headers({bool auth = false}) => {
    'apikey': _cfg.anonKey,
    if (auth && _access != null) 'Authorization': 'Bearer $_access',
  };

  /// GoTrue xato kodlari → [AuthFailure]. Server matni ko‘rsatilmaydi.
  static AuthFailure? failureFor(RestResponse r) {
    if (r.ok) return null;
    if (r.status == 429) return AuthFailure.tooManyRequests;
    if (r.status >= 500) return AuthFailure.server;
    final code =
        '${r.map['error_code'] ?? r.map['code'] ?? r.map['error'] ?? ''}';
    return switch (code) {
      'otp_expired' => AuthFailure.codeExpired,
      'otp_disabled' ||
      'email_provider_disabled' => AuthFailure.backendNotConfigured,
      'over_email_send_rate_limit' ||
      'over_request_rate_limit' => AuthFailure.tooManyRequests,
      'validation_failed' ||
      'email_address_invalid' => AuthFailure.invalidEmail,
      'weak_password' => AuthFailure.weakPassword,
      'invalid_credentials' ||
      'invalid_grant' => AuthFailure.invalidCredentials,
      'email_not_confirmed' => AuthFailure.emailNotVerified,
      'reauthentication_needed' => AuthFailure.requiresRecentLogin,
      _ =>
        r.status == 403
            ? AuthFailure.codeInvalid
            : r.status == 401
            ? AuthFailure.invalidCredentials
            : AuthFailure.server,
    };
  }

  Future<AuthOutcome> _call(
    String method,
    String path, {
    Object? body,
    bool auth = false,
    bool opensSession = false,
  }) async {
    try {
      final r = await _http.send(
        method,
        _u(path),
        headers: _headers(auth: auth),
        jsonBody: body,
      );
      final f = failureFor(r);
      if (f != null) return AuthOutcome.fail(f);
      if (opensSession && !await _applySession(r.map)) {
        return const AuthOutcome.fail(AuthFailure.server);
      }
      return const AuthOutcome.ok();
    } on SocketException {
      return const AuthOutcome.fail(AuthFailure.offline);
    } on TimeoutException {
      return const AuthOutcome.fail(AuthFailure.offline);
    } on HandshakeException {
      return const AuthOutcome.fail(AuthFailure.offline);
    }
  }

  /// `{access_token, refresh_token, user: {id, email, email_confirmed_at}}`.
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
          emailVerified: user['email_confirmed_at'] != null,
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
      'token?grant_type=refresh_token',
      body: {'refresh_token': rt},
      opensSession: true,
    );
    if (!r.ok && r.failure != AuthFailure.offline) await _dropSession();
  }

  @override
  Future<AuthOutcome> requestEmailCode(String email, {String? locale}) {
    final e = EmailAddress.normalize(email);
    if (!EmailAddress.isValid(e)) {
      return Future.value(const AuthOutcome.fail(AuthFailure.invalidEmail));
    }
    return _call(
      'POST',
      'otp',
      body: {
        'email': e,
        'create_user': true,
        // Email shabloni tili (supabase/templates); faqat til kodi.
        if (locale != null) 'data': {'locale': locale},
      },
    );
  }

  @override
  Future<AuthOutcome> verifyEmailCode({
    required String email,
    required String code,
  }) {
    if (!AuthCodePolicy.looksLikeCode(code)) {
      return Future.value(const AuthOutcome.fail(AuthFailure.codeInvalid));
    }
    return _call(
      'POST',
      'verify',
      body: {
        'type': 'email',
        'email': EmailAddress.normalize(email),
        'token': code.trim(),
      },
      opensSession: true,
    );
  }

  @override
  Future<AuthOutcome> register({
    required String email,
    required String password,
    required String acceptedTermsVersion,
  }) => _call(
    'POST',
    'signup',
    body: {
      'email': EmailAddress.normalize(email),
      'password': password,
      'data': {'accepted_terms_version': acceptedTermsVersion},
    },
  );

  @override
  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) => _call(
    'POST',
    'token?grant_type=password',
    body: {'email': EmailAddress.normalize(email), 'password': password},
    opensSession: true,
  );

  @override
  Future<AuthOutcome> resendVerification(String email) => _call(
    'POST',
    'resend',
    body: {'type': 'signup', 'email': EmailAddress.normalize(email)},
  );

  @override
  Future<AuthOutcome> verifyEmail({
    required String email,
    required String code,
  }) => _call(
    'POST',
    'verify',
    body: {
      'type': 'signup',
      'email': EmailAddress.normalize(email),
      'token': code.trim(),
    },
    opensSession: true,
  );

  @override
  Future<AuthOutcome> requestPasswordReset(String email) =>
      _call('POST', 'recover', body: {'email': EmailAddress.normalize(email)});

  @override
  Future<AuthOutcome> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final v = await _call(
      'POST',
      'verify',
      body: {
        'type': 'recovery',
        'email': EmailAddress.normalize(email),
        'token': code.trim(),
      },
      opensSession: true,
    );
    if (!v.ok) return v;
    final r = await _call(
      'PUT',
      'user',
      body: {'password': newPassword},
      auth: true,
    );
    await _dropSession();
    return r;
  }

  @override
  Future<void> signOut() async {
    if (_access != null) {
      await _call('POST', 'logout', auth: true);
    }
    await _dropSession();
  }

  /// Akkauntni o‘chirish — `delete-account` Edge Function (server
  /// tomonda service-role bilan; `supabase/functions/delete-account`).
  @override
  Future<AuthOutcome> deleteAccount({required String password}) async {
    if (!_state.signedIn) {
      return const AuthOutcome.fail(AuthFailure.notSignedIn);
    }
    try {
      final r = await _http.send(
        'POST',
        _cfg.url.resolve('functions/v1/delete-account'),
        headers: _headers(auth: true),
        jsonBody: const {'confirm': true},
      );
      final f = failureFor(r);
      if (f != null) return AuthOutcome.fail(f);
      await _dropSession();
      return const AuthOutcome.ok();
    } on SocketException {
      return const AuthOutcome.fail(AuthFailure.offline);
    } on TimeoutException {
      return const AuthOutcome.fail(AuthFailure.offline);
    }
  }

  @override
  Future<String?> accessToken() async => _access;
}
