import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/lessons/lesson_models.dart';
import 'lesson_canvas.dart';
import 'lesson_image_view.dart';
import 'lesson_rich_diagram.dart';

enum LessonPageKind { slide, extras, references }

/// Ko‘rish oynasidagi bitta sahifa: slayd (yoki uning davomi), «Qiziqarli
/// ma’lumotlar» yoki «Adabiyotlar».
class LessonPage {
  const LessonPage({
    required this.kind,
    required this.title,
    this.bullets = const [],
    this.diagram,
    this.image,
    this.notes = '',
    this.sources = const [],
    this.group = 0,
    this.part = 1,
    this.parts = 1,
    this.originalTitle,
  });

  final LessonPageKind kind;

  /// Ko‘rsatiladigan sarlavha (davom sahifasida «… · 2/3»).
  final String title;
  final List<LessonBullet> bullets;
  final LessonDiagram? diagram;

  /// Faqat ishonchli hostdan (`LessonImage.tryParse`) — diagrammasiz sahifada.
  final LessonImage? image;
  final String notes;

  /// Shu sahifadagi bandlarning manbalari (kitob bo‘yicha guruhlangan).
  final List<LessonSourceGroup> sources;

  /// Asl slayd tartib raqami (davom sahifalari bir guruhda).
  final int group;

  /// Guruh ichidagi qism (1 dan) va qismlar soni.
  final int part;
  final int parts;

  /// Bo‘lingan slaydning asl sarlavhasi (qism belgisisiz).
  final String? originalTitle;

  /// Asl slayd sarlavhasi — ro‘yxat uchun.
  String get baseTitle => originalTitle ?? title;
}

/// «Tinglash» uchun matn: sarlavha + band matnlari. Ustoz eslatmalari,
/// manbalar va adabiyotlar kirmaydi (adabiyotlar sahifasi uchun — bo‘sh).
/// Har qism nuqta bilan tugaydi — ovoz pauza qilishi uchun.
String lessonListenText(LessonPage page) {
  if (page.kind == LessonPageKind.references) return '';
  String sentence(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    return RegExp(r'[.!?:;…]$').hasMatch(t) ? t : '$t.';
  }

  return [
    sentence(page.baseTitle),
    for (final b in page.bullets) sentence(b.text),
  ].where((s) => s.isNotEmpty).join('\n');
}

/// Bir kitobning shu sahifadagi betlari.
class LessonSourceGroup {
  const LessonSourceGroup(this.author, this.title, this.pages);

  final String author;
  final String title;
  final List<String> pages;
}

