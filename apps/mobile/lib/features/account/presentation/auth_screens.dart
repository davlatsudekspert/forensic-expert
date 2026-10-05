import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/auth/auth_models.dart';

/// Joriy Shartlar / Maxfiylik versiyasi (ro‘yxatdan o‘tishda serverga
/// yuboriladi; matn o‘zgarsa oshiriladi).
const acceptedTermsVersion = '2026-10';

String authFailureText(AppLocalizations l, AuthFailure f) => switch (f) {
  AuthFailure.invalidEmail => l.authErrInvalidEmail,
  AuthFailure.weakPassword => l.authErrWeakPassword,
  AuthFailure.passwordMismatch => l.authErrMismatch,
  AuthFailure.termsNotAccepted => l.authErrTerms,
  AuthFailure.invalidCredentials => l.authErrCredentials,
  AuthFailure.emailNotVerified => l.authErrNotVerified,
  AuthFailure.codeInvalid => l.authErrCodeInvalid,
  AuthFailure.codeExpired => l.authErrCodeExpired,
  AuthFailure.alreadyVerified => l.authErrAlreadyVerified,
  AuthFailure.tooManyRequests => l.authErrTooMany,
  AuthFailure.offline => l.authErrOffline,
  AuthFailure.server => l.authErrServer,
  AuthFailure.backendNotConfigured => l.authErrNotConfigured,
  AuthFailure.requiresRecentLogin => l.authErrRecentLogin,
  AuthFailure.notSignedIn => l.authErrNotSignedIn,
};

/// Akkaunt ekranlari uchun umumiy karkas: backend holati banneri (ulanmagan
/// / TEST) va oflayn funksiyalar ishlashi haqida eslatma.
class _AuthScaffold extends ConsumerWidget {
  const _AuthScaffold({
    required this.title,
    required this.children,
    this.screenKey,
  });

  final String title;
  final List<Widget> children;
  final Key? screenKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authRepositoryProvider);
    return Scaffold(
      key: screenKey,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    if (!auth.isConfigured) ...[
                      FeBanner(
                        key: const Key('auth.notConfigured'),
                        icon: Icons.cloud_off_outlined,
                        text: l.accountNotConnected,
                        tone: FeBannerTone.warning,
                      ),
                      const SizedBox(height: FeSpace.md),
                    ] else if (auth.isTestBackend) ...[
                      FeBanner(
                        key: const Key('auth.testBackend'),
                        icon: Icons.science_outlined,
                        text: l.accountTestBackend,
                        tone: FeBannerTone.warning,
                      ),
                      const SizedBox(height: FeSpace.md),
                    ],
                    ...children,
                    const SizedBox(height: FeSpace.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.failure);

  final AuthFailure? failure;

  @override
  Widget build(BuildContext context) {
    final f = failure;
    if (f == null) return const SizedBox.shrink();
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: Semantics(
        liveRegion: true,
        child: Text(
          authFailureText(AppLocalizations.of(context), f),
          key: Key('auth.error.${f.name}'),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: c.danger),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: FeSpace.sm),
    child: TextField(
      key: const Key('auth.email'),
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).accountEmail,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.fieldKey,
    this.newPassword = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final Key fieldKey;
  final bool newPassword;
  final ValueChanged<String>? onChanged;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  var _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: TextField(
        key: widget.fieldKey,
        controller: widget.controller,
        obscureText: _obscure,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: [
          widget.newPassword
              ? AutofillHints.newPassword
              : AutofillHints.password,
        ],
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            tooltip: _obscure ? l.accountShowPassword : l.accountHidePassword,
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    );
  }
}

/// Parol talablari — ochiq ko‘rsatiladi, kiritilganda belgilanadi.
class PasswordRulesList extends StatelessWidget {
  const PasswordRulesList({super.key, required this.password, this.email});

