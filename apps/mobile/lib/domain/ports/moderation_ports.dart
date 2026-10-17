import '../moderation/moderation_models.dart';
import '../support/support_models.dart';

/// Shikoyat, bloklash, hamjamiyat qoidalari va admin kengaytmasi porti.
/// Admin huquqi, rol qoidalari, tezlik (soatiga 5 ta) va ekranlash faqat
/// serverda; mijoz bayrog‘i hech narsani ruxsat etmaydi.
abstract interface class ModerationService {
  bool get isConfigured;

  // ------------------------------------------------------------ user
  /// Kirmagan foydalanuvchi ham yuboradi (anon kalit bilan).
  Future<ReportResult> submitReport(ReportDraft draft);

  /// O‘z shikoyatlari (faqat tur va holat). Kirmagan/xato — `null`.
  Future<List<MyReport>?> myReports();

  /// Post muallifini bloklaydi (kimligi mijozga hech qachon kelmaydi).
  Future<BlockResult> blockAuthor(ReportTarget target, String postId);

  Future<List<BlockedAuthor>?> myBlocks();

  Future<bool> unblock(String blockId);

  /// Hamjamiyat qoidalari qabul qilinganmi (joriy versiya). Xato — `null`.
  Future<bool?> communityTermsAccepted();

  Future<bool> acceptCommunityTerms();

  // ------------------------------------------------------------ admin
  Future<AdminStatsExt?> adminStatsExt();

  Future<AdminPage<AdminReport>?> adminReports(
    AdminReportFilter filter, {
    int limit = AdminReportFilter.pageSize,
    int offset = 0,
  });

  Future<bool> adminReportNote(String id, String note);

  Future<bool> adminResolveReport(
    String id, {
    bool resolved = true,
    String? note,
  });

  Future<RoleChangeResult> adminSetRole(
    String userId,
    ManagedRole role, {
    required bool grant,
    required String reason,
  });

  Future<SuspensionResult> adminSetSuspension(
    String userId, {
    required bool suspend,
    required String reason,
  });
}

/// Backend’siz yig‘ma: bo‘lim halol «ulanmagan» holatini ko‘rsatadi.
class UnconfiguredModerationService implements ModerationService {
  const UnconfiguredModerationService();

  @override
  bool get isConfigured => false;

  @override
  Future<ReportResult> submitReport(ReportDraft draft) async =>
      ReportResult.failed;

  @override
  Future<List<MyReport>?> myReports() async => null;

  @override
  Future<BlockResult> blockAuthor(ReportTarget target, String postId) async =>
      BlockResult.failed;

  @override
  Future<List<BlockedAuthor>?> myBlocks() async => null;

  @override
  Future<bool> unblock(String blockId) async => false;

  @override
  Future<bool?> communityTermsAccepted() async => null;

  @override
  Future<bool> acceptCommunityTerms() async => false;

  @override
  Future<AdminStatsExt?> adminStatsExt() async => null;

  @override
  Future<AdminPage<AdminReport>?> adminReports(
    AdminReportFilter filter, {
    int limit = AdminReportFilter.pageSize,
    int offset = 0,
  }) async => null;

  @override
  Future<bool> adminReportNote(String id, String note) async => false;

  @override
  Future<bool> adminResolveReport(
    String id, {
    bool resolved = true,
    String? note,
  }) async => false;

  @override
  Future<RoleChangeResult> adminSetRole(
    String userId,
    ManagedRole role, {
    required bool grant,
    required String reason,
  }) async => RoleChangeResult.failed;

  @override
  Future<SuspensionResult> adminSetSuspension(
    String userId, {
    required bool suspend,
    required String reason,
  }) async => SuspensionResult.failed;
}
