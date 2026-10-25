import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/instruments/gcms_content.dart';

const _gcMsDir = 'assets/content/instruments/gc_ms';
const gcMsImage480 = '$_gcMsDir/mass_spec_gc_480.png';
const gcMsImage1200 = '$_gcMsDir/mass_spec_gc_1200.png';

/// (qismlar JSON, katalog kartasi JSON) — testlarda almashtiriladi.
final gcMsLoaderProvider = Provider<Future<(String, String)> Function()>(
  (ref) =>
      () async => (
        await rootBundle.loadString('$_gcMsDir/gc_ms_parts_3lang.json'),
        await rootBundle.loadString(
          '$_gcMsDir/gc_ms_catalog_card_and_sources.json',
        ),
      ),
);

final gcMsProvider = FutureProvider<GcMsContent?>((ref) async {
  try {
    final (parts, card) = await ref.watch(gcMsLoaderProvider)();
    return GcMsContent.fromJson(
      (jsonDecode(parts) as Map).cast<String, Object?>(),
      (jsonDecode(card) as Map).cast<String, Object?>(),
    );
  } on Object {
    return null;
  }
});
