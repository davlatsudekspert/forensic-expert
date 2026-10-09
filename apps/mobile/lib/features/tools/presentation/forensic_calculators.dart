part of 'lab_calculators.dart';

/// Sud-tibbiy va toksikologik kalkulyatorlar: Widmark, teskari hisob,
/// etanol birliklari, Henssge. Hisob — `fe_calc_engine` da; har bir natija
/// diapazon, taxminlar, cheklovlar va manbalar bilan.

const _widmarkRefs = [
  'Widmark E.M.P. (1932). Die theoretischen Grundlagen und die praktische '
      'Verwendbarkeit der gerichtlich-medizinischen Alkoholbestimmung. '
      'Berlin: Urban & Schwarzenberg.',
  'Seidl S., Jensen U., Alt A. (2000). The calculation of blood ethanol '
      'concentrations in males and females. Int J Legal Med 114:71–77.',
  'Jones A.W. (2010). Evidence-based survey of the elimination rates of '
      'ethanol from blood with applications in forensic casework. '
      'Forensic Sci Int 200:1–20.',
];

const _henssgeRefs = [
  'Henssge C. (1988). Death time estimation in case work. I. The rectal '
      'temperature time of death nomogram. Forensic Sci Int 38:209–236.',
  'Henssge C., Madea B. (2004). Estimation of the time since death in the '
      'early post-mortem period. Forensic Sci Int 144:167–175.',
];

const _rainey =
    'Rainey P.M. (1993). Relation between serum and whole-blood ethanol '
    'concentrations. Clin Chem 39:2288–2292.';

String _errorFor(AppLocalizations l, CalcInputException e) => switch (e.code) {
  'weight_out_of_range' => l.calcErrorWeight,
  'time_out_of_range' => l.calcErrorTime,
  'abv_out_of_range' => l.calcErrorAbv,
  'height_out_of_range' => l.calcErrorHeight,
  'bac_out_of_range' => l.calcErrorBac,
  'ratio_out_of_range' => l.calcErrorRatio,
  'rectal_out_of_range' || 'out_of_model_range' => l.calcErrorRectal,
  'ambient_out_of_range' => l.calcErrorAmbient,
  _ => l.calcErrorPositive,
};

String _warningFor(AppLocalizations l, CalcWarning w) => switch (w.code) {
  'fully_eliminated' => l.calcWarnEliminated,
  'r_unusual' => l.calcWarnRUnusual,
  'absorption_phase' => l.calcWarnAbsorption,
  'no_cooling' => l.calcWarnNoCooling,
  'late_phase' => l.calcWarnLatePhase,
  _ => w.code,
};

// ---------------------------------------------------------------------------

class WidmarkView extends StatefulWidget {
  const WidmarkView({super.key});

  @override
  State<WidmarkView> createState() => _WidmarkState();
}

