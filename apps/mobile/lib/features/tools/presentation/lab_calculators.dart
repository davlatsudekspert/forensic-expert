import 'dart:math' as math;

import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../tool_strings.dart';
import 'calculator_status.dart';

part 'forensic_calculators.dart';

/// PHASE 6 laboratoriya kalkulyatorlari. Har biri bir xil tuzilma:
/// INPUT → RESULT → METHOD → FORMULA → ASSUMPTIONS → LIMITATIONS →
/// REFERENCES. Hisob `fe_calc_engine` da (UI’dan mustaqil, sof va test
/// qilingan).

const _superscript = {
  '0': '⁰',
  '1': '¹',
  '2': '²',
  '3': '³',
  '4': '⁴',
  '5': '⁵',
  '6': '⁶',
  '7': '⁷',
  '8': '⁸',
  '9': '⁹',
  '-': '⁻',
};

/// 6 ta qiymatli raqam; butun son — «.0» siz; juda katta/kichik —
/// `1,5 × 10⁻⁷`. [decimal] — o‘nlik belgi (uz/ru: «,», en: «.»).
String formatNumber(double v, {String decimal = '.'}) {
  if (v == 0) return '0';
  if (!v.isFinite) return v.toString();
  final s = v.toStringAsPrecision(6);
  String out;
  if (s.contains('e')) {
    final i = s.indexOf('e');
    var mant = s.substring(0, i);
    if (mant.contains('.')) {
      mant = mant.replaceFirst(RegExp(r'0+$'), '');
      if (mant.endsWith('.')) mant = mant.substring(0, mant.length - 1);
    }
    final exp = s.substring(i + 1).replaceFirst('+', '');
    out = '$mant × 10${exp.split('').map((c) => _superscript[c] ?? c).join()}';
  } else {
    final d = double.parse(s);
    // Butun son — «.0» siz (1000, emas 1000.0).
    out = d == d.truncateToDouble() && d.abs() < 1e12
        ? d.toInt().toString()
        : d.toString();
  }
  return decimal == '.' ? out : out.replaceAll('.', decimal);
}

/// Natijalarni foydalanuvchi tilidagi o‘nlik belgisi bilan ko‘rsatish.
extension CalcFormat on AppLocalizations {
  /// uz va ru — o‘nlik vergul; en — nuqta.
  String get calcDecimal => localeName.startsWith('en') ? '.' : ',';

  String fmtNum(double v) => formatNumber(v, decimal: calcDecimal);

  String fmtFixed(double v, int digits) =>
      v.toStringAsFixed(digits).replaceAll('.', calcDecimal);
}

double? calcParse(TextEditingController c) =>
    double.tryParse(c.text.trim().replaceAll(',', '.'));

bool calcAnyEmpty(Iterable<TextEditingController> cs) =>
    cs.any((c) => c.text.trim().isEmpty);

/// Kiritish o‘zgarsa (matn yoki birlik) eski natija darhol tozalanadi —
/// boshqa qiymatlarga tegishli natija ekranda qolmasin.
mixin CalcInputsMixin<T extends StatefulWidget> on State<T> {
  final _seen = <TextEditingController, String>{};

  /// Natija, ogohlantirish va xatoni tozalaydi (setState ichida).
  void clearOutput();

  void watchInputs(Iterable<TextEditingController> cs) {
    for (final c in cs) {
      _seen[c] = c.text;
      c.addListener(() {
        // Kursor/tanlov o‘zgarishi emas — faqat matn o‘zgarishi.
        if (_seen[c] == c.text) return;
        _seen[c] = c.text;
        if (mounted) setState(clearOutput);
      });
    }
  }

  /// Birlik yoki variant tanlandi.
  void changed(VoidCallback f) => setState(() {
    f();
    clearOutput();
  });
}

