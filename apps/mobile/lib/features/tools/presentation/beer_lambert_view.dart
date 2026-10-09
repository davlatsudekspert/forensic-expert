part of 'lab_calculators.dart';

/// Ber–Lambert A = ε·l·c: A, c yoki ε (a) ni topish. Ta’rifiy hisob —
/// ilovada hech qanday ε qiymati saqlanmaydi (foydalanuvchi o‘z
/// kalibrlashidan yoki tekshirilgan manbadan kiritadi).
class BeerLambertView extends StatefulWidget {
  const BeerLambertView({super.key});

  @override
  State<BeerLambertView> createState() => _BeerLambertState();
}

class _BeerLambertState extends State<BeerLambertView> with CalcInputsMixin {
  static const _molarUnits = [
    Unit.molePerLiter,
    Unit.millimolePerLiter,
    Unit.micromolePerLiter,
  ];
  static const _massUnits = [
    Unit.gramPerLiter,
    Unit.milligramPerLiter,
    Unit.milligramPerMilliliter,
    Unit.microgramPerMilliliter,
    Unit.microgramPerLiter,
  ];

  final _calc = const BeerLambertCalculator();
  final _absorbance = TextEditingController();
  final _absorptivity = TextEditingController();
  final _path = TextEditingController(text: '1');
  final _conc = TextEditingController();
  BeerLambertUnknown _unknown = BeerLambertUnknown.concentration;
  AbsorptivityBasis _basis = AbsorptivityBasis.molar;
  PathLengthUnit _pathUnit = PathLengthUnit.centimeter;
  Unit _concUnit = Unit.micromolePerLiter;
  List<(String, String)>? _result;
  String? _note;
  String? _error;

  List<TextEditingController> get _controllers => [
    _absorbance,
    _absorptivity,
    _path,
    _conc,
  ];

  @override
  void initState() {
    super.initState();
    watchInputs(_controllers);
  }

