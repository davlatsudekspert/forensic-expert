import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../l10n/gen/app_localizations.dart';
import 'instrument_catalog.dart';
import 'lab_direction_card.dart';
import 'schematic_parts_l10n.dart';

/// Sxematik chizmadagi bitta raqamli belgi (1..n) va unga mos qism.
/// Matnlar ARB da: `<id>Name` (nomi) va `<id>Fn` (vazifasi).
@immutable
class SchematicPart {
  const SchematicPart({required this.n, required this.id});

  final int n;
  final String id;

  String get nameId => '${id}Name';
  String get fnId => '${id}Fn';
}

/// Bitta chizma kaliti uchun qismlar ro'yxati, ishlash prinsipi va natija
/// (egasi talabi 2026-10-25; manbalar — docs/SCHEMATIC_PARTS_SOURCES.md).
@immutable
class SchematicPartsEntry {
  const SchematicPartsEntry({
    required this.key,
    required this.parts,
    required this.principleId,
    required this.resultId,
  });

  /// Chizma kaliti (`mass_spec_gc`, `chemistry` ...).
  final String key;
  final List<SchematicPart> parts;
  final String principleId;
  final String resultId;

  /// Barcha ARB id'lari (nom, vazifa, prinsip, natija).
  Iterable<String> get textIds sync* {
    for (final p in parts) {
      yield p.nameId;
      yield p.fnId;
    }
    yield principleId;
    yield resultId;
  }
}

/// `assets/instruments/schematic_parts.json` — chizma kaliti -> qismlar.
/// Yuklashda tekshiriladi: sxema versiyasi, ma'lum kalit (model turi yoki
/// yo'nalish kartasi sinfi), kamida bitta qism, raqamlar 1..n ketma-ket,
/// takrorlanmagan id. Xato — [FormatException].
class SchematicPartsIndex {
  SchematicPartsIndex._(this._entries);

  static const asset = 'assets/instruments/schematic_parts.json';
  static const schemaVersion = 1;

  /// Ilovada chizmasi bor barcha kalitlar (7 model turi + 25 sinf).
  static Set<String> get knownKeys => {
    for (final s in InstrumentSchematic.values) s.key,
    for (final s in LabSchematic.values) s.key,
  };

  final Map<String, SchematicPartsEntry> _entries;

  Iterable<String> get keys => _entries.keys;

  SchematicPartsEntry? of(String key) => _entries[key];

  factory SchematicPartsIndex.fromJson(Map<String, Object?> j) {
    if (j['schema_version'] != schemaVersion) {
      throw FormatException(
        'schematic_parts: schema_version ${j['schema_version']}',
      );
    }
    final raw = j['schematics'];
    if (raw is! Map) {
      throw const FormatException('schematic_parts: schematics missing');
    }
    final known = knownKeys;
    final seen = <String>{};
    final entries = <String, SchematicPartsEntry>{};
    for (final MapEntry(:key, :value) in raw.entries) {
      final k = key as String;
      if (!known.contains(k)) {
        throw FormatException('schematic_parts: unknown schematic key $k');
      }
      if (value is! Map) throw FormatException('schematic_parts: $k');
      final list = value['parts'];
      if (list is! List || list.isEmpty) {
        throw FormatException('schematic_parts: $k has no parts');
      }
      final parts = <SchematicPart>[];
      for (final (i, p) in list.indexed) {
        if (p is! Map || p['n'] != i + 1 || p['id'] is! String) {
          throw FormatException('schematic_parts: $k part #${i + 1}');
        }
        final id = p['id'] as String;
        if (id.isEmpty || !seen.add(id)) {
          throw FormatException('schematic_parts: $k duplicate id $id');
        }
        parts.add(SchematicPart(n: i + 1, id: id));
      }
      final principle = value['principle_id'];
      final result = value['result_id'];
      if (principle is! String ||
          result is! String ||
          principle.isEmpty ||
          result.isEmpty) {
        throw FormatException('schematic_parts: $k principle/result id');
      }
      entries[k] = SchematicPartsEntry(
        key: k,
        parts: List.unmodifiable(parts),
        principleId: principle,
        resultId: result,
      );
    }
    return SchematicPartsIndex._(Map.unmodifiable(entries));
  }

  static Future<SchematicPartsIndex> load(AssetBundle bundle) async =>
      SchematicPartsIndex.fromJson(
        (jsonDecode(await bundle.loadString(asset)) as Map)
            .cast<String, Object?>(),
      );

  /// Shu tilda matni topilmagan id'lar (bo'sh bo'lishi kerak).
  List<String> missingTexts(AppLocalizations l) => [
    for (final e in _entries.values)
      for (final id in e.textIds)
        if ((schematicPartsText(l, id) ?? '').trim().isEmpty) id,
  ];
}
