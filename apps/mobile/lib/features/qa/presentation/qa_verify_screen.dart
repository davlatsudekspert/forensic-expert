import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/qa.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/qa/qa_models.dart';
import '../qa_document_picker.dart';
import '../qa_strings.dart';
import 'qa_widgets.dart';

/// Mutaxassis sifatida tasdiqlanish.
///
/// Hujjat **saqlanmaydi**: tanlangan baytlar faqat shu ekran ochiq turganda
/// xotirada bo‘ladi, serverga bir marta yuboriladi va u yerda ham faqat
/// tekshiruv vaqtida xotirada bo‘ladi. Ekrandan chiqilganda yo‘qoladi.
class QaVerifyScreen extends ConsumerStatefulWidget {
  const QaVerifyScreen({super.key});

  @override
  ConsumerState<QaVerifyScreen> createState() => _QaVerifyScreenState();
}

class _QaVerifyScreenState extends ConsumerState<QaVerifyScreen> {
  QaRole _role = QaRole.forensicPhysician;
  final _country = TextEditingController(text: 'UZ');
  QaDocument? _document;
  bool _sending = false;
  QaVerifyOutcome? _outcome;

  @override
  void dispose() {
    _country.dispose();
    // Baytlarga havola shu yerda uziladi — diskda nusxa qolmaydi.
    _document = null;
    super.dispose();
  }

  String _size(int bytes) => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).round()} KB';

  Future<void> _pick() async {
    final picked = await ref.read(qaDocumentPickerProvider).pick();
    if (!mounted || picked == null) return;
    setState(() {
      _document = picked;
      _outcome = null;
    });
  }

  Future<void> _send() async {
    final document = _document;
    if (document == null) return;
    setState(() {
      _sending = true;
      _outcome = null;
    });
    final out = await ref
        .read(qaServiceProvider)
        .verify(
          role: _role,
          countryCode: _country.text.trim().toUpperCase(),
          document: document,
          lang: QaLang.fromLocale(Localizations.localeOf(context).languageCode),
        );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _outcome = out;
      // Natija qanday bo‘lishidan qat’i nazar, hujjat xotiradan chiqariladi.
      _document = null;
    });
    ref.invalidate(qaMeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final me = ref.watch(qaMeProvider).value;
    final attemptsLeft = me?.attemptsLeft ?? QaMe.dailyVerifyAttempts;
    final document = _document;
    return QaGate(
      title: l.qaVerifyTitle,
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.qaVerifyTitle)),
        body: SafeArea(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            key: const Key('qa.verify'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    if (me != null)
                      StatusChip(
                        key: const Key('qa.verify.status'),
                        icon: me.profile.isVerified
                            ? Icons.verified_outlined
                            : Icons.badge_outlined,
                        label: l.qaProfileStatus(me.profile.status),
                        color: me.profile.isVerified ? c.verified : c.warning,
                      ),
                    if (me?.profile.manual ?? false) ...[
                      const SizedBox(height: FeSpace.xxs),
                      Text(
                        l.qaManualBadge,
                        key: const Key('qa.verify.manual'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                    const SizedBox(height: FeSpace.sm),
                    Text(l.qaVerifyIntro),
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      key: const Key('qa.verify.notStored'),
                      icon: Icons.lock_outline,
                      tone: FeBannerTone.critical,
                      text: l.qaVerifyFileNotStored,
                    ),
                    const SizedBox(height: FeSpace.md),
                    Text(
                      l.qaVerifyRole,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: FeSpace.xxs),
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      children: [
                        for (final role in QaRole.values.where(
                          (r) => r.verifiable,
                        ))
                          ChoiceChip(
                            key: Key('qa.verify.role.${role.wire}'),
                            label: Text(l.qaRole(role)),
                            selected: _role == role,
                            onSelected: (_) => setState(() => _role = role),
                          ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      key: const Key('qa.verify.country'),
                      controller: _country,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 2,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
                      ],
                      decoration: InputDecoration(labelText: l.qaVerifyCountry),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    OutlinedButton.icon(
                      key: const Key('qa.verify.pick'),
                      onPressed: _sending ? null : _pick,
                      icon: const Icon(Icons.attach_file),
                      label: Text(l.qaVerifyPickFile),
                    ),
                    if (document != null) ...[
                      const SizedBox(height: FeSpace.xxs),
                      Text(
                        l.qaVerifyFileChosen(_size(document.bytes.length)),
                        key: const Key('qa.verify.chosen'),
                      ),
                      if (!document.isAllowed)
                        Text(
                          l.qaVerifyBadDocument,
                          key: const Key('qa.verify.badDocument'),
                          style: TextStyle(color: c.danger),
                        ),
                    ],
                    const SizedBox(height: FeSpace.sm),
                    Text(
                      l.qaVerifyAttemptsLeft(attemptsLeft),
                      key: const Key('qa.verify.attempts'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    FilledButton(
                      key: const Key('qa.verify.send'),
                      onPressed:
                          document != null &&
                              document.isAllowed &&
                              RegExp('^[A-Za-z]{2}\$')
                                  .hasMatch(_country.text.trim()) &&
                              attemptsLeft > 0 &&
                              !_sending
                          ? _send
                          : null,
                      child: Text(l.qaVerifySend),
                    ),
                    if (_sending) ...[
                      const SizedBox(height: FeSpace.sm),
                      Text(
                        l.qaVerifyChecking,
                        key: const Key('qa.verify.checking'),
                      ),
                      const SizedBox(height: FeSpace.xxs),
                      const LinearProgressIndicator(),
                    ],
                    if (_outcome case final out?) ...[
                      const SizedBox(height: FeSpace.sm),
                      _Outcome(out),
                    ],
                    const SizedBox(height: FeSpace.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome(this.outcome);

  final QaVerifyOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (outcome.verified) {
      return FeBanner(
        key: const Key('qa.verify.accepted'),
        icon: Icons.verified_outlined,
        tone: FeBannerTone.review,
        text: l.qaVerifyAccepted,
      );
    }
    if (outcome.rejected) {
      final reason = l.qaReasonText(outcome.reason) ?? l.qaStatusRejected;
      return FeBanner(
        key: const Key('qa.verify.rejected'),
        icon: Icons.highlight_off,
        tone: FeBannerTone.warning,
        text: l.qaVerifyRejected(reason),
      );
    }
    return FeBanner(
      key: const Key('qa.verify.unavailable'),
      icon: Icons.cloud_off_outlined,
      tone: FeBannerTone.info,
      text: outcome.error == 'too_many_requests'
          ? l.qaDailyLimit
          : (outcome.error == 'bad_document'
                ? l.qaVerifyBadDocument
                : l.qaVerifyUnavailable),
    );
  }
}
