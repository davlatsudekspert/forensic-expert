import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/plan.dart';
import '../../../app/pro_samples.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/pro_lock_card.dart';
import '../../../domain/library/library_models.dart' show LibrarySection;
import '../../../domain/plan/plan_models.dart';
import '../../../domain/plan/pro_split.dart';

/// Reja nomi: «Talaba Pro», «Ustoz Pro», «Mutaxassis Pro».
String proPlanName(AppLocalizations l, Plan p) => switch (p) {
  Plan.student => l.proPlanStudent,
  Plan.teacher => l.proPlanTeacher,
  Plan.expert => l.proPlanExpert,
  Plan.premium => l.proPlanPremium,
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
  ProFeature.proModules => l.proBenefitModules,
  ProFeature.proTools => l.proBenefitTools,
  ProFeature.proAi => l.proBenefitAi,
  ProFeature.listen => l.proBenefitListen,
  ProFeature.groupTestReview => l.proBenefitGroupReview,
  ProFeature.teacherPanel => l.proBenefitTeacherPanel,
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
    // Har qanday pullik reja ochadigan funksiya: umumiy «Pro» va rejimga mos
    // Pro sahifasi; boshqalari — o‘z rejasi.
    return ProLockCard(
      key: Key('pro.lock.${feature.name}'),
      benefit: benefit ?? proBenefit(l, feature),
      planName: feature.anyPlan
          ? l.proTitle
          : proPlanName(l, feature.requiredPlan),
      compact: compact,
      onUnlock: () => feature.anyPlan
          ? context.push(Routes.pro)
          : openPro(context, feature.requiredPlan),
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
    this.sample,
    this.strictOnly = false,
  });

  final ProFeature feature;
  final String title;
  final Widget child;

  /// `true` — bu holatda funksiya bepul (masalan, bepul fan/dars).
  final bool freeIf;

  /// Qulf kartasi ustida ko‘rsatiladigan qisqa namuna (bo‘lim dastlabki 1–2
  /// yozuvi). Bepul/Pro bo‘linishi (2026-10-31).
  final ProSampleSource? sample;

  /// `true` — mavjud ([ProFeature.strictOnly] bo‘lmagan) funksiyani FAQAT
  /// qat’iy bo‘linish yoqilganda qulflaydi; o‘chiqda child ochiq.
  final bool strictOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    if (freeIf ||
        (strictOnly && !ref.watch(proStrictProvider)) ||
        proOpen(ref, feature)) {
      return child;
    }
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
                          if (sample != null) ProSamples(source: sample!),
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

/// Qulfli bo‘lim ichidagi qisqa namuna: dastlabki 1–2 yozuv (ochiladi) va izoh.
/// Yozuv bo‘lmasa — hech narsa (qulf kartasi o‘zi ko‘rinadi).
class ProSamples extends ConsumerWidget {
  const ProSamples({super.key, required this.source});

