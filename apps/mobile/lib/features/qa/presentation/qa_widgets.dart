import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/qa.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/qa/qa_models.dart';
import '../qa_strings.dart';

/// Bo‘lim ochiqmi: bayroq/admin + server ulangan + kirgan. Aks holda halol
/// bo‘sh holat — ishlamaydigan ekran ko‘rsatilmaydi.
class QaGate extends ConsumerWidget {
  const QaGate({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(qaVisibleProvider)) return child;
    final l = AppLocalizations.of(context);
    final signedIn = ref.watch(authStateProvider).signedIn;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: FeContentFrameOrSelf(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FeEmptyState(
                key: Key(signedIn ? 'qa.unavailable' : 'qa.signInRequired'),
                icon: signedIn ? Icons.lock_clock_outlined : Icons.login,
                body: signedIn ? l.qaUnavailable : l.qaSignInRequired,
              ),
              if (!signedIn)
                FilledButton(
                  key: const Key('qa.signIn'),
                  onPressed: () => context.push(Routes.accountSignIn),
                  child: Text(l.qaSignIn),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Markazlashtirilgan ramka — `FeContentFrame` ni sahifa markazida beradi.
class FeContentFrameOrSelf extends StatelessWidget {
  const FeContentFrameOrSelf({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Center(child: SingleChildScrollView(child: child));
}

/// «Javob — hamkasb fikri, ilmiy xulosa emas».
class QaNotice extends StatelessWidget {
  const QaNotice({super.key});

  @override
  Widget build(BuildContext context) => FeBanner(
    key: const Key('qa.notice'),
    icon: Icons.info_outline,
    tone: FeBannerTone.warning,
    text: AppLocalizations.of(context).qaNotice,
  );
}

/// Ish materialini yozmaslik haqidagi ogohlantirish (forma ustida).
class QaPrivacyWarning extends StatelessWidget {
  const QaPrivacyWarning({super.key});

  @override
  Widget build(BuildContext context) => FeBanner(
    key: const Key('qa.privacyWarning'),
    icon: Icons.shield_outlined,
    tone: FeBannerTone.critical,
    text: AppLocalizations.of(context).qaPrivacyWarning,
  );
}

/// Muallif belgisi: faqat tasdiqlangan mutaxassis uchun rol bilan.
class QaAuthorBadge extends StatelessWidget {
  const QaAuthorBadge(this.role, {super.key});

  final QaRole? role;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final badge = role;
    if (badge == null) return const SizedBox.shrink();
    final label = '${l.qaVerifiedBadge} · ${l.qaRole(badge)}';
    return StatusChip(
      key: const Key('qa.verifiedBadge'),
      icon: Icons.verified_outlined,
      label: label,
      color: c.verified,
    );
  }
}

/// Post holati chipi (menikilar va moderatsiya ro‘yxatlarida).
class QaPostStatusChip extends StatelessWidget {
  const QaPostStatusChip(this.status, {super.key});

  final QaPostStatus status;

  @override
  Widget build(BuildContext context) => StatusChip(
    icon: qaPostStatusIcon(status),
    label: AppLocalizations.of(context).qaPostStatusLabel(status),
    color: qaPostStatusColor(status, FeTheme.of(context)),
  );
}

/// Maxfiylik filtri natijasi — qaysi qoida ishlagani.
class QaFlagsNotice extends StatelessWidget {
  const QaFlagsNotice(this.flags, {super.key});

  final List<QaPrivacyFlag> flags;

  @override
  Widget build(BuildContext context) {
    if (flags.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return FeBanner(
      key: const Key('qa.flags'),
      icon: Icons.policy_outlined,
      tone: FeBannerTone.warning,
      text:
          '${l.qaHeldForReview}\n'
          '${l.qaFlagsFound(flags.map(l.qaFlag).join(', '))}',
    );
  }
}

/// Mashina tarjimasi bloki: «Tarjima qilish» → serverdagi kesh, keyin
/// «Mashina tarjimasi» belgisi va «Asl matn» tugmasi.
class QaTranslatableText extends ConsumerStatefulWidget {
  const QaTranslatableText({
    super.key,
    required this.target,
    required this.id,
    required this.postLang,
    required this.title,
    required this.body,
  });

  final QaTargetType target;
  final String id;
  final QaLang postLang;
  final String? title;
  final String body;

  @override
  ConsumerState<QaTranslatableText> createState() => _QaTranslatableTextState();
}

class _QaTranslatableTextState extends ConsumerState<QaTranslatableText> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final uiLang = QaLang.fromLocale(
      Localizations.localeOf(context).languageCode,
    );
    final sameLanguage = uiLang == widget.postLang;

    Widget text(String? title, String body) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title.isNotEmpty)
          Text(title, style: t.titleMedium),
        if (title != null && title.isNotEmpty)
          const SizedBox(height: FeSpace.xxs),
        Text(body, style: t.bodyMedium),
      ],
    );

    if (sameLanguage || !_showTranslation) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(widget.title, widget.body),
          if (!sameLanguage)
            TextButton.icon(
              key: Key('qa.translate.${widget.id}'),
              onPressed: () => setState(() => _showTranslation = true),
              icon: const Icon(Icons.translate, size: 18),
              label: Text(l.qaShowTranslation),
            ),
        ],
      );
    }

    final request = (target: widget.target, id: widget.id, lang: uiLang);
    final async = ref.watch(qaTranslationProvider(request));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        switch (async) {
          AsyncData(value: final v?) when !v.isSource => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusChip(
                key: Key('qa.machineTranslation.${widget.id}'),
                icon: Icons.translate,
                label: l.qaMachineTranslation,
                color: c.warning,
              ),
              const SizedBox(height: FeSpace.xxs),
              text(v.title, v.body),
            ],
          ),
          AsyncData() => Padding(
            padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
            child: Text(
              l.qaTranslationFailed,
              key: Key('qa.translationFailed.${widget.id}'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
          AsyncError() => Text(
            l.qaTranslationFailed,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          _ => const Padding(
            padding: EdgeInsets.symmetric(vertical: FeSpace.xs),
            child: LinearProgressIndicator(),
          ),
        },
        TextButton.icon(
          key: Key('qa.original.${widget.id}'),
          onPressed: () => setState(() => _showTranslation = false),
          icon: const Icon(Icons.article_outlined, size: 18),
          label: Text(l.qaShowOriginal),
        ),
      ],
    );
  }
}