  @override
  void clearOutput() {
    _result = null;
    _note = null;
    _error = null;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<Unit> get _units =>
      _basis == AbsorptivityBasis.molar ? _molarUnits : _massUnits;

  String _absorptivityLabel(AppLocalizations l) =>
      _basis == AbsorptivityBasis.molar
      ? l.calcBeerAbsorptivityMolar
      : l.calcBeerAbsorptivityMass;

  String _unknownLabel(AppLocalizations l, BeerLambertUnknown u) => switch (u) {
    BeerLambertUnknown.absorbance => l.calcBeerAbsorbance,
    BeerLambertUnknown.concentration => l.calcBeerConcentration,
    BeerLambertUnknown.absorptivity => _absorptivityLabel(l),
  };

  String _symbol(BeerLambertUnknown u) => switch (u) {
    BeerLambertUnknown.absorbance => 'A',
    BeerLambertUnknown.concentration => 'c',
    BeerLambertUnknown.absorptivity =>
      _basis == AbsorptivityBasis.molar ? 'ε' : 'a',
  };

  /// «Nom (belgi)» — belgi formula belgisidir (A, c, ε, a), tarjima qilinmaydi.
  static String _withSymbol(String name, String symbol) => '$name ($symbol)';

  String _chipText(AppLocalizations l, BeerLambertUnknown u) =>
      '${_symbol(u)} · ${_unknownLabel(l, u)}';

  void _run(AppLocalizations l) => setState(() {
    clearOutput();
    final needed = [
      _path,
      if (_unknown != BeerLambertUnknown.absorbance) _absorbance,
      if (_unknown != BeerLambertUnknown.absorptivity) _absorptivity,
      if (_unknown != BeerLambertUnknown.concentration) _conc,
    ];
    if (calcAnyEmpty(needed)) {
      _error = l.calcErrorRequired;
      return;
    }
    double? read(TextEditingController c, BeerLambertUnknown u) =>
        _unknown == u ? null : calcParse(c);
    final path = calcParse(_path);
    final a = read(_absorbance, BeerLambertUnknown.absorbance);
    final eps = read(_absorptivity, BeerLambertUnknown.absorptivity);
    final c = read(_conc, BeerLambertUnknown.concentration);
    if (path == null ||
        (_unknown != BeerLambertUnknown.absorbance && a == null) ||
        (_unknown != BeerLambertUnknown.absorptivity && eps == null) ||
        (_unknown != BeerLambertUnknown.concentration && c == null)) {
      _error = l.calcErrorPositive;
      return;
    }
    try {
      final r = _calc
          .calculate(
            BeerLambertInput(
              basis: _basis,
              pathLength: path,
              pathLengthUnit: _pathUnit,
              absorbance: a,
              absorptivity: eps,
              concentration: c == null ? null : Quantity(c, _concUnit),
              concentrationUnit: _concUnit,
            ),
          )
          .value;
      final label = '${_unknownLabel(l, _unknown)} (${_symbol(_unknown)})';
      _result = switch (_unknown) {
        BeerLambertUnknown.absorbance => [(label, l.fmtNum(r.value!))],
        BeerLambertUnknown.absorptivity => [
          (label, '${l.fmtNum(r.value!)} ${_basis.symbol}'),
        ],
        BeerLambertUnknown.concentration => [
          (
            label,
            '${l.fmtNum(r.concentration!.value)} '
                '${r.concentration!.unit.symbol}',
          ),
        ],
      };
      if (r.concentration case final q?) {
        // Boshqa birliklar — bitta izoh qatorida (tor ekranda ham sig‘adi).
        _note = [
          for (final u in _units)
            if (u != q.unit) '${l.fmtNum(q.to(u).value)} ${u.symbol}',
        ].join(' = ');
      }
    } on CalcInputException catch (e) {
      _error = e.code == 'concentration_basis_mismatch'
          ? l.calcBeerErrorBasis
          : l.calcErrorPositive;
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return CalcScaffold(
      descriptor: _calc.descriptor,
      inputs: [
        Text(l.calcSolveFor, style: t.labelLarge),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final u in BeerLambertUnknown.values)
              ChoiceChip(
                key: Key('calc.unknown.${u.name}'),
                label: Text(_chipText(l, u)),
                selected: _unknown == u,
                onSelected: (_) => changed(() => _unknown = u),
              ),
          ],
        ),
        Text(l.calcBeerBasis, style: t.labelLarge),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final b in AbsorptivityBasis.values)
              ChoiceChip(
                key: Key('calc.basis.${b.name}'),
                label: Text(
                  b == AbsorptivityBasis.molar
                      ? l.calcBeerBasisMolar
                      : l.calcBeerBasisMass,
                ),
                selected: _basis == b,
                onSelected: (_) => changed(() {
                  _basis = b;
                  _concUnit = b == AbsorptivityBasis.molar
                      ? Unit.micromolePerLiter
                      : Unit.milligramPerLiter;
                }),
              ),
          ],
        ),
        if (_unknown != BeerLambertUnknown.absorbance)
          _NumberField(
            label: _withSymbol(l.calcBeerAbsorbance, 'A'),
            controller: _absorbance,
            k: 'calc.absorbance',
          ),
        if (_unknown != BeerLambertUnknown.absorptivity)
          _NumberField(
            label:
                '${_absorptivityLabel(l)} '
                '(${_symbol(BeerLambertUnknown.absorptivity)})',
            suffix: _basis.symbol,
            controller: _absorptivity,
            k: 'calc.absorptivity',
          ),
        _ValueWithUnit(
          field: _NumberField(
            label: l.calcBeerPath,
            controller: _path,
            k: 'calc.path',
          ),
          unit: DropdownButtonFormField<PathLengthUnit>(
            key: const Key('calc.pathUnit'),
            initialValue: _pathUnit,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.calcUnit),
            items: [
              for (final u in PathLengthUnit.values)
                DropdownMenuItem(value: u, child: Text(u.symbol)),
            ],
            onChanged: (u) {
              if (u != null) changed(() => _pathUnit = u);
            },
          ),
        ),
        if (_unknown == BeerLambertUnknown.concentration)
          KeyedSubtree(
            key: ValueKey('calc.resultUnit.${_basis.name}'),
            child: _UnitDropdown(
              label: l.calcBeerResultUnit,
              value: _concUnit,
              units: _units,
              onChanged: (u) => changed(() => _concUnit = u),
            ),
          )
        else
          _ValueWithUnit(
            field: _NumberField(
              label: _withSymbol(l.calcBeerConcentration, 'c'),
              controller: _conc,
              k: 'calc.conc',
            ),
            unit: KeyedSubtree(
              key: ValueKey('calc.concUnit.${_basis.name}'),
              child: _UnitDropdown(
                label: l.calcUnit,
                value: _concUnit,
                units: _units,
                onChanged: (u) => changed(() => _concUnit = u),
              ),
            ),
          ),
      ],
      onCalculate: () => _run(l),
      formula: 'A = ε · l · c',
      formulaNote: l.calcBeerFormulaNote,
      result: _result,
      resultNote: _note == null || _note!.isEmpty ? null : '= $_note',
      error: _error,
      copyInputs: [
        if (_unknown != BeerLambertUnknown.absorbance)
          (l.calcBeerAbsorbance, _absorbance.text),
        if (_unknown != BeerLambertUnknown.absorptivity)
          (_absorptivityLabel(l), '${_absorptivity.text} ${_basis.symbol}'),
        (l.calcBeerPath, '${_path.text} ${_pathUnit.symbol}'),
        if (_unknown != BeerLambertUnknown.concentration)
          (l.calcBeerConcentration, '${_conc.text} ${_concUnit.symbol}'),
      ],
      assumptions: [l.calcBeerAssumptionDefinition, l.calcBeerAssumptionBlank],
      limitations: [l.calcBeerLimitationLinear, l.calcBeerLimitationIdentity],
      references: [l.calcBeerReference],
      footer: [
        FeSectionHeader(l.calcBeerRelatedTools),
        for (final tool in const [
          ToolsCatalog.calibration,
          ToolsCatalog.lodLoq,
        ])
          ListTile(
            key: Key('calc.related.${tool.id}'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calculate_outlined),
            title: Text(l.toolName(tool)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.tool(tool.id)),
          ),
      ],
    );
  }
}
