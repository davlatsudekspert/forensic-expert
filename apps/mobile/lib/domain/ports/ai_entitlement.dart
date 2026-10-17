/// Forensic AI ruxsati va server kvotasi. Ilovaning o‘zida hamma funksiya
/// bepul va ochiq; bu yerda faqat AI xizmatining chegarasi (suiiste’molga
/// qarshi) modellashtiriladi.
library;

import 'package:flutter/foundation.dart';

/// AI ruxsati turi.
enum AiPlan {
  /// AI ulanmagan yoki foydalanuvchi kirmagan.
  none,

  /// Kirgan foydalanuvchiga server kvotasi doirasida ochiq.
  includedQuota,
}

@immutable
class AiEntitlement {
  const AiEntitlement({
    required this.plan,
    this.monthlyQuestionLimit,
    this.usedThisPeriod = 0,
  });

  static const none = AiEntitlement(plan: AiPlan.none);

  final AiPlan plan;

  /// `null` faqat [AiPlan.none] da (cheklov tushunchasi yo‘q). AI hech
  /// qachon «cheksiz» deb modellashtirilmaydi.
  final int? monthlyQuestionLimit;
  final int usedThisPeriod;

  bool get canAsk =>
      plan != AiPlan.none &&
      monthlyQuestionLimit != null &&
      usedThisPeriod < monthlyQuestionLimit!;
}

/// AI kvotasi manbai.
abstract interface class AiEntitlementService {
  Future<AiEntitlement> current();
}

/// AI ulanmagan: kvota yo‘q.
class NoAiEntitlementService implements AiEntitlementService {
  const NoAiEntitlementService();

  @override
  Future<AiEntitlement> current() async => AiEntitlement.none;
}