/// Nusxa matni: vosita nomi, kiritilgan qiymatlar, natija, ogohlantirishlar,
/// formula va usul versiyasi (ekspert yozuvi uchun).
String calcCopyText(
  AppLocalizations l, {
  required CalculatorDescriptor descriptor,
  required List<(String, String)> inputs,
  required List<(String, String)> result,
  required String formula,
  List<String> warnings = const [],
}) {
  final b = StringBuffer();
  for (final t in ToolsCatalog.all) {
    if (t.engineId == descriptor.id) b.writeln(l.toolName(t));
  }
  final shown = [
    for (final (k, v) in inputs)
      if (v.trim().isNotEmpty) (k, v),
  ];
  if (shown.isNotEmpty) {
    b.writeln('${l.calcCopyInputs}:');
    for (final (k, v) in shown) {
      b.writeln('  $k: ${v.trim()}');
    }
  }
  b.writeln('${l.calcResult}:');
  for (final (k, v) in result) {
    b.writeln(
      k.isEmpty
          ? '  $v'
          : v.isEmpty
          ? '  $k'
          : '  $k: $v',
    );
  }
  for (final w in warnings) {
    b.writeln('⚠ $w');
  }
  b.writeln('${l.calcFormula}: $formula');
  b.write(
    '${descriptor.id} · v${descriptor.engineVersion} — '
    '${l.calcInterpretationValue}',
  );
  return b.toString();
}

/// «Natijani nusxalash» tugmasi.
class CalcCopyButton extends StatelessWidget {
  const CalcCopyButton({super.key, required this.text});

  final String Function() text;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        key: const Key('calc.copy'),
        icon: const Icon(Icons.copy_outlined, size: 18),
        label: Text(l.calcCopyResult),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: text()));
          if (!context.mounted) return;
          ScaffoldMessenger.maybeOf(context)
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l.calcCopied)));
        },
      ),
    );
  }
}

/// Umumiy sahifa skeleti.
class CalcScaffold extends StatelessWidget {
  const CalcScaffold({
    super.key,
    required this.descriptor,
    required this.inputs,
    required this.onCalculate,
    required this.formula,
    required this.result,
    required this.assumptions,
    required this.limitations,
    this.references = const [],
    this.error,
    this.warnings = const [],
    this.copyInputs = const [],
    this.emphasizeFirst = true,
    this.resultNote,
    this.formulaNote,
  });

  final CalculatorDescriptor descriptor;
  final List<Widget> inputs;
  final VoidCallback onCalculate;
  final String formula;

  /// (yorliq, qiymat) qatorlari; `null` — hali hisoblanmagan.
  final List<(String, String)>? result;
  final List<String> assumptions;
  final List<String> limitations;

  /// Bo‘sh bo‘lsa — ta’rifiy munosabat (adabiyot qiymati ishlatilmaydi).
  final List<String> references;
  final String? error;
  final List<String> warnings;

  /// Nusxa matni uchun (yorliq, kiritilgan qiymat + birlik).
  final List<(String, String)> copyInputs;

  /// Birinchi natija qatori asosiy natija sifatida katta ko‘rsatiladi.
  final bool emphasizeFirst;

  /// Natija ostidagi qisqa izoh (masalan, birlik).
  final String? resultNote;

