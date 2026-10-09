/// Moddaning biologik ob’ektlarda tahlili — faqat kontent paketidagi manbali
/// graf bog‘lanishlaridan yig‘iladi (`measured_in`, `analysed_by`,
/// `screened_by`, `confirmed_by`, `has_metabolite` va metabolit
/// munosabatlari).
///
/// Hech qanday metod, namuna, raqam yoki chegara taxmin qilinmaydi: agar
/// paketda metod aniq namunaga bog‘lanmagan bo‘lsa, metodlar modda
/// darajasida qoladi ([SubstanceAnalysis.methodsLinkedToSpecimens] = false).
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../library/library_models.dart';
import 'evidence_models.dart';
import 'provenance_models.dart';

/// Namuna (biologik ob’ekt) — moddaning manbada qiymati keltirilgan joyi.
@immutable
class AnalysisSpecimen {
  const AnalysisSpecimen({
    required this.specimenId,
    required this.basisIds,
    required this.basisClaims,
    this.specimen,
    this.methodIds = const [],
  });

  final String specimenId;

  /// Paketdagi namuna yozuvi (lokalizatsiyalangan nomlar bilan).
  final SpecimenView? specimen;

  /// Bog‘lanish asoslari (claim ID’lari), takrorsiz.
  final List<String> basisIds;

  /// Asoslarning paketdagi claim’lari (topilganlari).
  final List<ClaimView> basisClaims;

  /// Shu namunaga **aynan bir xil manbali claim** orqali bog‘langan metodlar.
  /// Paket buni ajratmasa — bo‘sh.
  final List<String> methodIds;
}

/// Metodning moddaga nisbatan roli — faqat graf munosabatidan.
enum AnalysisMethodRole {
  /// `analysed_by`: modda va metod manbadagi jumlada birga tilga olingan.
  analytical,

  /// `screened_by` → `confirmed_by`: skrining natijasini tasdiqlovchi metod.
  confirmation,
}

@immutable
class AnalysisMethod {
  const AnalysisMethod({
    required this.methodId,
    required this.role,
    required this.basisIds,
    required this.basisClaims,
    this.afterScreeningIds = const [],
  });

  final String methodId;
  final AnalysisMethodRole role;
  final List<String> basisIds;
  final List<ClaimView> basisClaims;

  /// [AnalysisMethodRole.confirmation] uchun: qaysi skrining testlaridan
  /// keyin (paketdagi `confirmed_by` bog‘lanishi bo‘yicha).
  final List<String> afterScreeningIds;
}

/// Skrining testi (taxminiy natija; tasdiqlash talab qilinadi).
@immutable
class AnalysisScreening {
  const AnalysisScreening({
    required this.screeningId,
    required this.basisIds,
    required this.basisClaims,
    this.confirmationMethodIds = const [],
  });

  final String screeningId;
  final List<String> basisIds;
  final List<ClaimView> basisClaims;

  /// `confirmed_by` bo‘yicha tasdiqlovchi metodlar.
  final List<String> confirmationMethodIds;
}

/// Nishon metabolit — ota moddaning manbali metabolit munosabati.
@immutable
class AnalysisMetabolite {
  const AnalysisMetabolite({
    required this.relation,
    this.basisClaim,
    this.specimenIds = const [],
  });

  final MetaboliteRelation relation;
  final ClaimView? basisClaim;

  /// Metabolitning o‘zi uchun paketdagi namunalar (o‘z `measured_in`
  /// bog‘lanishlari + munosabatda tilga olingan namunalar).
  final List<String> specimenIds;
}

@immutable
class SubstanceAnalysis {
  const SubstanceAnalysis({
    required this.entityId,
    this.specimens = const [],
    this.screenings = const [],
    this.confirmationMethods = const [],
    this.analyticalMethods = const [],
    this.metabolites = const [],
  });

  final String entityId;
  final List<AnalysisSpecimen> specimens;
  final List<AnalysisScreening> screenings;
  final List<AnalysisMethod> confirmationMethods;
  final List<AnalysisMethod> analyticalMethods;
  final List<AnalysisMetabolite> metabolites;

  /// Paketda shu modda uchun hech qanday tahlil ma’lumoti yo‘q.
  bool get isEmpty =>
      specimens.isEmpty &&
      screenings.isEmpty &&
      confirmationMethods.isEmpty &&
      analyticalMethods.isEmpty &&
      metabolites.isEmpty;

  /// Hech bo‘lmasa bitta metod aniq namunaga bog‘langanmi.
  bool get methodsLinkedToSpecimens =>
      specimens.any((s) => s.methodIds.isNotEmpty);