class _WidmarkState extends State<WidmarkView> with CalcInputsMixin {
  final _calc = const WidmarkCalculator();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _hours = TextEditingController();
  final _drinks = <(TextEditingController, TextEditingController)>[];
  BiologicalSex _sex = BiologicalSex.male;
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_weight, _height, _hours]);
    _addDrink();
  }

  void _addDrink() {
    final d = (TextEditingController(), TextEditingController());
    watchInputs([d.$1, d.$2]);
    _drinks.add(d);
  }

  @override
  void clearOutput() {
    _result = null;
    _warnings = const [];
    _error = null;
  }

  @override
  void dispose() {
    for (final c in [_weight, _height, _hours]) {
      c.dispose();
    }
    for (final (v, a) in _drinks) {
      v.dispose();
      a.dispose();
    }
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([
      _weight,
      _hours,
      for (final (v, a) in _drinks) ...[v, a],
    ])) {
      _error = l.calcErrorRequired;
      return;
    }
    final w = calcParse(_weight), t = calcParse(_hours);
    final h = _height.text.trim().isEmpty ? null : calcParse(_height);
    final drinks = <Drink>[];
    for (final (v, a) in _drinks) {
      final vol = calcParse(v), abv = calcParse(a);
      if (vol == null || abv == null) {
        _error = l.calcErrorPositive;
        return;
      }
      drinks.add(Drink(volumeMl: vol, abvPercent: abv));
    }
    if (w == null ||
        t == null ||
        (_height.text.trim().isNotEmpty && h == null)) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        WidmarkInput(
          sex: _sex,
          bodyWeightKg: w,
          heightCm: h,
          drinks: drinks,
          hoursSinceDrinkingStart: t,
        ),
      );
      final v = r.value;
      _result = [
        (
          l.calcEstimatedRange,
          '${l.fmtFixed(v.minPromille, 2)}–${l.fmtFixed(v.maxPromille, 2)} ‰',
        ),
        (l.calcWidmarkMin, '${l.fmtFixed(v.minPromille, 2)} ‰'),
        (l.calcWidmarkMax, '${l.fmtFixed(v.maxPromille, 2)} ‰'),
        (l.calcWidmarkPeak, '${l.fmtFixed(v.peakPromille, 2)} ‰'),
        (l.calcWidmarkEthanol, '${l.fmtFixed(v.ethanolGrams, 1)} g'),
        (l.calcWidmarkR, l.fmtFixed(v.r, 3)),
      ];
      _warnings = [for (final w in r.warnings) _warningFor(l, w)];
    } on CalcInputException catch (e) {
      _error = _errorFor(l, e);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sexLabel = _sex == BiologicalSex.male
        ? l.calcSexMale
        : l.calcSexFemale;
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        DropdownButtonFormField<BiologicalSex>(
          key: const Key('calc.sex'),
          initialValue: _sex,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.calcSex),
          items: [
            DropdownMenuItem(
              value: BiologicalSex.male,
              child: Text(l.calcSexMale),
            ),
            DropdownMenuItem(
              value: BiologicalSex.female,
              child: Text(l.calcSexFemale),
            ),
          ],
          onChanged: (s) {
            if (s != null) changed(() => _sex = s);
          },
        ),
        _NumberField(
          label: l.calcBodyWeight,
          controller: _weight,
          k: 'calc.weight',
        ),
        _NumberField(
          label: l.calcHeightOptional,
          controller: _height,
          k: 'calc.height',
        ),
        for (var i = 0; i < _drinks.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l.calcDrinkN('${i + 1}'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (_drinks.length > 1)
                IconButton(
                  tooltip: l.calcRemoveDrink,
                  icon: const Icon(Icons.close),
                  onPressed: () => changed(() {
                    final (v, a) = _drinks.removeAt(i);
                    v.dispose();
                    a.dispose();
                  }),
                ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _NumberField(
                  label: l.calcDrinkVolume,
                  controller: _drinks[i].$1,
                  k: 'calc.drink.$i.volume',
                ),
              ),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: _NumberField(
                  label: l.calcDrinkAbv,
                  controller: _drinks[i].$2,
                  k: 'calc.drink.$i.abv',
                ),
              ),
            ],
          ),
        ],
        if (_drinks.length < 6)
          OutlinedButton.icon(
            key: const Key('calc.addDrink'),
            onPressed: () => changed(_addDrink),
            icon: const Icon(Icons.add),
            label: Text(l.calcAddDrink),
          ),
        _NumberField(
          label: l.calcHoursSinceStart,
          controller: _hours,
          k: 'calc.hours',
        ),
      ],
      onCalculate: () => _run(l),
      formula: 'c = A·(1 − d) / (m·r) − β·t',
      result: _result,
      warnings: _warnings,
      error: _error,
      copyInputs: [
        (l.calcSex, sexLabel),
        (l.calcBodyWeight, _weight.text),
        (l.calcHeightOptional, _height.text),
        for (var i = 0; i < _drinks.length; i++)
          (
            l.calcDrinkN('${i + 1}'),
            '${_drinks[i].$1.text} mL × ${_drinks[i].$2.text} %',
          ),
        (l.calcHoursSinceStart, _hours.text),
      ],
      assumptions: [
        l.calcWidmarkAssumptionR,
        l.calcWidmarkAssumptionDeficit,
        l.calcWidmarkAssumptionBeta,
      ],
      limitations: [l.calcWidmarkLimitation],
      references: _widmarkRefs,
    );
  }
}