  /// Formula ostidagi izoh (masalan, qaysi tenglama qo‘llangani).
  final String? formulaNote;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final res = result;
    Widget row((String, String) r) => MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FeSpace.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(r.$1, style: t.bodyMedium)),
            const SizedBox(width: FeSpace.sm),
            Flexible(
              child: Text(
                r.$2,
                textAlign: TextAlign.end,
                style: FeThemeBuilder.numeric(t.titleMedium!),
              ),
            ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.calcInput),
        for (final w in inputs) ...[w, const SizedBox(height: FeSpace.sm)],
        FilledButton(
          key: const Key('calc.calculate'),
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onCalculate();
          },
          child: Text(l.calcCalculate),
        ),
        if (error != null) ...[
          const SizedBox(height: FeSpace.sm),
          Semantics(
            liveRegion: true,
            child: FeBanner(
              key: const Key('calc.error'),
              icon: Icons.error_outline,
              text: error!,
              tone: FeBannerTone.warning,
            ),
          ),
        ],
        FeSectionHeader(l.calcResult),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(FeRadius.md),
            border: Border.all(color: res == null ? c.border : c.accentBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: res == null || res.isEmpty
                ? Text(
                    FeGlyphs.emDash,
                    style: FeThemeBuilder.numeric(t.titleLarge!),
                  )
                : Semantics(
                    liveRegion: true,
                    child: Column(
                      key: const Key('calc.result'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (emphasizeFirst) ...[
                          MergeSemantics(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(res.first.$1, style: t.labelLarge),
                                const SizedBox(height: FeSpace.xxs),
                                Text(
                                  res.first.$2,
                                  key: const Key('calc.result.primary'),
                                  style: FeThemeBuilder.numeric(
                                    t.headlineSmall!,
                                  ).copyWith(color: c.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          if (res.length > 1) ...[
                            const SizedBox(height: FeSpace.xs),
                            Divider(height: FeSpace.sm, color: c.border),
                          ],
                          for (final r in res.skip(1)) row(r),
                        ] else
                          for (final r in res) row(r),
                        if (resultNote != null) ...[
                          const SizedBox(height: FeSpace.xxs),
                          Text(
                            resultNote!,
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                        for (final w in warnings) ...[
                          const SizedBox(height: FeSpace.xs),
                          FeBanner(
                            icon: Icons.warning_amber_rounded,
                            text: w,
                            tone: FeBannerTone.warning,
                          ),
                        ],
                        const SizedBox(height: FeSpace.xxs),
                        CalcCopyButton(
                          text: () => calcCopyText(
                            l,
                            descriptor: descriptor,
                            inputs: copyInputs,
                            result: res,
                            warnings: warnings,
                            formula: formula,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        FeSectionHeader(l.calcMethod),
        CalculatorStatusPanel(
          engineId: descriptor.id,
          engineVersion: descriptor.engineVersion,
        ),
        FeSectionHeader(l.calcFormula),
        Text(formula, style: FeThemeBuilder.numeric(t.titleMedium!)),
        if (formulaNote != null) ...[
          const SizedBox(height: FeSpace.xxs),
          Text(
            formulaNote!,
            key: const Key('calc.formulaNote'),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
        FeSectionHeader(l.calcAssumptions),
        for (final a in assumptions) _Bullet(a),
        FeSectionHeader(l.calcLimitations),
        for (final a in limitations) _Bullet(a),
        FeSectionHeader(l.calcReferences),
        if (references.isEmpty)
          Text(
            l.calcDefinitional,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          )
        else
          for (final r in references) _Bullet(r),
        const SizedBox(height: FeSpace.xl),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Text(FeGlyphs.bullet, style: t.bodyMedium)),
          Expanded(child: Text(text, style: t.bodyMedium)),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    this.k,
    this.signed = false,
  });

  final String label;
  final TextEditingController controller;
  final String? k;

  /// Manfiy qiymat mumkinmi (masalan, muhit harorati).
  final bool signed;

  @override
  Widget build(BuildContext context) => TextField(
    key: k == null ? null : Key(k!),
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(
      decimal: true,
      signed: signed,
    ),
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(labelText: label),
  );
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.label,
    required this.value,
    required this.units,
    required this.onChanged,
  });

  final String label;
  final Unit value;
  final List<Unit> units;
  final ValueChanged<Unit> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<Unit>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final u in units) DropdownMenuItem(value: u, child: Text(u.symbol)),
    ],
    onChanged: (u) {
      if (u != null) onChanged(u);
    },
  );
}

/// Son maydoni va birlik tanlovi bir qatorda.
class _ValueWithUnit extends StatelessWidget {
  const _ValueWithUnit({required this.field, required this.unit});

  final Widget field;
  final Widget unit;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 3, child: field),
      const SizedBox(width: FeSpace.xs),
      Expanded(flex: 2, child: unit),
    ],
  );
}

const _concUnits = [
  Unit.gramPerLiter,
  Unit.milligramPerLiter,
  Unit.microgramPerLiter,
  Unit.milligramPerMilliliter,
  Unit.microgramPerMilliliter,
  Unit.nanogramPerMilliliter,
  Unit.molePerLiter,
  Unit.millimolePerLiter,
  Unit.micromolePerLiter,
];

// ---------------------------------------------------------------------------

class ConcentrationConvertView extends StatefulWidget {
  const ConcentrationConvertView({super.key});

  @override
  State<ConcentrationConvertView> createState() => _ConvertState();
}

class _ConvertState extends State<ConcentrationConvertView>
    with CalcInputsMixin {
  final _calc = const ConcentrationConversionCalculator();
  final _value = TextEditingController();
  final _mm = TextEditingController();
  Unit _from = Unit.milligramPerLiter;
  Unit _to = Unit.nanogramPerMilliliter;
  List<(String, String)>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_value, _mm]);
  }

  @override
  void clearOutput() {
    _result = null;
    _error = null;
  }

  @override
  void dispose() {
    _value.dispose();
    _mm.dispose();
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([_value])) {
      _error = l.calcErrorRequired;
      return;
    }
    final v = calcParse(_value);
    if (v == null) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        ConcentrationConversionInput(
          value: Quantity(v, _from),
          target: _to,
          molarMassGPerMol: calcParse(_mm),
        ),
      );
      _result = [
        (
          '${l.fmtNum(v)} ${_from.symbol} =',
          '${l.fmtNum(r.value.value)} ${_to.symbol}',
        ),
      ];
    } on CalcInputException catch (e) {
      _error = e.code == 'molar_mass_required'
          ? l.calcErrorMolarMass
          : l.calcErrorPositive;
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final needsMolar =
        (_from.dimension == Dimension.molarConcentration) !=
        (_to.dimension == Dimension.molarConcentration);
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        _ValueWithUnit(
          field: _NumberField(
            label: l.calcValue,
            controller: _value,
            k: 'calc.value',
          ),
          unit: _UnitDropdown(
            label: l.calcFrom,
            value: _from,
            units: _concUnits,
            onChanged: (u) => changed(() => _from = u),
          ),
        ),
        _UnitDropdown(
          label: l.calcTo,
          value: _to,
          units: _concUnits,
          onChanged: (u) => changed(() => _to = u),
        ),
        if (needsMolar || _mm.text.isNotEmpty)
          _NumberField(label: l.calcMolarMass, controller: _mm, k: 'calc.mm'),
      ],
      onCalculate: () => _run(l),
      formula: 'ρ = c · M',
      result: _result,
      error: _error,
      copyInputs: [
        (l.calcValue, '${_value.text} ${_from.symbol}'),
        (l.calcTo, _to.symbol),
        (l.calcMolarMass, _mm.text),
      ],
      assumptions: [l.calcConvertAssumption],
      limitations: [l.calcConvertLimitation],
    );
  }
}

