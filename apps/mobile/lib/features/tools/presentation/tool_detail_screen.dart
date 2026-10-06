import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/user_data.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../common/favorite_button.dart';
import '../../library/presentation/content_entry_sections.dart';
import '../tool_strings.dart';
import 'calculator_status.dart';
import 'lab_calculators.dart';

/// Vosita sahifasi. Mavjud kalkulyator — to‘liq INPUT · METHOD · FORMULA ·
/// RESULT · ASSUMPTIONS · LIMITATIONS · REFERENCES tuzilmasi bilan.
/// Rejalashtirilgan vosita — faqat tavsif va «Rejalashtirilgan» holati.
class ToolDetailScreen extends ConsumerStatefulWidget {
  const ToolDetailScreen({super.key, required this.toolId});

  final String toolId;

  @override
  ConsumerState<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends ConsumerState<ToolDetailScreen> {
  @override
  void initState() {
    super.initState();
    final tool = ToolsCatalog.byId(widget.toolId);
    if (tool != null && tool.isAvailable) {
      // Faqat lokal tarix; telemetriyaga yuborilmaydi.
      Future.microtask(
        () => ref.read(userDataProvider.notifier).recordToolOpened(tool.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tool = ToolsCatalog.byId(widget.toolId);
    if (tool == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l.toolName(tool)),
        actions: [FavoriteButton(id: tool.id)],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child:
                  tool.isAvailable &&
                      !AccessPolicy.isToolUnlocked(
                        tool.id,
                        ref.watch(accessProvider),
                      )
                  ? const LockedContentCard(key: Key('tool.lockedCard'))
                  : tool.engineId == ToolsCatalog.dilution.engineId
                  ? const _DilutionCalculatorView()
                  : tool.engineId == ToolsCatalog.solution.engineId
                  ? const _SolutionCalculatorView()
                  : switch (tool.engineId) {
                      'lab.concentration.convert' =>
                        const ConcentrationConvertView(),
                      'lab.molarity.from_mass' => const MolarityView(),
                      'lab.percent.solute_amount' =>
                        const PercentSolutionView(),
                      'stats.descriptive' => const DescriptiveStatsView(),
                      'stats.linear_regression' => const CalibrationView(),
                      'stats.lod_loq.ich' => const CalibrationView(
                        withLimits: true,
                      ),
                      'tox.ethanol.widmark' => const WidmarkView(),
                      'tox.ethanol.back_calculation' =>
                        const BackCalculationView(),
                      'tox.ethanol.units' => const EthanolUnitsView(),
                      'fm.pmi.henssge' => const HenssgeView(),
                      _ => _PlannedToolView(tool: tool),
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannedToolView extends StatelessWidget {
  const _PlannedToolView({required this.tool});

  final ToolEntry tool;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FeSpace.md),
        Text(
          l.toolDescription(tool),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: FeSpace.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: StatusChip(
            icon: Icons.schedule_outlined,
            label: tool.plannedRelease == null
                ? l.toolStatusPlanned
                : '${l.toolStatusPlanned} · ${tool.plannedRelease}',
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: FeSpace.md),
        FeBanner(icon: Icons.info_outline, text: l.toolPlannedBody),
      ],
    );
  }
}

enum _Field { c1, v1, c2, v2 }

class _DilutionCalculatorView extends StatefulWidget {
  const _DilutionCalculatorView();

  @override
  State<_DilutionCalculatorView> createState() =>
      _DilutionCalculatorViewState();
}

class _DilutionCalculatorViewState extends State<_DilutionCalculatorView> {
  static const _concUnits = [
    Unit.milligramPerMilliliter,
    Unit.microgramPerMilliliter,
    Unit.milligramPerLiter,
    Unit.gramPerLiter,
    Unit.nanogramPerMilliliter,
    Unit.millimolePerLiter,
    Unit.micromolePerLiter,
  ];
  static const _volUnits = [Unit.milliliter, Unit.microliter, Unit.liter];

  final _calc = const DilutionCalculator();
  final _controllers = {
    for (final f in _Field.values) f: TextEditingController(),
  };
  final _units = <_Field, Unit>{
    _Field.c1: Unit.milligramPerMilliliter,
    _Field.v1: Unit.milliliter,
    _Field.c2: Unit.milligramPerMilliliter,
    _Field.v2: Unit.milliliter,
  };
  _Field _unknown = _Field.v1;
  String? _error;
  CalcResult<DilutionOutput>? _result;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate(AppLocalizations l) {
    Quantity? q(_Field f) {
      if (f == _unknown) return null;
      final v = double.tryParse(_controllers[f]!.text.replaceAll(',', '.'));
      if (v == null || v <= 0 || !v.isFinite) throw const FormatException();
      return Quantity(v, _units[f]!);
    }

    setState(() {
      _result = null;
      _error = null;
      try {
        _result = _calc.calculate(
          DilutionInput(
            c1: q(_Field.c1),
            v1: q(_Field.v1),
            c2: q(_Field.c2),
            v2: q(_Field.v2),
          ),
        );
      } on FormatException {
        _error = l.calcErrorPositive;
      } on CalcInputException catch (e) {
        _error = e.code == 'concentration_dimensions_differ'
            ? l.calcErrorUnits
            : l.calcErrorPositive;
      }
    });
  }

  String _label(AppLocalizations l, _Field f) => switch (f) {
    _Field.c1 => l.calcStockConc,
    _Field.v1 => l.calcStockVol,
    _Field.c2 => l.calcFinalConc,
    _Field.v2 => l.calcFinalVol,
  };

  static String _format(double v) {
    final s = v.toStringAsPrecision(6);
    return s.contains('e') ? s : double.parse(s).toString();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final d = _calc.descriptor;
    final result = _result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FeSpace.sm),
        Text(l.toolDilutionDesc, style: t.bodyMedium),
        const SizedBox(height: FeSpace.sm),
        FeBanner(
          icon: Icons.pending_outlined,
          text: l.calcNeedsReviewNotice,
          tone: FeBannerTone.warning,
        ),
        FeSectionHeader(l.calcInput),
        Text(l.calcSolveFor, style: t.labelLarge),
        const SizedBox(height: FeSpace.xs),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final f in _Field.values)
              ChoiceChip(
                key: Key('calc.unknown.${f.name}'),
                label: Text(f.name.toUpperCase()),
                selected: _unknown == f,
                onSelected: (_) => setState(() {
                  _unknown = f;
                  _result = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: FeSpace.sm),
        for (final f in _Field.values)
          if (f != _unknown)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.sm),
              child: _QuantityField(
                key: Key('calc.field.${f.name}'),
                label: _label(l, f),
                controller: _controllers[f]!,
                unit: _units[f]!,
                units: f == _Field.v1 || f == _Field.v2
                    ? _volUnits
                    : _concUnits,
                unitLabel: l.calcUnit,
                onUnit: (u) => setState(() => _units[f] = u),
              ),
            ),
        Text(
          l.calcEnterValues,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.sm),
        FilledButton(
          key: const Key('calc.calculate'),
          onPressed: () => _calculate(l),
          child: Text(l.calcCalculate),
        ),
        if (_error != null) ...[
          const SizedBox(height: FeSpace.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              style: t.bodyMedium?.copyWith(color: c.danger),
            ),
          ),
        ],
        FeSectionHeader(l.calcResult),
        Semantics(
          liveRegion: true,
          label: result == null
              ? null
              : l.calcResultSemantics(
                  '${_label(l, _unknown)} = ${_format(result.value.result.value)} '
                  '${result.value.result.unit.symbol}',
                ),
          excludeSemantics: result != null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(FeRadius.md),
              border: Border.all(color: c.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: result == null
                  ? Text(
                      FeGlyphs.emDash,
                      style: FeThemeBuilder.numeric(t.titleLarge!),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_label(l, _unknown), style: t.labelLarge),
                        const SizedBox(height: FeSpace.xxs),
                        Text(
                          '${_format(result.value.result.value)} '
                          '${result.value.result.unit.symbol}',
                          key: const Key('calc.result'),
                          style: FeThemeBuilder.numeric(t.headlineSmall!)
                              .copyWith(color: c.textPrimary),
                        ),
                        if (result.warnings.isNotEmpty) ...[
                          const SizedBox(height: FeSpace.xs),
                          FeBanner(
                            icon: Icons.warning_amber_rounded,
                            text: l.calcWarnExceeds,
                            tone: FeBannerTone.warning,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
        FeSectionHeader(l.calcMethod),
        CalculatorStatusPanel(engineId: d.id, engineVersion: d.engineVersion),
        FeSectionHeader(l.calcFormula),
        Text(
          'C₁ × V₁ = C₂ × V₂',
          style: FeThemeBuilder.numeric(t.titleMedium!),
        ),
        FeSectionHeader(l.calcAssumptions),
        _Bullet(l.calcDilutionAssumptionConservation),
        _Bullet(l.calcDilutionAssumptionMixing),
        FeSectionHeader(l.calcLimitations),
        _Bullet(l.calcDilutionLimitationContraction),
        FeSectionHeader(l.calcReferences),
        Text(
          l.calcDefinitional,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.xl),
      ],
    );
  }
}

class _SolutionCalculatorView extends StatefulWidget {
  const _SolutionCalculatorView();

  @override
  State<_SolutionCalculatorView> createState() =>
      _SolutionCalculatorViewState();
}

class _SolutionCalculatorViewState extends State<_SolutionCalculatorView> {
  static const _concUnits = [
    Unit.gramPerLiter,
    Unit.milligramPerMilliliter,
    Unit.milligramPerLiter,
    Unit.microgramPerMilliliter,
    Unit.millimolePerLiter,
    Unit.micromolePerLiter,
  ];
  static const _volUnits = [Unit.milliliter, Unit.liter, Unit.microliter];

  final _calc = const SolutionPreparationCalculator();
  final _conc = TextEditingController();
  final _vol = TextEditingController();
  final _molar = TextEditingController();
  final _purity = TextEditingController(text: '1');
  Unit _concUnit = Unit.gramPerLiter;
  Unit _volUnit = Unit.milliliter;
  String? _error;
  CalcResult<SolutionPreparationOutput>? _result;

  @override
  void dispose() {
    for (final c in [_conc, _vol, _molar, _purity]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isMolar => _concUnit.dimension == Dimension.molarConcentration;

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _calculate(AppLocalizations l) {
    setState(() {
      _result = null;
      _error = null;
      final conc = _num(_conc);
      final vol = _num(_vol);
      final purity = _num(_purity);
      if (conc == null || vol == null || purity == null) {
        _error = l.calcErrorPositive;
        return;
      }
      try {
        _result = _calc.calculate(
          SolutionPreparationInput(
            targetConcentration: Quantity(conc, _concUnit),
            finalVolume: Quantity(vol, _volUnit),
            molarMassGPerMol: _isMolar ? _num(_molar) : null,
            purityFraction: purity,
          ),
        );
      } on CalcInputException catch (e) {
        _error = switch (e.code) {
          'molar_mass_required' => l.calcErrorMolarMass,
          'purity_out_of_range' => l.calcErrorPurity,
          _ => l.calcErrorPositive,
        };
      }
    });
  }

  static String _format(double v) {
    final s = v.toStringAsPrecision(6);
    return s.contains('e') ? s : double.parse(s).toString();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final d = _calc.descriptor;
    final result = _result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FeSpace.sm),
        Text(l.toolSolutionDesc, style: t.bodyMedium),
        const SizedBox(height: FeSpace.sm),
        FeBanner(
          icon: Icons.pending_outlined,
          text: l.calcNeedsReviewNotice,
          tone: FeBannerTone.warning,
        ),
        const SizedBox(height: FeSpace.xs),
        FeBanner(
          key: const Key('calc.solution.notRecipe'),
          icon: Icons.science_outlined,
          text: l.calcSolutionLimitationRecipe,
        ),
        FeSectionHeader(l.calcInput),
        _QuantityField(
          key: const Key('calc.solution.conc'),
          label: l.calcTargetConc,
          controller: _conc,
          unit: _concUnit,
          units: _concUnits,
          unitLabel: l.calcUnit,
          onUnit: (u) => setState(() {
            _concUnit = u;
            _result = null;
          }),
        ),
        const SizedBox(height: FeSpace.sm),
        _QuantityField(
          key: const Key('calc.solution.vol'),
          label: l.calcFinalVol,
          controller: _vol,
          unit: _volUnit,
          units: _volUnits,
          unitLabel: l.calcUnit,
          onUnit: (u) => setState(() => _volUnit = u),
        ),
        if (_isMolar) ...[
          const SizedBox(height: FeSpace.sm),
          TextField(
            key: const Key('calc.solution.molar'),
            controller: _molar,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.calcMolarMass),
          ),
        ],
        const SizedBox(height: FeSpace.sm),
        TextField(
          key: const Key('calc.solution.purity'),
          controller: _purity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l.calcPurity),
        ),
        const SizedBox(height: FeSpace.sm),
        FilledButton(
          key: const Key('calc.calculate'),
          onPressed: () => _calculate(l),
          child: Text(l.calcCalculate),
        ),
        if (_error != null) ...[
          const SizedBox(height: FeSpace.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              key: const Key('calc.error'),
              style: t.bodyMedium?.copyWith(color: c.danger),
            ),
          ),
        ],
        FeSectionHeader(l.calcResult),
        Semantics(
          liveRegion: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(FeRadius.md),
              border: Border.all(color: c.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.calcMassRequired, style: t.labelLarge),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    result == null
                        ? FeGlyphs.emDash
                        : '${_format(result.value.mass.value)} '
                              '${result.value.mass.unit.symbol}',
                    key: const Key('calc.result'),
                    style: FeThemeBuilder.numeric(t.headlineSmall!),
                  ),
                  if (result != null && result.warnings.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.xs),
                    FeBanner(icon: Icons.info_outline, text: l.calcWarnPurity),
                  ],
                ],
              ),
            ),
          ),
        ),
        FeSectionHeader(l.calcMethod),
        CalculatorStatusPanel(engineId: d.id, engineVersion: d.engineVersion),
        FeSectionHeader(l.calcFormula),
        Text(
          'm = C · V (· M) / p',
          style: FeThemeBuilder.numeric(t.titleMedium!),
        ),
        FeSectionHeader(l.calcAssumptions),
        _Bullet(l.calcSolutionAssumptionDefinition),
        _Bullet(l.calcSolutionAssumptionInputs),
        FeSectionHeader(l.calcLimitations),
        _Bullet(l.calcSolutionLimitationRecipe),
        _Bullet(l.calcSolutionLimitationVolume),
        FeSectionHeader(l.calcReferences),
        Text(
          l.calcDefinitional,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
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

class _QuantityField extends StatelessWidget {
  const _QuantityField({
    super.key,
    required this.label,
    required this.controller,
    required this.unit,
    required this.units,
    required this.unitLabel,
    required this.onUnit,
  });

  final String label;
  final TextEditingController controller;
  final Unit unit;
  final List<Unit> units;
  final String unitLabel;
  final ValueChanged<Unit> onUnit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: label),
          ),
        ),
        const SizedBox(width: FeSpace.xs),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<Unit>(
            initialValue: unit,
            isExpanded: true,
            decoration: InputDecoration(labelText: unitLabel),
            items: [
              for (final u in units)
                DropdownMenuItem(value: u, child: Text(u.symbol)),
            ],
            onChanged: (u) {
              if (u != null) onUnit(u);
            },
          ),
        ),
      ],
    );
  }
}
