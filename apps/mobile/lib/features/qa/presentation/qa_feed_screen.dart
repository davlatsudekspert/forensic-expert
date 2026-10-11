import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/account.dart';
import '../../../app/qa.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/qa/qa_models.dart';
import '../qa_strings.dart';
import 'qa_widgets.dart';

/// «Savol-javob (Hamjamiyat)»: savollar ro‘yxati, mavzu bo‘yicha filtr va
/// qidiruv. O‘qish hammaga (kirgan foydalanuvchiga) ochiq va bepul.
class QaFeedScreen extends ConsumerStatefulWidget {
  const QaFeedScreen({super.key});

  @override
  ConsumerState<QaFeedScreen> createState() => _QaFeedScreenState();
}

class _QaFeedScreenState extends ConsumerState<QaFeedScreen> {
  String? _tag;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final me = ref.watch(qaMeProvider).value;
    final isAdmin = ref.watch(serverAccessProvider).value?.isAdmin ?? false;
    final request = (tag: _tag, query: _query.isEmpty ? null : _query);
    final feed = ref.watch(qaFeedProvider(request));
    return QaGate(
      title: l.qaTitle,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.qaTitle),
          actions: [
            IconButton(
              key: const Key('qa.mine'),
              tooltip: l.qaOpenMine,
              icon: const Icon(Icons.folder_shared_outlined),
              onPressed: () => context.push(Routes.qaMine),
            ),
            if (isAdmin)
              IconButton(
                key: const Key('qa.moderation'),
                tooltip: l.qaOpenModeration,
                icon: const Icon(Icons.gavel_outlined),
                onPressed: () => context.push(Routes.qaModeration),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('qa.ask'),
          onPressed: () => context.push(Routes.qaAsk),
          icon: const Icon(Icons.help_outline),
          label: Text(l.qaAsk),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(qaFeedProvider(request).future),
            child: ListView(
              key: const Key('qa.list'),
              children: [
                FeContentFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: FeSpace.sm),
                      Text(
                        l.qaIntro,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FeTheme.of(context).textSecondary,
                        ),
                      ),
                      const SizedBox(height: FeSpace.xs),
                      const QaNotice(),
                      const SizedBox(height: FeSpace.sm),
                      if (me != null && !me.profile.isVerified)
                        _VerifyPrompt(me: me),
                      _SearchField(
                        onChanged: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: FeSpace.xs),
                      _TagFilter(
                        tags: me?.tags ?? const [],
                        selected: _tag,
                        onSelected: (t) => setState(() => _tag = t),
                      ),
                      const SizedBox(height: FeSpace.sm),
                      ..._content(context, l, feed),
                      const SizedBox(height: FeSpace.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    AppLocalizations l,
    AsyncValue<QaFeed?> feed,
  ) => switch (feed) {
    AsyncData(value: final f?) when f.items.isNotEmpty => [
      for (final q in f.items) ...[
        QaQuestionCard(q),
        const SizedBox(height: FeSpace.xs),
      ],
    ],
    AsyncData(value: final f?) when f.items.isEmpty => [
      FeEmptyState(
        key: const Key('qa.empty'),
        icon: Icons.forum_outlined,
        body: l.qaEmpty,
      ),
    ],
    AsyncData() || AsyncError() => [
      FeEmptyState(
        key: const Key('qa.loadFailed'),
        icon: Icons.cloud_off_outlined,
        body: l.qaLoadFailed,
      ),
    ],
    _ => const [
      Padding(
        padding: EdgeInsets.symmetric(vertical: FeSpace.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
    ],
  };
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    key: const Key('qa.search'),
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      labelText: AppLocalizations.of(context).qaSearchHint,
    ),
  );
}

class _TagFilter extends StatelessWidget {
  const _TagFilter({
    required this.tags,
    required this.selected,
    required this.onSelected,
  });

  final List<String> tags;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: FeSpace.xs,
      runSpacing: FeSpace.xxs,
      children: [
        ChoiceChip(
          key: const Key('qa.tag.all'),
          label: Text(l.qaAllTopics),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final tag in tags)
          ChoiceChip(
            key: Key('qa.tag.$tag'),
            label: Text(l.qaTag(tag)),
            selected: selected == tag,
            onSelected: (_) => onSelected(tag),
          ),
      ],
    );
  }
}

/// Tasdiqdan o‘tmaganlarga taklif — javob yozish uchun kerak.
class _VerifyPrompt extends StatelessWidget {
  const _VerifyPrompt({required this.me});

  final QaMe me;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeCard(
        key: const Key('qa.verifyPrompt'),
        onTap: () => context.push(Routes.qaVerify),
        child: Row(
          children: [
            const Icon(Icons.verified_outlined),
            const SizedBox(width: FeSpace.sm),
            Expanded(child: Text(l.qaOnlyVerifiedMayAnswer)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/// Ro‘yxatdagi savol kartasi.
class QaQuestionCard extends StatelessWidget {
  const QaQuestionCard(this.question, {super.key});

  final QaQuestionSummary question;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('qa.card.${question.id}'),
      onTap: () => context.push(Routes.qaQuestion(question.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: FeSpace.xxs,
            runSpacing: FeSpace.xxs,
            children: [
              if (question.pinned)
                StatusChip(
                  icon: Icons.push_pin_outlined,
                  label: l.qaPinned,
                  color: c.accent,
                ),
              if (question.hasAccepted)
                StatusChip(
                  icon: Icons.verified_outlined,
                  label: l.qaAcceptedAnswer,
                  color: c.verified,
                ),
            ],
          ),
          if (question.pinned || question.hasAccepted)
            const SizedBox(height: FeSpace.xxs),
          Text(question.title, style: t.titleSmall),
          const SizedBox(height: FeSpace.xxs),
          Text(
            question.excerpt,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xs),
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              QaAuthorBadge(question.authorRole),
              Text(
                l.qaAnswersCount(question.answerCount),
                style: t.labelSmall?.copyWith(color: c.textSecondary),
              ),
              if (question.createdAt case final date?)
                Text(
                  feDate(context, date),
                  style: t.labelSmall?.copyWith(color: c.textSecondary),
                ),
              for (final tag in question.tags)
                Text(
                  '#${l.qaTag(tag)}',
                  style: t.labelSmall?.copyWith(color: c.accent),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
