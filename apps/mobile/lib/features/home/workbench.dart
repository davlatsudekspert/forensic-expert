import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/professional.dart';
import '../../app/routes.dart';
import '../../core/design/tokens.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/knowledge/knowledge_models.dart';
import '../../domain/professional/professional_models.dart';

/// Kunlik sana raqami (mahalliy sana bo‘yicha: kun davomida bir xil).
int dayNumberOf(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(2020)).inDays;

/// «Ish stolim» to‘plami mutaxassislik guruhi. Faqat Home’dagi tezkor
/// kirishlarni tanlaydi — kontent, huquq yoki ruxsatga ta’sir qilmaydi.
enum WorkbenchSpecialty { medicine, chemistry, mixed }

/// Mutaxassislikdan guruh: asosiy mutaxassislik hal qiladi; u guruhlarga
/// kirmasa («Boshqa», genetika …) — qo‘shimcha mutaxassisliklardan birinchisi;
/// hech biri mos kelmasa — aralash to‘plam.
WorkbenchSpecialty workbenchSpecialtyOf({
  Specialty? primary,
  Iterable<Specialty> additional = const [],
}) {
  WorkbenchSpecialty? group(Specialty? s) => switch (s) {
    Specialty.forensicMedicine ||
    Specialty.pathologyHistology ||
    Specialty.forensicAnthropology ||
    Specialty.forensicOdontology ||
    Specialty.forensicRadiology => WorkbenchSpecialty.medicine,
    Specialty.forensicToxicology ||
    Specialty.forensicChemistry ||
    Specialty.analyticalLaboratory ||
    Specialty.forensicBiochemistry => WorkbenchSpecialty.chemistry,
    _ => null,
  };
  final own = group(primary);
  if (own != null) return own;
  for (final s in additional) {
    final g = group(s);
    if (g != null) return g;
  }
  return WorkbenchSpecialty.mixed;
}

/// Qurilmadagi profildan mutaxassislik guruhi (profil yo‘q — aralash).
final workbenchSpecialtyProvider = Provider<WorkbenchSpecialty>((ref) {
  final p = ref.watch(localProfileProvider).professional;
  return workbenchSpecialtyOf(
    primary: p?.primarySpecialty,
    additional: p?.additionalSpecialties ?? const [],
  );
});

/// Ish stoli elementlari. Har biri MAVJUD ekranga olib boradi.
enum WorkbenchItemId {
  casebook,
  courtPrep,
  calculators,
  ai,
  labMethods,
  labReagents,
  labExpress,
  labSpectro,
  labMs,
  solutionCalc,
  lodLoq,
  deskLessons,
  deskTests,
  deskExam,
  deskGroup,
}

/// Pro darvozasi uchun YAGONA moslik jadvali (ekspert «Ish stolim» va talaba
/// «O‘qish stolim»). Hozir hech narsa yopilmaydi (`null` — bepul). Pro rejimi
/// ulanganda faqat shu funksiya yangilanadi: «Laboratoriya usullari»
/// kartasining o‘zi va Laboratoriya kirishi BEPUL, uning 4 ichki bandi
/// (reaktivlar, ekspress, spektro, GC-MS/LC-MS) — Pro; talabada
/// `deskTests` / `deskExam` oddiy test ekranlari orqali yopilishi mumkin.
String? workbenchProFeature(WorkbenchItemId id) => null;

/// Elementni Pro darvozasidan o‘tkazuvchi YAGONA nuqta. Darvoza qatlami
/// ulanmagan (hamma funksiya bepul va ochiq) — bola vidjet o‘zgarishsiz
/// qaytariladi, hech qanday «Pro» belgisi chiqmaydi.
Widget gateWorkbenchItem(
  BuildContext context,
  WorkbenchItemId id,
  Widget child,
) => child;

/// Ish stoli kartasi: ekran, marshrut va ko‘rinish.
@immutable
class WorkbenchItem {
  const WorkbenchItem({
    required this.id,
    required this.icon,
    required this.hue,
    required this.route,
    required this.title,
    required this.body,
    this.isTab = false,
  });

  final WorkbenchItemId id;
  final IconData icon;
  final FeHue hue;
  final String route;

  /// Pastki tab (Kalkulyatorlar, AI) — `go`; qolganlari ustiga `push`.
  final bool isTab;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l) body;

  Key get key => Key('workbench.${id.name}');
}

abstract final class Workbench {
  static final casebook = WorkbenchItem(
    id: WorkbenchItemId.casebook,
    icon: Icons.menu_book_outlined,
    hue: FeHues.slate,
    route: Routes.casebook,
    title: (l) => l.workbenchCasebookTitle,
    body: (l) => l.workbenchCasebookBody,
  );
  static final courtPrep = WorkbenchItem(
    id: WorkbenchItemId.courtPrep,
    icon: Icons.gavel_outlined,
    hue: FeHues.indigo,
    route: Routes.courtPrep,
    title: (l) => l.workbenchCourtTitle,
    body: (l) => l.workbenchCourtBody,
  );
  static final calculatorsMed = WorkbenchItem(
    id: WorkbenchItemId.calculators,
    icon: Icons.calculate_outlined,
    hue: FeHues.ochre,
    route: Routes.tools,
    isTab: true,
    title: (l) => l.workbenchCalcTitle,
    body: (l) => l.workbenchCalcMedBody,
  );
  static final calculatorsMixed = WorkbenchItem(
    id: WorkbenchItemId.calculators,
    icon: Icons.calculate_outlined,
    hue: FeHues.ochre,
    route: Routes.tools,
    isTab: true,
    title: (l) => l.workbenchCalcTitle,
    body: (l) => l.workbenchCalcMixedBody,
  );
  static final ai = WorkbenchItem(
    id: WorkbenchItemId.ai,
    icon: Icons.auto_awesome_outlined,
    hue: FeHues.teal,
    route: Routes.ai,
    isTab: true,
    title: (l) => l.moduleAi,
    body: (l) => l.workbenchAiBody,
  );

