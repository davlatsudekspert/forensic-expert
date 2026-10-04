import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/fe_data_components.dart';
import '../../../domain/evidence/evidence_models.dart';
import '../evidence_strings.dart';

/// Rasm turi belgisi: sxema / real nashr rasmi / hisoblangan struktura.
class ImageKindBadge extends StatelessWidget {
  const ImageKindBadge({super.key, required this.meta});

  final ImageMeta meta;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final (icon, label) = meta.kind == ImageKind.chemicalStructure
        ? (Icons.hub_outlined, l.imageDepiction)
        : meta.isOriginalDiagram
        ? (Icons.schema_outlined, l.imageSchematic)
        : (Icons.article_outlined, l.imageRealData);
    return StatusChip(icon: icon, label: label, color: c.textSecondary);
  }
}

/// Rasm (baytlar bazadan lazily). Struktura va sxemalar oq «namuna
/// kartochkasi» ustida — light/dark ikkala rejimda o‘qiladi.
class ScientificImageView extends ConsumerWidget {
  const ScientificImageView({
    super.key,
    required this.meta,
    this.fit = BoxFit.contain,
    this.height,
  });

  final ImageMeta meta;
  final BoxFit fit;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final bytes = ref.watch(imageBytesProvider(meta.id));
    final child = bytes.when(
      data: (b) => b == null
          ? _Fallback(text: l.imageUnavailable)
          : Image.memory(
              b,
              fit: fit,
              gaplessPlayback: true,
              semanticLabel: meta.alt.resolve(lang),
              errorBuilder: (_, _, _) => _Fallback(text: l.imageUnavailable),
            ),
      loading: () => FeSkeleton(lines: 4, semanticLabel: l.homeDbLoading),
      error: (_, _) => _Fallback(text: l.imageUnavailable),
    );
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        // Oq panel — chizma/struktura uchun (dark rejimda ham).
        color: Colors.white,
        borderRadius: BorderRadius.circular(FeRadius.md),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(FeSpace.xs),
      child: child,
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: const Color(0xFF5B6B73)),
    ),
  );
}

/// Galereya kartochkasi: rasm + sarlavha + tur + qisqa atribusiya.
class ScientificImageCard extends StatelessWidget {
  const ScientificImageCard({super.key, required this.meta});

  final ImageMeta meta;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: Semantics(
        button: true,
        label: l.imageOpen(meta.title.resolve(lang)),
        child: InkWell(
          key: Key('image.${meta.id}'),
          borderRadius: BorderRadius.circular(FeRadius.md),
          onTap: () => context.push(Routes.image(meta.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScientificImageView(meta: meta, height: 200),
              const SizedBox(height: FeSpace.xxs),
              Text(meta.title.resolve(lang), style: t.titleSmall),
              const SizedBox(height: 2),
              Wrap(
                spacing: FeSpace.xs,
                runSpacing: FeSpace.xxs,
                children: [
                  ImageKindBadge(meta: meta),
                  StatusChip(
                    icon: Icons.copyright_outlined,
                    label: l.imageLicense(l.licenseName(meta.license)),
                    color: c.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                meta.attribution,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yozuvga tegishli rasmlar galereyasi (bo‘lsa).
class ScientificImageGallery extends ConsumerWidget {
  const ScientificImageGallery({
    super.key,
    required this.entityId,
    this.exclude = const {},
  });

  final String entityId;
  final Set<ImageKind> exclude;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final images = [
      for (final m in ref.watch(evidenceDataProvider).imagesFor(entityId))
        if (!exclude.contains(m.kind)) m,
    ];
    if (images.isEmpty) return const SizedBox.shrink();
    return Column(
      key: Key('gallery.$entityId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.imagesHeading),
        for (final m in images) ScientificImageCard(meta: m),
      ],
    );
  }
}

/// To‘liq ekran: kattalashtirish + barcha litsenziya/atribusiya metadatasi.
class ImageViewerScreen extends ConsumerWidget {
  const ImageViewerScreen({super.key, required this.imageId});

  final String imageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final meta = [
      for (final m in ref.watch(evidenceDataProvider).images)
        if (m.id == imageId) m,
    ].firstOrNull;
    if (meta == null) {
      return Scaffold(
        appBar: AppBar(),
        body: FeEmptyState(
          icon: Icons.image_not_supported_outlined,
          body: l.imageUnavailable,
        ),
      );
    }
    String date(DateTime d) => feDate(context, d);
    final rows = <(String, String)>[
      (l.imageAttribution, meta.attribution),
      if (meta.creator != null) (l.metaCreator, meta.creator!),
      if (meta.sourceName != null) (l.metaSource, meta.sourceName!),
      if (meta.doi != null) ('DOI', meta.doi!),
      if (meta.accessedDate != null) (l.metaAccessed, date(meta.accessedDate!)),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(meta.title.resolve(lang))),
      body: SafeArea(
        child: ListView(
          key: Key('imageViewer.${meta.id}'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(FeRadius.md),
                    child: InteractiveViewer(
                      maxScale: 5,
                      child: ScientificImageView(meta: meta),
                    ),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xxs,
                    children: [
                      ImageKindBadge(meta: meta),
                      StatusChip(
                        icon: Icons.copyright_outlined,
                        label: l.imageLicense(l.licenseName(meta.license)),
                        color: c.textSecondary,
                      ),
                    ],
                  ),
                  FeSectionHeader(l.imageAttribution),
                  FeMetaList(rows: rows),
                  if (meta.sourceUrl != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        key: const Key('image.copyLink'),
                        icon: const Icon(Icons.link),
                        label: Text(l.researchCopyLink),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: meta.sourceUrl!),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.researchLinkCopied)),
                            );
                          }
                        },
                      ),
                    ),
                  if (meta.captionOriginal != null) ...[
                    FeSectionHeader(l.imageOriginalCaption),
                    Text(
                      meta.captionOriginal!,
                      locale: const Locale('en'),
                      style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
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
