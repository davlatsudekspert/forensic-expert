import '../admin/admin_models.dart';

/// Server hisobi: qurilma ro‘yxati, server grant va admin panel.
abstract interface class AccountService {
  bool get isConfigured;

  /// O‘z server kirishi (grant va admin roli); xato/oflayn — `null`.
  Future<ServerAccess?> myAccess();

  /// Platforma, versiya, til va qurilma hududi (IP yoki joylashuv emas).
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  });

  /// Faqat admin; aks holda `null`.
  Future<AdminDashboard?> dashboard();

  /// Email bo‘yicha Pro berish (`tier`) yoki olib tashlash (`null`).
  Future<AdminGrantResult> setAccess(String email, String? tier);
}

class UnconfiguredAccountService implements AccountService {
  const UnconfiguredAccountService();

  @override
  bool get isConfigured => false;

  @override
  Future<ServerAccess?> myAccess() async => null;

  @override
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  }) async {}

  @override
  Future<AdminDashboard?> dashboard() async => null;

  @override
  Future<AdminGrantResult> setAccess(String email, String? tier) async =>
      AdminGrantResult.failed;
}
