import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/programs/program_models.dart';
import 'routes.dart';

/// «Toksikologik kimyo» ixtisoslashtirish kursi katalogi (bitta umumiy manba:
/// Ustoz, Talaba va Mutaxassis uchun; ilovaga qo‘shilgan, oflayn).
const toxChemProgramAsset =
    'assets/content/programs/toksikologik_kimyo_v1.json';

const toxChemProgramId = 'toksikologik_kimyo';

final programLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(toxChemProgramAsset),
);

final toxChemProgramProvider = FutureProvider<Program>((ref) async {
  try {
    final text = await ref.watch(programLoaderProvider)();
    return Program.fromJson((jsonDecode(text) as Map).cast<String, Object?>());
  } on Object {
    // Buzilgan yoki yo‘q katalog — bo‘sh (soxta mavzu yo‘q).
    return Program.empty;
  }
});

/// Mavzu havolasining mavjud ekranga marshruti.
String programLinkRoute(ProgramLink l) {
  final v = l.value;
  return switch (l.kind) {
    'method' => Routes.knowledgeEntry(v!),
    'substances' =>
      v == null
          ? Routes.librarySection('substances')
          : Uri(
              path: Routes.librarySection('substances'),
              queryParameters: {'group': v},
            ).toString(),
    'lab' => Routes.labHub(v!),
    'tool' => Routes.homeTool(v!),
    'equipment' => Routes.equipmentItem(v!),
    'knowledge' => Routes.knowledge(v!),
    'jurisdictions' => Routes.jurisdictions,
    // Ma’ruza: «Darslar»dagi ko‘rgich (slaydlar + oxirida test).
    'lesson' => Routes.lesson(v!),
    _ => Routes.home,
  };
}
