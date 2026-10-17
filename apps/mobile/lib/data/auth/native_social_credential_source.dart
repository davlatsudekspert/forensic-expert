import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/auth/auth_models.dart';
import '../../domain/auth/social_sign_in.dart';

/// Native Google / Apple token manbai.
///
/// Client ID’lar kodda yo‘q — yig‘ishda `--dart-define` bilan beriladi:
/// * `GOOGLE_IOS_CLIENT_ID` — iOS OAuth client ID (Google Cloud Console),
/// * `GOOGLE_SERVER_CLIENT_ID` — Web OAuth client ID (Supabase’dagi Google
///   provayderiga ham shu yoziladi; ID token `aud` shu bo‘ladi).
/// Android’da faqat `GOOGLE_SERVER_CLIENT_ID` kerak (SHA-1 bilan Android
/// client Console’da ro‘yxatdan o‘tgan bo‘lishi shart).
///
/// Token, nonce va hisob ma’lumoti jurnalga yozilmaydi.
class NativeSocialCredentialSource implements SocialCredentialSource {
  NativeSocialCredentialSource({
    this.googleIosClientId = const String.fromEnvironment(
      'GOOGLE_IOS_CLIENT_ID',
    ),
    this.googleServerClientId = const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    ),
  });

  final String googleIosClientId;
  final String googleServerClientId;

  Future<void>? _googleInit;

  @override
  Future<SocialCredentialResult> obtain(SocialProvider provider) =>
      switch (provider) {
        SocialProvider.google => _google(),
        SocialProvider.apple => _apple(),
      };

  Future<SocialCredentialResult> _google() async {
    if (googleServerClientId.isEmpty) {
      return const SocialCredentialResult.fail(
        AuthFailure.backendNotConfigured,
      );
    }
    try {
      await (_googleInit ??= GoogleSignIn.instance.initialize(
        clientId: googleIosClientId.isEmpty ? null : googleIosClientId,
        serverClientId: googleServerClientId,
      ));
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const SocialCredentialResult.fail(AuthFailure.socialUnavailable);
      }
      return SocialCredentialResult.ok(
        SocialCredential(provider: SocialProvider.google, idToken: idToken),
      );
    } on GoogleSignInException catch (e) {
      _googleInit = null;
      return SocialCredentialResult.fail(
        e.code == GoogleSignInExceptionCode.canceled
            ? AuthFailure.cancelled
            : AuthFailure.socialUnavailable,
      );
    }
  }

  Future<SocialCredentialResult> _apple() async {
    try {
      if (!await SignInWithApple.isAvailable()) {
        return const SocialCredentialResult.fail(AuthFailure.socialUnavailable);
      }
      final raw = SocialNonce.generate();
      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: SocialNonce.sha256Hex(raw),
      );
      final token = cred.identityToken;
      if (token == null || token.isEmpty) {
        return const SocialCredentialResult.fail(AuthFailure.socialUnavailable);
      }
      final name = [cred.givenName, cred.familyName]
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .join(' ');
      return SocialCredentialResult.ok(
        SocialCredential(
          provider: SocialProvider.apple,
          idToken: token,
          rawNonce: raw,
          fullName: name.isEmpty ? null : name,
          authorizationCode: cred.authorizationCode.isEmpty
              ? null
              : cred.authorizationCode,
        ),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      return SocialCredentialResult.fail(
        e.code == AuthorizationErrorCode.canceled
            ? AuthFailure.cancelled
            : AuthFailure.socialUnavailable,
      );
    } on SignInWithAppleException {
      return const SocialCredentialResult.fail(AuthFailure.socialUnavailable);
    }
  }
}
