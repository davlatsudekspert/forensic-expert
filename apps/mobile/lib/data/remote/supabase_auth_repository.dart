import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/auth/auth_models.dart';
import '../../domain/ports/backend_ports.dart';
import 'supabase_rest.dart';

/// Supabase Auth (GoTrue REST) adapteri.
///
/// * Parolsiz: `functions/v1/email-otp` — FORENSIC EXPERT’ning o‘z 6 xonali
///   kodi (Resend orqali, o‘z jo‘natuvchisi), tasdiqlangach server sessiya
///   qaytaradi.
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
    DateTime Function()? clock,
  }) : _cfg = config,
       _session = sessionStore,
       _http = transport ?? HttpClientTransport(),
       _now = clock ?? DateTime.now;

  final SupabaseConfig _cfg;
  final SessionStore _session;
  final RestTransport _http;
  final _changes = StreamController<AuthState>.broadcast();

  AuthState _state = AuthState.signedOut;
  String? _access;
  final DateTime Function() _now;
  Future<void>? _refreshing;

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
    final code =
        '${r.map['error_code'] ?? r.map['code'] ?? r.map['error'] ?? ''}';
    // Email jo‘natuvchisi (Resend) hali sozlanmagan — halol «ulanmagan».
    if (code == 'email_not_configured') return AuthFailure.backendNotConfigured;
    if (r.status == 429) return AuthFailure.tooManyRequests;
    if (r.status >= 500) return AuthFailure.server;
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

  /// FORENSIC EXPERT’ning o‘z email kodi: `functions/v1/email-otp`
  /// (6 xonali kod, 10 daqiqa, FORENSIC EXPERT jo‘natuvchisi). Kod faqat
  /// serverda xesh ko‘rinishida saqlanadi; tasdiqlangach server sessiya
  /// qaytaradi.
  Future<AuthOutcome> _emailOtp(
    Map<String, Object?> body, {
    bool opensSession = false,
  }) async {
    try {
      final r = await _http.send(
        'POST',
        _cfg.url.resolve('functions/v1/email-otp'),
        headers: _headers(),
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

  @override
  Future<AuthOutcome> requestEmailCode(String email, {String? locale}) {
    final e = EmailAddress.normalize(email);
    if (!EmailAddress.isValid(e)) {
      return Future.value(const AuthOutcome.fail(AuthFailure.invalidEmail));
    }
    return _emailOtp({'action': 'request', 'email': e, 'locale': ?locale});
  }

  @override
  Future<AuthOutcome> verifyEmailCode({
    required String email,
    required String code,
  }) {
    if (!AuthCodePolicy.looksLikeCode(code)) {
      return Future.value(const AuthOutcome.fail(AuthFailure.codeInvalid));
    }
    return _emailOtp({
      'action': 'verify',
      'email': EmailAddress.normalize(email),
      'code': code.trim(),
    }, opensSession: true);
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

  /// Access token (JWT, odatda 1 soat). Muddati tugashiga 60 s qolganda
  /// refresh token orqali yangilanadi — aks holda server 401 qaytaradi.
  @override
  Future<String?> accessToken() async {
    final token = _access;
    if (token == null) return null;
    final exp = _expiry(token);
    if (exp != null && !_now().isBefore(exp.subtract(_refreshMargin))) {
      await (_refreshing ??= restoreSession().whenComplete(
        () => _refreshing = null,
      ));
    }
    return _access;
  }

  static const _refreshMargin = Duration(seconds: 60);

  /// JWT `exp` (imzo tekshirilmaydi — faqat yangilash vaqtini bilish uchun).
  static DateTime? _expiry(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload is Map ? payload['exp'] : null;
      return exp is num
          ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true)
          : null;
    } on FormatException {
      return null;
    }
  }
}
