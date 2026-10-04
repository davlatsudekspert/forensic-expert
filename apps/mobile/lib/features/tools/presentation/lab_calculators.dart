import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:fe_content_schema/fe_content_schema.dart' show ScientificStatus;
import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';

/// PHASE 6 laboratoriya kalkulyatorlari. Har biri bir xil tuzilma:
/// INPUT → FORMULA → RESULT → ASSUMPTIONS → LIMITATIONS → REFERENCES.
/// Hisob `fe_calc_engine` da (UI’dan mustaqil, sof va test qilingan).

String formatNumber(double v) {
  if (v == 0) return '0';
  final s = v.toStringAsPrecision(6);
  return s.contains('e') ? s : double.parse(s).toString();
}

double? _num(TextEditingController c) =>
    double.tryParse(c.text.trim().replaceAll(',', '.'));

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final res = result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.calcInput),
        for (final w in inputs) ...[w, const SizedBox(height: FeSpace.sm)],
        FilledButton(
          key: const Key('calc.calculate'),
          onPressed: onCalculate,
          child: Text(l.calcCalculate),
        ),
        if (error != null) ...[
          const SizedBox(height: FeSpace.sm),
          FeBanner(
            key: const Key('calc.error'),
            icon: Icons.error_outline,
            text: error!,
            tone: FeBannerTone.warning,
          ),
        ],
        FeSectionHeader(l.calcResult),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(FeRadius.md),
            border: Border.all(color: c.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: res == null
                ? Text(
                    FeGlyphs.emDash,
                    style: FeThemeBuilder.numeric(t.titleLarge!),
                  )
                : Column(
                    key: const Key('calc.result'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (k, v) in res)
                        MergeSemantics(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: FeSpace.xxs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(k, style: t.bodyMedium)),
                                const SizedBox(width: FeSpace.sm),
                                Text(
                                  v,
                                  style: FeThemeBuilder.numeric(t.titleMedium!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      for (final w in warnings) ...[
                        const SizedBox(height: FeSpace.xs),
                        FeBanner(
                          icon: Icons.warning_amber_rounded,
                          text: w,
                          tone: FeBannerTone.warning,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        FeSectionHeader(l.calcMethod),
        Wrap(
          spacing: FeSpace.sm,
          runSpacing: FeSpace.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const ReviewStatusBadge(status: ScientificStatus.needsReview),
            Text(
              '${descriptor.id} · v${descriptor.engineVersion}',
              style: FeThemeBuilder.numeric(t.bodySmall!)
                  .copyWith(color: c.textSecondary),
            ),
          ],
        ),
        FeSectionHeader(l.calcFormula),
        Text(formula, style: FeThemeBuilder.numeric(t.titleMedium!)),
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
  const _NumberField({required this.label, required this.controller, this.k});

  final String label;
  final TextEditingController controller;
  final String? k;

  @override
  Widget build(BuildContext context) => TextField(
    key: k == null ? null : Key(k!),
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
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

class _ConvertState extends State<ConcentrationConvertView> {
  final _calc = const ConcentrationConversionCalculator();
  final _value = TextEditingController();
  final _mm = TextEditingController();
  Unit _from = Unit.milligramPerLiter;
  Unit _to = Unit.nanogramPerMilliliter;
  List<(String, String)>? _result;
  String? _error;

  @override
  void dispose() {
    _value.dispose();
    _mm.dispose();
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    _result = null;
    _error = null;
    final v = _num(_value);
    if (v == null) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        ConcentrationConversionInput(
          value: Quantity(v, _from),
          target: _to,
          molarMassGPerMol: _num(_mm),
        ),
      );
      _result = [
        (l.calcResult, '${formatNumber(r.value.value)} ${_to.symbol}'),
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
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        _NumberField(label: l.calcValue, controller: _value, k: 'calc.value'),
        _UnitDropdown(
          label: l.calcFrom,
          value: _from,
          units: _concUnits,
          onChanged: (u) => setState(() => _from = u),
        ),
        _UnitDropdown(
          label: l.calcTo,
          value: _to,
          units: _concUnits,
          onChanged: (u) => setState(() => _to = u),
        ),
        _NumberField(label: l.calcMolarMass, controller: _mm, k: 'calc.mm'),
      ],
      onCalculate: () => _run(l),
      formula: 'ρ = c · M',
      result: _result,
      error: _error,
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

class _MolarityState extends State<MolarityView> {
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
  void dispose() {
    for (final c in [_mass, _mm, _vol, _purity]) {
      c.dispose();
    }
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    _result = null;
    _error = null;
    final m = _num(_mass), mm = _num(_mm), v = _num(_vol), p = _num(_purity);
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
        (l.calcMolarityResult, '${formatNumber(r.value.value)} mol/L'),
        ('', '${formatNumber(mmol.value)} mmol/L'),
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
        _NumberField(
          label: l.calcMolarityMass,
          controller: _mass,
          k: 'calc.mass',
        ),
        _UnitDropdown(
          label: l.calcUnit,
          value: _massUnit,
          units: const [Unit.gram, Unit.milligram, Unit.microgram],
          onChanged: (u) => setState(() => _massUnit = u),
        ),
        _NumberField(label: l.calcMolarMass, controller: _mm, k: 'calc.mm'),
        _NumberField(
          label: l.calcMolarityVolume,
          controller: _vol,
          k: 'calc.volume',
        ),
        _UnitDropdown(
          label: l.calcUnit,
          value: _volUnit,
          units: const [Unit.milliliter, Unit.liter, Unit.microliter],
          onChanged: (u) => setState(() => _volUnit = u),
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

class _PercentState extends State<PercentSolutionView> {
  final _calc = const PercentSolutionCalculator();
  final _pct = TextEditingController();
  final _total = TextEditingController();
  PercentBasis _basis = PercentBasis.weightPerVolume;
  List<(String, String)>? _result;
  String? _error;

  @override
  void dispose() {
    _pct.dispose();
    _total.dispose();
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    _result = null;
    _error = null;
    final p = _num(_pct), t = _num(_total);
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
          '${formatNumber(r.value.soluteAmount)} ${r.value.soluteUnit}',
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
            if (b != null) setState(() => _basis = b);
          },
        ),
        _NumberField(
          label: l.calcPercentValue,
          controller: _pct,
          k: 'calc.percent',
        ),
        _NumberField(
          label: _basis == PercentBasis.weightPerWeight
              ? l.calcPercentTotalG
              : l.calcPercentTotalMl,
          controller: _total,
          k: 'calc.total',
        ),
      ],
      onCalculate: () => _run(l),
      formula: 'x = % · total / 100',
      result: _result,
      error: _error,
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

class _StatsState extends State<DescriptiveStatsView> {
  final _calc = const DescriptiveStatsCalculator();
  final _values = TextEditingController();
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

  @override
  void dispose() {
    _values.dispose();
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    _result = null;
    _error = null;
    _warnings = const [];
    try {
      final r = _calc.calculate(parseValues(_values.text));
      final s = r.value;
      _result = [
        (l.calcStatsN, '${s.n}'),
        (l.calcStatsMean, formatNumber(s.mean)),
        (l.calcStatsMedian, formatNumber(s.median)),
        (l.calcStatsSd, s.sd == null ? FeGlyphs.emDash : formatNumber(s.sd!)),
        (
          l.calcStatsCv,
          s.cvPercent == null ? FeGlyphs.emDash : formatNumber(s.cvPercent!),
        ),
        (l.calcStatsMin, formatNumber(s.min)),
        (l.calcStatsMax, formatNumber(s.max)),
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
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        TextField(
          key: const Key('calc.values'),
          controller: _values,
          minLines: 3,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(labelText: l.calcStatsValues),
        ),
      ],
      onCalculate: () => _run(l),
      formula: 's = √(Σ(xᵢ − x̄)² / (n − 1));  CV = s / x̄ · 100',
      result: _result,
      warnings: _warnings,
      error: _error,
      assumptions: [l.calcStatsAssumption],
      limitations: [l.calcStatsLimitation],
    );
  }
}

/// Kalibrlash (OLS) — ixtiyoriy ravishda LOD/LOQ (ICH Q2(R1)) ga uzatish.
class CalibrationView extends StatefulWidget {
  const CalibrationView({super.key, this.withLimits = false});

  /// `true` — LOD/LOQ vositasi: σ va S qo‘lda yoki regressiyadan.
  final bool withLimits;

  @override
  State<CalibrationView> createState() => _CalibrationState();
}

class _CalibrationState extends State<CalibrationView> {
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
  void dispose() {
    for (final c in [_points, _sigma, _slope]) {
      c.dispose();
    }
    super.dispose();
  }

  List<(double, double)> _parsePoints() => [
    for (final line in _points.text.split('\n'))
      if (line.trim().isNotEmpty)
        () {
          final v = parseValues(line.replaceAll(';', ' '));
          if (v.length != 2) throw const FormatException();
          return (v[0], v[1]);
        }(),
  ];

  void _regress(AppLocalizations l) => setState(() {
    _error = null;
    _result = null;
    _warnings = const [];
    try {
      final r = _reg.calculate(_parsePoints());
      _regression = r.value;
      _result = [
        (l.calcRegSlope, formatNumber(r.value.slope)),
        (l.calcRegIntercept, formatNumber(r.value.intercept)),
        (l.calcRegR2, r.value.rSquared.toStringAsFixed(5)),
        (l.calcRegSyx, formatNumber(r.value.residualSd)),
      ];
      _warnings = [if (r.warnings.isNotEmpty) l.calcRegWarnFew];
    } on FormatException {
      _error = l.calcErrorPoints;
    } on CalcInputException {
      _error = l.calcErrorPoints;
    }
  });

  void _limits(AppLocalizations l) => setState(() {
    _error = null;
    _result = null;
    final s = _num(_sigma), b = _num(_slope);
    if (s == null || b == null) {
      _error = l.calcErrorSigma;
      return;
    }
    try {
      final r = _lod.calculate(
        LodLoqInput(sigma: s, slope: b, sigmaBasis: _basis),
      );
      _result = [
        (l.calcLodLod, formatNumber(r.value.lod)),
        (l.calcLodLoq, formatNumber(r.value.loq)),
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
      decoration: InputDecoration(labelText: l.calcRegPoints),
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
              _sigma.text = formatNumber(r.residualSd);
              _slope.text = formatNumber(r.slope);
              setState(() => _basis = SigmaBasis.residualSd);
            }
          },
          child: Text(l.calcUseRegression),
        ),
        if (reg != null)
          Text(
            '${l.calcRegSlope}: ${formatNumber(reg.slope)} · '
            '${l.calcRegSyx}: ${formatNumber(reg.residualSd)}',
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
            if (b != null) setState(() => _basis = b);
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
        ),
      ],
      onCalculate: () => _limits(l),
      formula: 'DL = 3.3 σ / S;  QL = 10 σ / S',
      result: _result,
      error: _error,
      assumptions: [l.calcLodAssumptionSigma, l.calcLodAssumptionLinear],
      limitations: [l.calcLodLimitationOne, l.calcLodLimitationVerify],
      references: [l.calcLodReference, l.calcLodReferenceNote],
    );
  }
}
