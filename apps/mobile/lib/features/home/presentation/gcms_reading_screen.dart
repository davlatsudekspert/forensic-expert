import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../professional/presentation/professional_widgets.dart' show FeNote;

/// «Natijani o‘qish: xromatogramma va mass-spektr» (egasi talabi, 2026-11-01).
///
/// Matn — «Apparatlar bilan ishlash» kursidagi «GC-MS da ishlash usullari:
/// asoslar» darsidan (Yuldashev Z.A. va boshq. «Giyohvand moddalar tahlili»,
/// 2024; Shimadzu «GC/MS Basics» ochiq sahifalari). Diagrammalar — sxema:
/// tajriba ma’lumoti emas, intensivlik raqamlari qo‘yilmaydi. Ion
/// ro‘yxatlari darsdagi tartibda (kamayish tartibida) beriladi.
/// Yangi kontent — avval o‘zbekcha (egasi qarori, 2026-10-12): boshqa
/// tillarda asl matn «tarjima kutilmoqda» belgisi bilan.
class GcmsReadingScreen extends StatelessWidget {
  const GcmsReadingScreen({super.key});

  static const source =
      'Manba: «GC-MS da ishlash usullari: asoslar» darsi — Yuldashev Z.A. va '
      'boshq. «Giyohvand moddalar tahlili» (2024); Yuldashev Z.A., Umarova '
      'G.Q. «Toksikologik kimyo» (2025); Shimadzu «GC/MS Basics».';

  static const _sections = <(String, List<String>)>[
    (
      'Natija nimadan iborat',
      [
        'GC-MS ning yakuniy natijasi — mass-xromatogramma va har bir cho‘qqining mass-spektri.',
        'TIC (umumiy ion toki) — bir skandagi barcha mass-spektr cho‘qqilari intensivliklarini qo‘shish orqali hosil bo‘ladi.',
        'Mass-spektr nisbiy ion intensivligini m/z (massa/zaryad) ga bog‘lab ko‘rsatadi.',
      ],
    ),
    (
      'Xromatogrammani o‘qish',
      [
        'Ushlanish vaqti — namuna yuborilgandan modda cho‘qqisigacha bo‘lgan vaqt; bir xil sharoitda u modda sifatini aniqlovchi parametr.',
        'Qaynash harorati past moddalar odatda erta chiqadi; K = C(suyuq)/C(gaz) katta bo‘lsa, modda kolonkada uzoqroq qoladi.',
        'Dasturlangan haroratda n-alkanlar yordamida chiziqli ushlanish indeksi (LRI) hisoblanadi.',
        'Miqdor cho‘qqi intensivligi yoki yuzasi bo‘yicha aniqlanadi; aniq o‘lchov uchun ichki standart bilan jadval tuziladi.',
      ],
    ),
    (
      'Mass-spektrni o‘qish',
      [
        'Elektron urib chiqarilsa, molekula parchalanmay molekulyar ion (M⁺) hosil qilishi mumkin — u molekulyar massani beradi.',
        '70 eV elektronlar molekulani parchalaydi: fragment ionlar hosil bo‘ladi; bog‘lar odatda zaif joyda uziladi.',
        'Kutubxona spektrlarining ko‘pchiligi 70 eV EI da yozilgan — shu sababli 70 eV standart.',
      ],
    ),
    (
      'Scan va SIM',
      [
        'Full scan tanlangan massa oralig‘idagi barcha ionlarni yozadi va TIC beradi — noma’lum modda uchun qulay.',
        'SIM faqat belgilangan ionlarni belgilangan ushlanish vaqtida o‘lchaydi: sezgirligi yuqori, shovqin past — ma’lum moddalarni miqdoriy tahlil qilish uchun.',
        'SIM da kvantifikator (odatda eng ko‘p ion) va kvalifikator (2- va 3- eng ko‘p ionlar) tanlanadi — yolg‘on musbat natija kamayadi.',
      ],
    ),
    (
      'Identifikatsiya va cheklovlar',
      [
        'Noma’lum spektr kutubxonadagi etalon spektrlar (masalan, NIST) bilan solishtiriladi; natija moslik ehtimoli sifatida beriladi, qarorni mutaxassis qabul qiladi.',
        'Izomerlar o‘xshash spektrga, ammo turlicha ushlanish vaqtiga ega bo‘lishi mumkin — standart bilan bir xil sharoitda ushlanish vaqtini solishtirish kerak.',
        'Moddalar uchuvchan va termik barqaror bo‘lishi talab qilinadi; spektrlar asbob, parametr va namuna holatiga ko‘ra biroz farq qiladi.',
      ],
    ),
  ];

