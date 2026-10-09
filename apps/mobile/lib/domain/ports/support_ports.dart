import '../support/support_models.dart';

/// «Taklif va murojaatlar» va admin panel server porti. Muallif/admin
/// tekshiruvi, uzunlik va tezlik cheklovlari faqat serverda; mijoz bayrog‘i
/// hech qachon admin huquqini bermaydi.
abstract interface class SupportService {
  bool get isConfigured;

  // ------------------------------------------------------------ user
  /// Rasm (bo‘lsa) avval shaxsiy bucket’ga yuklanadi, so‘ng murojaat.
  Future<SupportCreateResult> createThread(SupportDraft draft);

  Future<SupportSendResult> sendMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  });

  /// O‘z murojaatlari. Kirmagan/xato — `null`.
  Future<List<SupportThread>?> myThreads();

  /// Muallif yoki admin; xabarlar bilan. Topilmadi/xato — `null`.
  Future<SupportThread?> thread(String id);

  /// O‘qilmagan admin javoblari (o‘z murojaatlarida).
  Future<int> unreadCount();

  Future<void> markRead(String id);

  /// Shaxsiy rasm uchun qisqa muddatli imzolangan havola (yoki `null`).
  Future<Uri?> attachmentUrl(String path);

  // ------------------------------------------------------------ admin
  Future<AdminStats?> adminStats();

  Future<AdminPage<SupportThread>?> adminInbox(
    SupportInboxFilter filter, {
    int limit = 25,
    int offset = 0,
  });

  Future<SupportSendResult> adminReply(String threadId, String body);

  /// Yangi holat yoki `null` (xato).
  Future<SupportStatus?> adminSetStatus(String threadId, SupportStatus status);

  Future<AdminPage<AdminUserSummary>?> adminUsers(AdminUserFilter filter);

  Future<List<AdminAuditEntry>?> adminAuditLog({int limit = 100});
}

/// Backend’siz yig‘ma: bo‘lim halol «ulanmagan» holatini ko‘rsatadi.
class UnconfiguredSupportService implements SupportService {
  const UnconfiguredSupportService();

  @override
  bool get isConfigured => false;

  @override
  Future<SupportCreateResult> createThread(SupportDraft draft) async =>
      SupportCreateResult.failed;

  @override
  Future<SupportSendResult> sendMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  }) async => SupportSendResult.failed;

  @override
  Future<List<SupportThread>?> myThreads() async => null;

  @override
  Future<SupportThread?> thread(String id) async => null;

  @override
  Future<int> unreadCount() async => 0;

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<Uri?> attachmentUrl(String path) async => null;

  @override
  Future<AdminStats?> adminStats() async => null;

  @override
  Future<AdminPage<SupportThread>?> adminInbox(
    SupportInboxFilter filter, {
    int limit = 25,
    int offset = 0,
  }) async => null;

  @override
  Future<SupportSendResult> adminReply(String threadId, String body) async =>
      SupportSendResult.failed;

  @override
  Future<SupportStatus?> adminSetStatus(
    String threadId,
    SupportStatus status,
  ) async => null;

  @override
  Future<AdminPage<AdminUserSummary>?> adminUsers(
    AdminUserFilter filter,
  ) async => null;

  @override
  Future<List<AdminAuditEntry>?> adminAuditLog({int limit = 100}) async => null;
}
