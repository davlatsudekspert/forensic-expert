import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/plan.dart';
import '../../../app/routes.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/pro_lock_card.dart';
import '../../../domain/plan/plan_models.dart';

/// Reja nomi: «Talaba Pro», «Ustoz Pro», «Mutaxassis Pro».
String proPlanName(AppLocalizations l, Plan p) => switch (p) {
  Plan.student => l.proPlanStudent,
  Plan.teacher => l.proPlanTeacher,
  Plan.expert => l.proPlanExpert,
};

/// Funksiya foydasi — bir jumla.
String proBenefit(AppLocalizations l, ProFeature f) => switch (f) {
  ProFeature.fullQuizBank => l.proBenefitFullQuizBank,
  ProFeature.examMode => l.proBenefitExamMode,
  ProFeature.allFlashcards => l.proBenefitAllFlashcards,
  ProFeature.errorAnalytics => l.proBenefitErrorAnalytics,
  ProFeature.offlineDownload => l.proBenefitOfflineDownload,
  ProFeature.allLessons => l.proBenefitAllLessons,
  ProFeature.unlimitedGroupTests => l.proBenefitUnlimitedGroupTests,
  ProFeature.resultsCsv => l.proBenefitResultsCsv,
  ProFeature.hardestDiscussion => l.proBenefitHardestDiscussion,
  ProFeature.liveTestLarge => l.proBenefitLiveTestLarge,
  ProFeature.instrumentsCourseFull => l.proBenefitInstrumentsCourseFull,
  ProFeature.proCalculators => l.proBenefitProCalculators,
  ProFeature.caseNotebook => l.proBenefitCaseNotebook,
  ProFeature.courtPrep => l.proBenefitCourtPrep,
  ProFeature.aiExtended => l.proBenefitAiExtended,
};

/// Pro sahifasini ochadi (funksiya talab qiladigan reja bilan).
void openPro(BuildContext context, Plan plan) =>
    context.push(Routes.proFor(plan));

/// [feature] uchun qulf kartasi (tugma Pro sahifasiga olib boradi).
class ProFeatureLock extends StatelessWidget {
  const ProFeatureLock({
    super.key,
    required this.feature,
    this.compact = false,
    this.benefit,
  });

  final ProFeature feature;
  final bool compact;

  /// Maxsus foyda jumlasi (kontekstli taklif); aks holda funksiyaniki.
  final String? benefit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ProLockCard(
      key: Key('pro.lock.${feature.name}'),
      benefit: benefit ?? proBenefit(l, feature),
      planName: proPlanName(l, feature.requiredPlan),
      compact: compact,
      onUnlock: () => openPro(context, feature.requiredPlan),
    );
  }
}

/// Kontekstli taklif: [feature] ochiq bo‘lsa — hech narsa; yuklanayotgan
/// yoki yopiq bo‘lsa — qulf kartasi (natija nuqtalarida; popup emas).
class ProContextOffer extends ConsumerWidget {
  const ProContextOffer({super.key, required this.feature, this.benefit});

  final ProFeature feature;
  final String? benefit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (proLoading(ref) || proGate(ref, feature)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
      child: ProFeatureLock(feature: feature, benefit: benefit),
    );
  }
}

/// Butun ekran qulfi: [feature] ochiq bo‘lsa — [child]; aks holda ekran
/// sarlavhasi bilan qulf kartasi (funksiya ko‘rinadi, lekin qulfli).
class ProGated extends ConsumerWidget {
  const ProGated({
    super.key,
    required this.feature,
    required this.title,
    required this.child,
    this.freeIf = false,
  });

  final ProFeature feature;
  final String title;
  final Widget child;

  /// `true` — bu holatda funksiya bepul (masalan, bepul fan/dars).
  final bool freeIf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    if (freeIf || proGate(ref, feature)) return child;
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(title)),
      body: SafeArea(
        child: proLoading(ref)
            ? Padding(
                padding: const EdgeInsets.all(FeSpace.md),
                child: FeListSkeleton(rows: 2, semanticLabel: l.loadingContent),
              )
            : ListView(
                children: [
                  FeContentFrame(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProFeatureLock(feature: feature),
                          const SizedBox(height: FeSpace.sm),
                          FeBanner(
                            icon: Icons.health_and_safety_outlined,
                            text: l.proFreeAlways,
                          ),
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

/// «Sudda so‘roq: tayyorgarlik» — Mutaxassis Pro.
class CourtPrepGate extends StatelessWidget {
  const CourtPrepGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ProGated(
    feature: ProFeature.courtPrep,
    title: AppLocalizations.of(context).courtTitle,
    child: child,
  );
}

/// «Ekspert ish daftari» — Mutaxassis Pro.
class CasebookGate extends StatelessWidget {
  const CasebookGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ProGated(
    feature: ProFeature.caseNotebook,
    title: AppLocalizations.of(context).casebookTitle,
    child: child,
  );
}

/// Tugma belgisi: [feature] yopiq bo‘lsa — qulf, ochiq bo‘lsa — [icon].
class ProIcon extends ConsumerWidget {
  const ProIcon({super.key, required this.feature, required this.icon});

  final ProFeature feature;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Icon(proGate(ref, feature) ? icon : Icons.lock_outline);
}