class MolarityView extends StatefulWidget {
  const MolarityView({super.key});

  @override
  State<MolarityView> createState() => _MolarityState();
}

class _MolarityState extends State<MolarityView> with CalcInputsMixin {
  final _calc = const MolarityCalculator();
  final _mass = TextEditingController();
  final _mm = TextEditingController();
  final _vol = TextEditingController();
  final _purity = TextEditingController(text: '1');
  Unit _massUnit = Unit.milligram;
  Unit _volUnit = Unit.milliliter;
  List<(String, String)>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_mass, _mm, _vol, _purity]);
  }

  @override
  void clearOutput() {
    _result = null;
    _error = null;
  }

  @override
  void dispose() {
    for (final c in [_mass, _mm, _vol, _purity]) {
      c.dispose();
    }
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([_mass, _mm, _vol, _purity])) {
      _error = l.calcErrorRequired;
      return;
    }
    final m = calcParse(_mass),
        mm = calcParse(_mm),
        v = calcParse(_vol),
        p = calcParse(_purity);
    if (m == null || mm == null || v == null || p == null) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        MolarityInput(
          mass: Quantity(m, _massUnit),
          molarMassGPerMol: mm,
          volume: Quantity(v, _volUnit),
          purityFraction: p,
        ),
      );
      final mmol = r.value.to(Unit.millimolePerLiter);
      _result = [
        (l.calcMolarityResult, '${l.fmtNum(r.value.value)} mol/L'),
        ('', '${l.fmtNum(mmol.value)} mmol/L'),
        ('', '${l.fmtNum(r.value.value * mm)} g/L'),
      ];
    } on CalcInputException catch (e) {
      _error = e.code == 'purity_out_of_range'
          ? l.calcErrorPurity
          : l.calcErrorPositive;
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        _ValueWithUnit(
          field: _NumberField(
            label: l.calcMolarityMass,
            controller: _mass,
            k: 'calc.mass',
          ),
          unit: _UnitDropdown(
            label: l.calcUnit,
            value: _massUnit,
            units: const [Unit.gram, Unit.milligram, Unit.microgram],
            onChanged: (u) => changed(() => _massUnit = u),
          ),
        ),
        _NumberField(label: l.calcMolarMass, controller: _mm, k: 'calc.mm'),
        _ValueWithUnit(
          field: _NumberField(
            label: l.calcMolarityVolume,
            controller: _vol,
            k: 'calc.volume',
          ),
          unit: _UnitDropdown(
            label: l.calcUnit,
            value: _volUnit,
            units: const [Unit.milliliter, Unit.liter, Unit.microliter],
            onChanged: (u) => changed(() => _volUnit = u),
          ),
        ),
        _NumberField(
          label: l.calcPurity,
          controller: _purity,
          k: 'calc.purity',
        ),
      ],
      onCalculate: () => _run(l),
      formula: 'c = m · p / (M · V)',
      result: _result,
      error: _error,
      copyInputs: [
        (l.calcMolarityMass, '${_mass.text} ${_massUnit.symbol}'),
        (l.calcMolarMass, _mm.text),
        (l.calcMolarityVolume, '${_vol.text} ${_volUnit.symbol}'),
        (l.calcPurity, _purity.text),
      ],
      assumptions: [l.calcMolarityAssumption],
      limitations: [l.calcSolutionLimitationRecipe],
    );
  }
}

