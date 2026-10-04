/// Vositalar katalogi (`Tools` ekrani, Global Search va Home uchun).
///
/// Bu yerda faqat **metadata** bor: nom, toifa, holat. Formula va
/// koeffitsientlar yo‘q. Faqat `fe_calc_engine` da amalga oshirilgan va
/// test qilingan kalkulyator `available` bo‘ladi; qolganlari `planned`
/// — reviewer tasdig‘isiz hech qanday ilmiy formula qo‘shilmaydi.
library;

import 'package:flutter/foundation.dart';

enum ToolCategory { forensicMedicine, toxicology, laboratory, conversions }

enum ToolAvailability { available, planned }

@immutable
class ToolEntry {
  const ToolEntry({
    required this.id,
    required this.category,
    required this.availability,
    this.engineId,
    this.plannedRelease,
  });

  /// Barqaror ID (favorites, recents va qidiruvda ishlatiladi).
  final String id;
  final ToolCategory category;
  final ToolAvailability availability;

  /// `fe_calc_engine` dagi `CalculatorDescriptor.id`.
  final String? engineId;

  /// Masalan `V1.1` (Henssge).
  final String? plannedRelease;

  bool get isAvailable => availability == ToolAvailability.available;
}

abstract final class ToolsCatalog {
  static const dilution = ToolEntry(
    id: 'tool.lab.dilution',
    category: ToolCategory.laboratory,
    availability: ToolAvailability.available,
    engineId: 'lab.dilution.c1v1',
  );

  /// m = C·V(·M)/p — ta’rifiy hisob; reagent retsepti emas.
  static const solution = ToolEntry(
    id: 'tool.lab.solution',
    category: ToolCategory.laboratory,
    availability: ToolAvailability.available,
    engineId: 'lab.solution.mass_required',
  );

  static const all = <ToolEntry>[
    ToolEntry(
      id: 'tool.fm.pmi_henssge',
      category: ToolCategory.forensicMedicine,
      availability: ToolAvailability.planned,
      plannedRelease: 'V1.1',
    ),
    ToolEntry(
      id: 'tool.tox.widmark',
      category: ToolCategory.toxicology,
      availability: ToolAvailability.planned,
    ),
    ToolEntry(
      id: 'tool.tox.back_calculation',
      category: ToolCategory.toxicology,
      availability: ToolAvailability.planned,
    ),
    dilution,
    solution,
    ToolEntry(
      id: 'tool.lab.molarity',
      category: ToolCategory.laboratory,
      availability: ToolAvailability.planned,
    ),
    ToolEntry(
      id: 'tool.lab.calibration',
      category: ToolCategory.laboratory,
      availability: ToolAvailability.planned,
    ),
    ToolEntry(
      id: 'tool.lab.lod_loq',
      category: ToolCategory.laboratory,
      availability: ToolAvailability.planned,
    ),
    ToolEntry(
      id: 'tool.lab.descriptive_stats',
      category: ToolCategory.laboratory,
      availability: ToolAvailability.planned,
    ),
    ToolEntry(
      id: 'tool.conv.concentration_units',
      category: ToolCategory.conversions,
      availability: ToolAvailability.planned,
    ),
    ToolEntry(
      id: 'tool.conv.ethanol_units',
      category: ToolCategory.conversions,
      availability: ToolAvailability.planned,
    ),
  ];

  static ToolEntry? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  static List<ToolEntry> inCategory(ToolCategory c) => [
    for (final t in all)
      if (t.category == c) t,
  ];
}
