/// Pro (pullik reja) domen modeli. Qoida (egasi, 2026-10-24): har reja
/// **faqat o‘z rejimidagi** funksiyalarni ochadi; foydalanuvchi rejimini
/// almashtirish huquq bermaydi. Xavfsizlik, manbalar va provenance hech
/// qachon reja ortida emas.
library;

import 'package:flutter/foundation.dart';

/// Pullik reja (server: `plans.plan`). Bepul = reja yo‘q.
enum Plan {
  student,
  teacher,
  expert;

  String get wire => name;

  static Plan? fromWire(Object? v) {
    for (final p in values) {
      if (p.name == v) return p;
    }
    return null;
  }
}

/// Reja manbai (server: `plans.source`).
enum PlanSource {
  store,
  admin,
  trial;

  static PlanSource? fromWire(Object? v) {
    for (final s in values) {
      if (s.name == v) return s;
    }
    return null;
  }
}

/// Obuna davri.
enum PlanPeriod { monthly, yearly }

/// Do‘kon mahsuloti identifikatori: `fe_<reja>_<davr>` (App Store va Google
/// Play’da bir xil).
abstract final class PlanProducts {
  static String idFor(Plan plan, PlanPeriod period) =>
      'fe_${plan.name}_${period.name}';

  static Set<String> idsFor(Plan plan) => {
    for (final p in PlanPeriod.values) idFor(plan, p),
  };

  static Set<String> get allIds => {
    for (final plan in Plan.values) ...idsFor(plan),
  };

  static Plan? planOf(String productId) {
    for (final plan in Plan.values) {
      if (idsFor(plan).contains(productId)) return plan;
    }
    return null;
  }

  static PlanPeriod? periodOf(String productId) {
    for (final p in PlanPeriod.values) {
      if (productId.endsWith('_${p.name}')) return p;
    }
    return null;
  }
}

/// Reja bilan ochiladigan funksiyalar (shartnoma §3).
enum ProFeature {
  // Talaba
  fullQuizBank,
  examMode,
  allFlashcards,
  errorAnalytics,
  offlineDownload,
  // Ustoz
  allLessons,
  unlimitedGroupTests,
  resultsCsv,
  hardestDiscussion,
  liveTestLarge,
  // Mutaxassis
  instrumentsCourseFull,
  proCalculators,
  caseNotebook,
  courtPrep,
  aiExtended;

  /// Funksiyani ochadigan yagona reja.
  Plan get requiredPlan => switch (this) {
    fullQuizBank ||
    examMode ||
    allFlashcards ||
    errorAnalytics ||
    offlineDownload => Plan.student,
    allLessons ||
    unlimitedGroupTests ||
    resultsCsv ||
    hardestDiscussion ||
    liveTestLarge => Plan.teacher,
    instrumentsCourseFull ||
    proCalculators ||
    caseNotebook ||
    courtPrep ||
    aiExtended => Plan.expert,
  };
}

/// Foydalanuvchining joriy huquqi (faqat server tasdiqlagan holat).
@immutable
class Entitlements {
  const Entitlements({
    this.plan,
    this.source,
    this.expiresAt,
    this.autoRenew = false,
    this.trialAvailable = false,
    this.productId,
  });

  /// Reja yo‘q (mehmon yoki bepul).
  static const none = Entitlements();

  factory Entitlements.fromJson(Map<String, Object?> j) => Entitlements(
    plan: Plan.fromWire(j['plan']),
    source: PlanSource.fromWire(j['source']),
    expiresAt: j['expires_at'] is String
        ? DateTime.tryParse(j['expires_at']! as String)
        : null,
    autoRenew: j['auto_renew'] == true,
    trialAvailable: j['trial_available'] == true,
    productId: j['product_id'] as String?,
  );

  final Plan? plan;
  final PlanSource? source;

  /// `null` — muddatsiz.
  final DateTime? expiresAt;
  final bool autoRenew;

  /// Server: bu qurilma ham, bu akkaunt ham sinov olmagan.
  final bool trialAvailable;
  final String? productId;

  /// [now] paytida faol reja bormi (muddati tugagan — faol emas).
  bool isActiveAt(DateTime now) =>
      plan != null && (expiresAt == null || expiresAt!.isAfter(now));

  bool get isActive => isActiveAt(DateTime.now());

  /// Faol reja (muddati tugagan bo‘lsa `null`).
  Plan? activePlanAt(DateTime now) => isActiveAt(now) ? plan : null;

  /// Faqat **o‘z** rejasi funksiyani ochadi.
  bool allows(ProFeature feature, {DateTime? now}) =>
      isActiveAt(now ?? DateTime.now()) && plan == feature.requiredPlan;

  bool get isTrial => source == PlanSource.trial;

  @override
  bool operator ==(Object other) =>
      other is Entitlements &&
      other.plan == plan &&
      other.source == source &&
      other.expiresAt == expiresAt &&
      other.autoRenew == autoRenew &&
      other.trialAvailable == trialAvailable &&
      other.productId == productId;

  @override
  int get hashCode => Object.hash(
    plan,
    source,
    expiresAt,
    autoRenew,
    trialAvailable,
    productId,
  );
}

/// Dars qulfi qoidalari (egasi qarori, 2026-10-24): hamma dars,
/// prezentatsiya va dars testi Pro’da — bepul darslar yo‘q. Ustoz darslari —
/// Ustoz Pro, «Apparatlar bilan ishlash» — Mutaxassis Pro.
abstract final class LessonAccess {
  /// Ustozga bepul ochiq darslar soni.
  static const freeTeacherLessons = 0;

  static bool isInstrument(String topicId) => topicId.startsWith('instr-');

  /// Bepul namuna dars yo‘q.
  static bool isFreeInstrumentSample(String topicId) => false;
}

/// Professional kalkulyatorlar (Mutaxassis). Oddiy hisoblar bepul.
abstract final class ProCalculators {
  static const ids = {
    'tool.fm.pmi_henssge',
    'tool.tox.widmark',
    'tool.tox.back_calculation',
    'tool.conv.concentration_units',
    'tool.lab.calibration',
    'tool.lab.lod_loq',
  };

  static bool isPro(String toolId) => ids.contains(toolId);
}

/// Bepul mashq/guruh chegaralari yo‘q (egasi qarori, 2026-10-24: hammasi Pro;
/// 1 oylik sinov hammasini ochadi). Talabaning ustoz kodi bilan guruh testiga
/// qo‘shilishi bepul.
/// Talabaga bepul mashq savollari soni (har mavzudan).
const freePracticeQuestions = 0;

/// Ustozga bepul guruh testi: guruhlar soni va savollar soni.
const freeGroupLimit = 0;
const freeGroupTestQuestions = 0;
