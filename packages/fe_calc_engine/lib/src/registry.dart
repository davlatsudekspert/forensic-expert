import 'calculator.dart';
import 'fm/henssge.dart';
import 'lab/beer_lambert.dart';
import 'lab/concentration_conversion.dart';
import 'lab/dilution.dart';
import 'lab/molarity.dart';
import 'lab/percent_solution.dart';
import 'lab/solution_preparation.dart';
import 'stats/descriptive.dart';
import 'stats/linear_regression.dart';
import 'stats/lod_loq.dart';
import 'tox/back_calculation.dart';
import 'tox/ethanol_units.dart';
import 'tox/widmark.dart';

/// Barcha kalkulyatorlar reyestri. UI va kontent bazasi kalkulyatorni
/// `descriptor.id` orqali topadi.
abstract final class CalculatorRegistry {
  static const List<Calculator<Object?, Object?>> _all = [
    DilutionCalculator(),
    SolutionPreparationCalculator(),
    ConcentrationConversionCalculator(),
    MolarityCalculator(),
    PercentSolutionCalculator(),
    DescriptiveStatsCalculator(),
    LinearRegressionCalculator(),
    LodLoqCalculator(),
    WidmarkCalculator(),
    BackCalculationCalculator(),
    EthanolUnitsCalculator(),
    HenssgeCalculator(),
    BeerLambertCalculator(),
  ];

  static List<CalculatorDescriptor> get descriptors => [
    for (final c in _all) c.descriptor,
  ];

  static CalculatorDescriptor? descriptorById(String id) {
    for (final c in _all) {
      if (c.descriptor.id == id) return c.descriptor;
    }
    return null;
  }
}
