import 'package:flutter/material.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/publications/publication_models.dart';

extension PublicationStrings on AppLocalizations {
  String pubStatus(PublicationStatus s) => switch (s) {
    PublicationStatus.draft => pubStatusDraft,
    PublicationStatus.submitted => pubStatusSubmitted,
    PublicationStatus.screening => pubStatusScreening,
    PublicationStatus.inReview => pubStatusInReview,
    PublicationStatus.approved => pubStatusApproved,
    PublicationStatus.rejected => pubStatusRejected,
    PublicationStatus.published => pubStatusPublished,
    PublicationStatus.retracted => pubStatusRetracted,
    PublicationStatus.superseded => pubStatusSuperseded,
  };

  String pubReason(ReportReason r) => switch (r) {
    ReportReason.plagiarism => pubReasonPlagiarism,
    ReportReason.personalData => pubReasonPersonalData,
    ReportReason.copyright => pubReasonCopyright,
    ReportReason.misinformation => pubReasonMisinformation,
    ReportReason.abuse => pubReasonAbuse,
    ReportReason.other => pubReasonOther,
  };

  String pubLang(PublicationLanguage x) => switch (x) {
    PublicationLanguage.uz => pubLangUz,
    PublicationLanguage.ru => pubLangRu,
    PublicationLanguage.en => pubLangEn,
  };
}

extension PublicationStatusUi on PublicationStatus {
  IconData get icon => switch (this) {
    PublicationStatus.draft => Icons.edit_note,
    PublicationStatus.submitted => Icons.outbox_outlined,
    PublicationStatus.screening => Icons.manage_search,
    PublicationStatus.inReview => Icons.rate_review_outlined,
    PublicationStatus.approved => Icons.thumb_up_alt_outlined,
    PublicationStatus.rejected => Icons.undo,
    PublicationStatus.published => Icons.public,
    PublicationStatus.retracted => Icons.block,
    PublicationStatus.superseded => Icons.history,
  };

  Color color(FeColorTokens c) => switch (this) {
    PublicationStatus.published => c.verified,
    PublicationStatus.approved => c.reviewed,
    PublicationStatus.rejected || PublicationStatus.retracted => c.danger,
    PublicationStatus.superseded => c.outdated,
    PublicationStatus.draft => c.textSecondary,
    _ => c.warning,
  };
}