  /// Barcha metodlar (tasdiqlovchi + tahliliy), takrorsiz.
  Set<String> get allMethodIds => {
    for (final m in confirmationMethods) m.methodId,
    for (final m in analyticalMethods) m.methodId,
  };

  /// Graf va provenance qatlamidan yig‘adi.
  static SubstanceAnalysis build({
    required String entityId,
    required EvidenceData evidence,
    required ProvenanceIndex provenance,
  }) {
    List<ClaimView> claims(Iterable<String> ids) => [
      for (final id in ids) ?provenance.claimsById[id],
    ];
    Map<String, List<String>> group(
      Iterable<GraphLink> links,
      LinkRelation rel,
    ) {
      final m = <String, List<String>>{};
      for (final l in links) {
        if (l.relation != rel) continue;
        final bases = m.putIfAbsent(l.toId, () => []);
        if (!bases.contains(l.basis)) bases.add(l.basis);
      }
      return m;
    }

    final from = evidence.linksFrom(entityId);
    final measured = group(from, LinkRelation.measuredIn);
    final analysed = group(from, LinkRelation.analysedBy);
    final screened = group(from, LinkRelation.screenedBy);

    // Namunalar — paketdagi amaliy tartibda (qon birinchi).
    final order = [for (final s in provenance.specimens) s.id];
    int rank(String id) {
      final i = order.indexOf(id);
      return i < 0 ? order.length : i;
    }

    final specimenIds = measured.keys.toList()
      ..sort((a, b) {
        final r = rank(a).compareTo(rank(b));
        return r != 0 ? r : a.compareTo(b);
      });
    final specimens = [
      for (final id in specimenIds)
        AnalysisSpecimen(
          specimenId: id,
          specimen: provenance.specimen(id),
          basisIds: measured[id]!,
          basisClaims: claims(measured[id]!),
          methodIds: [
            for (final e in analysed.entries)
              if (e.value.any(measured[id]!.contains)) e.key,
          ]..sort(),
        ),
    ];

    final screeningIds = screened.keys.toList()..sort();
    final confirmBy = <String, List<String>>{};
    final confirmBasis = <String, List<String>>{};
    final screenings = <AnalysisScreening>[];
    for (final sid in screeningIds) {
      final conf = group(evidence.linksFrom(sid), LinkRelation.confirmedBy);
      for (final e in conf.entries) {
        confirmBy.putIfAbsent(e.key, () => []).add(sid);
        final b = confirmBasis.putIfAbsent(e.key, () => []);
        for (final x in e.value) {
          if (!b.contains(x)) b.add(x);
        }
      }
      screenings.add(
        AnalysisScreening(
          screeningId: sid,
          basisIds: screened[sid]!,
          basisClaims: claims(screened[sid]!),
          confirmationMethodIds: conf.keys.toList()..sort(),
        ),
      );
    }
    final confirmation = [
      for (final id in confirmBy.keys.toList()..sort())
        AnalysisMethod(
          methodId: id,
          role: AnalysisMethodRole.confirmation,
          basisIds: confirmBasis[id]!,
          basisClaims: claims(confirmBasis[id]!),
          afterScreeningIds: confirmBy[id]!,
        ),
    ];
    final analytical = [
      for (final id in analysed.keys.toList()..sort())
        AnalysisMethod(
          methodId: id,
          role: AnalysisMethodRole.analytical,
          basisIds: analysed[id]!,
          basisClaims: claims(analysed[id]!),
        ),
    ];

    final metabolites = [
      for (final m in provenance.metabolitesOf(entityId))
        AnalysisMetabolite(
          relation: m,
          basisClaim: provenance.claimsById[m.basisClaimId],
          specimenIds: {
            ...m.specimens,
            if (m.metaboliteId != null)
              for (final l in evidence.linksFrom(m.metaboliteId!))
                if (l.relation == LinkRelation.measuredIn) l.toId,
          }.toList()..sort((a, b) => rank(a).compareTo(rank(b))),
        ),
    ];

    return SubstanceAnalysis(
      entityId: entityId,
      specimens: specimens,
      screenings: screenings,
      confirmationMethods: confirmation,
      analyticalMethods: analytical,
      metabolites: metabolites,
    );
  }
}

/// Teskari yo‘nalish: namunada (manbada qiymat keltirilgan) moddalar.
List<String> substancesMeasuredIn(EvidenceData evidence, String specimenId) {
  final ids = <String>{
    for (final l in evidence.linksTo(specimenId))
      if (l.relation == LinkRelation.measuredIn) l.fromId,
  };
  return ids.toList()..sort();
}
