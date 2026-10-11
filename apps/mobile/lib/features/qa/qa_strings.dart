import 'package:flutter/material.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/qa/qa_models.dart';

/// «Savol-javob» domen qiymatlari → tarjima qilingan matn.
extension QaStrings on AppLocalizations {
  String qaRole(QaRole r) => switch (r) {
    QaRole.forensicPhysician => qaRolePhysician,
    QaRole.forensicChemist => qaRoleChemist,
    QaRole.labTechnician => qaRoleTechnician,
    QaRole.student => qaRoleStudent,
    QaRole.other => qaRoleOther,
  };

  String qaProfileStatus(QaStatus s) => switch (s) {
    QaStatus.unverified => qaStatusUnverified,
    QaStatus.verified => qaStatusVerified,
    QaStatus.rejected => qaStatusRejected,
    QaStatus.suspended => qaStatusSuspended,
  };

  String qaPostStatusLabel(QaPostStatus s) => switch (s) {
    QaPostStatus.published => qaPostPublished,
    QaPostStatus.moderation => qaPostModeration,
    QaPostStatus.removed => qaPostRemoved,
  };

  String qaTag(String tag) => switch (tag) {
    'toxicology' => qaTagToxicology,
    'alcohol' => qaTagAlcohol,
    'drugs' => qaTagDrugs,
    'dna' => qaTagDna,
    'histology' => qaTagHistology,
    'thanatology' => qaTagThanatology,
    'methods' => qaTagMethods,
    'regulations' => qaTagRegulations,
    'biology' => qaTagBiology,
    'criminalistics' => qaTagCriminalistics,
    'documentation' => qaTagDocumentation,
    // Server yangi teg qo‘shsa — kodning o‘zi ko‘rsatiladi, ilova sinmaydi.
    _ => tag,
  };

  String qaFlag(QaPrivacyFlag f) => switch (f) {
    QaPrivacyFlag.caseNumber => qaFlagCaseNumber,
    QaPrivacyFlag.personName => qaFlagPersonName,
    QaPrivacyFlag.dateAndPlace => qaFlagDateAndPlace,
    QaPrivacyFlag.contact => qaFlagContact,
    QaPrivacyFlag.identifier => qaFlagIdentifier,
  };

  /// Rad etish sababi — hujjatdan olingan matn emas, mashina kodi.
  String? qaReasonText(QaReason? r) => switch (r) {
    QaReason.notACredential => qaReasonNotACredential,
    QaReason.unreadable => qaReasonUnreadable,
    QaReason.roleMismatch => qaReasonRoleMismatch,
    QaReason.lowConfidence => qaReasonLowConfidence,
    QaReason.expired => qaReasonExpired,
    QaReason.reported => qaReasonReported,
    QaReason.documentOk || QaReason.manualCheck || null => null,
  };

  String qaModerationAction(QaModerationAction a) => switch (a) {
    QaModerationAction.publish => qaActionPublish,
    QaModerationAction.remove => qaActionRemove,
    QaModerationAction.pin => qaActionPin,
    QaModerationAction.unpin => qaActionUnpin,
    QaModerationAction.reinstate => qaActionReinstate,
    QaModerationAction.suspend => qaActionSuspend,
  };
}

/// Post holatining ikonkasi (rang yagona belgi emas).
IconData qaPostStatusIcon(QaPostStatus s) => switch (s) {
  QaPostStatus.published => Icons.check_circle_outline,
  QaPostStatus.moderation => Icons.hourglass_empty,
  QaPostStatus.removed => Icons.block,
};

Color qaPostStatusColor(QaPostStatus s, FeColorTokens c) => switch (s) {
  QaPostStatus.published => c.verified,
  QaPostStatus.moderation => c.warning,
  QaPostStatus.removed => c.danger,
};