List<LessonSourceGroup> _sourceGroups(Iterable<LessonBullet> bullets) {
  final groups = <String, LessonSourceGroup>{};
  for (final b in bullets) {
    final src = b.source;
    if (src.isEmpty) continue;
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
  return groups.values.toList();
}

/// Dars → sahifalar. Slaydlar, so‘ng (bo‘lsa) «Qiziqarli ma’lumotlar», oxirida
/// «Adabiyotlar» (manbalar bo‘lsa).
///
/// Uzun slayd 1280×720 kanvasga [LessonCanvasMetrics.minBody] px asosiy matn
/// bilan sig‘masa, davom sahifalariga bo‘linadi («Sarlavha · 2/3»):
/// bandlar chegarasida (bitta juda uzun band — jumlalar bo‘yicha), jadval yoki
/// sxema bandlar bilan sig‘masa — alohida sahifada (jadval qatorlari bo‘yicha,
/// sarlavha qatori takrorlanadi). Har sahifa manbasi — o‘z bandlariniki.
/// Bo‘lish deterministik: o‘lchov [TextPainter] bilan, kanvas chizadigan
/// uslubning aynan o‘zida. Telefon rejimi ham shu sahifalarni ko‘rsatadi.
List<LessonPage> buildLessonPages(LessonDeck d, AppLocalizations l) {
  final b = _PageBuilder(l);
  final groups = <List<LessonPage>>[];
  for (var i = 0; i < d.slides.length; i++) {
    final s = d.slides[i];
    groups.add(
      b.slide(
        group: i,
        kind: LessonPageKind.slide,
        title: s.title.isEmpty ? l.lessonViewerSlideLabel(i + 1) : s.title,
        bullets: s.bullets,
        diagram: s.diagram,
        image: s.image != null && LessonImage.isAllowedUrl(s.image!.url)
            ? s.image
            : null,
        notes: s.teacherNotes,
      ),
    );
  }
  if (d.extras.isNotEmpty) {
    groups.add(
      b.slide(
        group: groups.length,
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
    groups.add(
      b.slide(
        group: groups.length,
        kind: LessonPageKind.references,
        title: l.lessonViewerReferences,
        bullets: [for (final r in refs) LessonBullet(text: r)],
      ),
    );
  }
  // Oxirgi sahifada proyektorda test tugmasi bor — joy ajratiladi.
  if (groups.isNotEmpty && !b.fitsWithAction(groups.last.last)) {
    final g = groups.removeLast();
    final f = g.first;
    groups.add(
      b.slide(
        group: f.group,
        kind: f.kind,
        title: f.baseTitle,
        bullets: [for (final p in g) ...p.bullets],
        diagram: _mergeDiagram(g),
        image: g.map((p) => p.image).whereType<LessonImage>().firstOrNull,
        notes: f.notes,
        action: true,
      ),
    );
  }
  return [for (final g in groups) ...g];
}

/// Bo‘lingan jadval qismlarini qayta birlashtiradi.
LessonDiagram? _mergeDiagram(List<LessonPage> g) {
  final ds = [
    for (final p in g)
      if (p.diagram != null) p.diagram!,
  ];
  if (ds.isEmpty) return null;
  if (ds.length == 1) return ds.first;
  return LessonDiagram(
    kind: ds.first.kind,
    header: ds.first.header,
    caption: ds.last.caption,
    rows: [for (final x in ds) ...x.rows],
    nodes: ds.first.nodes,
  );
}

class _PageBuilder {
  _PageBuilder(this.l);

  final AppLocalizations l;
  final m = LessonCanvasMeasurer();

  bool _fits(
    LessonPage p,
    double body, {
    bool action = false,
    List<LessonSourceGroup>? sources,
  }) => LessonCanvasLayout.fitsAt(
    p,
    body,
    lessonSourceLine(l, sources ?? _sourceGroups(p.bullets)),
    m,
    action: action,
  );

  bool fitsWithAction(LessonPage p) =>
      _fits(p, LessonCanvasMetrics.minBody, action: true, sources: p.sources);

  List<LessonPage> slide({
    required int group,
    required LessonPageKind kind,
    required String title,
    required List<LessonBullet> bullets,
    LessonDiagram? diagram,
    LessonImage? image,
    String notes = '',
    bool action = false,
  }) {
    LessonPage page(
      String t,
      List<LessonBullet> bs, [
      LessonDiagram? dg,
      LessonImage? im,
    ]) => LessonPage(kind: kind, title: t, bullets: bs, diagram: dg, image: im);

    // 1) Butunligicha sig‘sa — bitta sahifa (rasm + diagramma bir sahifada
    // bo‘lmaydi: rasm bandlar bilan, diagramma alohida «davom» sahifasida).
    final whole = page(title, bullets, diagram, image);
    if ((image == null || diagram == null) &&
        _fits(whole, LessonCanvasMetrics.minBody, action: action)) {
      return [
        LessonPage(
          kind: kind,
          title: title,
          bullets: bullets,
          diagram: diagram,
          image: image,
          notes: notes,
          sources: _sourceGroups(bullets),
          group: group,
        ),
      ];
    }

    // 2) Bo‘lish: qulay o‘lchamda (packBody), sarlavha eng uzun qism belgisi
    // bilan o‘lchanadi.
    const pack = LessonCanvasMetrics.packBody;
    final probe = '$title · 88/88';
    // Faqat jadval/sxema sahifasi slaydning barcha manbalarini ko‘rsatadi.
    final allSources = _sourceGroups(bullets);
    bool fitsBullets(
      List<LessonBullet> bs, [
      LessonDiagram? dg,
      LessonImage? im,
    ]) => _fits(
      page(probe, bs, dg, im),
      pack,
      action: action,
      sources: bs.isEmpty ? allSources : null,
    );

    final atoms = <LessonBullet>[
      for (final b in bullets)
        if (fitsBullets([b])) b else ..._splitBullet(b, fitsBullets),
    ];
    final chunks =
        <
          ({
            List<LessonBullet> bullets,
            LessonDiagram? diagram,
            LessonImage? image,
          })
        >[
          for (final c in _paginate(atoms, fitsBullets, (b) => b.text.length))
            (bullets: c, diagram: null, image: null),
        ];
    if (image != null) {
      // Rasm birinchi bandlar qismi yonida; sig‘masa — o‘z sahifasida.
      if (chunks.isNotEmpty && fitsBullets(chunks.first.bullets, null, image)) {
        chunks[0] = (
          bullets: chunks.first.bullets,
          diagram: null,
          image: image,
        );
      } else {
        chunks.insert(0, (bullets: const [], diagram: null, image: image));
      }
    }
    if (diagram != null) {
      final lastBullets = chunks.isEmpty ? null : chunks.last.bullets;
      if (lastBullets != null &&
          chunks.last.image == null &&
          fitsBullets(lastBullets, diagram)) {
        chunks.last = (bullets: lastBullets, diagram: diagram, image: null);
      } else if (diagram.kind == LessonDiagramKind.table &&
          !fitsBullets(const [], diagram)) {
        final rowChunks = _paginate<List<String>>(
          diagram.rows,
          (rows) => fitsBullets(const [], _rows(diagram, rows, false)),
          (r) => r.fold(0, (a, c) => a + c.length),
        );
        for (var i = 0; i < rowChunks.length; i++) {
          chunks.add((
            bullets: const [],
            diagram: _rows(diagram, rowChunks[i], i == rowChunks.length - 1),
            image: null,
          ));
        }
      } else {
        chunks.add((bullets: const [], diagram: diagram, image: null));
      }
    }
    final n = chunks.length;
    return [
      for (var i = 0; i < n; i++)
        LessonPage(
          kind: kind,
          title: n > 1 ? '$title · ${i + 1}/$n' : title,
          originalTitle: title,
          bullets: chunks[i].bullets,
          diagram: chunks[i].diagram,
          image: chunks[i].image,
          notes: notes,
          // Faqat jadval/sxema sahifasi — slaydning manbalari (jadval shu
          // slayd manbalaridan); qolganlari — o‘z bandlarining manbalari.
          sources: chunks[i].bullets.isEmpty
              ? allSources
              : _sourceGroups(chunks[i].bullets),
          group: group,
          part: i + 1,
          parts: n,
        ),
    ];
  }

  static LessonDiagram _rows(
    LessonDiagram d,
    List<List<String>> rows,
    bool last,
  ) => LessonDiagram(
    kind: d.kind,
    header: d.header,
    rows: rows,
    caption: last ? d.caption : '',
  );

  /// Bitta juda uzun band: jumlalar, kerak bo‘lsa so‘zlar bo‘yicha.
  static List<LessonBullet> _splitBullet(
    LessonBullet b,
    bool Function(List<LessonBullet>) fits,
  ) {
    LessonBullet part(String t) =>
        LessonBullet(text: t, source: b.source, uncertain: b.uncertain);
    bool ok(String t) => fits([part(t)]);
    final sentences = b.text
        .split(RegExp(r'(?<=[.!?;])\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final units = <String>[
      for (final s in sentences)
        if (ok(s)) s else ..._greedy(s.split(RegExp(r'\s+')), ok),
    ];
    return [for (final t in _greedy(units, ok)) part(t)];
  }

  static List<String> _greedy(List<String> units, bool Function(String) ok) {
    final out = <String>[];
    var cur = '';
    for (final u in units) {
      final next = cur.isEmpty ? u : '$cur $u';
      if (cur.isEmpty || ok(next)) {
        cur = next;
      } else {
        out.add(cur);
        cur = u;
      }
    }
    if (cur.isNotEmpty) out.add(cur);
    return out;
  }
}

/// Ochko‘z bo‘lish + muvozanat: oxirgi sahifa juda bo‘sh qolmasin
/// (oldingi sahifadan elementlar ko‘chiriladi, sig‘ish saqlanadi).
List<List<T>> _paginate<T>(
  List<T> items,
  bool Function(List<T>) fits,
  int Function(T) weight,
) {
  final pages = <List<T>>[];
  var cur = <T>[];
  for (final it in items) {
    final next = [...cur, it];
    if (cur.isEmpty || fits(next)) {
      cur = next;
    } else {
      pages.add(cur);
      cur = [it];
    }
  }
  if (cur.isNotEmpty) pages.add(cur);
  int sum(List<T> xs) => xs.fold(0, (a, x) => a + weight(x));
  for (var pass = 0; pass < 3; pass++) {
    var moved = false;
    for (var k = pages.length - 1; k > 0; k--) {
      while (pages[k - 1].length > 1) {
        final prev = pages[k - 1];
        final it = prev.last;
        if (sum(prev) - sum(pages[k]) <= weight(it)) break;
        final cand = [it, ...pages[k]];
        if (!fits(cand)) break;
        prev.removeLast();
        pages[k] = cand;
        moved = true;
      }
    }
    if (!moved) break;
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
/// yo‘q. [projector] — 1280×720 kanvas ([LessonCanvas]): sahifa har doim
/// bitta ekranga to‘liq sig‘adi; aks holda telefon uchun o‘qiladigan,
/// siljitiladigan ko‘rinish (tizim matn masshtabi qo‘llanadi).
class LessonSlideView extends StatelessWidget {
  const LessonSlideView({
    super.key,
    required this.page,
    this.projector = false,
    this.counter,
    this.action,
  });

  final LessonPage page;
  final bool projector;

  /// Proyektor: kanvas burchagidagi «3 / 12».
  final String? counter;

  /// Proyektor: oxirgi sahifadagi tugma (pastki o‘ng burchak).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    if (projector) {
      return LessonCanvas(page: page, counter: counter, action: action);
    }
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final body = w >= 700 ? 20.0 : 16.0;
        final title = body * 1.3;
        final small = (body * 0.62).clamp(12.0, 24.0);
        const pad = FeSpace.md;
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
            : lessonIsRichDiagram(page.diagram!.kind)
            ? LessonRichDiagram(diagram: page.diagram!, size: body)
            : _DiagramView(diagram: page.diagram!, size: body * 0.85);

        final imageBlock = page.image == null
            ? null
            : Center(
                child: LessonImageView(
                  image: page.image!,
                  width: math.min(w - 2 * pad, 560),
                  height: math.min(w - 2 * pad, 560) * 0.62,
                  captionSize: small + 3,
                  creditSize: small,
                  captionLines: 3,
                  creditLines: 3,
                ),
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
                  color: c.textPrimary,
                ),
              ),
            ),
            SizedBox(height: body * 0.8),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: bullets),
                  const SizedBox(width: pad),
                  Expanded(flex: 2, child: diagram!),
                ],
              )
            else ...[
              bullets,
              if (imageBlock != null) ...[
                SizedBox(height: body * 0.4),
                imageBlock,
              ],
              if (diagram != null) ...[SizedBox(height: body), diagram],
            ],
          ],
        );
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(pad, pad, pad, FeSpace.sm),
                child: content,
              ),
            ),
            if (srcLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(pad, 0, pad, FeSpace.xs),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    srcLine,
                    key: const Key('lesson.source'),
                    maxLines: 3,
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
  const _DiagramView({required this.diagram, required this.size});

  final LessonDiagram diagram;
  final double size;

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
      default:
        body = const SizedBox.shrink();
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
