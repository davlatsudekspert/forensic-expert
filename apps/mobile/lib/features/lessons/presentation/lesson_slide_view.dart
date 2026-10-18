import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/lessons/lesson_models.dart';

enum LessonPageKind { slide, extras, references }

/// Ko‘rish oynasidagi bitta sahifa: slayd, «Qiziqarli ma’lumotlar» yoki
/// «Adabiyotlar».
class LessonPage {
  const LessonPage({
    required this.kind,
    required this.title,
    this.bullets = const [],
    this.diagram,
    this.notes = '',
    this.sources = const [],
  });

  final LessonPageKind kind;
  final String title;
  final List<LessonBullet> bullets;
  final LessonDiagram? diagram;
  final String notes;

  /// Slayd manbalari (kitob bo‘yicha guruhlangan).
  final List<LessonSourceGroup> sources;
}

/// Bir kitobning shu slayddagi betlari.
class LessonSourceGroup {
  const LessonSourceGroup(this.author, this.title, this.pages);

  final String author;
  final String title;
  final List<String> pages;
}

/// Dars → sahifalar. Slaydlar, so‘ng (bo‘lsa) «Qiziqarli ma’lumotlar», oxirida
/// «Adabiyotlar» (manbalar bo‘lsa).
List<LessonPage> buildLessonPages(LessonDeck d, AppLocalizations l) {
  final pages = <LessonPage>[];
  for (var i = 0; i < d.slides.length; i++) {
    final s = d.slides[i];
    final groups = <String, LessonSourceGroup>{};
    for (final src in s.sources) {
      final k = '${src.author}|${src.title}';
      final g = groups[k];
      if (g == null) {
        groups[k] = LessonSourceGroup(src.author, src.title, [
          if (src.page.isNotEmpty) src.page,
        ]);
      } else if (src.page.isNotEmpty && !g.pages.contains(src.page)) {
        g.pages.add(src.page);
      }
    }
    pages.add(
      LessonPage(
        kind: LessonPageKind.slide,
        title: s.title.isEmpty ? l.lessonViewerSlideLabel(i + 1) : s.title,
        bullets: s.bullets,
        diagram: s.diagram,
        notes: s.teacherNotes,
        sources: groups.values.toList(),
      ),
    );
  }
  if (d.extras.isNotEmpty) {
    pages.add(
      LessonPage(
        kind: LessonPageKind.extras,
        title: l.lessonViewerExtras,
        bullets: [
          for (final e in d.extras)
            LessonBullet(text: e.text, source: e.source),
        ],
      ),
    );
  }
  final refs = [
    for (final r in d.references)
      if (r.line.isNotEmpty) r.line,
  ];
  if (refs.isNotEmpty) {
    pages.add(
      LessonPage(
        kind: LessonPageKind.references,
        title: l.lessonViewerReferences,
        bullets: [for (final r in refs) LessonBullet(text: r)],
      ),
    );
  }
  return pages;
}

/// «Muallif, Sarlavha, bet 12, 14; …»
String lessonSourceLine(AppLocalizations l, List<LessonSourceGroup> groups) {
  final parts = <String>[];
  for (final g in groups) {
    final p = [
      if (g.author.isNotEmpty) g.author,
      if (g.title.isNotEmpty) g.title,
      if (g.pages.isNotEmpty) l.lessonViewerPage(g.pages.join(', ')),
    ];
    if (p.isNotEmpty) parts.add(p.join(', '));
  }
  return parts.isEmpty ? '' : l.lessonViewerSource(parts.join('; '));
}

/// Slaydni mahalliy (native) chizadi. Matn tanlanmaydi, nusxalash/ulashish
/// yo‘q. [projector] — katta matn, qorong‘i fon bilan mos o‘lchamlar.
class LessonSlideView extends StatelessWidget {
  const LessonSlideView({
    super.key,
    required this.page,
    this.projector = false,
  });

  final LessonPage page;
  final bool projector;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final shortest = box.biggest.shortestSide;
        final w = box.maxWidth;
        // Proyektor: ekran o‘lchamiga mutanosib matn; telefon: o‘qiladigan
        // standart o‘lcham (tizim matn masshtabi qo‘llanadi).
        final body = projector
            ? (shortest * 0.05).clamp(17.0, 44.0)
            : (w >= 700 ? 20.0 : 16.0);
        final title = body * (projector ? 1.45 : 1.3);
        final small = (body * 0.62).clamp(12.0, 24.0);
        final pad = projector ? (w * 0.04).clamp(16.0, 72.0) : FeSpace.md;
        final wide = w >= 840 && page.diagram != null;
        final srcLine = lessonSourceLine(l, page.sources);

