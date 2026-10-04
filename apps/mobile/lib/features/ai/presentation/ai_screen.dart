import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ai/ai_architecture.dart';
import '../../../domain/ports/ai_ports.dart';

/// Forensic AI — PHASE 2: to‘liq UI/UX prototipi, **real AI ulanmagan**.
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
  bool _searching = false;

  Future<void> _findSources(String lang) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _searching = true);
    final r = await ref
        .read(aiRouterProvider(lang))
        .route(
          AiQuestion(text: text, languageCode: lang),
          experience: _experience,
          entitlement: await ref.read(aiEntitlementServiceProvider).current(),
        );
    if (!mounted) return;
    setState(() {
      _result = r;
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
                        // Real AI ulanmagan; PII topilsa ham yuborilmaydi.
                        onPressed: available && kinds.isEmpty ? () {} : null,
                      ),
                    ],
                  ),
                  if (_result case final r?) _RouteResultView(result: r),
                  if (!available) ...[
                    const SizedBox(height: FeSpace.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.cloud_off_outlined, color: c.textSecondary),
                        const SizedBox(width: FeSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  l.aiNotConnectedTitle,
                                  style: t.titleSmall,
                                ),
                              ),
                              const SizedBox(height: FeSpace.xxs),
                              Text(
                                l.aiNotConnectedBody,
                                style: t.bodySmall?.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  FeSectionHeader(l.aiPreviewTitle),
                  const _AnswerPreview(),
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
                },
              ),
            )
        else if (result.chunks.isEmpty)
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
              child: FeCard(
                key: Key('ai.chunk.${ch.chunkId}'),
                padding: const EdgeInsets.all(FeSpace.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ch.title != null) Text(ch.title!, style: t.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      ch.text,
                      locale: const Locale('en'),
                      style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ch.sourceIds.join(', '),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Javob tuzilmasi namunasi. Matnlar — placeholder (ARB’dan), ilmiy emas.
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
            FeBanner(icon: Icons.science_outlined, text: l.aiPreviewNotice),
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