  final String password;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    String label(PasswordRule r) => switch (r) {
      PasswordRule.minLength => l.pwRuleMinLength(PasswordPolicy.minLength),
      PasswordRule.letter => l.pwRuleLetter,
      PasswordRule.digit => l.pwRuleDigit,
      PasswordRule.notEmail => l.pwRuleNotEmail,
      PasswordRule.maxLength => '',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: Column(
        key: const Key('auth.passwordRules'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.passwordRulesTitle, style: t.titleSmall),
          const SizedBox(height: FeSpace.xxs),
          for (final r in PasswordPolicy.rules)
            Builder(
              builder: (context) {
                final ok =
                    password.isNotEmpty &&
                    PasswordPolicy.satisfies(r, password, email: email);
                return Row(
                  key: Key('auth.rule.${r.name}.${ok ? 'ok' : 'todo'}'),
                  children: [
                    Icon(
                      ok ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                      color: ok ? c.accent : c.textSecondary,
                    ),
                    const SizedBox(width: FeSpace.xs),
                    Expanded(child: Text(label(r), style: t.bodyMedium)),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Submit extends StatelessWidget {
  const _Submit({
    required this.label,
    required this.busy,
    required this.onPressed,
    required this.buttonKey,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;
  final Key buttonKey;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 52),
    child: FilledButton(
      key: buttonKey,
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    ),
  );
}

// ---------------------------------------------------------------------------

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  AuthFailure? _error;
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = ref.read(authRepositoryProvider);
    if (!EmailAddress.isValid(_email.text)) {
      setState(() => _error = AuthFailure.invalidEmail);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await auth.signIn(email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.ok) {
      TextInput.finishAutofillContext();
      context.go(Routes.profile);
    } else if (r.failure == AuthFailure.emailNotVerified) {
      await context.push(
        Routes.accountVerify,
        extra: EmailAddress.normalize(_email.text),
      );
    } else {
      setState(() => _error = r.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    return _AuthScaffold(
      screenKey: const Key('screen.signIn'),
      title: l.accountSignIn,
      children: [
        _EmailField(controller: _email),
        _PasswordField(
          controller: _password,
          label: l.accountPassword,
          fieldKey: const Key('auth.password'),
        ),
        _ErrorText(_error),
        _Submit(
          label: l.accountSignIn,
          busy: _busy,
          buttonKey: const Key('auth.submit'),
          onPressed: configured ? _submit : null,
        ),
        TextButton(
          key: const Key('auth.toForgot'),
          onPressed: () => context.push(Routes.accountForgot),
          child: Text(l.accountForgot),
        ),
        TextButton(
          key: const Key('auth.toRegister'),
          onPressed: () => context.pushReplacement(Routes.accountRegister),
          child: Text(l.accountNoAccount),
        ),
      ],
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _terms = false;
  AuthFailure? _error;
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final invalid = AuthInput.registration(
      email: _email.text,
      password: _password.text,
      confirmPassword: _confirm.text,
      termsAccepted: _terms,
    );
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authRepositoryProvider)
        .register(
          email: _email.text,
          password: _password.text,
          acceptedTermsVersion: acceptedTermsVersion,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.ok) {
      TextInput.finishAutofillContext();
      context.pushReplacement(
        Routes.accountVerify,
        extra: EmailAddress.normalize(_email.text),
      );
    } else {
      setState(() => _error = r.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    return _AuthScaffold(
      screenKey: const Key('screen.register'),
      title: l.accountCreate,
      children: [
        Text(
          l.accountMinimalData,
          key: const Key('auth.minimalData'),
          style: t.bodyMedium?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.md),
        _EmailField(controller: _email),
        _PasswordField(
          controller: _password,
          label: l.accountPassword,
          fieldKey: const Key('auth.password'),
          newPassword: true,
          onChanged: (_) => setState(() {}),
        ),
        PasswordRulesList(password: _password.text, email: _email.text),
        _PasswordField(
          controller: _confirm,
          label: l.accountConfirmPassword,
          fieldKey: const Key('auth.confirm'),
          newPassword: true,
        ),
        CheckboxListTile(
          key: const Key('auth.terms'),
          value: _terms,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (v) => setState(() => _terms = v ?? false),
          title: Text(l.accountTermsAccept),
        ),
        Wrap(
          spacing: FeSpace.sm,
          children: [
            TextButton(
              onPressed: () => context.push(Routes.terms),
              child: Text(l.termsOfUse),
            ),
            TextButton(
              onPressed: () => context.push(Routes.privacy),
              child: Text(l.privacyPolicy),
            ),
          ],
        ),
        _ErrorText(_error),
        _Submit(
          label: l.accountCreate,
          busy: _busy,
          buttonKey: const Key('auth.submit'),
          onPressed: configured ? _submit : null,
        ),
        TextButton(
          key: const Key('auth.toSignIn'),
          onPressed: () => context.pushReplacement(Routes.accountSignIn),
          child: Text(l.accountHaveAccount),
        ),
      ],
    );
  }
}

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  AuthFailure? _error;
  var _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!AuthCodePolicy.looksLikeCode(_code.text)) {
      setState(() => _error = AuthFailure.codeInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authRepositoryProvider)
        .verifyEmail(email: widget.email, code: _code.text);
    if (!mounted) return;
    setState(() => _busy = false);
    final l = AppLocalizations.of(context);
    if (r.ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.verifyDone)));
      context.go(Routes.profile);
    } else {
      setState(() => _error = r.failure);
    }
  }

  Future<void> _resend() async {
    final r = await ref
        .read(authRepositoryProvider)
        .resendVerification(widget.email);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    if (r.ok) {
      setState(() => _error = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.verifyResent)));
    } else {
      setState(() => _error = r.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    return _AuthScaffold(
      screenKey: const Key('screen.verify'),
      title: l.verifyTitle,
      children: [
        Text(
          l.verifyBody(AuthCodePolicy.codeLength, widget.email),
          style: t.bodyLarge,
        ),
        const SizedBox(height: FeSpace.md),
        TextField(
          key: const Key('auth.code'),
          controller: _code,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          maxLength: AuthCodePolicy.codeLength,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l.verifyCode,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: FeSpace.xs),
        _ErrorText(_error),
        if (_error == AuthFailure.alreadyVerified)
          OutlinedButton(
            key: const Key('auth.toSignIn'),
            onPressed: () => context.pushReplacement(Routes.accountSignIn),
            child: Text(l.accountSignIn),
          )
        else
          _Submit(
            label: l.verifySubmit,
            busy: _busy,
            buttonKey: const Key('auth.submit'),
            onPressed: configured ? _verify : null,
          ),
        TextButton(
          key: const Key('auth.resend'),
          onPressed: configured ? _resend : null,
          child: Text(l.verifyResend),
        ),
      ],
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  AuthFailure? _error;
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!EmailAddress.isValid(_email.text)) {
      setState(() => _error = AuthFailure.invalidEmail);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(_email.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.ok) {
      context.pushReplacement(
        Routes.accountReset,
        extra: EmailAddress.normalize(_email.text),
      );
    } else {
      setState(() => _error = r.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    return _AuthScaffold(
      screenKey: const Key('screen.forgot'),
      title: l.forgotTitle,
      children: [
        Text(l.forgotBody, style: t.bodyLarge),
        const SizedBox(height: FeSpace.md),
        _EmailField(controller: _email),
        _ErrorText(_error),
        _Submit(
          label: l.forgotSubmit,
          busy: _busy,
          buttonKey: const Key('auth.submit'),
          onPressed: configured ? _submit : null,
        ),
      ],
    );
  }
}

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  AuthFailure? _error;
  var _busy = false;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!AuthCodePolicy.looksLikeCode(_code.text)) {
      setState(() => _error = AuthFailure.codeInvalid);
      return;
    }
    final invalid = AuthInput.newPassword(
      email: widget.email,
      password: _password.text,
      confirmPassword: _confirm.text,
    );
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authRepositoryProvider)
        .resetPassword(
          email: widget.email,
          code: _code.text,
          newPassword: _password.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    final l = AppLocalizations.of(context);
    if (r.ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.resetDone)));
      context.pushReplacement(Routes.accountSignIn);
    } else {
      setState(() => _error = r.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    return _AuthScaffold(
      screenKey: const Key('screen.reset'),
      title: l.resetTitle,
      children: [
        FeBanner(
          key: const Key('auth.resetSent'),
          icon: Icons.mark_email_read_outlined,
          text: l.forgotSent(AuthCodePolicy.resetTtl.inMinutes),
        ),
        const SizedBox(height: FeSpace.md),
        TextField(
          key: const Key('auth.code'),
          controller: _code,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          maxLength: AuthCodePolicy.codeLength,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l.resetCode,
            border: const OutlineInputBorder(),
          ),
        ),
        _PasswordField(
          controller: _password,
          label: l.resetNewPassword,
          fieldKey: const Key('auth.password'),
          newPassword: true,
          onChanged: (_) => setState(() {}),
        ),
        PasswordRulesList(password: _password.text, email: widget.email),
        _PasswordField(
          controller: _confirm,
          label: l.accountConfirmPassword,
          fieldKey: const Key('auth.confirm'),
          newPassword: true,
        ),
        _ErrorText(_error),
        _Submit(
          label: l.resetSubmit,
          busy: _busy,
          buttonKey: const Key('auth.submit'),
          onPressed: configured ? _submit : null,
        ),
        const SizedBox(height: FeSpace.xs),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}

/// Akkauntni o‘chirish — jiddiy tasdiq: oqibatlar ro‘yxati, «tushunaman»
/// belgisi, joriy parol va yakuniy dialog. Qurilmadagi ma’lumotni
/// o‘chirish — alohida amal.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _password = TextEditingController();
  var _understood = false;
  AuthFailure? _error;
  var _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteAccountFinalTitle),
        content: Text(l.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            key: const Key('auth.delete.final'),
            style: FilledButton.styleFrom(backgroundColor: c.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authRepositoryProvider)
        .deleteAccount(password: _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.deleteAccountDone)));
      context.go(Routes.profile);
    } else {
      setState(() => _error = r.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final state = ref.watch(authStateProvider);
    final signedIn = state.signedIn;
    return _AuthScaffold(
      screenKey: const Key('screen.deleteAccount'),
      title: l.deleteAccountTitle,
      children: [
        FeBanner(
          icon: Icons.warning_amber_outlined,
          text: l.deleteAccountBody,
          tone: FeBannerTone.critical,
        ),
        const SizedBox(height: FeSpace.sm),
        FeBanner(
          key: const Key('auth.delete.storeNote'),
          icon: Icons.storefront_outlined,
          text: l.deleteAccountStoreNote,
        ),
        const SizedBox(height: FeSpace.sm),
        Text(
          l.deleteAccountLocalNote,
          key: const Key('auth.delete.localNote'),
          style: t.bodyMedium?.copyWith(color: c.textSecondary),
        ),
        if (signedIn) ...[
          const SizedBox(height: FeSpace.md),
          Text(state.account!.email, style: t.titleSmall),
          const SizedBox(height: FeSpace.sm),
          _PasswordField(
            controller: _password,
            label: l.deleteAccountPassword,
            fieldKey: const Key('auth.password'),
            onChanged: (_) => setState(() {}),
          ),
          CheckboxListTile(
            key: const Key('auth.delete.understand'),
            value: _understood,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) => setState(() => _understood = v ?? false),
            title: Text(l.deleteAccountUnderstand),
          ),
          _ErrorText(_error),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: FilledButton(
              key: const Key('auth.delete.submit'),
              style: FilledButton.styleFrom(backgroundColor: c.danger),
              onPressed: _busy || !_understood || _password.text.isEmpty
                  ? null
                  : _delete,
              child: Text(l.deleteAccountConfirm),
            ),
          ),
        ] else ...[
          const SizedBox(height: FeSpace.md),
          const _ErrorText(AuthFailure.notSignedIn),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Parolsiz kirish: email → 6 xonali kod → sessiya.

/// Email kodi bilan kirish / ro‘yxatdan o‘tish. Muvaffaqiyatda `true` bilan
/// yopiladi (chaqiruvchi keyingi qadamni hal qiladi).
class EmailCodeScreen extends ConsumerStatefulWidget {
  const EmailCodeScreen({super.key});

  @override
  ConsumerState<EmailCodeScreen> createState() => _EmailCodeScreenState();
}

class _EmailCodeScreenState extends ConsumerState<EmailCodeScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  String? _sentTo;
  AuthFailure? _error;
  var _busy = false;
  var _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = AuthCodePolicy.resendCooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown = _cooldown > 0 ? _cooldown - 1 : 0);
      if (_cooldown == 0) t.cancel();
    });
  }

  Future<void> _send() async {
    final email = EmailAddress.normalize(_sentTo ?? _email.text);
    if (!EmailAddress.isValid(email)) {
      setState(() => _error = AuthFailure.invalidEmail);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authRepositoryProvider)
        .requestEmailCode(
          email,
          locale: Localizations.localeOf(context).languageCode,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (r.ok) {
        _sentTo = email;
        _code.clear();
      } else {
        _error = r.failure;
      }
    });
    if (r.ok) _startCooldown();
  }

