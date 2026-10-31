/// Bepul / Pro bo‘linishi (egasi qarori, 2026-10-31, `docs/DECISIONS.md`).
///
/// Bo‘linish kodda TAYYOR, lekin **o‘chiq**: [kProStrict] yig‘ishda
/// (`--dart-define=FE_PRO_STRICT=true`) yoqiladi. Masofadan yoqiladigan
/// bayroq yo‘q (Apple 2.3.1). O‘chiqda ilova avvalgidek ishlaydi.
///
/// Bepul (hamma rejimda): Sud tibbiyoti, Toksikologiya va Biokimyo
/// kitob/darslarini o‘qish; qidiruv; lug‘at; manba, provenance va xavfsizlik
/// ogohlantirishlari; hisob/sozlamalar; guruhga qo‘shilish va ustoz bergan
/// testni yechish (talaba faqat ballni ko‘radi). Qolgani — Pro.
library;

import 'package:fe_content_schema/fe_content_schema.dart' show KnowledgeArea;

import '../knowledge/knowledge_models.dart' show KnowledgeKind;
import '../library/library_models.dart' show LibrarySection;
import 'plan_models.dart';

/// Qat’iy bo‘linish yoqilganmi (kompilyatsiya vaqtida; standart — o‘chiq).
const kProStrict = bool.fromEnvironment('FE_PRO_STRICT');

/// Bepul/Pro bo‘linishi qoidalari (sof funksiyalar; UI’siz).
abstract final class ProSplit {
  /// Bepul o‘qiladigan Home bo‘limlari (`HomeModule.name`).
  ///
  /// «Laboratoriya» kirishi ham bepul (egasi, 2026-10-31, keyingi o‘zgarish):
  /// bo‘lim sahifasi va mavzu ro‘yxati ochiq; ichidagi vositalar (GC-MS/LC-MS,
  /// spektrofotometriya, Beer–Lambert, laboratoriya kalkulyatorlari), metodlar,
  /// skrining va reagent yozuvlari — Pro.
  static const freeModules = {
    'forensicMedicine',
    'toxicology',
    'biochemistry',
    'laboratory',
  };

  /// Bepul bilim sohalari (taksonomiya mavzulari).
  static const freeAreas = {
    KnowledgeArea.forensicMedicine,
    KnowledgeArea.toxicology,
    KnowledgeArea.biochemistry,
    KnowledgeArea.laboratory,
  };

  /// Home bo‘limi o‘qishini ochadigan funksiya; `null` — bepul.
  ///
  /// `learn` — markaz sahifasi: guruhga qo‘shilish va ustoz testi bepul, ichki
  /// mustaqil test/kartochka/imtihon alohida qulflanadi.
  static ProFeature? featureForModule(String module) => switch (module) {
    'forensicMedicine' ||
    'toxicology' ||
    'biochemistry' ||
    'laboratory' ||
    'learn' => null,
    'ai' => ProFeature.proAi,
    _ => ProFeature.proModules,
  };

  static bool isFreeArea(KnowledgeArea area) => freeAreas.contains(area);

  /// Bilim yozuvi bepulmi: faqat bepul sohaning mavzu yozuvlari. Reagent,
  /// skrining, metod va yangi muammolar yozuvlari (soha qanday bo‘lmasin) —
  /// Pro bo‘limlariniki.
  static bool isFreeKnowledge(KnowledgeKind kind, KnowledgeArea area) =>
      kind == KnowledgeKind.topic && isFreeArea(area);

  /// Kutubxona bo‘limi bepulmi. Moddalar va Usullar — Pro; namunalar
  /// (provenance), manbalar va lug‘at — doim bepul.
  static bool isFreeLibrarySection(LibrarySection s) => switch (s) {
    LibrarySection.substances || LibrarySection.methods => false,
    _ => true,
  };

  /// Dars o‘qishi bepulmi: Sud tibbiyoti va Toksikologiya darslari; «Apparatlar
  /// bilan ishlash» kursi (`instr-`) — Pro.
  static bool isFreeLessonTopic(String topicId) =>
      !LessonAccess.isInstrument(topicId);
}
