import 'package:flutter/material.dart';

import '../../core/design/theme.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/support/support_models.dart';

extension SupportStrings on AppLocalizations {
  String supCategoryLabel(SupportCategory c) => switch (c) {
    SupportCategory.suggestion => supCatSuggestion,
    SupportCategory.bug => supCatBug,
    SupportCategory.scientificError => supCatScientificError,
    SupportCategory.featureRequest => supCatFeatureRequest,
    SupportCategory.techSupport => supCatTechSupport,
    SupportCategory.general => supCatGeneral,
  };

  String supStatus(SupportStatus s) => switch (s) {
    SupportStatus.newRequest => supStatusNew,
    SupportStatus.inReview => supStatusInReview,
    SupportStatus.answered => supStatusAnswered,
    SupportStatus.closed => supStatusClosed,
  };

  String admAction(String action) => switch (action) {
    'SUPPORT_REPLY' => admActSupportReply,
    'SUPPORT_STATUS' => admActSupportStatus,
    'SUPPORT_THREAD_VIEW' => admActSupportView,
    'USERS_VIEW' => admActUsersView,
    'ACCESS_SET' => admActAccessSet,
    'ROLE_GRANTED' => admActRoleGranted,
    'ROLE_REVOKED' => admActRoleRevoked,
    'ROLE_CHANGED' => admActRoleChanged,
    _ => admActOther,
  };
}

extension SupportCategoryUi on SupportCategory {
  IconData get icon => switch (this) {
    SupportCategory.suggestion => Icons.lightbulb_outline,
    SupportCategory.bug => Icons.bug_report_outlined,
    SupportCategory.scientificError => Icons.science_outlined,
    SupportCategory.featureRequest => Icons.add_task_outlined,
    SupportCategory.techSupport => Icons.support_agent_outlined,
    SupportCategory.general => Icons.chat_bubble_outline,
  };
}

extension SupportStatusUi on SupportStatus {
  IconData get icon => switch (this) {
    SupportStatus.newRequest => Icons.fiber_new_outlined,
    SupportStatus.inReview => Icons.manage_search,
    SupportStatus.answered => Icons.mark_chat_read_outlined,
    SupportStatus.closed => Icons.lock_outline,
  };

  Color color(BuildContext context) {
    final c = FeTheme.of(context);
    return switch (this) {
      SupportStatus.newRequest => c.accent,
      SupportStatus.inReview => c.reviewed,
      SupportStatus.answered => c.verified,
      SupportStatus.closed => c.textSecondary,
    };
  }
}