class PercentSolutionView extends StatefulWidget {
  const PercentSolutionView({super.key});

  @override
  State<PercentSolutionView> createState() => _PercentState();
}

class _PercentState extends State<PercentSolutionView> with CalcInputsMixin {
  final _calc = const PercentSolutionCalculator();
  final _pct = TextEditingController();
  final _total = TextEditingController();
  PercentBasis _basis = PercentBasis.weightPerVolume;
  List<(String, String)>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_pct, _total]);
  }

  @override
  void clearOutput() {
    _result = null;
    _error = null;
  }

  @override
  void dispose() {
    _pct.dispose();
    _total.dispose();
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([_pct, _total])) {
      _error = l.calcErrorRequired;
      return;
    }
    final p = calcParse(_pct), t = calcParse(_total);
    if (p == null || t == null) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        PercentSolutionInput(basis: _basis, percent: p, totalAmount: t),
      );
      _result = [
        (
          l.calcPercentSolute,
          '${l.fmtNum(r.value.soluteAmount)} ${r.value.soluteUnit}',
        ),
      ];
    } on CalcInputException catch (e) {
      _error = e.code == 'percent_out_of_range'
          ? l.calcErrorPercent
          : l.calcErrorPositive;
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String basisLabel(PercentBasis b) => switch (b) {
      PercentBasis.weightPerVolume => l.calcPercentWv,
      PercentBasis.volumePerVolume => l.calcPercentVv,
      PercentBasis.weightPerWeight => l.calcPercentWw,
    };
    final totalLabel = _basis == PercentBasis.weightPerWeight
        ? l.calcPercentTotalG
        : l.calcPercentTotalMl;
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        DropdownButtonFormField<PercentBasis>(
          initialValue: _basis,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.calcPercentBasis),
          items: [
            for (final b in PercentBasis.values)
              DropdownMenuItem(value: b, child: Text(basisLabel(b))),
          ],
          onChanged: (b) {
            if (b != null) changed(() => _basis = b);
          },
        ),
        _NumberField(
          label: l.calcPercentValue,
          controller: _pct,
          k: 'calc.percent',
        ),
        _NumberField(label: totalLabel, controller: _total, k: 'calc.total'),
      ],
      onCalculate: () => _run(l),
      formula: 'x = % · total / 100',
      result: _result,
      error: _error,
      copyInputs: [
        (l.calcPercentBasis, basisLabel(_basis)),
        (l.calcPercentValue, _pct.text),
        (totalLabel, _total.text),
      ],
      assumptions: [l.calcPercentAssumption],
      limitations: [
        l.calcPercentLimitationBasis,
        l.calcSolutionLimitationRecipe,
      ],
    );
  }
}

