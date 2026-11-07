import 'dart:math';

import 'package:fe_content_schema/fe_content_schema.dart' show ScientificStatus;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/class_quiz.dart' show ClassQuizBank, classQuizBankProvider;
import '../../app/professional.dart' show localProfileProvider;
import '../../app/routes.dart';
import '../../app/study.dart';
import '../../domain/learn/study_models.dart';
import '../../domain/library/library_models.dart';
import '../../domain/professional/professional_models.dart';
import 'daily_fact.dart' show workbenchClockProvider;
import 'workbench.dart';

/// «Bugungi savol» yo‘nalishi (egasi qarori, 2026-11-07): asosan sud
/// tibbiyoti; farmatsiya / toksikologik kimyo yo‘nalishidagilar uchun —
/// asosan toksikologiya. Yo‘nalish noma’lum — sud tibbiyoti.
enum DailyQuestionDirection { forensicMedicine, toxicology }

/// Har [dailyQuestionCycle] kundan bittasi ozchilik manbadan (9:1).
const dailyQuestionCycle = 10;

/// Sikl ichidagi «ozchilik» kuni (kun raqami % 10).
const dailyQuestionMinorityDay = 9;

/// Bugungi savol manbasi: asosiy yo‘nalish, har 10 kundan 1 kun — ikkinchisi.
DailyQuestionDirection dailyQuestionSourceFor(
  int day,
  DailyQuestionDirection primary,
) => day % dailyQuestionCycle == dailyQuestionMinorityDay
    ? _other(primary)
    : primary;

DailyQuestionDirection _other(DailyQuestionDirection d) =>
    d == DailyQuestionDirection.forensicMedicine
    ? DailyQuestionDirection.toxicology
    : DailyQuestionDirection.forensicMedicine;

/// Talaba fakulteti (erkin matn) farmatsiya / toksikologik kimyo yoki
/// sud-kimyo yo‘nalishini bildiradimi.
final _pharmacyFaculty = RegExp(
  r'farmats|farmas|фармац|pharm|toksikolog|токсиколог|toxicolog|'
  r'sud[\s-]*kimyo|суд\w*[\s-]*хим|forensic\s+chem',
  caseSensitive: false,
);

/// Foydalanuvchi yo‘nalishi: «Ish stolim»da tanlangan ko‘rinish (Sud-tibbiy /
/// Sud-kimyo), so‘ng mutaxassis profili (asosiy, keyin qo‘shimcha
/// mutaxassislik), so‘ng talaba profili (fakultet, qiziqishlar). Hech biri
/// aniqlanmasa — sud tibbiyoti.
DailyQuestionDirection dailyQuestionDirectionOf({
  WorkbenchSpecialty? view,
  LocalUserProfile profile = const LocalUserProfile(),
}) {
  DailyQuestionDirection? of(WorkbenchSpecialty s) => switch (s) {
    WorkbenchSpecialty.chemistry => DailyQuestionDirection.toxicology,
    WorkbenchSpecialty.medicine => DailyQuestionDirection.forensicMedicine,
    WorkbenchSpecialty.mixed => null,
  };
  if (view != null) {
    final v = of(view);
    if (v != null) return v;
  }
  final p = profile.professional;
  if (p != null) {
    final v = of(
      workbenchSpecialtyOf(
        primary: p.primarySpecialty,
        additional: p.additionalSpecialties,
      ),
    );
    if (v != null) return v;
  }
  final s = profile.student;
  if (s != null) {
    if (_pharmacyFaculty.hasMatch(s.faculty ?? '')) {
      return DailyQuestionDirection.toxicology;
    }
    final v = of(workbenchSpecialtyOf(additional: s.interests));
    if (v != null) return v;
  }
  return DailyQuestionDirection.forensicMedicine;
}

