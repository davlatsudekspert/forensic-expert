import 'package:fe_content_schema/fe_content_schema.dart'
    show ClaimLifecycle, KnowledgeArea, ScientificStatus;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../domain/knowledge/knowledge_models.dart';
import '../../domain/library/library_models.dart';
import 'workbench.dart';

/// Bugungi sana manbai (testlarda soat shu orqali qotiriladi).
final workbenchClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// «Bugungi ma’lumot»: mavjud paket yozuvidan bitta manbali da’vo.
@immutable
class DailyFact {
  const DailyFact({
    required this.entryId,
    required this.claimId,
    required this.title,
    required this.excerpt,
    required this.source,
    required this.route,
    required this.translationPending,
  });

  final String entryId;
  final String claimId;
  final String title;

  /// `value.statement` — manbadan o‘z so‘zlarimiz bilan yozilgan matn.
  final String excerpt;

  /// Manba satri — paketda saqlangan ko‘rinishda (muallif, kitob, bet / DOI).
  final String source;
  final String route;

  /// Matn asl tilda; tanlangan til uchun tarjima hali yo‘q.
  final bool translationPending;
}

class _Candidate {
  const _Candidate(
    this.claim,
    this.title,
    this.route,
    this.source,
    this.isMedicine,
  );

  final ClaimView claim;
  final String title;
  final String route;
  final String source;

  /// `true` — sud tibbiyoti/gistologiya; `false` — qolgan sohalar.
  final bool isMedicine;
}

/// Da’vo ko‘rsatishga yaroqlimi: aktual, manbali, matni bor.
bool _claimEligible(ClaimView c, String lang) {
  if (c.sources.isEmpty || c.sources.any((s) => s.isRetracted)) return false;
  if (c.status == ScientificStatus.rejected ||
      c.status == ScientificStatus.outdated) {
    return false;
  }
  if (c.lifecycle == ClaimLifecycle.retracted ||
      c.lifecycle == ClaimLifecycle.rejected ||
      c.lifecycle == ClaimLifecycle.outdated ||
      c.lifecycle == ClaimLifecycle.superseded) {
    return false;
  }
  final text = c.statementFor(lang)?.trim() ?? '';
  return text.isNotEmpty;
}

/// Manba satri — paketdagi qiymatlar aynan: avval `locator_i18n` (muallif,
/// kitob, bet), bo‘lmasa birinchi manbaning nomi · jurnal · yil · joy · DOI.
/// Hech narsa to‘qilmaydi; bo‘sh bo‘lsa — `null` (yozuv ko‘rsatilmaydi).
String? _sourceLine(ClaimView c, String lang) {
  final loc = c.locatorFor(lang)?.trim();
  if (loc != null && loc.isNotEmpty) return loc;
  final s = c.sources.first;
  final parts = [
    s.title,
    ?s.journal,
    if (s.year != null) '${s.year}',
    ?s.locator,
    if (s.doi != null) 'doi:${s.doi}',
  ].where((p) => p.trim().isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Mutaxassislikka mos, manbali, bugungi ma’lumot. Aniq (deterministik):
/// bir kunda bir xil, ertasi kuni boshqa. Mos yozuv bo‘lmasa — `null`.
DailyFact? pickDailyFact({
  required LibraryRepository library,
  required KnowledgeRepository knowledge,
  required WorkbenchSpecialty specialty,
  required String lang,
  required DateTime today,
}) {
  final all = <_Candidate>[];

  void addClaims(
    Iterable<ClaimView> claims,
    String title,
    String route,
    bool medicine,
  ) {
    for (final c in claims) {
      if (!c.visibleIn(lang) || !_claimEligible(c, lang)) continue;
      final src = _sourceLine(c, lang);
      if (src == null) continue;
      all.add(_Candidate(c, title, route, src, medicine));
    }
  }

  for (final e in library.entries(LibrarySection.substances)) {
    final d = e.details;
    if (e.isTestData || d == null) continue;
    addClaims(
      d.claims,
      e.name.resolve(lang),
      Routes.homeSubstance(e.id),
      false,
    );
  }
  for (final kind in KnowledgeKind.values) {
    for (final e in knowledge.byKind(kind)) {
      if (e.isTestData) continue;
      final medicine =
          e.area == KnowledgeArea.forensicMedicine ||
          e.area == KnowledgeArea.histology;
      addClaims(
        e.claims,
        e.name.resolve(lang),
        Routes.knowledgeEntry(e.id),
        medicine,
      );
    }
  }
  if (all.isEmpty) return null;

  var pool = switch (specialty) {
    WorkbenchSpecialty.medicine => [
      for (final c in all)
        if (c.isMedicine) c,
    ],
    WorkbenchSpecialty.chemistry => [
      for (final c in all)
        if (!c.isMedicine) c,
    ],
    WorkbenchSpecialty.mixed => all,
  };
  // Mutaxassislikka mos yozuv topilmasa ham, manbali yozuvlardan biri
  // ko‘rsatiladi (karta bo‘sh qolmaydi).
  if (pool.isEmpty) pool = all;

  pool.sort((a, b) => a.claim.claimId.compareTo(b.claim.claimId));
  final pick = pool[dayNumberOf(today) % pool.length];
  final c = pick.claim;
  return DailyFact(
    entryId: pick.route,
    claimId: c.claimId,
    title: pick.title,
    excerpt: c.statementFor(lang)!.trim(),
    source: pick.source,
    route: pick.route,
    translationPending: c.statementTranslationPending(lang),
  );
}

/// Til bo‘yicha bugungi ma’lumot (Home’ning ekspert qismi).
final dailyFactProvider = Provider.family<DailyFact?, String>((ref, lang) {
  return pickDailyFact(
    library: ref.watch(libraryRepositoryProvider),
    knowledge: ref.watch(knowledgeRepositoryProvider),
    specialty: ref.watch(workbenchSpecialtyProvider),
    lang: lang,
    today: ref.watch(workbenchClockProvider)(),
  );
});