        final bullets = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final b in page.bullets)
              _BulletRow(
                bullet: b,
                size: body,
                color: c.textPrimary,
                dot: c.accent,
                warn: c.warning,
                marker: page.kind == LessonPageKind.references ? null : '•',
                uncertainLabel: l.lessonViewerUncertain,
              ),
          ],
        );
        final diagram = page.diagram == null
            ? null
            : _DiagramView(
                diagram: page.diagram!,
                size: body * 0.85,
                projector: projector,
              );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                page.title,
                style: TextStyle(
                  fontSize: title,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: projector ? c.accent : c.textPrimary,
                ),
              ),
            ),
            SizedBox(height: body * 0.8),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: bullets),
                  SizedBox(width: pad),
                  Expanded(flex: 2, child: diagram!),
                ],
              )
            else ...[
              bullets,
              if (diagram != null) ...[SizedBox(height: body), diagram],
            ],
          ],
        );
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, FeSpace.sm),
                child: content,
              ),
            ),
            if (srcLine.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, FeSpace.xs),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    srcLine,
                    key: const Key('lesson.source'),
                    maxLines: projector ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: small,
                      height: 1.3,
                      color: c.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.bullet,
    required this.size,
    required this.color,
    required this.dot,
    required this.warn,
    required this.marker,
    required this.uncertainLabel,
  });

  final LessonBullet bullet;
  final double size;
  final Color color;
  final Color dot;
  final Color warn;
  final String? marker;
  final String uncertainLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: size * 0.6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (marker != null)
            SizedBox(
              width: size * 0.9,
              child: Text(
                marker!,
                style: TextStyle(
                  fontSize: size,
                  height: 1.35,
                  color: dot,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: bullet.text),
                  if (bullet.uncertain)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Tooltip(
                          message: uncertainLabel,
                          child: Semantics(
                            label: uncertainLabel,
                            child: Icon(
                              Icons.help_outline_rounded,
                              key: const Key('lesson.uncertain'),
                              size: size * 0.85,
                              color: warn,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              style: TextStyle(fontSize: size, height: 1.35, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Oddiy diagramma: jadval yoki ketma-ket qutilar (strelkalar bilan).
class _DiagramView extends StatelessWidget {
  const _DiagramView({
    required this.diagram,
    required this.size,
    required this.projector,
  });

  final LessonDiagram diagram;
  final double size;
  final bool projector;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final Widget body;
    switch (diagram.kind) {
      case LessonDiagramKind.table:
        body = ClipRRect(
          borderRadius: BorderRadius.circular(FeRadius.md),
          child: Table(
            key: const Key('lesson.diagram.table'),
            border: TableBorder.all(color: c.border),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(color: c.brand),
                children: [
                  for (final h in diagram.header)
                    _cell(h, size, c.textOnBrand, bold: true),
                ],
              ),
              for (var i = 0; i < diagram.rows.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    color: i.isEven ? c.surfaceRaised : c.surfaceSunken,
                  ),
                  children: [
                    for (final cell in diagram.rows[i])
                      _cell(cell, size, c.textPrimary),
                  ],
                ),
            ],
          ),
        );
      case LessonDiagramKind.flow:
        final nodes = diagram.nodes.take(6).toList();
        body = Column(
          key: const Key('lesson.diagram.flow'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < nodes.length; i++) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.brand,
                  borderRadius: BorderRadius.circular(FeRadius.md),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size * 0.7,
                    vertical: size * 0.5,
                  ),
                  child: Text(
                    nodes[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: c.textOnBrand,
                    ),
                  ),
                ),
              ),
              if (i < nodes.length - 1)
                Icon(
                  Icons.arrow_downward_rounded,
                  color: c.accent,
                  size: size * 1.3,
                ),
            ],
          ],
        );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        body,
        if (diagram.caption.isNotEmpty) ...[
          const SizedBox(height: FeSpace.xs),
          Text(
            diagram.caption,
            style: TextStyle(
              fontSize: size * 0.75,
              color: c.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  static Widget _cell(
    String t,
    double size,
    Color color, {
    bool bold = false,
  }) => Padding(
    padding: EdgeInsets.all(size * 0.45),
    child: Text(
      t,
      style: TextStyle(
        fontSize: size,
        height: 1.25,
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      ),
    ),
  );
}