/// Sud tibbiyoti savollari olinadigan guruhlar (sinf testlari banki).
/// Bioetika, apparatlar va toksikologik kimyo bu ro‘yxatga kirmaydi.
const dailyForensicBankGroups = {
  'sud-tibbiyoti-4-davolash',
  'sud-tibbiyoti-4-pediatriya',
  'sud-tibbiyoti-5-tibbiy-profilaktika',
  'sud-tibbiyoti-ktp-2026',
  'ktp-2026-stomatologiya',
  'sud-toksikologiya',
};

/// Bank savoli kartadagi to‘plam id’si oldidan (strelka — mavzu mashqi).
const dailyBankDeckPrefix = 'classbank:';

/// Kartadagi strelka / «To‘liq izoh»: bank savoli — shu mavzu mashqi,
/// aks holda — odatiy o‘quv testi.
String dailyQuestionRoute(StudyQuestion q) {
  final deck = q.item.deckId;
  return deck.startsWith(dailyBankDeckPrefix)
      ? Routes.groupPractice(deck.substring(dailyBankDeckPrefix.length))
      : Routes.studyQuiz(deck);
}

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

/// Bankdagi kunlik savolga yaroqli sud tibbiyoti savollari ([lang] tilida),
/// id bo‘yicha tartibda; har biri `seed` (kun) bo‘yicha savolga aylanadi.
/// Faqat asosiy mavzular (`~ru`/`~en` nusxalar alohida sanalmaydi), manba
/// bilan solishtirilgan (`checked`), beti ko‘rsatilgan, savol va to‘rtala
/// variant shu tilda bor (tarjimasi kutilayotgani emas).
List<StudyQuestion Function(int seed)> dailyForensicPool(
  ClassQuizBank bank,
  String lang,
) {
  final variants = {for (final v in bank.variants) v.id: v};
  final out = <(String, StudyQuestion Function(int))>[];
  for (final meta in bank.topics) {
    if (!dailyForensicBankGroups.contains(meta.groupId)) continue;
    final variantId = ClassQuizBank.variantId(meta.id, lang);
    final topic = variants[variantId];
    if (topic == null) continue;
    final title = meta.title(lang).trim();
    if (title.isEmpty) continue;
    for (final q in topic.questions) {
      final src = q.source;
      if (!src.checked || src.isTranslationPending) continue;
      if (q.question.trim().isEmpty) continue;
      if (q.options.length != 4 || q.options.any((o) => o.trim().isEmpty)) {
        continue;
      }
      final id = q.id.isEmpty ? '$variantId#${out.length}' : q.id;
      final question = q.question;
      final options = q.options;
      final correct = q.correctIndex;
      final explanation = q.explanation.trim();
      final machine =
          src.isMachineTranslation || meta.isMachineTranslation(lang);
      out.add((
        id,
        (seed) => _bankQuestion(
          id: id,
          lang: lang,
          deckId: '$dailyBankDeckPrefix$variantId',
          topicId: meta.id,
          title: title,
          question: question,
          options: options,
          correct: correct,
          explanation: explanation,
          machine: machine,
          seed: seed,
        ),
      ));
    }
  }
  out.sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final (_, build) in out) build];
}

StudyQuestion _bankQuestion({
  required String id,
  required String lang,
  required String deckId,
  required String topicId,
  required String title,
  required String question,
  required List<String> options,
  required int correct,
  required String explanation,
  required bool machine,
  required int seed,
}) {
  LocalizedText t(String s) => LocalizedText({lang: s});
  StudyItem make(String itemId, String answer, List<StudyCitation> c) =>
      StudyItem(
        id: itemId,
        kind: StudyItemKind.guidelineQuestion,
        deckId: deckId,
        domain: 'classbank:$topicId',
        prompt: t(question),
        answer: t(answer),
        // Manba bilan solishtirilgan, lekin ekspert tasdig‘i emas.
        status: ScientificStatus.needsReview,
        isTestData: false,
        citations: c,
        origin: StudyOrigin.guideline,
        originId: topicId,
        draftLanguages: machine ? {lang} : const {},
        distractors: [
          for (final (i, o) in options.indexed)
            if (i != correct) t(o),
        ],
        explanation: explanation.isEmpty ? null : t(explanation),
      );
  final item = make('classbank.$id', options[correct], [
    // Kartada mavzu nomi (kodlar emas).
    StudyCitation(title: title, language: lang),
  ]);
  final wrong = [
    for (final (i, o) in options.indexed)
      if (i != correct) make('classbank.$id#d$i', o, const []),
  ];
  final shown = [item, ...wrong]..shuffle(Random(seed));
  return StudyQuestion(
    item: item,
    options: shown,
    correctIndex: shown.indexOf(item),
  );
}

