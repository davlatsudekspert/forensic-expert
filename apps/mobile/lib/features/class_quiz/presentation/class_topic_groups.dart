import '../../../app/class_quiz.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/class_quiz/class_topic_catalog.dart';

/// Ro‘yxatdagi bitta mavzu: server/qurilma mavzusi (tanlangan til varianti)
/// va bankdagi metama’lumoti.
class ClassTopicChoice {
  const ClassTopicChoice({
    required this.topic,
    required this.title,
    this.meta,
    this.untranslatedTitle = false,
  });

  final ClassTopic topic;
  final String title;
  final ClassQuizBankTopicMeta? meta;

  /// Til varianti sarlavhasi asl o‘zbekcha sarlavha bilan aynan bir xil
  /// (bank metama’lumoti yo‘q mavzular uchun: tarjima qilinmagan belgisi).
  final bool untranslatedTitle;

  /// Tarjimasi hali yo‘q: boshqa tilda asl o‘zbekcha matn ko‘rsatiladi.
  bool get translationPending {
    final vl = ClassQuizBank.variantLang(topic.id);
    if (vl == 'uz') return false;
    return meta?.isTranslationPending(vl) ?? untranslatedTitle;
  }

  /// Savollar avtomatik tarjima (ru/en, tekshirilmagan) bo‘lsa — belgi.
  bool get machineTranslated {
    final vl = ClassQuizBank.variantLang(topic.id);
    if (translationPending) return false;
    return meta?.isMachineTranslation(vl) ?? (vl != 'uz');
  }
}

/// Bitta guruh (fakultet yoki fan) va undagi mavzular.
class ClassTopicGroupData {
  ClassTopicGroupData(this.id, this.title, this.order);

  final String id;
  final String title;
  final int order;
  final items = <ClassTopicChoice>[];
}

/// Mavzu nomi: til varianti bo‘lsa — bankdagi o‘sha til nomi; asl mavzu
/// ru/en interfeysda — bankda tarjima nomi bo‘lsa u, bo‘lmasa server nomi
/// (server tarjima nomini qo‘ygan bo‘lishi mumkin), aks holda o‘zbekcha.
String classChoiceTitle(ClassTopic t, ClassQuizBank bank, String lang) =>
    classTopicDisplayTitle(
      ClassQuizBank.baseId(t.id),
      _rawChoiceTitle(t, bank, lang),
    );

String _rawChoiceTitle(ClassTopic t, ClassQuizBank bank, String lang) {
  final m = bank.meta(t.id);
  final vl = ClassQuizBank.variantLang(t.id);
  if (m == null) return t.title;
  if (vl != 'uz' || lang == 'uz') return m.title(vl);
  final local = m.title(lang);
  if (local != m.title('uz')) return local;
  return t.title.trim().isEmpty ? local : t.title;
}

/// Mavzularni BITTA ro‘yxatga — fakultet/fan guruhlariga — yig‘adi
/// («Darslar» kabi; bank va server guruhlari birlashtiriladi, har guruh bir
/// marta). Bir mavzuning til variantlari (`<id>`, `<id>~ru`, `<id>~en`) —
/// bitta qator (ilova tilidagi variant, bo‘lmasa asl o‘zbekcha). «Darslar»da
/// yashirin takror mavzu va fakultet nusxasi bor `ktp26-u-*` ko‘rsatilmaydi.
List<ClassTopicGroupData> groupClassTopics(
  List<ClassTopic> topics,
  ClassQuizBank bank,
  String lang,
  String otherTitle,
  String query,
) {
  final byBase = <String, Map<String, ClassTopic>>{};
  for (final t in topics) {
    final variants = byBase.putIfAbsent(ClassQuizBank.baseId(t.id), () => {});
    variants[ClassQuizBank.variantLang(t.id)] = t;
  }
  final present = byBase.keys.toSet();
  final q = query.trim().toLowerCase();
  final groups = <String, ClassTopicGroupData>{};
  for (final e in byBase.entries) {
    if (classTopicIsCovered(e.key, present)) continue;
    final v = e.value;
    final topic = v[lang] ?? v['uz'] ?? v.values.first;
    final meta = bank.meta(e.key);
    final course = topic.course.trim();
    final canon = classTopicGroupOf(
      e.key,
      bankGroupId: meta?.groupId,
      course: course,
    );
    final def = canon == null ? null : classTopicGroupDef(canon);
    final bankGroup = meta == null ? null : bank.group(meta.groupId);
    final String gid;
    final String gTitle;
    final int gOrder;
    if (def != null) {
      gid = def.id;
      gTitle = def.title(lang);
      gOrder = def.order;
    } else if (bankGroup != null) {
      gid = 'bank:${bankGroup.id}';
      gTitle = bankGroup.title(lang);
      gOrder = 100 + bankGroup.order;
    } else if (course.isNotEmpty) {
      gid = 'course:${course.toLowerCase()}';
      gTitle = course;
      gOrder = 1000;
    } else {
      gid = '_other';
      gTitle = otherTitle;
      gOrder = 1 << 20;
    }
    final group = groups.putIfAbsent(
      gid,
      () => ClassTopicGroupData(gid, gTitle, gOrder),
    );
    final title = classChoiceTitle(topic, bank, lang);
    if (q.isNotEmpty &&
        !title.toLowerCase().contains(q) &&
        !group.title.toLowerCase().contains(q)) {
      continue;
    }
    group.items.add(
      ClassTopicChoice(
        topic: topic,
        title: title,
        meta: meta,
        untranslatedTitle:
            meta == null &&
            ClassQuizBank.variantLang(topic.id) != 'uz' &&
            v['uz'] != null &&
            v['uz']!.title == topic.title,
      ),
    );
  }
  final out =
      [
        for (final g in groups.values)
          if (g.items.isNotEmpty) g,
      ]..sort((a, b) {
        final c = a.order.compareTo(b.order);
        return c != 0 ? c : a.title.compareTo(b.title);
      });
  for (final g in out) {
    g.items.sort((a, b) {
      final c = classTopicSortKey(ClassQuizBank.baseId(a.topic.id))
          .compareTo(classTopicSortKey(ClassQuizBank.baseId(b.topic.id)));
      return c != 0 ? c : a.title.compareTo(b.title);
    });
    // Bir guruhda bir xil nomli mavzu bir marta (birinchisi — joriy reja).
    final seen = <String>{};
    g.items.retainWhere((x) => seen.add(classTopicTitleKey(x.title)));
  }
  return out;
}
