import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/assessment/assessment_models.dart';
import '../domain/lessons/lesson_oral.dart';
import '../domain/oral_group/oral_group_models.dart';
import 'assessment.dart';
import 'lessons.dart';

/// Rasmiy og‘zaki savollar id → savol (ilova tilida; `assessmentProvider`).
final assessmentQuestionIndexProvider =
    Provider<Map<String, AssessmentQuestion>>((ref) {
      final bundle = ref.watch(assessmentProvider).value;
      if (bundle == null) return const {};
      return {
        for (final s in bundle.specialties)
          for (final c in s.categories)
            for (final q in c.questions) q.id: q,
      };
    });

/// Guruh og‘zaki imtihoni (QR): bilet savolini ko‘ruvchining ilova tilida
/// ko‘rsatish. Serverdagi `oral_tickets.questions` — `[{id, text}]`, matn
/// ustoz bilet tuzgan tilda saqlanadi; shuning uchun matn id orqali qayta
/// topiladi (server o‘zgarmaydi, eski sessiyalar ham ishlaydi):
/// * `<mavzu>#<slayd>` — dars slaydi: ko‘ruvchi tilidagi deck’ning o‘sha
///   slaydi sarlavhasi (tarjima deck’i slaydlari asl bilan bir xil tartibda);
/// * rasmiy savol id’si (`sud_tib.c23.001`) — ilova ichidagi paketdan.
/// Topilmasa (deck yopiq/yuklanmadi, eski id) — serverdagi matn.
final oralGroupQuestionTextProvider = Provider.autoDispose
    .family<String, OralGroupQuestion>((ref, q) {
      final id = q.id;
      final official = ref.watch(assessmentQuestionIndexProvider)[id];
      if (official != null && official.text.isNotEmpty) return official.text;
      final hash = id.lastIndexOf('#');
      if (hash <= 0) return q.text;
      final slide = int.tryParse(id.substring(hash + 1));
      if (slide == null || slide < 0) return q.text;
      final deck = ref
          .watch(lessonDeckProvider(id.substring(0, hash)))
          .value
          ?.value;
      if (deck == null || slide >= deck.slides.length) return q.text;
      final title = lessonOralSlideTitle(deck.slides[slide].title);
      return title.isEmpty ? q.text : title;
    });