/// Bugungi savol. Aniq: bir kunda bir xil savol va variantlar tartibi;
/// ertasi kuni boshqa. Manba [direction] bo‘yicha: 9 kun asosiy yo‘nalish,
/// 1 kun ikkinchisi ([dailyQuestionSourceFor]). Sud tibbiyoti — sinf testlari
/// banki ([bank]), toksikologiya — o‘quv katalogidagi muallif savollari
/// ([catalog]). Tanlangan manbada savol bo‘lmasa — ikkinchisi; hech qayerda
/// yaroqli savol bo‘lmasa — `null`.
StudyQuestion? pickDailyQuestion({
  required StudyCatalog catalog,
  required String lang,
  required DateTime today,
  ClassQuizBank bank = ClassQuizBank.empty,
  DailyQuestionDirection direction = DailyQuestionDirection.forensicMedicine,
}) {
  final day = dayNumberOf(today);
  final forensic = dailyForensicPool(bank, lang);
  final tox = [
    for (final d in catalog.decks)
      for (final i in d.items)
        if (dailyQuestionEligible(i, lang)) i,
  ]..sort((a, b) => a.id.compareTo(b.id));
  bool hasPool(DailyQuestionDirection d) =>
      d == DailyQuestionDirection.forensicMedicine
      ? forensic.isNotEmpty
      : tox.isNotEmpty;
  final wanted = dailyQuestionSourceFor(day, direction);
  final source = hasPool(wanted) ? wanted : _other(wanted);
  if (!hasPool(source)) return null;
  // Ozchilik kunlari (har 10-kun) o‘z navbati bilan aylanadi (ketma-ket
  // ozchilik kunlarida har xil savol); qolganlari — kun raqami bo‘yicha.
  final minority = wanted != direction && source == wanted;
  final slot = minority ? day ~/ dailyQuestionCycle : day;
  if (source == DailyQuestionDirection.forensicMedicine) {
    return forensic[slot % forensic.length](day);
  }
  final item = tox[slot % tox.length];
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

/// Kunlik savol uchun sinf testlari banki; yuklanguncha — bo‘sh.
final dailyQuizBankProvider = Provider<ClassQuizBank>(
  (ref) => ref.watch(classQuizBankProvider).value ?? ClassQuizBank.empty,
);

/// Foydalanuvchi yo‘nalishi (qarang [dailyQuestionDirectionOf]).
final dailyQuestionDirectionProvider = Provider<DailyQuestionDirection>(
  (ref) => dailyQuestionDirectionOf(
    view: ref.watch(workbenchViewProvider),
    profile: ref.watch(localProfileProvider),
  ),
);

/// Til bo‘yicha bugungi savol (talaba, mutaxassis va ustoz Home’i).
final dailyQuestionProvider = Provider.family<StudyQuestion?, String>(
  (ref, lang) => pickDailyQuestion(
    catalog: ref.watch(studyCatalogProvider),
    bank: ref.watch(dailyQuizBankProvider),
    direction: ref.watch(dailyQuestionDirectionProvider),
    lang: lang,
    today: ref.watch(workbenchClockProvider)(),
  ),
);
