import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/moderation.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../profile/presentation/legal_screens.dart';
import '../../qa/presentation/qa_rules_screen.dart';
import '../../qa/presentation/qa_widgets.dart';
import 'moderation_widgets.dart';

/// «Foydalanish qoidalari» (EULA) — Savol-javobda birinchi yozishdan oldin.
///
/// Matn: mavjud hamjamiyat qoidalari + Foydalanish shartlari QORALAMASI
/// (yuridik tekshiruvdan o‘tmagan — shunday belgilangan). Qabul qilish
/// serverga yoziladi (`accept_terms`); server qabulsiz yangi savol/javobni
/// rad etadi. Ekran `true` (qabul qilindi) bilan yopiladi.
class CommunityTermsScreen extends ConsumerStatefulWidget {
  const CommunityTermsScreen({super.key});

  @override
  ConsumerState<CommunityTermsScreen> createState() =>
      _CommunityTermsScreenState();
}

class _CommunityTermsScreenState extends ConsumerState<CommunityTermsScreen> {
  bool _agree = false;
  bool _busy = false;
  bool _error = false;

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _error = false;
    });
    final ok = await ref.read(moderationServiceProvider).acceptCommunityTerms();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = !ok;
    });
    if (ok) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return QaGate(
      title: l.ctTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.ctTitle)),
        body: SafeArea(
          child: ListView(
            key: const Key('terms.list'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      key: const Key('terms.draft'),
                      icon: Icons.edit_note_outlined,
                      tone: FeBannerTone.warning,
                      text: l.ctDraft,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      key: const Key('terms.zeroTolerance'),
                      icon: Icons.gavel_outlined,
                      tone: FeBannerTone.critical,
                      text: l.ctZeroTolerance,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    const QaRulesContent(),
                    const SizedBox(height: FeSpace.xs),
                    TextButton.icon(
                      key: const Key('terms.openTerms'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LegalDocumentScreen(
                            document: LegalDocument.terms,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.article_outlined),
                      label: Text(l.ctOpenTerms),
                    ),
                    const SupportContactLine(),
                    CheckboxListTile(
                      key: const Key('terms.agree'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      title: Text(l.ctAgree),
                    ),
                    if (_error)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: Text(
                          l.ctSaveFailed,
                          key: const Key('terms.error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    FilledButton(
                      key: const Key('terms.accept'),
                      onPressed: _agree && !_busy ? _accept : null,
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l.ctAccept),
                    ),
                    TextButton(
                      key: const Key('terms.decline'),
                      onPressed: () => context.pop(false),
                      child: Text(l.ctDecline),
                    ),
                    const SizedBox(height: FeSpace.xl),
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