// ---------------------------------------------------------------------------

class BackCalculationView extends StatefulWidget {
  const BackCalculationView({super.key});

  @override
  State<BackCalculationView> createState() => _BackCalcState();
}

class _BackCalcState extends State<BackCalculationView> with CalcInputsMixin {
  final _calc = const BackCalculationCalculator();
  final _bac = TextEditingController();
  final _dt = TextEditingController();
  final _end = TextEditingController();
  EthanolUnit _unit = EthanolUnit.promille;
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_bac, _dt, _end]);
  }

  @override
  void clearOutput() {
    _result = null;
    _warnings = const [];
    _error = null;
  }

  @override
  void dispose() {
    for (final c in [_bac, _dt, _end]) {
      c.dispose();
    }
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([_bac, _dt])) {
      _error = l.calcErrorRequired;
      return;
    }
    final c = calcParse(_bac), dt = calcParse(_dt);
    final end = _end.text.trim().isEmpty ? null : calcParse(_end);
    if (c == null ||
        dt == null ||
        (_end.text.trim().isNotEmpty && end == null)) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        BackCalculationInput(
          measured: c,
          unit: _unit,
          hoursBetweenEventAndSampling: dt,
          hoursFromDrinkingEndToEvent: end,
        ),
      );
      final u = r.value.unit.symbol;
      _result = [
        (
          l.calcEstimatedRange,
          '${l.fmtFixed(r.value.min, 2)}–${l.fmtFixed(r.value.max, 2)} $u',
        ),
        (l.calcBackMin, '${l.fmtFixed(r.value.min, 2)} $u'),
        (l.calcBackMax, '${l.fmtFixed(r.value.max, 2)} $u'),
      ];
      _warnings = [for (final w in r.warnings) _warningFor(l, w)];
    } on CalcInputException catch (e) {
      _error = _errorFor(l, e);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const formula = 'c₀ = cₜ + β·Δt;  β = 0.10…0.25 g/L/h;  ‰: β ÷ 1.055';
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _NumberField(
                label: l.calcBacMeasured,
                controller: _bac,
                k: 'calc.bac',
              ),
            ),
            const SizedBox(width: FeSpace.xs),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<EthanolUnit>(
                key: const Key('calc.bacUnit'),
                initialValue: _unit,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.calcUnit),
                items: [
                  for (final u in const [
                    EthanolUnit.promille,
                    EthanolUnit.gramPerLiter,
                  ])
                    DropdownMenuItem(value: u, child: Text(u.symbol)),
                ],
                onChanged: (u) {
                  if (u != null) changed(() => _unit = u);
                },
              ),
            ),
          ],
        ),
        _NumberField(
          label: l.calcHoursEventToSample,
          controller: _dt,
          k: 'calc.hours',
        ),
        _NumberField(
          label: l.calcHoursDrinkEndOptional,
          controller: _end,
          k: 'calc.drinkEnd',
        ),
      ],
      onCalculate: () => _run(l),
      formula: formula,
      result: _result,
      warnings: _warnings,
      error: _error,
      copyInputs: [
        (l.calcBacMeasured, '${_bac.text} ${_unit.symbol}'),
        (l.calcHoursEventToSample, _dt.text),
        (l.calcHoursDrinkEndOptional, _end.text),
      ],
      assumptions: [l.calcBackAssumptionLinear, l.calcBackAssumptionBeta],
      limitations: [l.calcBackLimitation],
      references: _widmarkRefs.sublist(2),
    );
  }
}

// ---------------------------------------------------------------------------

class EthanolUnitsView extends StatefulWidget {
  const EthanolUnitsView({super.key});

  @override
  State<EthanolUnitsView> createState() => _EthanolUnitsState();
}

