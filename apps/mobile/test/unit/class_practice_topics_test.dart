import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_demo_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';

void main() {
  // Xato (2026-11-03): class_topics() faqat ustozga javob beradi — talabada
  // dars oxiridagi test tugmasi o‘chiq qolardi. practiceTopics() — hammaga.
  test(
    'talaba (ustoz emas): savolli mavzular ko‘rinadi, tugma yonadi',
    () async {
      final real = ClassBankTopic(
        id: '4-kurs-davolash-10',
        title: 'Haqiqiy mavzu',
        isDemo: false,
        questions: classQuizDemoTopic.questions,
      );
      final backend = FakeClassQuizBackend(topics: [real, classQuizDemoTopic]);
      final student = FakeClassQuizService(backend, userId: 'talaba-1');

      // Ustoz funksiyasi talabaga yopiq (o‘zgarmagan).
      expect((await student.topics()).value, isNull);

      final practice = await student.practiceTopics();
      expect(practice.value, isNotNull);
      expect(practice.value!.map((t) => t.id), contains('4-kurs-davolash-10'));
      expect(
        practice.value!.firstWhere((t) => t.id == '4-kurs-davolash-10').count,
        real.questions.length,
      );

      final c = ProviderContainer(
        overrides: [classQuizServiceProvider.overrideWithValue(student)],
      );
      addTearDown(c.dispose);
      final sub = c.listen(classPracticeTopicsProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(classPracticeTopicsProvider.future);
      expect(c.read(lessonQuizAvailableProvider('4-kurs-davolash-10')), isTrue);
      // Savoli yo‘q mavzu — tugma o‘chiq («tez orada»).
      expect(c.read(lessonQuizAvailableProvider('yoq-mavzu')), isFalse);
    },
  );
}
