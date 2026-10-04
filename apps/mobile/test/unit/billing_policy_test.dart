import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/offline/offline_billing.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

void main() {
  const lifetime = Entitlements(
    access: AccessLevel.lifetime,
    source: EntitlementSource.playStore,
  );

  test('Lifetime — yagona bir martalik mahsulot, obuna ID’lari yo‘q', () {
    expect(ProductIds.all, [ProductIds.lifetime]);
    for (final id in ProductIds.all) {
      expect(id, isNot(contains('monthly')));
      expect(id, isNot(contains('annual')));
    }
  });

  test('bepul: demo; Lifetime: to‘liq; xavfsizlik va manbalar doim ochiq', () {
    for (final f in ProductFeature.values) {
      final free = AccessPolicy.accessFor(f, Entitlements.free);
      final paid = AccessPolicy.accessFor(f, lifetime);
      expect(paid, FeatureAccess.full, reason: f.name);
      expect(
        free,
        f == ProductFeature.safetyAndProvenance
            ? FeatureAccess.full
            : FeatureAccess.demo,
        reason: f.name,
      );
    }
    expect(AccessPolicy.freeEntriesPerSection, greaterThan(0));
    expect(AccessPolicy.freeCourses, greaterThan(0));
    expect(AccessPolicy.freeSearchResultsPerGroup, greaterThan(0));
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
    expect(AccessPolicy.isToolUnlocked('tool.tox.widmark', lifetime), isTrue);
  });

  test('AI Lifetime’dan alohida va hech qachon cheksiz emas', () async {
    expect(await const NoAiEntitlementService().current(), AiEntitlement.none);
    expect(AiEntitlement.none.canAsk, isFalse);
    const quota = AiEntitlement(
      plan: AiPlan.includedQuota,
      monthlyQuestionLimit: 10,
      usedThisPeriod: 10,
    );
    expect(quota.canAsk, isFalse);
    // Kvota rejasida limit majburiy (null — «cheksiz» emas, ruxsat yo‘q).
    expect(const AiEntitlement(plan: AiPlan.includedQuota).canAsk, isFalse);
  });

  test('store ulanmagan: taklif yo‘q, xarid «unavailable»', () async {
    const s = StoreUnavailableEntitlementService();
    expect(await s.offers(), isEmpty);
    expect(await s.purchase(ProductIds.lifetime), PurchaseOutcome.unavailable);
    expect((await s.restore()).hasFullAccess, isFalse);
  });

  test('narx UI kodida yozilmagan (faqat BillingConfig reference)', () {
    final offenders = <String>[];
    for (final f in Directory('lib/features').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      if (RegExp(r'59[.,]99|\$\d').hasMatch(src)) offenders.add(f.path);
    }
    expect(offenders, isEmpty);
  });
}
