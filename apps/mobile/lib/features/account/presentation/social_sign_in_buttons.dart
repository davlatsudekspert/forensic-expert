import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart'
    show SignInWithAppleButton, SignInWithAppleButtonStyle;

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/social_sign_in_flag.dart';
import '../../../domain/auth/auth_models.dart';
import '../../../domain/auth/social_sign_in.dart';
import 'auth_screens.dart' show acceptedTermsVersion;

/// «Google bilan davom etish» / «Apple bilan davom etish» tugmalari.
///
/// Bayroq o‘chiq (`socialSignInEnabled == false`) yoki platforma qo‘llamasa
/// hech narsa chizilmaydi. Apple faqat iOS’da (native), Google iOS va
/// Android’da. Foydalanuvchi oynani yopsa — xato ko‘rsatilmaydi.
class SocialSignInButtons extends ConsumerStatefulWidget {
  const SocialSignInButtons({
    super.key,
    required this.onSignedIn,
    required this.onError,
  });

  final VoidCallback onSignedIn;
  final ValueChanged<AuthFailure> onError;

  @override
  ConsumerState<SocialSignInButtons> createState() =>
      _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends ConsumerState<SocialSignInButtons> {
  SocialProvider? _busy;

  Future<void> _start(SocialProvider provider) async {
    if (_busy != null) return;
    final auth = ref.read(authRepositoryProvider);
    final service = ref.read(socialSignInServiceProvider);
    setState(() => _busy = provider);
    final r = await service.signIn(
      provider,
      exchange: (c) => auth.signInWithIdToken(
        provider: c.provider,
        idToken: c.idToken,
        nonce: c.rawNonce,
        fullName: c.fullName,
        acceptedTermsVersion: acceptedTermsVersion,
      ),
    );
    if (!mounted) return;
    setState(() => _busy = null);
    if (r.ok) {
      widget.onSignedIn();
    } else if (r.failure != AuthFailure.cancelled) {
      widget.onError(r.failure ?? AuthFailure.socialUnavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = visibleSocialProviders(
      enabled: socialSignInEnabled,
      platform: defaultTargetPlatform,
      isWeb: kIsWeb,
    );
    if (providers.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    final enabled = configured && _busy == null;
    return Column(
      key: const Key('social.buttons'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FeSpace.md),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FeSpace.sm),
              child: Text(
                l.socialOr,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: FeSpace.md),
        for (final p in providers) ...[
          switch (p) {
            SocialProvider.apple => Semantics(
              button: true,
              enabled: enabled,
              label: l.socialContinueApple,
              excludeSemantics: true,
              child: Opacity(
                opacity: enabled ? 1 : 0.5,
                child: SignInWithAppleButton(
                  key: const Key('social.apple'),
                  text: l.socialContinueApple,
                  height: 52,
                  style: dark
                      ? SignInWithAppleButtonStyle.white
                      : SignInWithAppleButtonStyle.black,
                  onPressed: enabled
                      ? () => _start(SocialProvider.apple)
                      : null,
                ),
              ),
            ),
            SocialProvider.google => _GoogleButton(
              key: const Key('social.google'),
              label: l.socialContinueGoogle,
              dark: dark,
              busy: _busy == SocialProvider.google,
              onPressed: enabled ? () => _start(SocialProvider.google) : null,
            ),
          },
          const SizedBox(height: FeSpace.sm),
        ],
        Text(
          l.socialTermsNote,
          key: const Key('social.termsNote'),
          textAlign: TextAlign.center,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}

/// Google brend yo‘riqnomasi: oq (qorong‘i rejimda #131314) fon, ingichka
/// kulrang chegara, 4 rangli «G», matn «Google bilan davom etish».
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    super.key,
    required this.label,
    required this.dark,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool dark;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF131314) : Colors.white;
    final fg = dark ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);
    final border = dark ? const Color(0xFF8E918F) : const Color(0xFF747775);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg.withValues(alpha: 0.6),
            side: BorderSide(color: border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size.fromHeight(52),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const SizedBox.square(
                  dimension: 20,
                  child: CustomPaint(painter: _GoogleGPainter()),
                ),
              const SizedBox(width: FeSpace.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soddalashtirilgan 4 rangli «G» belgisi (vektor). Store’ga topshirishdan
/// oldin rasmiy Google «G» aktivi bilan almashtirish tavsiya etiladi
/// (`docs/SOCIAL_SIGN_IN.md`).
class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.2;
    final rect = Rect.fromCircle(
      center: Offset(s / 2, s / 2),
      radius: s / 2 - stroke / 2,
    );
    Paint p(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    const blue = Color(0xFF4285F4);
    const green = Color(0xFF34A853);
    const yellow = Color(0xFFFBBC05);
    const red = Color(0xFFEA4335);
    double rad(double deg) => deg * math.pi / 180;
    canvas.drawArc(rect, rad(-45), rad(-90), false, p(red));
    canvas.drawArc(rect, rad(-135), rad(-65), false, p(yellow));
    canvas.drawArc(rect, rad(-200), rad(-95), false, p(green));
    canvas.drawArc(rect, rad(-295), rad(-65), false, p(blue));
    canvas.drawLine(
      Offset(s / 2, s / 2),
      Offset(s - stroke / 2 + 1, s / 2),
      p(blue),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
