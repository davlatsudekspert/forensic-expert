import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ai/ai_architecture.dart';
import '../../../domain/ai/rag_pipeline.dart';
import '../../../domain/ports/ai_ports.dart';
import '../../evidence/presentation/localized_content.dart';
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
  RagAnswer? _rag;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    // Talaba rejimida standart uslub — «Tushuntirib bering».
    if (ref.read(settingsControllerProvider).userMode == UserMode.student) {
      _experience = AiExperience.tutor;
    }
  }

  /// Bitta savol — bitta quvur, ko‘pi bilan bitta server so‘rovi.
  /// [offlineOnly] — tarmoqqa umuman chiqmaydi (faqat qurilmadagi qidiruv).
  Future<void> _submit(String lang, {required bool offlineOnly}) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _searching) return;
    setState(() {
      _searching = true;
      _rag = null;
    });
    try {
      final base = ref.read(ragPipelineProvider(lang));
      final pipeline = offlineOnly
          ? RagPipeline(
              safety: base.safety,
              retrieve: base.retrieve,
              provider: const UnconfiguredAiProvider(),
              knownSourceIds: base.knownSourceIds,
            )
          : base;
      final rag = await pipeline.ask(
        AiQuestion(
          text: text,
          languageCode: lang,
          jurisdictionId: ref.read(settingsControllerProvider).jurisdictionId,
        ),
        experience: _experience,
        entitlement: await ref.read(aiEntitlementServiceProvider).current(),
      );
      if (mounted) setState(() => _rag = rag);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
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
    final needsSignIn = ai.availability == AiAvailability.signInRequired;
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
                  _AiHeader(available: available, needsSignIn: needsSignIn),
                  FeSectionHeader(l.aiAskTitle),
                  // Avval savol maydoni; PII ogohlantirishi doim uning ostida
                  // (ixcham yordamchi matn).
                  TextField(
                    key: const Key('ai.input'),
                    controller: _controller,
                    minLines: 2,
                    maxLines: 5,
                    onChanged: (v) => setState(() => _pii = scanner.scan(v)),
                    decoration: InputDecoration(hintText: l.aiInputHint),
                  ),
                  const SizedBox(height: FeSpace.xxs),
                  Row(
                    key: const Key('ai.piiWarning'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.privacy_tip_outlined,
                          size: 16,
                          color: c.warning,
                        ),
                      ),
                      const SizedBox(width: FeSpace.xs),
                      Expanded(
                        child: Text(
                          l.aiPiiWarning,
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FeSpace.sm),
                  SegmentedButton<AiExperience>(
                    key: const Key('ai.experience'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: AiExperience.professional,
                        label: Text(l.aiExperienceProfessional),
                      ),
                      ButtonSegment(
                        value: AiExperience.tutor,
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
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xs,
                    children: [
                      // Ikkilamchi amal — matnli tugma; asosiy — «Yuborish».
                      TextButton.icon(
                        key: const Key('ai.findSources'),
                        icon: const Icon(Icons.travel_explore_outlined),
                        label: Text(l.aiFindSources),
                        onPressed: _searching || kinds.isNotEmpty
                            ? null
                            : () => _submit(
                                Localizations.localeOf(context).languageCode,
                                offlineOnly: true,
                              ),
                      ),
                      FilledButton.icon(
                        key: const Key('ai.send'),
                        icon: const Icon(Icons.send_outlined),
                        label: Text(l.aiSend),
                        // Server AI (Gemini) — faqat ulanganda; PII topilsa
                        // yuborilmaydi. Javob manbalar bilan tekshiriladi.
                        onPressed: available && kinds.isEmpty && !_searching
                            ? () => _submit(
                                Localizations.localeOf(context).languageCode,
                                offlineOnly: false,
                              )
                            : null,
                      ),
                    ],
                  ),
                  if (!available)
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xxs),
                      child: Text(
                        needsSignIn ? l.aiSendSignIn : l.aiSendUnavailable,
                        key: const Key('ai.sendUnavailable'),
                        textAlign: TextAlign.end,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                  // Holat kartasi — savol maydonidan keyin (avval kiritish).
                  if (ai.availability == AiAvailability.signInRequired) ...[
                    const SizedBox(height: FeSpace.sm),
                    const _SignInRequiredCard(),
                  ] else if (!available) ...[
                    const SizedBox(height: FeSpace.sm),
                    const _PreviewStateCard(),
                  ],
                  if (_searching)
                    Padding(
                      key: const Key('ai.progress'),
                      padding: const EdgeInsets.only(top: FeSpace.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LinearProgressIndicator(),
                          const SizedBox(height: FeSpace.xs),
                          Text(
                            available ? l.aiWorking : l.aiSearchingOffline,
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_rag case final a?) ...[
                    _AiResultView(answer: a),
                    if (a.evidence.isNotEmpty) RagSectionsView(answer: a),
                  ],
                  if (!available && !needsSignIn) ...[
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

/// Natija: avval AI javobi yoki uning yo‘qligi sababi, keyin alohida —
/// oflayn bazadan topilgan manbalar. Oflayn natija hech qachon AI javobi
/// sifatida ko‘rsatilmaydi.
class _AiResultView extends StatelessWidget {
  const _AiResultView({required this.answer});

  final RagAnswer answer;

  String? _failure(AppLocalizations l) => switch (answer.failureCode) {
    null => null,
    'too_many_requests' || '429' => l.aiErrRateLimited,
    'unauthorized' || 'not_signed_in' || '401' => l.aiErrSignIn,
    'offline' => l.aiErrOffline,
    'not_configured' || '503' => l.aiErrNotConfigured,
    _ => l.aiErrServer,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final blocks = answer.safety?.blocks ?? const <SafetyBlock>{};
    final chunks = [for (final e in answer.evidence) e.chunk];
    final failure = _failure(l);
    final answered = answer.outcome == RagOutcome.answered;

    Widget sources({required bool collapsed}) {
      final list = [
        for (final ch in chunks)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: _ChunkCard(chunk: ch),
          ),
      ];
      if (collapsed) {
        return ExpansionTile(
          key: const Key('ai.sources.collapsed'),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(l.aiOfflineSourcesCount(chunks.length)),
          children: list,
        );
      }
      return Column(
        key: const Key('ai.sources.offline'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeSectionHeader(l.aiOfflineSourcesTitle),
          FeBanner(icon: Icons.info_outline, text: l.aiRetrievalNote),
          const SizedBox(height: FeSpace.xs),
          ...list,
        ],
      );
    }

    return Column(
      key: Key('ai.result.${answer.outcome.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FeSpace.sm),
        switch (answer.outcome) {
          RagOutcome.blocked => Column(
            children: [
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
                ),
            ],
          ),
          RagOutcome.jurisdictionRequired => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
            ],
          ),
          RagOutcome.noReliableContext => FeEmptyState(
            key: const Key('ai.noContext'),
            icon: Icons.search_off,
            body: l.aiNoContext,
            compact: true,
          ),
          RagOutcome.answered => Column(
            key: const Key('ai.answer'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FeSectionHeader(l.aiRagAnswer),
              SelectableText(
                answer.text ?? '',
                style: t.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          RagOutcome.notCovered => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FeBanner(
                key: const Key('ai.notCovered'),
                icon: Icons.help_outline,
                tone: FeBannerTone.warning,
                text: l.aiNotCovered,
              ),
            ],
          ),
          RagOutcome.quotaUnavailable => FeBanner(
            key: const Key('ai.quota'),
            icon: Icons.hourglass_empty,
            tone: FeBannerTone.warning,
            text: l.aiQuotaUsed,
          ),
          RagOutcome.rejectedCitation ||
          RagOutcome.rejectedIdentifier ||
          RagOutcome.rejectedSafety => FeBanner(
            key: const Key('ai.rejected'),
            icon: Icons.gpp_maybe_outlined,
            tone: FeBannerTone.warning,
            text: l.aiAnswerRejected,
          ),
          RagOutcome.retrievalOnly =>
            failure == null
                ? const SizedBox.shrink()
                : FeBanner(
                    key: Key('ai.failure.${answer.failureCode}'),
                    icon: Icons.cloud_off_outlined,
                    tone: FeBannerTone.warning,
                    text: failure,
                  ),
        },
        if (chunks.isNotEmpty) sources(collapsed: answered),
      ],
    );
  }
}

/// Oflayn bazadagi bitta bo‘lak: sarlavha, asl iqtibos va manbalar.
class _ChunkCard extends StatelessWidget {
  const _ChunkCard({required this.chunk});

  final RetrievedChunk chunk;

  @override
  Widget build(BuildContext context) {
    final ch = chunk;
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Consumer(
      builder: (context, ref, _) {
        // Kartani bosish — to‘liq yozuv; SRC — manba sahifasi.
        final isLibrary =
            ref.watch(libraryRepositoryProvider).byId(ch.entityId) != null;
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
                    if (ch.title != null) Text(ch.title!, style: t.titleSmall),
                    const SizedBox(height: 2),
                    // Manba parchasi: UI tilidagi tarjima (claim ID bo‘yicha)
                    // birinchi, asl matn «Asl matn» ostida.
                    LocalizedContentText(
                      kind: ContentTextKind.claimExcerpt,
                      id: ch.chunkId,
                      source: ch.text,
                      quote: true,
                      style: t.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: FeSpace.xs,
                      children: [
                        for (final id in ch.sourceIds)
                          InkWell(
                            key: Key('ai.chunk.source.$id'),
                            onTap: () => context.push(Routes.source(id)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                id,
                                style: t.bodySmall?.copyWith(
                                  color: c.accent,
                                  decoration: TextDecoration.underline,
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
  const _AiHeader({required this.available, this.needsSignIn = false});

  final bool available;
  final bool needsSignIn;

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
                            available
                                ? l.aiStatusConnected
                                : needsSignIn
                                ? l.aiStatusSignIn
                                : l.aiStatusPreview,
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

/// Server AI ulangan, foydalanuvchi esa hisobga kirmagan: «ulanmagan» emas,
/// «hisobga kiring» deyiladi (BACKLOG 4).
class _SignInRequiredCard extends StatelessWidget {
  const _SignInRequiredCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('ai.signInRequired'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.aiSignInTitle, style: t.titleSmall),
          const SizedBox(height: FeSpace.xxs),
          Text(
            l.aiSignInBody,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xs),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: const Key('ai.signIn'),
              onPressed: () => context.push(Routes.accountEmailCode),
              icon: const Icon(Icons.login),
              label: Text(l.accountSignInEmailCode),
            ),
          ),
        ],
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
            // Osilgan chekinish: belgi alohida, matn o‘z ustunida o‘raladi.
            for (final p in [
              l.aiPreviewPoint1,
              l.aiPreviewPoint2,
              l.aiPreviewPoint3,
              l.aiPreviewPoint4,
            ])
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        FeGlyphs.bullet,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                    const SizedBox(width: FeSpace.xs),
                    Expanded(
                      child: Text(
                        p,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
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