  Future<void> _verify() async {
    if (!AuthCodePolicy.looksLikeCode(_code.text)) {
      setState(() => _error = AuthFailure.codeInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authRepositoryProvider)
        .verifyEmailCode(email: _sentTo!, code: _code.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.ok) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.emailCodeSignedIn)));
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(Routes.profile);
      }
    } else {
      setState(() => _error = r.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    final sent = _sentTo;
    return _AuthScaffold(
      screenKey: const Key('screen.emailCode'),
      title: sent == null ? l.emailCodeTitle : l.emailCodeEnterTitle,
      children: [
        if (sent == null) ...[
          Text(l.emailCodeSubtitle, style: t.bodyLarge),
          const SizedBox(height: FeSpace.md),
          _EmailField(controller: _email),
          _ErrorText(_error),
          _Submit(
            label: l.emailCodeSend,
            busy: _busy,
            buttonKey: const Key('emailCode.send'),
            onPressed: configured ? _send : null,
          ),
        ] else ...[
          Text(
            l.verifyBody(AuthCodePolicy.codeLength, sent),
            key: const Key('emailCode.sentTo'),
            style: t.bodyLarge,
          ),
          const SizedBox(height: FeSpace.md),
          TextField(
            key: const Key('emailCode.code'),
            controller: _code,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofillHints: const [AutofillHints.oneTimeCode],
            maxLength: AuthCodePolicy.codeLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: FeThemeBuilder.numeric(
              t.headlineSmall!.copyWith(letterSpacing: 10),
            ),
            decoration: InputDecoration(
              labelText: l.verifyCode,
              counterText: '',
            ),
            onSubmitted: (_) => _verify(),
          ),
          const SizedBox(height: FeSpace.sm),
          _ErrorText(_error),
          _Submit(
            label: l.verifySubmit,
            busy: _busy,
            buttonKey: const Key('emailCode.verify'),
            onPressed: configured ? _verify : null,
          ),
          const SizedBox(height: FeSpace.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextButton(
                  key: const Key('emailCode.change'),
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _sentTo = null;
                          _error = null;
                        }),
                  child: Text(l.emailCodeChange),
                ),
              ),
              Flexible(
                child: TextButton(
                  key: const Key('emailCode.resend'),
                  onPressed: _busy || _cooldown > 0 ? null : _send,
                  child: Text(
                    _cooldown > 0
                        ? l.emailCodeResendIn(_cooldown)
                        : l.verifyResend,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: FeSpace.md),
        Text(
          l.emailCodeNotProfessional,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}