class _EthanolUnitsState extends State<EthanolUnitsView> with CalcInputsMixin {
  final _calc = const EthanolUnitsCalculator();
  final _value = TextEditingController();
  late final _ratio = TextEditingController();
  EthanolUnit _unit = EthanolUnit.promille;
  EthanolMatrix _matrix = EthanolMatrix.wholeBlood;
  List<(String, String)>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_value, _ratio]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ratio.text.isEmpty) {
      _ratio.text = AppLocalizations.of(context)
          .fmtNum(EthanolUnitsCalculator.defaultSerumBloodRatio);
    }
  }

  @override
  void clearOutput() {
    _result = null;
    _error = null;
  }

  @override
  void dispose() {
    _value.dispose();
    _ratio.dispose();
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([_value, if (_matrix == EthanolMatrix.serum) _ratio])) {
      _error = l.calcErrorRequired;
      return;
    }
    final v = calcParse(_value), q = calcParse(_ratio);
    if (v == null || q == null) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        EthanolUnitsInput(
          value: v,
          unit: _unit,
          matrix: _matrix,
          serumBloodRatio: q,
        ),
      );
      _result = [
        if (_matrix == EthanolMatrix.serum) (l.calcEthanolBloodHeader, ''),
        for (final u in EthanolUnit.values)
          (u.symbol, l.fmtNum(r.value.wholeBlood[u]!)),
      ];
    } on CalcInputException catch (e) {
      _error = _errorFor(l, e);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const formula =
        'g/L = ‰ · 1.055;  mmol/L = g/L ÷ 46.07 · 1000;  '
        'c(blood) = c(serum) ÷ Q';
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        _ValueWithUnit(
          field: _NumberField(
            label: l.calcValue,
            controller: _value,
            k: 'calc.value',
          ),
          unit: DropdownButtonFormField<EthanolUnit>(
            key: const Key('calc.ethanolUnit'),
            initialValue: _unit,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.calcUnit),
            items: [
              for (final u in EthanolUnit.values)
                DropdownMenuItem(value: u, child: Text(u.symbol)),
            ],
            onChanged: (u) {
              if (u != null) changed(() => _unit = u);
            },
          ),
        ),
        DropdownButtonFormField<EthanolMatrix>(
          key: const Key('calc.matrix'),
          initialValue: _matrix,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.calcEthanolMatrix),
          items: [
            DropdownMenuItem(
              value: EthanolMatrix.wholeBlood,
              child: Text(l.calcMatrixBlood),
            ),
            DropdownMenuItem(
              value: EthanolMatrix.serum,
              child: Text(l.calcMatrixSerum),
            ),
          ],
          onChanged: (m) {
            if (m != null) changed(() => _matrix = m);
          },
        ),
        if (_matrix == EthanolMatrix.serum)
          _NumberField(
            label: l.calcSerumRatio,
            controller: _ratio,
            k: 'calc.ratio',
          ),
      ],
      onCalculate: () => _run(l),
      formula: formula,
      result: _result,
      error: _error,
      emphasizeFirst: false,
      copyInputs: [
        (l.calcValue, '${_value.text} ${_unit.symbol}'),
        (
          l.calcEthanolMatrix,
          _matrix == EthanolMatrix.serum
              ? l.calcMatrixSerum
              : l.calcMatrixBlood,
        ),
        if (_matrix == EthanolMatrix.serum) (l.calcSerumRatio, _ratio.text),
      ],
      assumptions: [
        l.calcEthanolAssumptionDensity,
        l.calcEthanolAssumptionRatio,
      ],
      limitations: [l.calcEthanolLimitation],
      references: const [_rainey],
    );
  }
}

// ---------------------------------------------------------------------------

class HenssgeView extends StatefulWidget {
  const HenssgeView({super.key});

  @override
  State<HenssgeView> createState() => _HenssgeState();
}

class _HenssgeState extends State<HenssgeView> with CalcInputsMixin {
  final _calc = const HenssgeCalculator();
  final _rectal = TextEditingController();
  final _ambient = TextEditingController();
  final _weight = TextEditingController();
  double _factor = 1.0;
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    watchInputs([_rectal, _ambient, _weight]);
    // Formula varianti muhit harorati kiritilishi bilan yangilanadi.
    _ambient.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void clearOutput() {
    _result = null;
    _warnings = const [];
    _error = null;
  }

