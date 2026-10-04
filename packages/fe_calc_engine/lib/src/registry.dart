import 'calculator.dart';
import 'lab/dilution.dart';

/// Barcha kalkulyatorlar reyestri. UI va kontent bazasi kalkulyatorni
/// `descriptor.id` orqali topadi.
abstract final class CalculatorRegistry {
  static const List<Calculator<Object?, Object?>> _all = [DilutionCalculator()];

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