  // Kimyo/toksikologiya: «Laboratoriya usullari» ichidagi 4 band.
  static final labReagents = WorkbenchItem(
    id: WorkbenchItemId.labReagents,
    icon: Icons.colorize_outlined,
    hue: FeHues.teal,
    route: Routes.knowledge(KnowledgeKind.reagent.name),
    title: (l) => l.workbenchLabReagents,
    body: (l) => l.workbenchLabReagentsSub,
  );
  static final labExpress = WorkbenchItem(
    id: WorkbenchItemId.labExpress,
    icon: Icons.fact_check_outlined,
    hue: FeHues.plum,
    route: Routes.knowledge(KnowledgeKind.screeningTest.name),
    title: (l) => l.workbenchLabExpress,
    body: (l) => l.workbenchLabExpressSub,
  );
  static final labSpectro = WorkbenchItem(
    id: WorkbenchItemId.labSpectro,
    icon: Icons.waves_outlined,
    hue: FeHues.indigo,
    route: Routes.homeTool('tool.lab.beer_lambert'),
    title: (l) => l.workbenchLabSpectro,
    body: (l) => l.workbenchLabSpectroSub,
  );

  /// `gcms_screen.dart` yo‘q — eng yaqin mavjud ekran: «Usullar» ro‘yxati
  /// (GC-MS, LC-MS/MS, HPLC … yozuvlari).
  static final labMs = WorkbenchItem(
    id: WorkbenchItemId.labMs,
    icon: Icons.troubleshoot_outlined,
    hue: FeHues.slate,
    route: Routes.knowledge(KnowledgeKind.method.name),
    title: (l) => l.workbenchLabMs,
    body: (l) => l.workbenchLabMsSub,
  );
  static final solutionCalc = WorkbenchItem(
    id: WorkbenchItemId.solutionCalc,
    icon: Icons.science_outlined,
    hue: FeHues.teal,
    route: Routes.homeTool('tool.lab.solution'),
    title: (l) => l.workbenchSolutionTitle,
    body: (l) => l.workbenchSolutionBody,
  );
  static final lodLoq = WorkbenchItem(
    id: WorkbenchItemId.lodLoq,
    icon: Icons.stacked_line_chart_outlined,
    hue: FeHues.sage,
    route: Routes.homeTool('tool.lab.lod_loq'),
    title: (l) => l.workbenchLodTitle,
    body: (l) => l.workbenchLodBody,
  );

  /// Keng karta ichidagi 4 band (tartib: reaktivlar, ekspress, spektro, MS).
  static final labItems = [labReagents, labExpress, labSpectro, labMs];

  // Talaba «O‘qish stolim»: hammasi mavjud o‘quv ekranlari.
  static final deskLessons = WorkbenchItem(
    id: WorkbenchItemId.deskLessons,
    icon: Icons.menu_book_outlined,
    hue: FeHues.ochre,
    route: Routes.learn,
    title: (l) => l.deskLessonsTitle,
    body: (l) => l.deskLessonsBody,
  );
  static final deskTests = WorkbenchItem(
    id: WorkbenchItemId.deskTests,
    icon: Icons.style_outlined,
    hue: FeHues.teal,
    route: Routes.study,
    title: (l) => l.deskTestsTitle,
    body: (l) => l.deskTestsBody,
  );
  static final deskExam = WorkbenchItem(
    id: WorkbenchItemId.deskExam,
    icon: Icons.assignment_turned_in_outlined,
    hue: FeHues.indigo,
    route: Routes.exam,
    title: (l) => l.deskExamTitle,
    body: (l) => l.deskExamBody,
  );
  static final deskGroup = WorkbenchItem(
    id: WorkbenchItemId.deskGroup,
    icon: Icons.groups_outlined,
    hue: FeHues.plum,
    route: Routes.groups,
    title: (l) => l.deskGroupTitle,
    body: (l) => l.deskGroupBody,
  );

  /// Talaba stoli kartalari (tartib o‘zgarmas).
  static final studentCards = [deskLessons, deskTests, deskExam, deskGroup];

  /// Oddiy kartalar (kimyo uchun — keng kartadan keyingi qator).
  static List<WorkbenchItem> cardsFor(WorkbenchSpecialty s) => switch (s) {
    WorkbenchSpecialty.medicine => [casebook, courtPrep, calculatorsMed, ai],
    WorkbenchSpecialty.chemistry => [solutionCalc, lodLoq],
    WorkbenchSpecialty.mixed => [casebook, labMs, calculatorsMixed, ai],
  };
}
