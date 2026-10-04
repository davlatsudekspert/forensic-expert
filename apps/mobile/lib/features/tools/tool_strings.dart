import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/catalog/tools_catalog.dart';

/// Vosita va toifa nomlarini lokalizatsiya qiladi (ARB’dan).
extension ToolStrings on AppLocalizations {
  String toolName(ToolEntry t) => switch (t.id) {
    'tool.lab.dilution' => toolDilutionName,
    'tool.tox.widmark' => toolWidmarkName,
    'tool.tox.back_calculation' => toolBackCalcName,
    'tool.fm.pmi_henssge' => toolPmiName,
    'tool.lab.molarity' => toolMolarityName,
    'tool.lab.calibration' => toolCalibrationName,
    'tool.lab.lod_loq' => toolLodName,
    'tool.lab.descriptive_stats' => toolStatsName,
    'tool.conv.concentration_units' => toolUnitsName,
    'tool.conv.ethanol_units' => toolEthanolUnitsName,
    _ => t.id,
  };

  String toolDescription(ToolEntry t) => switch (t.id) {
    'tool.lab.dilution' => toolDilutionDesc,
    'tool.tox.widmark' => toolWidmarkDesc,
    'tool.tox.back_calculation' => toolBackCalcDesc,
    'tool.fm.pmi_henssge' => toolPmiDesc,
    'tool.lab.molarity' => toolMolarityDesc,
    'tool.lab.calibration' => toolCalibrationDesc,
    'tool.lab.lod_loq' => toolLodDesc,
    'tool.lab.descriptive_stats' => toolStatsDesc,
    'tool.conv.concentration_units' => toolUnitsDesc,
    'tool.conv.ethanol_units' => toolEthanolUnitsDesc,
    _ => '',
  };

  String toolCategoryName(ToolCategory c) => switch (c) {
    ToolCategory.forensicMedicine => moduleForensicMedicine,
    ToolCategory.toxicology => toolCategoryToxicology,
    ToolCategory.laboratory => moduleLaboratory,
    ToolCategory.conversions => toolCategoryConversions,
  };
}
