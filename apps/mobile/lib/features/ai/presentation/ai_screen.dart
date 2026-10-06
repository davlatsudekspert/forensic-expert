import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ai/ai_architecture.dart';
import '../../../domain/ai/rag_pipeline.dart';
import '../../../domain/ports/ai_ports.dart';
import 'rag_sections.dart';

/// Forensic AI. Production AI provayderi ulanmaguncha ekran yuqorisida
/// «Namoyish · ulanmagan» holati ko‘rsatiladi, «Yuborish» o‘chiq va javob
/// namunasi NAMOYISH deb belgilanadi. Provayder ulanganda (`available`)
/// oddiy holat avtomatik ishlaydi.
///
/// Konsumer chatbot emas: savol maydoni, doimiy PII ogohlantirishi,
/// tuzilgan javob (mavjud ma’lumot · differensial mulohazalar ·
/// cheklovlar), har bir da’vo yonida raqamli citation, manbalar ro‘yxati
/// dalil darajasi bilan va ekspert xulosasi haqidagi doimiy izoh.
class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _controller = TextEditingController();
  List<PiiFinding> _pii = const [];
  AiExperience _experience = AiExperience.professional;
  AiRouteResult? _result;
  RagAnswer? _rag;
  bool _searching = false;

  Future<void> _findSources(String lang) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _searching = true);
    final r = await ref
        .read(aiRouterProvider(lang))
        .route(
          AiQuestion(
            text: text,
            languageCode: lang,
            jurisdictionId: ref.read(settingsControllerProvider).jurisdictionId,
          ),
          experience: _experience,
          entitlement: await ref.read(aiEntitlementServiceProvider).current(),
        );
    // Tuzilgan RAG natijasi (provenance, ziddiyat, retraksiya).
    final rag = await ref
        .read(ragPipelineProvider(lang))
        .ask(
          AiQuestion(
            text: text,
            languageCode: lang,
            jurisdictionId: ref.read(settingsControllerProvider).jurisdictionId,
          ),
          experience: _experience,
          entitlement: await ref.read(aiEntitlementServiceProvider).current(),
        );
    if (!mounted) return;
    setState(() {
      _result = r;
      _rag = rag;
      _searching = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _kindLabel(AppLocalizations l, PiiKind k) => switch (k) {
    PiiKind.email => l.piiKindEmail,
    PiiKind.phone => l.piiKindPhone,
    PiiKind.passport => l.piiKindPassport,
    PiiKind.caseNumber => l.piiKindCase,
    PiiKind.personalName => l.piiKindName,
    PiiKind.address => l.piiKindAddress,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    // Kirish holati o‘zgarsa, server AI mavjudligi qayta hisoblanadi.
    ref.watch(authStateProvider);
    final ai = ref.watch(aiAssistantProvider);
    final scanner = ref.watch(piiScannerProvider);
    final available = ai.availability == AiAvailability.available;
    final kinds = {for (final f in _pii) f.kind}.toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.moduleAi)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.xs),
                  _AiHeader(available: available),
                  const SizedBox(height: FeSpace.sm),
                  if (!available) ...[
                    const _PreviewStateCard(),
                    const SizedBox(height: FeSpace.sm),
                  ],
                  // Doimiy PII ogohlantirishi (18-bo‘lim).
                  FeBanner(
                    key: const Key('ai.piiWarning'),
                    icon: Icons.privacy_tip_outlined,
                    text: l.aiPiiWarning,
                    tone: FeBannerTone.warning,
                  ),
                  FeSectionHeader(l.aiAskTitle),
                  SegmentedButton<AiExperience>(
                    key: const Key('ai.experience'),
                    segments: [
                      ButtonSegment(
                        value: AiExperience.professional,
                        icon: const Icon(Icons.work_outline),
                        label: Text(l.aiExperienceProfessional),
                      ),
                      ButtonSegment(
                        value: AiExperience.tutor,
                        icon: const Icon(Icons.school_outlined),
                        label: Text(l.aiExperienceTutor),
                      ),
                    ],
                    selected: {_experience},
                    onSelectionChanged: (v) =>
                        setState(() => _experience = v.first),
                  ),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    _experience == AiExperience.tutor
                        ? l.aiExperienceTutorHint
                        : l.aiExperienceProfessionalHint,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  TextField(
                    key: const Key('ai.input'),
                    controller: _controller,
                    minLines: 2,
                    maxLines: 5,
                    onChanged: (v) => setState(() => _pii = scanner.scan(v)),
                    decoration: InputDecoration(hintText: l.aiInputHint),
                  ),
                  if (kinds.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.xs),
                    Semantics(
                      liveRegion: true,
                      child: FeBanner(
                        key: const Key('ai.piiDetected'),
                        icon: Icons.report_gmailerrorred_outlined,
                        text: l.aiPiiDetected(
                          kinds.map((k) => _kindLabel(l, k)).join(', '),
                        ),
                        tone: FeBannerTone.warning,
                      ),
                    ),
                  ],
                  const SizedBox(height: FeSpace.sm),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xs,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('ai.findSources'),
                        icon: const Icon(Icons.travel_explore_outlined),
                        label: Text(l.aiFindSources),
                        onPressed: _searching || kinds.isNotEmpty
                            ? null
                            : () => _findSources(
                                Localizations.localeOf(context).languageCode,
                              ),
                      ),
                      FilledButton.icon(
                        key: const Key('ai.send'),
                        icon: const Icon(Icons.send_outlined),
                        label: Text(l.aiSend),
                        // Server AI (Gemini) — faqat ulanganda; PII topilsa
                        // yuborilmaydi. Javob manbalar bilan tekshiriladi.
                        onPressed: available && kinds.isEmpty && !_searching
                            ? () => _findSources(
                                Localizations.localeOf(context).languageCode,
                              )
                            : null,
                      ),
                    ],
                  ),
                  if (!available)
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xxs),
                      child: Text(
                        l.aiSendUnavailable,
                        key: const Key('ai.sendUnavailable'),
                        textAlign: TextAlign.end,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                  if (_result case final r?) _RouteResultView(result: r),
                  if (_rag case final a?)
                    if (a.evidence.isNotEmpty) RagSectionsView(answer: a),
                  if (!available) ...[
                    FeSectionHeader(l.aiPreviewTitle),
                    const _AnswerPreview(),
                  ],
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lokal qidiruv natijasi yoki xavfsizlik blokining sababi.
class _RouteResultView extends StatelessWidget {
  const _RouteResultView({required this.result});

  final AiRouteResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final blocks = result.safety?.blocks ?? const <SafetyBlock>{};
    return Column(
      key: Key('ai.result.${result.outcome.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FeSpace.sm),
        if (result.outcome == AiRouteOutcome.blocked)
          for (final b in blocks)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: FeBanner(
                key: Key('ai.blocked.${b.name}'),
                icon: Icons.block,
                tone: FeBannerTone.warning,
                text: switch (b) {
                  SafetyBlock.personalData => l.aiBlockedPii,
                  SafetyBlock.finalCauseOrManner => l.aiBlockedConclusion,
                  SafetyBlock.legalConclusion => l.aiBlockedLegal,
                  SafetyBlock.officialOpinion => l.aiBlockedOfficial,
                },
              ),
            )
        else if (result.outcome == AiRouteOutcome.jurisdictionRequired) ...[
          FeBanner(
            key: const Key('ai.jurisdictionRequired'),
            icon: Icons.public,
            tone: FeBannerTone.warning,
            text: l.aiJurisdictionRequired,
          ),
          const SizedBox(height: FeSpace.xs),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              key: const Key('ai.selectJurisdiction'),
              icon: const Icon(Icons.public),
              label: Text(l.aiSelectJurisdiction),
              onPressed: () => context.push(Routes.jurisdictionSelect),
            ),
          ),
        ] else if (result.chunks.isEmpty)
          FeEmptyState(
            key: const Key('ai.noContext'),
            icon: Icons.search_off,
            body: l.aiNoContext,
            compact: true,
          )
        else ...[
          FeSectionHeader(l.aiRetrievalTitle),
          FeBanner(icon: Icons.info_outline, text: l.aiRetrievalNote),
          const SizedBox(height: FeSpace.xs),
          for (final ch in result.chunks)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: Consumer(
                builder: (context, ref, _) {
                  // Kartani bosish — to‘liq yozuv; SRC — manba sahifasi.
                  final isLibrary =
                      ref.watch(libraryRepositoryProvider).byId(ch.entityId) !=
                      null;
                  return FeCard(
                    key: Key('ai.chunk.${ch.chunkId}'),
                    padding: const EdgeInsets.all(FeSpace.sm),
                    onTap: () => context.push(
                      isLibrary
                          ? Routes.libraryEntry(ch.entityId)
                          : Routes.knowledgeEntry(ch.entityId),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (ch.title != null)
                                Text(ch.title!, style: t.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                ch.text,
                                locale: const Locale('en'),
                                style: t.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: FeSpace.xs,
                                children: [
                                  for (final id in ch.sourceIds)
                                    InkWell(
                                      key: Key('ai.chunk.source.$id'),
                                      onTap: () =>
                                          context.push(Routes.source(id)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          id,
                                          style: t.bodySmall?.copyWith(
                                            color: c.accent,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: c.textSecondary),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }
}

/// Javob tuzilmasi namoyishi. Matnlar — namuna (ARB’dan), ilmiy emas.
class _AnswerPreview extends StatelessWidget {
  const _AnswerPreview();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;

    final sources = [
      (1, AiEvidenceTier.internalVerified),
      (2, AiEvidenceTier.internalReviewed),
      (3, AiEvidenceTier.externalUnverified),
    ];

    return DecoratedBox(
      key: const Key('ai.answerPreview'),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(FeRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FeBanner(
              key: const Key('ai.demoLabel'),
              icon: Icons.science_outlined,
              text: l.aiPreviewNotice,
              tone: FeBannerTone.warning,
            ),
            _AnswerSection(
              title: l.aiSectionAvailable,
              text: l.aiSampleInternal,
              citations: const [1, 2],
            ),
            _AnswerSection(
              title: l.aiSectionConsiderations,
              text: l.aiSampleExternal,
              citations: const [3],
            ),
            _AnswerSection(
              title: l.aiSectionLimitations,
              text: l.aiSampleLimitation,
              citations: const [],
            ),
            // Javob tuzilmasi — dalil holati, yurisdiksiya va
            // bog‘liq yozuvlar. Citation metama’lumotlariga server/ilova
            // egalik qiladi, model emas.
            _AnswerSection(
              title: l.aiSectionEvidenceStatus,
              text: l.aiSampleEvidenceStatus,
              citations: const [],
            ),
            _AnswerSection(
              title: l.aiSectionJurisdiction,
              text: l.aiSampleJurisdiction,
              citations: const [],
            ),
            _AnswerSection(
              title: l.aiSectionRelated,
              text: l.aiSampleRelated,
              citations: const [],
            ),
            FeSectionHeader(l.sourcesButton),
            for (final (n, tier) in sources)
              Padding(
                padding: const EdgeInsets.only(bottom: FeSpace.xs),
                child: _SourceRow(number: n, tier: tier),
              ),
            const Divider(),
            const SizedBox(height: FeSpace.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gavel_outlined, size: 18, color: c.textSecondary),
                const SizedBox(width: FeSpace.xs),
                Expanded(
                  child: Text(
                    l.aiExpertJudgment,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FeSpace.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('ai.report'),
                icon: const Icon(Icons.flag_outlined),
                label: Text(l.aiReport),
                onPressed: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerSection extends StatelessWidget {
  const _AnswerSection({
    required this.title,
    required this.text,
    required this.citations,
  });

  final String title;
  final String text;
  final List<int> citations;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeSectionHeader(title),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: FeSpace.xxs,
          runSpacing: FeSpace.xxs,
          children: [
            Text(text, style: t.bodyMedium),
            for (final n in citations) _CitationMarker(number: n),
          ],
        ),
      ],
    );
  }
}

/// Inline citation: raqamli marker; dalil darajasi ranggi + ikonkasi bilan.
class _CitationMarker extends StatelessWidget {
  const _CitationMarker({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Semantics(
      label: l.aiCitationSemantics(number),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.accentContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Text(
            '$number',
            style: FeThemeBuilder.numeric(
              Theme.of(context).textTheme.labelSmall!,
            ).copyWith(color: c.onAccentContainer, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.number, required this.tier});

  final int number;
  final AiEvidenceTier tier;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final (label, color, icon) = switch (tier) {
      AiEvidenceTier.internalVerified => (
        l.aiEvidenceInternalVerified,
        c.verified,
        Icons.verified_outlined,
      ),
      AiEvidenceTier.internalReviewed => (
        l.aiEvidenceInternalReviewed,
        c.reviewed,
        Icons.fact_check_outlined,
      ),
      AiEvidenceTier.externalUnverified => (
        l.aiEvidenceExternal,
        c.warning,
        Icons.public,
      ),
    };
    final external = tier == AiEvidenceTier.externalUnverified;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FeRadius.sm),
        border: Border.all(
          color: external ? c.warning : c.border,
          width: external ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CitationMarker(number: number),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.aiPlaceholderSource(number), style: t.bodyMedium),
                  const SizedBox(height: FeSpace.xxs),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xxs,
                    children: [
                      StatusChip(icon: icon, label: label, color: color),
                      const TestDataBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ekran yuqorisidagi holat: AI ulanmagan, bu interfeys namoyishi.
/// Forensic AI sarlavhasi: navy panel, holat, ilmiy kontekst.
class _AiHeader extends ConsumerWidget {
  const _AiHeader({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final jid = ref.watch(
      settingsControllerProvider.select((s) => s.jurisdictionId),
    );
    final jname =
        ref.watch(jurisdictionResolverProvider).byId(jid)?.name(lang) ?? jid;
    const muted = Color(0xFFC9D2E0);
    Widget chip(IconData icon, String text) => DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: muted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: t.labelSmall?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
    return DecoratedBox(
      key: const Key('ai.header'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1E3D), Color(0xFF123A4A)],
        ),
        borderRadius: BorderRadius.circular(FeRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x264CC9D6),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.auto_awesome_outlined,
                      color: Color(0xFF7FDDE6),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: FeSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          l.moduleAi,
                          style: t.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: available
                              ? const Color(0x336ED3A0)
                              : const Color(0x33F2C14E),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          child: Text(
                            available ? l.aiStatusConnected : l.aiStatusPreview,
                            key: const Key('ai.headerStatus'),
                            style: t.labelSmall?.copyWith(
                              color: available
                                  ? const Color(0xFF9FE6C1)
                                  : const Color(0xFFFFE3A3),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: FeSpace.sm),
            Text(
              l.aiHeroSubtitle,
              style: t.bodySmall?.copyWith(color: muted, height: 1.45),
            ),
            const SizedBox(height: FeSpace.sm),
            Wrap(
              spacing: FeSpace.xs,
              runSpacing: FeSpace.xs,
              children: [
                chip(Icons.public, l.homeJurisdictionChip(jname)),
                chip(Icons.dataset_outlined, l.aiContextSources),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStateCard extends StatelessWidget {
  const _PreviewStateCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('ai.previewState'),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.aiNotConnectedTitle, style: t.titleSmall),
            const SizedBox(height: FeSpace.xxs),
            for (final p in [
              l.aiPreviewPoint1,
              l.aiPreviewPoint2,
              l.aiPreviewPoint3,
              l.aiPreviewPoint4,
            ])
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${FeGlyphs.bullet} $p',
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