  final ProSampleSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(proSamplesProvider(source));
    if (items.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      key: Key('pro.sample.${source.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.proSampleTitle),
        for (final i in items)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: FeCard(
              key: Key('pro.sample.item.${i.id}'),
              onTap: () => context.push(i.route),
              child: Row(
                children: [
                  Expanded(
                    child: Text(i.name.resolve(lang), style: t.titleSmall),
                  ),
                  ExcludeSemantics(
                    child: Icon(Icons.chevron_right, color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        Text(
          l.proSampleNote,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.sm),
      ],
    );
  }
}

/// Pro bo‘lim kartasidagi kichik qulf belgisi (bo‘lim ko‘rinadi, lekin Pro
/// bilan ochiladi). Faqat qat’iy bo‘linishda va bo‘lim yopiq bo‘lsa chiziladi.
class ProLockBadge extends StatelessWidget {
  const ProLockBadge({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Semantics(
      label: AppLocalizations.of(context).proLockedBadge,
      child: ExcludeSemantics(
        child: Icon(Icons.lock_outline, size: size, color: c.accent),
      ),
    );
  }
}

/// Bo‘lim yopiqmi (qat’iy bo‘linish yoqilgan, [feature] ochiq emas va huquq
/// yuklanib bo‘lgan). `feature == null` — bepul bo‘lim.
bool proSectionLocked(WidgetRef ref, ProFeature? feature) {
  if (feature == null) return false;
  if (!ref.watch(proStrictProvider)) return false;
  return !proLoading(ref) && !proGate(ref, feature);
}

/// Bilim yozuvi sahifasi qulfi: bepul sohaning mavzusi, namuna yoki Pro
/// foydalanuvchi — ochiq; qolgani — qulf kartasi.
class KnowledgeEntryGate extends ConsumerWidget {
  const KnowledgeEntryGate({
    super.key,
    required this.entryId,
    required this.child,
  });

  final String entryId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = ref.watch(knowledgeRepositoryProvider).byId(entryId);
    final lang = Localizations.localeOf(context).languageCode;
    // Topilmagan yozuv — ekranning o‘zi «topilmadi» ko‘rsatadi.
    final free =
        e == null ||
        ProSplit.isFreeKnowledge(e.kind, e.area) ||
        ref.watch(proSampleIdsProvider).contains(entryId);
    return ProGated(
      feature: ProFeature.proModules,
      title: e?.name.resolve(lang) ?? AppLocalizations.of(context).appTitle,
      freeIf: free,
      child: child,
    );
  }
}

/// Namunasi bo‘lishi mumkin bo‘lgan sahifa (masalan, tadqiqot yozuvi) qulfi:
/// [id] namunalar orasida bo‘lsa yoki Pro ochiq bo‘lsa — [child].
class ProSampleIdGate extends ConsumerWidget {
  const ProSampleIdGate({
    super.key,
    required this.id,
    required this.feature,
    required this.title,
    required this.child,
  });

  final String id;
  final ProFeature feature;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ProGated(
    feature: feature,
    title: title,
    freeIf: ref.watch(proSampleIdsProvider).contains(id),
    child: child,
  );
}

/// Kutubxona yozuvi (modda va h.k.) sahifasi qulfi.
class LibraryEntryGate extends ConsumerWidget {
  const LibraryEntryGate({
    super.key,
    required this.entryId,
    required this.child,
  });

  final String entryId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = ref.watch(libraryRepositoryProvider).byId(entryId);
    final lang = Localizations.localeOf(context).languageCode;
    final free =
        e == null ||
        ProSplit.isFreeLibrarySection(e.section) ||
        ref.watch(proSampleIdsProvider).contains(entryId);
    return ProGated(
      feature: ProFeature.proModules,
      title: e?.name.resolve(lang) ?? AppLocalizations.of(context).appTitle,
      freeIf: free,
      child: child,
    );
  }
}

/// Kutubxona bo‘limi (Moddalar, Usullar) sahifasi qulfi; namuna bilan.
class LibrarySectionGate extends StatelessWidget {
  const LibrarySectionGate({
    super.key,
    required this.section,
    required this.title,
    required this.child,
  });

  final LibrarySection section;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => ProGated(
    feature: ProFeature.proModules,
    title: title,
    freeIf: ProSplit.isFreeLibrarySection(section),
    sample: section == LibrarySection.substances
        ? ProSampleSource.substances
        : null,
    child: child,
  );
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

/// Talaba guruh/jonli testga kirishi.
///
/// EGASI QARORI (2026-10-31): talaba guruhga qo‘shilishi va ustoz bergan testni
/// yechishi HOZIRCHA BEPUL (sinfni to‘xtatib qo‘ymaslik uchun). Pullik qilish
/// keyingi bosqichda — shunda bu qo‘riqchi yana [ProFeature.fullQuizBank] ni
/// (Talaba Pro, 1 oylik sinov) tekshiradi. Marshrutlar shu sinf orqali o‘ralgani
/// uchun qayta yoqish bitta joyda.
class StudentTestGate extends StatelessWidget {
  const StudentTestGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
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