class DescriptiveStatsView extends StatefulWidget {
  const DescriptiveStatsView({super.key});

  @override
  State<DescriptiveStatsView> createState() => _StatsState();
}

class _StatsState extends State<DescriptiveStatsView> with CalcInputsMixin {
  final _calc = const DescriptiveStatsCalculator();
  final _values = TextEditingController();
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_values]);
  }

  @override
  void clearOutput() {
    _result = null;
    _error = null;
    _warnings = const [];
  }

  @override
  void dispose() {
    _values.dispose();
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([_values])) {
      _error = l.calcErrorRequired;
      return;
    }
    try {
      final r = _calc.calculate(parseValues(_values.text));
      final s = r.value;
      _result = [
        (l.calcStatsN, '${s.n}'),
        (l.calcStatsMean, l.fmtNum(s.mean)),
        (l.calcStatsMedian, l.fmtNum(s.median)),
        (l.calcStatsSd, s.sd == null ? FeGlyphs.emDash : l.fmtNum(s.sd!)),
        (
          l.calcStatsCv,
          s.cvPercent == null ? FeGlyphs.emDash : l.fmtNum(s.cvPercent!),
        ),
        (l.calcStatsMin, l.fmtNum(s.min)),
        (l.calcStatsMax, l.fmtNum(s.max)),
      ];
      _warnings = [if (r.warnings.isNotEmpty) l.calcStatsWarnSd];
    } on FormatException {
      _error = l.calcErrorValues;
    } on CalcInputException {
      _error = l.calcErrorValues;
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const formula = 's = √(Σ(xᵢ − x̄)² / (n − 1));  CV = s / x̄ · 100';
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        TextField(
          key: const Key('calc.values'),
          controller: _values,
          minLines: 3,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: l.calcStatsValues,
            alignLabelWithHint: true,
          ),
        ),
      ],
      onCalculate: () => _run(l),
      formula: formula,
      result: _result,
      warnings: _warnings,
      error: _error,
      emphasizeFirst: false,
      copyInputs: [(l.calcStatsValues, _values.text.replaceAll('\n', '; '))],
      assumptions: [l.calcStatsAssumption],
      limitations: [l.calcStatsLimitation],
    );
  }
}

/// Kalibrlash (OLS) — ixtiyoriy ravishda LOD/LOQ (ICH Q2(R2)) ga uzatish.
class CalibrationView extends StatefulWidget {
  const CalibrationView({super.key, this.withLimits = false});

  /// `true` — LOD/LOQ vositasi: σ va S qo‘lda yoki regressiyadan.
  final bool withLimits;

  @override
  State<CalibrationView> createState() => _CalibrationState();
}

