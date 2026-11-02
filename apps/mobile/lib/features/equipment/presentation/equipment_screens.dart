import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/equipment.dart';
import '../../../app/guidelines.dart' show guidelinesProvider;
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/fe_localizations_delegate.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/equipment/equipment.dart';
import '../../../domain/guidelines/guideline_models.dart';
import 'equipment_diagrams.dart';

/// «Asbob-uskunalar»: Laboratoriya / Morg bo‘limlari, illyustratsiyali
/// kartalar. Boshlang‘ich bo‘lim — chaqiruvchi (ish stoli) ko‘rinishidan.
class EquipmentHubScreen extends ConsumerStatefulWidget {
  const EquipmentHubScreen({super.key, this.initial = EquipmentGroup.lab});

  final EquipmentGroup initial;

  @override
  ConsumerState<EquipmentHubScreen> createState() => _EquipmentHubState();
}

class _EquipmentHubState extends ConsumerState<EquipmentHubScreen> {
  late EquipmentGroup _group = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(equipmentProvider).value ?? EquipmentBundle.empty;
    final items = bundle.of(_group);
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.equipTitle)),
      body: ListView(
        key: const Key('equipment.hub'),
        padding: EdgeInsets.only(
          bottom: FeSpace.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
                Text(
                  l.equipIntro,
                  style: t.bodyMedium?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: FeSpace.sm),
                SegmentedButton<EquipmentGroup>(
                  key: const Key('equipment.group'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: EquipmentGroup.lab,
                      icon: const Icon(Icons.science_outlined, size: 18),
                      label: Text(
                        l.equipGroupLab,
                        key: const Key('equipment.group.lab'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ButtonSegment(
                      value: EquipmentGroup.morgue,
                      icon: const Icon(
                        Icons.medical_services_outlined,
                        size: 18,
                      ),
                      label: Text(
                        l.equipGroupMorgue,
                        key: const Key('equipment.group.morgue'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  selected: {_group},
                  onSelectionChanged: (s) => setState(() => _group = s.first),
                ),
                const SizedBox(height: FeSpace.md),
                if (items.isEmpty)
                  FeBanner(icon: Icons.info_outline, text: l.equipEmpty)
                else
                  GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: FeSpace.sm,
                    crossAxisSpacing: FeSpace.sm,
                    childAspectRatio: 0.78,
                    children: [for (final i in items) _EquipmentTile(item: i)],
                  ),
                const SizedBox(height: FeSpace.md),
                _IllustrationNote(text: l.equipIllustrationNote),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({required this.item});

  final EquipmentItem item;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final (title, subtitle) = tileTitle(_u(item.name));
    return FeCard(
      key: Key('equipment.tile.${item.id}'),
      padding: EdgeInsets.zero,
      semanticLabel: item.name,
      onTap: () => context.push(Routes.equipmentItem(item.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Illustration(item: item, radius: FeRadius.md),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FeSpace.sm,
              FeSpace.xs,
              FeSpace.sm,
              FeSpace.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: subtitle == null ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: c.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(
                      height: 1.25,
                      color: c.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Illyustratsiya: rasm krem fonda chizilgan — qorong‘i rejimda ham shu krem
/// «plashka» ichida turadi (rasm buzilmaydi).
class _Illustration extends StatelessWidget {
  const _Illustration({required this.item, required this.radius});

  final EquipmentItem item;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      child: ColoredBox(
        color: const Color(0xFFF4EFE6),
        child: Image.asset(
          item.image,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) =>
              const Center(child: Icon(Icons.image_not_supported_outlined)),
        ),
      ),
    );
  }
}

class _IllustrationNote extends StatelessWidget {
  const _IllustrationNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.brush_outlined, size: 16, color: c.textSecondary),
        const SizedBox(width: FeSpace.xs),
        Expanded(
          child: Text(
            text,
            key: const Key('equipment.illustrationNote'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

class EquipmentDetailScreen extends ConsumerWidget {
  const EquipmentDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final async = ref.watch(equipmentProvider);
    final item = async.value?.byId(id);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.equipTitle)),
        body: async.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(l.equipEmpty)),
      );
    }
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final guides = ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty;
    final related = <(IconData, String, String)>[
      for (final m in item.methods)
        if (knowledge.byId(m) case final e?)
          (
            Icons.rule_folder_outlined,
            e.name.resolve(lang),
            Routes.knowledgeEntry(m),
          ),
      for (final g in item.guides)
        if (guides.cards.where((x) => x.id == g).firstOrNull case final card?)
          (Icons.assignment_outlined, card.title.of(lang), Routes.guideline(g)),
      for (final d in item.lessons)
        (Icons.slideshow_rounded, l.equipLesson, Routes.lesson(d)),
    ];
    Widget bullets(List<String> xs) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final x in xs)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: FeSpace.sm),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: c.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(child: Text(x, style: t.bodyMedium)),
              ],
            ),
          ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(_u(item.name))),
      body: ListView(
        key: Key('equipment.detail.${item.id}'),
        padding: EdgeInsets.only(
          bottom: FeSpace.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(FeRadius.lg),
                        child: ColoredBox(
                          color: const Color(0xFFF4EFE6),
                          child: Image.asset(
                            item.image,
                            fit: BoxFit.cover,
                            semanticLabel: item.name,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(Icons.image_not_supported_outlined),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FeSpace.xs),
                _IllustrationNote(text: l.equipIllustrationNote),
                if (lang != 'uz') ...[
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    key: const Key('equipment.translationPending'),
                    icon: Icons.translate,
                    text: l.trPendingTranslation,
                  ),
                ],
                FeSectionHeader(l.equipWhat),
                Text(_u(item.what), style: t.bodyLarge),
                if (item.use.isNotEmpty) ...[
                  FeSectionHeader(l.equipUse),
                  bullets(item.use.map(_u).toList()),
                ],
                if (item.steps.isNotEmpty) ...[
                  FeSectionHeader(l.equipSteps),
                  for (final (i, x) in item.steps.map(_u).indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: FeSpace.sm),
                            decoration: BoxDecoration(
                              color: c.accentContainer,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.accentBorder),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: t.labelMedium?.copyWith(
                                color: c.onAccentContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(child: Text(x, style: t.bodyMedium)),
                        ],
                      ),
                    ),
                ],
                if (item.gallery.isNotEmpty) ...[
                  const SizedBox(height: FeSpace.sm),
                  SizedBox(
                    height: 340,
                    child: ListView.separated(
                      key: const Key('equipment.gallery'),
                      scrollDirection: Axis.horizontal,
                      itemCount: item.gallery.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: FeSpace.sm),
                      itemBuilder: (context, i) {
                        final g = item.gallery[i];
                        return SizedBox(
                          width: 290,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                key: Key('equipment.gallery.$i'),
                                onTap: () =>
                                    _openFull(context, g.image, g.caption),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    FeRadius.md,
                                  ),
                                  child: ColoredBox(
                                    color: const Color(0xFFF4EFE6),
                                    child: Image.asset(
                                      g.image,
                                      width: 290,
                                      height: 290,
                                      fit: BoxFit.cover,
                                      semanticLabel: g.caption,
                                      errorBuilder: (_, _, _) =>
                                          const SizedBox.square(dimension: 290),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _u(g.caption),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: t.bodySmall?.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                ?EquipmentDiagrams.forItem(item.id),
                if (item.findings.isNotEmpty) ...[
                  FeSectionHeader(l.equipFindings),
                  bullets(item.findings.map(_u).toList()),
                ],
                if (item.care.isNotEmpty) ...[
                  FeSectionHeader(l.equipCare),
                  bullets(item.care.map(_u).toList()),
                ],
                if (item.national.isNotEmpty) ...[
                  const SizedBox(height: FeSpace.md),
                  FeBanner(
                    key: const Key('equipment.national'),
                    icon: Icons.flag_outlined,
                    text: _u(item.national),
                  ),
                ],
                if (related.isNotEmpty) ...[
                  FeSectionHeader(l.equipRelated),
                  FeCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final (i, (icon, title, route))
                            in related.indexed) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              indent: FeSpace.md + 24 + FeSpace.sm,
                              color: c.border.withValues(alpha: 0.6),
                            ),
                          ListTile(
                            key: Key('equipment.related.$i'),
                            leading: Icon(icon, color: c.accent),
                            title: Text(title),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: c.textSecondary,
                            ),
                            onTap: () => context.push(route),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                FeSectionHeader(l.equipSources),
                for (final s in item.sources)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FeSpace.xs),
                    child: Text(
                      '${_dot(s.author)} ${_dot(s.title)} ${s.page}'
                      '${s.doi.isEmpty ? '' : ' · DOI ${s.doi}'}',
                      key: const Key('equipment.source'),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// «Muallif.» ikki marta nuqta bo‘lmasin.
String _dot(String x) => x.endsWith('.') ? x : '$x.';

/// Kartochka sarlavhasi: qavs ichidagi qisqa nom (GC-MS, UV-Vis, alkotester)
/// sarlavha bo‘ladi, to‘liq nom — ostida; aks holda to‘liq nom.
(String, String?) tileTitle(String name) {
  final m = RegExp(r'^(.*?)\s*\(([^()]{1,12})\)\s*$').firstMatch(name);
  if (m == null) return (name, null);
  final short = m.group(2)!.trim();
  final rest = m.group(1)!.trim();
  final title = short[0].toUpperCase() + short.substring(1);
  return (title, rest.isEmpty ? null : rest);
}

/// Rasmni to‘liq ekranda ochish (kattalashtirish — barmoq bilan).
void _openFull(BuildContext context, String image, String caption) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        backgroundColor: const Color(0xFFF4EFE6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4EFE6),
          foregroundColor: const Color(0xFF0B1B2B),
          title: Text(
            caption,
            maxLines: 2,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            maxScale: 4,
            child: Image.asset(image, semanticLabel: caption),
          ),
        ),
      ),
    ),
  );
}

/// Kontent matni (asli o‘zbekcha) — yangi alifbo yoqilgan bo‘lsa o‘giriladi.
String _u(String s) => uzDisplay('uz', s);
