import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_info.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/ports/billing_ports.dart';

String tierLabel(AppLocalizations l, PlanTier t) => switch (t) {
  PlanTier.free => l.purchaseFreeTitle,
  PlanTier.studentPro => l.tierStudentPro,
  PlanTier.professionalPro => l.tierProfessionalPro,
  PlanTier.institution => l.tierInstitution,
};

String periodLabel(AppLocalizations l, BillingPeriod p) => switch (p) {
  BillingPeriod.month => l.periodMonthly,
  BillingPeriod.year => l.periodYearly,
  BillingPeriod.unknown => l.periodUnknown,
};

/// Obuna holati — foydalanuvchiga tushunarli matn.
String subscriptionStatusLabel(BuildContext context, Entitlements e) {
  final l = AppLocalizations.of(context);
  if (e.tier == PlanTier.free ||
      e.verification == EntitlementVerification.none) {
    return l.stNone;
  }
  final exp = e.expiresAt;
  final date = exp == null
      ? null
      : MaterialLocalizations.of(context).formatMediumDate(exp.toLocal());
  return switch (e.status) {
    EntitlementStatus.active => l.stActive,
    EntitlementStatus.expired => l.stExpired,
    EntitlementStatus.gracePeriod => l.stGrace,
    EntitlementStatus.billingRetry => l.stBillingRetry,
    EntitlementStatus.cancelledActiveUntilExpiry =>
      date == null ? l.stCancelledNoDate : l.stCancelled(date),
    EntitlementStatus.revoked => l.stRevoked,
    EntitlementStatus.unknown => l.stUnknown,
  };
}

/// Store’dagi obunani boshqarish sahifasi (Apple / Google rasmiy havolalari).
Uri? manageSubscriptionUri({String? productId}) {
  if (kIsWeb) return null;
  if (Platform.isIOS) {
    return Uri.parse('https://apps.apple.com/account/subscriptions');
  }
  if (Platform.isAndroid) {
    return Uri.https('play.google.com', '/store/account/subscriptions', {
      'package': AppInfo.applicationId,
      'sku': ?productId,
    });
  }
  return null;
}

Future<void> openManageSubscription(
  BuildContext context, {
  String? productId,
}) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final uri = manageSubscriptionUri(productId: productId);
  var ok = false;
  if (uri != null) {
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      ok = false;
    }
  }
  if (!ok) {
    messenger.showSnackBar(SnackBar(content: Text(l.manageSubscriptionFailed)));
  }
}