class _CalibrationState extends State<CalibrationView> with CalcInputsMixin {
  final _reg = const LinearRegressionCalculator();
  final _lod = const LodLoqCalculator();
  final _points = TextEditingController();
  final _sigma = TextEditingController();
  final _slope = TextEditingController();
  SigmaBasis _basis = SigmaBasis.residualSd;
  RegressionResult? _regression;
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_points, _sigma, _slope]);
  }

  @override
  void clearOutput() {
    _result = null;
    _error = null;
    _warnings = const [];
  }

  @override
  void dispose() {
    for (final c in [_points, _sigma, _slope]) {
      c.dispose();
    }
    super.dispose();
  }

  void _regress(AppLocalizations l) => setState(() {
    clearOutput();
    _regression = null;
    if (calcAnyEmpty([_points])) {
      _error = l.calcErrorPoints;
      return;
    }
    try {
      final r = _reg.calculate(parsePoints(_points.text));
      _regression = r.value;
      _result = [
        (l.calcRegSlope, l.fmtNum(r.value.slope)),
        (l.calcRegIntercept, l.fmtNum(r.value.intercept)),
        (l.calcRegR2, l.fmtFixed(r.value.rSquared, 5)),
        (l.calcRegSyx, l.fmtNum(r.value.residualSd)),
        ('n', '${r.value.n}'),
      ];
      _warnings = [if (r.warnings.isNotEmpty) l.calcRegWarnFew];
    } on FormatException {
      _error = l.calcErrorPoints;
    } on CalcInputException {
      _error = l.calcErrorPoints;
    }
  });

  void _limits(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([_sigma, _slope])) {
      _error = l.calcErrorRequired;
      return;
    }
    final s = calcParse(_sigma), b = calcParse(_slope);
    if (s == null || b == null) {
      _error = l.calcErrorSigma;
      return;
    }
    try {
      final r = _lod.calculate(
        LodLoqInput(sigma: s, slope: b, sigmaBasis: _basis),
      );
      _result = [
        (l.calcLodLod, l.fmtNum(r.value.lod)),
        (l.calcLodLoq, l.fmtNum(r.value.loq)),
      ];
    } on CalcInputException {
      _error = l.calcErrorSigma;
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pointsField = TextField(
      key: const Key('calc.points'),
      controller: _points,
      minLines: 4,
      maxLines: 10,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: l.calcRegPoints,
        alignLabelWithHint: true,
      ),
    );
    final pointsCopy = (
      l.calcRegPoints,
      _points.text.trim().replaceAll('\n', '; '),
    );
    if (!widget.withLimits) {
      return CalcScaffold(
        descriptor: _reg.descriptor,
        inputs: [pointsField],
        onCalculate: () => _regress(l),
        formula: 'y = a + b·x',
        result: _result,
        warnings: _warnings,
        error: _error,
        emphasizeFirst: false,
        copyInputs: [pointsCopy],
        assumptions: [l.calcRegAssumptionOls],
        limitations: [l.calcRegLimitationRange],
      );
    }
    String basisLabel(SigmaBasis b) => switch (b) {
      SigmaBasis.blankSd => l.calcLodBasisBlank,
      SigmaBasis.residualSd => l.calcLodBasisResidual,
      SigmaBasis.interceptSd => l.calcLodBasisIntercept,
    };
    final reg = _regression;
    return CalcScaffold(
      descriptor: _lod.descriptor,
      inputs: [
        pointsField,
        OutlinedButton(
          key: const Key('calc.regress'),
          onPressed: () {
            _regress(l);
            final r = _regression;
            if (r != null && _error == null) {
              _sigma.text = l.fmtNum(r.residualSd);
              _slope.text = l.fmtNum(r.slope);
              changed(() => _basis = SigmaBasis.residualSd);
            }
          },
          child: Text(l.calcUseRegression, textAlign: TextAlign.center),
        ),
        if (reg != null)
          Text(
            '${l.calcRegSlope}: ${l.fmtNum(reg.slope)} · '
            '${l.calcRegSyx}: ${l.fmtNum(reg.residualSd)} · '
            '${l.calcRegR2} ${l.fmtFixed(reg.rSquared, 4)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        DropdownButtonFormField<SigmaBasis>(
          initialValue: _basis,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.calcLodSigmaBasis),
          items: [
            for (final b in SigmaBasis.values)
              DropdownMenuItem(value: b, child: Text(basisLabel(b))),
          ],
          onChanged: (b) {
            if (b != null) changed(() => _basis = b);
          },
        ),
        _NumberField(
          label: l.calcLodSigma,
          controller: _sigma,
          k: 'calc.sigma',
        ),
        _NumberField(
          label: l.calcLodSlope,
          controller: _slope,
          k: 'calc.slope',
          signed: true,
        ),
      ],
      onCalculate: () => _limits(l),
      formula: 'DL = 3.3 σ / S;  QL = 10 σ / S',
      result: _result,
      error: _error,
      resultNote: l.calcLodUnitNote,
      copyInputs: [
        if (_points.text.trim().isNotEmpty) pointsCopy,
        (l.calcLodSigmaBasis, basisLabel(_basis)),
        (l.calcLodSigma, _sigma.text),
        (l.calcLodSlope, _slope.text),
      ],
      assumptions: [l.calcLodAssumptionSigma, l.calcLodAssumptionLinear],
      limitations: [l.calcLodLimitationOne, l.calcLodLimitationVerify],
      references: [l.calcLodReference, l.calcLodReferenceNote],
    );
  }
}
