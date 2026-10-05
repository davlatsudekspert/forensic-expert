import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/offline/offline_billing.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:forensic_expert/domain/ports/product_tiers.dart';

Entitlements _e(
  PlanTier tier, {
  EntitlementStatus status = EntitlementStatus.active,
  EntitlementVerification v = EntitlementVerification.serverVerified,
}) => Entitlements(
  tier: tier,
  status: status,
  source: EntitlementSource.playStore,
  verification: v,
);

void main() {
  final student = _e(PlanTier.studentPro);
  final pro = _e(PlanTier.professionalPro);

  test('mahsulotlar: konfiguratsiyadan, fe_ konvensiyasi, tarifga '
      'bog‘langan; Institution ommaga taklif qilinmaydi', () {
    expect(ProductIds.all, hasLength(4));
    for (final id in ProductIds.all) {
      expect(id, startsWith('fe_'));
      expect(ProductIds.tierOf(id), isNotNull);
      expect(ProductIds.expectedPeriodOf(id), isNot(BillingPeriod.unknown));
    }
    expect(ProductIds.tierOf('fe_unknown'), isNull);
    expect(ProductIds.tierOf('fe_lifetime_unlock'), isNull);
    expect(
      [for (final t in ProductTiers.publicTiers) t.tier],
      [PlanTier.free, PlanTier.studentPro, PlanTier.professionalPro],
    );
    expect(ProductTiers.purchasableProductIds, ProductIds.all);
  });

  test('feature gate: xavfsizlik va manbalar doim ochiq; Student — ta’lim '
      'va ma’lumotnoma; Professional — professional vositalar', () {
    for (final f in ProductFeature.values) {
      final min = FeatureGate.minimumTier(f);
      expect(FeatureGate.unlocks(f, pro), isTrue, reason: f.name);
      expect(
        FeatureGate.unlocks(f, Entitlements.free),
        min == PlanTier.free,
        reason: f.name,
      );
      expect(
        FeatureGate.unlocks(f, student),
        min.index <= PlanTier.studentPro.index,
        reason: f.name,
      );
    }
    expect(
      AccessPolicy.accessFor(
        ProductFeature.safetyAndProvenance,
        Entitlements.free,
      ),
      FeatureAccess.full,
    );
    expect(FeatureGate.unlocks(ProductFeature.learn, student), isTrue);
    expect(
      FeatureGate.unlocks(ProductFeature.quizzesAndFlashcards, student),
      isTrue,
    );
    expect(
      FeatureGate.unlocks(ProductFeature.professionalCalculators, student),
      isFalse,
    );
    expect(FeatureGate.unlocks(ProductFeature.professionalAi, pro), isTrue);
  });

  test('holatlar: grace va «bekor qilingan, muddat oxirigacha» — kirish bor; '
      'billing retry, expired, revoked, unknown — yo‘q', () {
    const granting = {
      EntitlementStatus.active,
      EntitlementStatus.gracePeriod,
      EntitlementStatus.cancelledActiveUntilExpiry,
    };
    for (final s in EntitlementStatus.values) {
      final e = _e(PlanTier.professionalPro, status: s);
      expect(
        e.effectiveTier,
        granting.contains(s) ? PlanTier.professionalPro : PlanTier.free,
        reason: s.name,
      );
    }
  });

  test('mijozning «men Pro» da’vosi yetarli emas: tasdiqsiz huquq — Free', () {
    final claimed = _e(
      PlanTier.professionalPro,
      v: EntitlementVerification.none,
    );
    expect(claimed.effectiveTier, PlanTier.free);
    expect(claimed.hasProfessionalAccess, isFalse);
  });

  test('bepul demoda kamida bitta haqiqiy vosita ochiq', () {
    expect(
      AccessPolicy.isToolUnlocked('tool.lab.dilution', Entitlements.free),
      isTrue,
    );
    expect(
      AccessPolicy.isToolUnlocked('tool.tox.widmark', Entitlements.free),
      isFalse,
    );
    expect(AccessPolicy.isToolUnlocked('tool.tox.widmark', student), isFalse);
    expect(AccessPolicy.isToolUnlocked('tool.tox.widmark', pro), isTrue);
  });

  test('AI tarifdan alohida va hech qachon cheksiz emas', () async {
    expect(await const NoAiEntitlementService().current(), AiEntitlement.none);
    expect(AiEntitlement.none.canAsk, isFalse);
    const quota = AiEntitlement(
      plan: AiPlan.includedQuota,
      monthlyQuestionLimit: 10,
      usedThisPeriod: 10,
    );
    expect(quota.canAsk, isFalse);
    expect(const AiEntitlement(plan: AiPlan.includedQuota).canAsk, isFalse);
  });

  test('store ulanmagan: taklif yo‘q, xarid «unavailable»', () async {
    const s = StoreUnavailableEntitlementService();
    expect(await s.offers(), isEmpty);
    expect(
      await s.purchase(ProductIds.professionalMonthly),
      PurchaseOutcome.unavailable,
    );
    expect((await s.restore()).hasFullAccess, isFalse);
  });

  test('narx UI va domen kodida yozilmagan (faqat store metadata)', () {
    final offenders = <String>[];
    for (final dir in ['lib/features', 'lib/domain']) {
      for (final f in Directory(dir).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final src = f.readAsStringSync();
        if (RegExp(r'\d+[.,]99\b|(?<![.\w])\$\d|€\s?\d|£\s?\d').hasMatch(src)) {
          offenders.add(f.path);
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('lokal `isPro` bayrog‘i yo‘q (huquq faqat store/serverdan)', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final code = f
          .readAsLinesSync()
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      if (RegExp(
        r'\bisPro\b|setBool\([^)]*(pro|premium|lifetime)',
        caseSensitive: false,
      ).hasMatch(code)) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