  /// Darsdagi misollar: asosiy m/z ionlar, ko‘pdan kamga tartibda.
  static const _ions = <(String, List<int>)>[
    ('Efedrin', [58, 146, 56, 105, 77, 42, 106, 40]),
    ('Efedron', [58, 77, 51, 56, 42, 105, 50, 43]),
    ('Fentanil', [245, 146, 42, 189, 44, 105, 29, 43]),
    ('Diazepam', [256, 283, 284, 285, 257, 255, 258, 286]),
    ('Ketamin', [180, 209, 182, 152, 181, 30, 211, 138]),
  ];

  /// Mashq uchun (darsdagi 23–26-slaydlar; ko‘pdan kamga tartib).
  static const quizIons = <(String, List<int>)>[
    ..._ions,
    ('Psilotsin', [58, 204, 59, 42, 30, 146, 77, 44]),
    ('Psilotsibin', [58, 42, 30, 51, 204, 146, 77, 44]),
    ('Xlordiazepoksid', [282, 299, 284, 283, 241, 56, 301, 253]),
    ('Fensiklidin', [243, 214, 200, 186, 166, 158, 84, 77]),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final uz = Localizations.localeOf(context).languageCode == 'uz';
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.labHubReading)),
      body: ListView(
        key: const Key('gcms.reading'),
        padding: EdgeInsets.only(
          bottom: FeSpace.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!uz) ...[
                  const SizedBox(height: FeSpace.sm),
                  FeNote(icon: Icons.translate, text: l.trPendingTranslation),
                ],
                FeSectionHeader(l.labHubChromatogram),
                const _Figure(child: _ChromatogramPainter()),
                FeSectionHeader(l.labHubSpectrum),
                const _Figure(child: _SpectrumPainter()),
                for (final (title, points) in _sections) ...[
                  FeSectionHeader(title),
                  FeCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final p in points)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: c.accent,
                                  ),
                                ),
                                const SizedBox(width: FeSpace.xs),
                                Expanded(child: Text(p, style: t.bodyMedium)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                FeSectionHeader(l.labHubIons),
                FeCard(
                  key: const Key('gcms.ions'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Asosiy m/z ionlar (ko‘pdan kamga):',
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                      for (final (name, ions) in _ions) ...[
                        const SizedBox(height: FeSpace.sm),
                        Text(
                          name,
                          style: t.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final (i, m) in ions.indexed)
                              _IonChip(mz: m, base: i == 0),
                          ],
                        ),
                      ],
                      const SizedBox(height: FeSpace.sm),
                      Text(
                        'Efedrin va efedronda 58 m/z asosiy; qolgan ionlar '
                        'tartibi va to‘plami farqlanadi.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
                FeSectionHeader(l.labHubQuiz),
                const _IonQuiz(),
                const SizedBox(height: FeSpace.md),
                Text(
                  source,
                  key: const Key('gcms.source'),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IonChip extends StatelessWidget {
  const _IonChip({required this.mz, required this.base});
  final int mz;
  final bool base;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: base ? c.accentContainer : c.surfaceRaised,
        borderRadius: BorderRadius.circular(FeRadius.sm),
        border: Border.all(color: base ? c.accent : c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          '$mz',
          style: TextStyle(
            fontWeight: base ? FontWeight.w700 : FontWeight.w500,
            color: base ? c.onAccentContainer : null,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Diagramma ramkasi + «Sxema — eksperimental ma’lumot emas».
class _Figure extends StatelessWidget {
  const _Figure({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return FeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(aspectRatio: 1.8, child: child),
          const SizedBox(height: FeSpace.xs),
          Text(
            l.imageSchematic,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

TextPainter _label(String s, Color color, double size, String? font) =>
    TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(color: color, fontSize: size, fontFamily: font),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

/// Xromatogramma sxemasi: vaqt o‘qi, erituvchi cho‘qqisi, ikki modda
/// cho‘qqisi, ushlanish vaqti (tR) va cho‘qqi yuzasi.
class _ChromatogramPainter extends StatelessWidget {
  const _ChromatogramPainter();

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return CustomPaint(
      painter: _Chrom(
        ink: c.textPrimary,
        muted: c.textSecondary,
        accent: c.accent,
        font: Theme.of(context).textTheme.bodySmall?.fontFamily,
      ),
    );
  }
}

class _Chrom extends CustomPainter {
  _Chrom({
    required this.ink,
    required this.muted,
    required this.accent,
    required this.font,
  });
  final Color ink, muted, accent;
  final String? font;

  double _g(double x, double mu, double s, double h) =>
      h * math.exp(-math.pow(x - mu, 2) / (2 * s * s));

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0, bottom = 26.0, top = 14.0;
    final w = size.width - left - 8, h = size.height - bottom - top;
    final axis = Paint()
      ..color = muted
      ..strokeWidth = 1;
    final o = Offset(left, size.height - bottom);
    canvas.drawLine(o, Offset(left + w, o.dy), axis);
    canvas.drawLine(o, const Offset(left, top), axis);
    _label(
      'vaqt →',
      muted,
      10,
      font,
    ).paint(canvas, Offset(left + w - 36, o.dy + 6));
    _label('signal', muted, 10, font).paint(canvas, const Offset(0, 0));

    double y(double x) =>
        _g(x, 0.12, 0.018, 0.95) +
        _g(x, 0.45, 0.025, 0.55) +
        _g(x, 0.72, 0.03, 0.8);
    final path = Path()..moveTo(o.dx, o.dy);
    final area = Path()..moveTo(left + 0.62 * w, o.dy);
    for (var i = 0; i <= 300; i++) {
      final x = i / 300;
      final p = Offset(left + x * w, o.dy - y(x) * h);
      path.lineTo(p.dx, p.dy);
      if (x >= 0.62 && x <= 0.82) area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(left + 0.82 * w, o.dy)
      ..close();
    canvas.drawPath(area, Paint()..color = accent.withValues(alpha: 0.18));
    canvas.drawPath(
      path,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final dash = Paint()
      ..color = accent
      ..strokeWidth = 1;
    final px = left + 0.72 * w;
    for (var d = o.dy; d > o.dy - 0.8 * h; d -= 6) {
      canvas.drawLine(Offset(px, d), Offset(px, d - 3), dash);
    }
    _label(
      'erituvchi',
      muted,
      10,
      font,
    ).paint(canvas, Offset(left + 0.12 * w - 20, top - 2));
    _label(
      'A',
      ink,
      11,
      font,
    ).paint(canvas, Offset(left + 0.45 * w - 4, o.dy - 0.55 * h - 16));
    _label(
      'B',
      ink,
      11,
      font,
    ).paint(canvas, Offset(px + 4, o.dy - 0.8 * h - 16));
    _label('tR', accent, 11, font).paint(canvas, Offset(px - 8, o.dy + 4));
    _label(
      'yuza → miqdor',
      accent,
      10,
      font,
    ).paint(canvas, Offset(px + 18, o.dy - 0.35 * h));
  }

  @override
  bool shouldRepaint(covariant _Chrom old) => false;
}

/// Mass-spektr sxemasi: m/z o‘qi, asosiy cho‘qqi (100 %), fragmentlar va
/// molekulyar ion M⁺. Balandliklar shartli (tajriba ma’lumoti emas).
class _SpectrumPainter extends StatelessWidget {
  const _SpectrumPainter();

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return CustomPaint(
      painter: _Spec(
        ink: c.textPrimary,
        muted: c.textSecondary,
        accent: c.accent,
        font: Theme.of(context).textTheme.bodySmall?.fontFamily,
      ),
    );
  }
}

class _Spec extends CustomPainter {
  _Spec({
    required this.ink,
    required this.muted,
    required this.accent,
    required this.font,
  });
  final Color ink, muted, accent;
  final String? font;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0, bottom = 26.0, top = 18.0;
    final w = size.width - left - 8, h = size.height - bottom - top;
    final axis = Paint()
      ..color = muted
      ..strokeWidth = 1;
    final o = Offset(left, size.height - bottom);
    canvas.drawLine(o, Offset(left + w, o.dy), axis);
    canvas.drawLine(o, const Offset(left, top), axis);
    _label(
      'm/z →',
      muted,
      10,
      font,
    ).paint(canvas, Offset(left + w - 34, o.dy + 6));
    _label('%', muted, 10, font).paint(canvas, const Offset(8, 2));
    const bars = [
      (0.10, 0.30),
      (0.18, 0.55),
      (0.26, 1.0),
      (0.38, 0.22),
      (0.50, 0.40),
      (0.62, 0.18),
      (0.74, 0.12),
      (0.90, 0.28),
    ];
    for (final (x, v) in bars) {
      final base = v == 1.0;
      final m = x == 0.90;
      canvas.drawRect(
        Rect.fromLTWH(left + x * w - 2.5, o.dy - v * h, 5, v * h),
        Paint()..color = base || m ? accent : ink.withValues(alpha: 0.75),
      );
    }
    _label(
      'asosiy cho‘qqi',
      accent,
      10,
      font,
    ).paint(canvas, Offset(left + 0.26 * w - 30, top - 14));
    _label(
      'M⁺',
      accent,
      11,
      font,
    ).paint(canvas, Offset(left + 0.90 * w - 8, o.dy - 0.28 * h - 16));
    _label(
      'fragmentlar',
      muted,
      10,
      font,
    ).paint(canvas, Offset(left + 0.46 * w, o.dy - 0.62 * h));
  }

  @override
  bool shouldRepaint(covariant _Spec old) => false;
}

/// Mashq: «Spektrga qarab moddani toping». Javob variantlari — asosiy ioni
/// bir xil yoki yaqin moddalar (efedrin/efedron, psilotsin/psilotsibin …),
/// ya’ni farqni 2- va 3- ionlar bo‘yicha ko‘rish o‘rgatiladi.
class _IonQuiz extends StatefulWidget {
  const _IonQuiz();

  @override
  State<_IonQuiz> createState() => _IonQuizState();
}

class _IonQuizState extends State<_IonQuiz> {
  static const _order = [1, 5, 0, 8, 2, 6, 3, 4, 7, 9];
  int _step = 0;
  int? _picked;
  int _score = 0;

  List<(String, List<int>)> get _all => GcmsReadingScreen.quizIons;

  int get _answer => _order[_step % _order.length];

  /// Variantlar: to‘g‘ri javob + asosiy ioni eng yaqin 3 modda (barqaror).
  List<int> _options() {
    final a = _all[_answer];
    final others =
        [
          for (var i = 0; i < _all.length; i++)
            if (i != _answer) i,
        ]..sort((x, y) {
          final dx = (_all[x].$2.first - a.$2.first).abs();
          final dy = (_all[y].$2.first - a.$2.first).abs();
          return dx != dy ? dx.compareTo(dy) : x.compareTo(y);
        });
    final opts = [_answer, ...others.take(3)]
      ..sort((x, y) => _all[x].$1.compareTo(_all[y].$1));
    return opts;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final (name, ions) = _all[_answer];
    final done = _picked != null;
    return FeCard(
      key: const Key('gcms.quiz'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${_step % _order.length + 1}/${_order.length} · '
            '${l.labHubQuizPrompt}',
            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: FeSpace.xs),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (i, m) in ions.indexed) _IonChip(mz: m, base: i == 0),
            ],
          ),
          const SizedBox(height: FeSpace.sm),
          for (final o in _options())
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: OutlinedButton(
                key: Key('gcms.quiz.opt.$o'),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: !done
                      ? null
                      : o == _answer
                      ? c.verified.withValues(alpha: 0.14)
                      : o == _picked
                      ? c.danger.withValues(alpha: 0.12)
                      : null,
                ),
                onPressed: done
                    ? null
                    : () => setState(() {
                        _picked = o;
                        if (o == _answer) _score++;
                      }),
                child: Text(_all[o].$1),
              ),
            ),
          if (done) ...[
            const SizedBox(height: FeSpace.xs),
            Text(
              '${_picked == _answer ? '✓' : '✗'} $name: asosiy ion m/z '
              '${ions[0]}, keyingilari ${ions[1]} va ${ions[2]}. '
              '${_twinNote(name)}',
              key: const Key('gcms.quiz.explain'),
              style: t.bodySmall,
            ),
            const SizedBox(height: FeSpace.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.labHubQuizScore(_score, _step + 1),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
                FilledButton(
                  key: const Key('gcms.quiz.next'),
                  onPressed: () => setState(() {
                    _step = (_step + 1) % _order.length;
                    if (_step == 0) _score = 0;
                    _picked = null;
                  }),
                  child: Text(l.labHubQuizNext),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _twinNote(String name) => switch (name) {
    'Efedrin' ||
    'Efedron' => 'Efedrin va efedronda 58 asosiy; farq 2-ionda (146 / 77).',
    'Psilotsin' || 'Psilotsibin' =>
      'Psilotsin va psilotsibinda 58 asosiy; farq 2-ionda (204 / 42).',
    'Diazepam' || 'Xlordiazepoksid' =>
      'Benzodiazepinlar: diazepamda 256, xlordiazepoksidda 282 asosiy.',
    _ => '',
  };
}
