import 'package:fe_content_schema/fe_content_schema.dart' show ScientificStatus;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/study.dart';
import '../../domain/learn/study_models.dart';
import 'daily_fact.dart' show workbenchClockProvider;
import 'workbench.dart' show dayNumberOf;

/// Kunlik savolga yaroqlimi: muallif yozgan savol, 3 ta aniq distraktor,
/// har bir manbada aniq joy (sahifa/bo‘lim), test ma’lumoti emas, rad
/// etilgan/eskirgan emas va savol-variantlar shu tilda mavjud.
bool dailyQuestionEligible(StudyItem i, String lang) {
  if (i.kind != StudyItemKind.guidelineQuestion || i.isTestData) return false;
  if (i.status == ScientificStatus.rejected ||
      i.status == ScientificStatus.outdated) {
    return false;
  }
  if (i.distractors.length < StudyQuizBuilder.distractorCount) return false;
  if (i.citations.isEmpty || !i.citations.every((c) => c.hasLocator)) {
    return false;
  }
  bool has(Map<String, String> v) => (v[lang] ?? '').trim().isNotEmpty;
  return has(i.prompt.values) &&
      has(i.answer.values) &&
      i.distractors.every((d) => has(d.values));
}

/// Mavjud savollar bankidan bugungi savol. Aniq: bir kunda bir xil savol va
/// variantlar tartibi; ertasi kuni boshqa. Yaroqli savol bo‘lmasa — `null`.
StudyQuestion? pickDailyQuestion({
  required StudyCatalog catalog,
  required String lang,
  required DateTime today,
}) {
  final pool = [
    for (final d in catalog.decks)
      for (final i in d.items)
        if (dailyQuestionEligible(i, lang)) i,
  ]..sort((a, b) => a.id.compareTo(b.id));
  if (pool.isEmpty) return null;
  final day = dayNumberOf(today);
  final item = pool[day % pool.length];
  final deck = StudyDeck(
    id: item.deckId,
    kind: StudyDeckKind.teachingMaterial,
    key: item.deckId,
    items: [item],
  );
  final built = StudyQuizBuilder.build(
    deck,
    catalog,
    seed: day,
    length: 1,
    lang: lang,
  );
  return built.isEmpty ? null : built.first;
}

/// Til bo‘yicha bugungi savol (talaba Home’i).
final dailyQuestionProvider = Provider.family<StudyQuestion?, String>(
  (ref, lang) => pickDailyQuestion(
    catalog: ref.watch(studyCatalogProvider),
    lang: lang,
    today: ref.watch(workbenchClockProvider)(),
  ),
);
