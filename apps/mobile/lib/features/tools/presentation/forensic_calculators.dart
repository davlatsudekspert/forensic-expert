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

String _p(double v) => v.toStringAsFixed(2);

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

class _WidmarkState extends State<WidmarkView> {
  final _calc = const WidmarkCalculator();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _hours = TextEditingController();
  final _drinks = <(TextEditingController, TextEditingController)>[
    (TextEditingController(), TextEditingController()),
  ];
  BiologicalSex _sex = BiologicalSex.male;
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

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
    _result = null;
    _warnings = const [];
    _error = null;
    final w = _num(_weight), t = _num(_hours);
    final h = _height.text.trim().isEmpty ? null : _num(_height);
    final drinks = <Drink>[];
    for (final (v, a) in _drinks) {
      final vol = _num(v), abv = _num(a);
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
        (l.calcWidmarkEthanol, '${v.ethanolGrams.toStringAsFixed(1)} g'),
        (l.calcWidmarkR, v.r.toStringAsFixed(3)),
        (l.calcWidmarkPeak, '${_p(v.peakPromille)} ‰'),
        (l.calcWidmarkMin, '${_p(v.minPromille)} ‰'),
        (l.calcWidmarkMax, '${_p(v.maxPromille)} ‰'),
      ];
      _warnings = [for (final w in r.warnings) _warningFor(l, w)];
    } on CalcInputException catch (e) {
      _error = _errorFor(l, e);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
            if (s != null) setState(() => _sex = s);
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
                  onPressed: () => setState(() {
                    final (v, a) = _drinks.removeAt(i);
                    v.dispose();
                    a.dispose();
                  }),
                ),
            ],
          ),
          _NumberField(
            label: l.calcDrinkVolume,
            controller: _drinks[i].$1,
            k: 'calc.drink.$i.volume',
          ),
          _NumberField(
            label: l.calcDrinkAbv,
            controller: _drinks[i].$2,
            k: 'calc.drink.$i.abv',
          ),
        ],
        if (_drinks.length < 6)
          OutlinedButton.icon(
            key: const Key('calc.addDrink'),
            onPressed: () => setState(
              () => _drinks.add((
                TextEditingController(),
                TextEditingController(),
              )),
            ),
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

class _BackCalcState extends State<BackCalculationView> {
  final _calc = const BackCalculationCalculator();
  final _bac = TextEditingController();
  final _dt = TextEditingController();
  final _end = TextEditingController();
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

  @override
  void dispose() {
    for (final c in [_bac, _dt, _end]) {
      c.dispose();
    }
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    _result = null;
    _warnings = const [];
    _error = null;
    final c = _num(_bac), dt = _num(_dt);
    final end = _end.text.trim().isEmpty ? null : _num(_end);
    if (c == null ||
        dt == null ||
        (_end.text.trim().isNotEmpty && end == null)) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc.calculate(
        BackCalculationInput(
          measuredPromille: c,
          hoursBetweenEventAndSampling: dt,
          hoursFromDrinkingEndToEvent: end,
        ),
      );
      _result = [
        (l.calcBackMin, '${_p(r.value.minPromille)} ‰'),
        (l.calcBackMax, '${_p(r.value.maxPromille)} ‰'),
      ];
      _warnings = [for (final w in r.warnings) _warningFor(l, w)];
    } on CalcInputException catch (e) {
      _error = _errorFor(l, e);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        _NumberField(label: l.calcBacMeasured, controller: _bac, k: 'calc.bac'),
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
      formula: 'c₀ = cₜ + β·Δt,  β = 0.10…0.25',
      result: _result,
      warnings: _warnings,
      error: _error,
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

class _EthanolUnitsState extends State<EthanolUnitsView> {
  final _calc = const EthanolUnitsCalculator();
  final _value = TextEditingController();
  final _ratio = TextEditingController(
    text: EthanolUnitsCalculator.defaultSerumBloodRatio.toString(),
  );
  EthanolUnit _unit = EthanolUnit.promille;
  EthanolMatrix _matrix = EthanolMatrix.wholeBlood;
  List<(String, String)>? _result;
  String? _error;

  @override
  void dispose() {
    _value.dispose();
    _ratio.dispose();
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    _result = null;
    _error = null;
    final v = _num(_value), q = _num(_ratio);
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
          (u.symbol, formatNumber(r.value.wholeBlood[u]!)),
      ];
    } on CalcInputException catch (e) {
      _error = _errorFor(l, e);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        _NumberField(label: l.calcValue, controller: _value, k: 'calc.value'),
        DropdownButtonFormField<EthanolUnit>(
          key: const Key('calc.ethanolUnit'),
          initialValue: _unit,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.calcUnit),
          items: [
            for (final u in EthanolUnit.values)
              DropdownMenuItem(value: u, child: Text(u.symbol)),
          ],
          onChanged: (u) {
            if (u != null) setState(() => _unit = u);
          },
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
            if (m != null) setState(() => _matrix = m);
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
      formula:
          'g/L = ‰ · 1.055;  mmol/L = g/L ÷ 46.07 · 1000;  '
          'c(blood) = c(serum) ÷ Q',
      result: _result,
      error: _error,
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

class _HenssgeState extends State<HenssgeView> {
  final _calc = const HenssgeCalculator();
  final _rectal = TextEditingController();
  final _ambient = TextEditingController();
  final _weight = TextEditingController();
  double _factor = 1.0;
  List<(String, String)>? _result;
  List<String> _warnings = const [];
  String? _error;

  @override
  void dispose() {
    for (final c in [_rectal, _ambient, _weight]) {
      c.dispose();
    }
    super.dispose();
  }

  void _run(AppLocalizations l) => setState(() {
    _result = null;
    _warnings = const [];
    _error = null;
    final tr = _num(_rectal), ta = _num(_ambient), m = _num(_weight);
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
      final lo = (v.hours - v.ci95Hours).clamp(0, double.infinity);
      _result = [
        (l.calcHenssgeTime, l.calcHoursValue(v.hours.toStringAsFixed(1))),
        (
          l.calcHenssgeRange,
          l.calcHoursRange(
            lo.toStringAsFixed(1),
            (v.hours + v.ci95Hours).toStringAsFixed(1),
          ),
        ),
        ('Q', v.q.toStringAsFixed(3)),
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
            if (f != null) setState(() => _factor = f);
          },
        ),
      ],
      onCalculate: () => _run(l),
      formula:
          '(Tr − Ta)/(37.2 − Ta) = 1.25·e^(Bt) − 0.25·e^(5Bt)\n'
          'B = −1.2815·(c·m)^(−0.625) + 0.0284',
      result: _result,
      warnings: _warnings,
      error: _error,
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
