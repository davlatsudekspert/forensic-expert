import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/ai/provenance_retrieval.dart';
import 'package:forensic_expert/domain/ai/rag_pipeline.dart';
import 'package:forensic_expert/domain/ai/retrieval_scoring.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

import '../helpers/pilot_content.dart';

/// Regressiya: BlueStacks’dagi YuQX savoli entomologiya/antropologiya/
/// odontologiya natijalarini olib kelmasligi kerak (faqat "sud" so‘zi
/// bo‘yicha moslik).
void main() {
  late ProvenanceRetrieval retrieval;

  setUpAll(() async {
    final pilot = await loadPilotContent();
    // Ilovadagi kabi o‘zbekcha sarlavhalar (moslik shu yerdan kelgan edi).
    final titles = <String, String>{
      for (final e in pilot.library.entries(LibrarySection.substances))
        e.id: e.name.resolve('uz'),
      for (final kind in KnowledgeKind.values)
        for (final e in pilot.knowledge.byKind(kind))
          e.id: e.name.resolve('uz'),
    };
    retrieval = ProvenanceRetrieval(
      index: pilot.provenance,
      entityTitles: titles,
    );
  });

  test('so‘rov tokenlari: apostrof va umumiy so‘zlar', () {
    final q = RetrievalText.queryTokens(
      'Sud-kimyo ekspertizasida yupqa qatlam xromatografiyasining '
      'afzalliklari va cheklovlari nimalardan iborat? Ilmiy manbalarni '
      'ko‘rsating.',
    );
    expect(q, isNot(contains('sud')));
    expect(q, isNot(contains('rsating')));
    expect(q, isNot(contains('korsating')));
    expect(q, containsAll(['yupqa', 'qatlam', 'thin', 'chromatograph']));
  });

  test('YuQX savoli: aloqasiz fanlar chiqmaydi', () async {
    const question =
        'Sud-kimyo ekspertizasida yupqa qatlam xromatografiyasining '
        'afzalliklari va cheklovlari nimalardan iborat? Ilmiy manbalarni '
        'ko‘rsating.';
    final hits = await retrieval.retrieve(
      question,
      AiIntentClassifier.classify(question),
    );
    final ids = [for (final h in hits) h.chunk.chunkId];
    expect(ids, contains('C-METHOD-TLC-APPLICATION-P5'));
    for (final bad in ['ENT-', 'ANTHROPOLOGY', 'ODONTOLOGY']) {
      expect(ids.where((i) => i.contains(bad)), isEmpty, reason: ids.join(','));
    }
  });

  test('faqat umumiy so‘zlar — natija yo‘q (to‘qima moslik emas)', () async {
    const q = 'Sud ekspertizasi bo‘yicha ilmiy manbalar';
    final hits = await retrieval.retrieve(q, AiIntentClassifier.classify(q));
    expect(hits, isEmpty);
  });

  test('ruscha va inglizcha so‘rov ham mos manbani topadi', () async {
    for (final q in [
      'тонкослойная хроматография',
      'thin-layer chromatography',
    ]) {
      final hits = await retrieval.retrieve(q, AiIntentClassifier.classify(q));
      expect(
        [for (final h in hits) h.chunk.chunkId],
        contains('C-METHOD-TLC-APPLICATION-P5'),
        reason: q,
      );
    }
  });
}