  @override
  void dispose() {
    for (final c in [_rectal, _ambient, _weight]) {
      c.dispose();
    }
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    if (calcAnyEmpty([_rectal, _ambient, _weight])) {
      _error = l.calcErrorRequired;
      return;
    }
    final tr = calcParse(_rectal),
        ta = calcParse(_ambient),
        m = calcParse(_weight);
    if (tr == null || ta == null || m == null) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        HenssgeInput(
          rectalTempC: tr,
          ambientTempC: ta,
          bodyWeightKg: m,
          correctiveFactor: _factor,
        ),
      );
      final v = r.value;
      final lo = math.max(0.0, v.hours - v.ci95Hours);
      _result = [
        (l.calcHenssgeTime, l.calcHoursValue(l.fmtFixed(v.hours, 1))),
        (
          l.calcHenssgeRange,
          l.calcHoursRange(
            l.fmtFixed(lo, 1),
            l.fmtFixed(v.hours + v.ci95Hours, 1),
          ),
        ),
        ('Q', l.fmtFixed(v.q, 3)),
        ('B', l.fmtFixed(v.b, 4)),
      ];
      _warnings = [for (final w in r.warnings) _warningFor(l, w)];
    } on CalcInputException catch (e) {
      _error = _errorFor(l, e);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final factors = <(double, String)>[
      (1.0, l.calcFactorNakedDry),
      (0.75, l.calcFactorNakedMovingAir),
      (0.5, l.calcFactorWetStill),
      (0.35, l.calcFactorWetFlowing),
      (1.1, l.calcFactorThin),
      (1.2, l.calcFactorLayers),
      (1.3, l.calcFactorThick),
      (2.0, l.calcFactorBedding),
    ];
    final ta = calcParse(_ambient);
    final high = ta != null && HenssgeCalculator.usesHighAmbientFormula(ta);
    final formula = high
        ? '(Tr − Ta)/(37.2 − Ta) = 1.11·e^(Bt) − 0.11·e^(10Bt)\n'
              'B = −1.2815·(c·m)^(−0.625) + 0.0284'
        : '(Tr − Ta)/(37.2 − Ta) = 1.25·e^(Bt) − 0.25·e^(5Bt)\n'
              'B = −1.2815·(c·m)^(−0.625) + 0.0284';
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        _NumberField(
          label: l.calcRectalTemp,
          controller: _rectal,
          k: 'calc.rectal',
        ),
        _NumberField(
          label: l.calcAmbientTemp,
          controller: _ambient,
          k: 'calc.ambient',
          signed: true,
        ),
        _NumberField(
          label: l.calcBodyWeight,
          controller: _weight,
          k: 'calc.weight',
        ),
        DropdownButtonFormField<double>(
          key: const Key('calc.factor'),
          initialValue: _factor,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.calcCorrectiveFactor),
          items: [
            for (final (f, label) in factors)
              DropdownMenuItem(
                value: f,
                child: Text(label, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (f) {
            if (f != null) changed(() => _factor = f);
          },
        ),
      ],
      onCalculate: () => _run(l),
      formula: formula,
      formulaNote: high ? l.calcHenssgeFormulaHigh : l.calcHenssgeFormulaLow,
      result: _result,
      warnings: _warnings,
      error: _error,
      copyInputs: [
        (l.calcRectalTemp, _rectal.text),
        (l.calcAmbientTemp, _ambient.text),
        (l.calcBodyWeight, _weight.text),
        (l.calcCorrectiveFactor, factors.firstWhere((f) => f.$1 == _factor).$2),
      ],
      assumptions: [
        l.calcHenssgeAssumptionNormal,
        l.calcHenssgeAssumptionAmbient,
        l.calcHenssgeAssumptionCi,
      ],
      limitations: [l.calcHenssgeLimitation],
      references: _henssgeRefs,
    );
  }
}
