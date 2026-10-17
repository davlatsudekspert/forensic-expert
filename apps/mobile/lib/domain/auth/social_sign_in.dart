/// Google / Apple bilan kirish (native ID-token oqimi) — domen qismi.
///
/// Native SDK token beradi, keyin Supabase Auth
/// `POST /auth/v1/token?grant_type=id_token` bilan sessiya ochadi
/// (`SupabaseAuthRepository.signInWithIdToken`). Tokenlar va nonce jurnalga
/// yozilmaydi.
library;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'auth_models.dart';

enum SocialProvider {
  google,
  apple;

  /// Supabase `provider` qiymati.
  String get wire => name;
}

/// Native SDK qaytargan hisob ma’lumoti.
@immutable
class SocialCredential {
  const SocialCredential({
    required this.provider,
    required this.idToken,
    this.rawNonce,
    this.fullName,
    this.authorizationCode,
  });

  final SocialProvider provider;
  final String idToken;

  /// Xom nonce (Apple SDK’ga uning SHA-256 xeshi beriladi; Supabase’ga xom
  /// qiymat yuboriladi). Google uchun `null`.
  final String? rawNonce;

  /// Apple ismni **faqat birinchi kirishda** beradi — shu paytda saqlanadi.
  final String? fullName;

  /// Apple `authorizationCode` — bir martalik, qisqa muddatli. Saqlanmaydi:
  /// faqat akkauntni o‘chirishdagi qayta tasdiqlashda serverga yuboriladi
  /// (Apple tokenini bekor qilish uchun). Google uchun `null`.
  final String? authorizationCode;
}

@immutable
class SocialCredentialResult {
  const SocialCredentialResult.ok(SocialCredential this.credential)
    : failure = null;
  const SocialCredentialResult.fail(AuthFailure this.failure)
    : credential = null;

  final SocialCredential? credential;
  final AuthFailure? failure;
}

/// Native token manbai (testlarda soxta implementatsiya bilan almashtiriladi).
abstract interface class SocialCredentialSource {
  Future<SocialCredentialResult> obtain(SocialProvider provider);
}

/// Native hisob tanlash + Supabase sessiyasi: UI shu yagona nuqtani chaqiradi.
class SocialSignInService {
  const SocialSignInService(this._source);

  final SocialCredentialSource _source;

  Future<AuthOutcome> signIn(
    SocialProvider provider, {
    required Future<AuthOutcome> Function(SocialCredential) exchange,
  }) async {
    final SocialCredentialResult r;
    try {
      r = await _source.obtain(provider);
    } on Object {
      return const AuthOutcome.fail(AuthFailure.socialUnavailable);
    }
    final cred = r.credential;
    if (cred == null) {
      return AuthOutcome.fail(r.failure ?? AuthFailure.socialUnavailable);
    }
    return exchange(cred);
  }
}

/// Apple nonce yordamchisi: xom nonce + uning SHA-256 (hex) xeshi.
abstract final class SocialNonce {
  static const _alphabet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';

  /// Kriptografik tasodifiy xom nonce.
  static String generate({int length = 32, Random? random}) {
    final rnd = random ?? Random.secure();
    return List.generate(
      length,
      (_) => _alphabet[rnd.nextInt(_alphabet.length)],
    ).join();
  }

  /// SHA-256, kichik harfli hex (Apple `identityToken.nonce` shuni kutadi).
  static String sha256Hex(String raw) =>
      sha256.convert(utf8.encode(raw)).toString();
}

/// Qaysi tugmalar ko‘rinadi. Bayroq o‘chiq — hech biri. Google: iOS va
/// Android. Apple: faqat iOS (native); Androidda web oqimi talab qilinadi,
/// shuning uchun yashiriladi. iOS’da Apple birinchi (HIG: Google’dan kam
/// ko‘rinmasin).
List<SocialProvider> visibleSocialProviders({
  required bool enabled,
  required TargetPlatform platform,
  required bool isWeb,
}) {
  if (!enabled || isWeb) return const [];
  return switch (platform) {
    TargetPlatform.iOS => const [SocialProvider.apple, SocialProvider.google],
    TargetPlatform.android => const [SocialProvider.google],
    _ => const [],
  };
}
