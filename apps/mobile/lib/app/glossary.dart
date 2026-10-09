import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/glossary/glossary.dart';
import '../domain/guidelines/guideline_models.dart';
import 'guidelines.dart';
import 'providers.dart';

/// «Ilmiy lug‘at»: paketdagi termin tarjimalari + yo‘riqnoma kartalaridagi
/// aniq `term_ids` bog‘lanishlari. Paket yuklanmaguncha — bo‘sh.
final glossaryProvider = Provider<Glossary>(
  (ref) => Glossary.build(
    ref.watch(provenanceIndexProvider).terms,
    ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty,
  ),
);
