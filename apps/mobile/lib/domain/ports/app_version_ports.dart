/// Server ma’lumoti: ilovaning joriy build’i ruxsat etiladimi
/// (`rpc/app_version_info`). `minBuild == 0` — cheklov yo‘q.
class AppVersionInfo {
  const AppVersionInfo({
    required this.minBuild,
    required this.latestBuild,
    this.androidUrl,
    this.iosUrl,
  });

  final int minBuild;
  final int latestBuild;
  final String? androidUrl;
  final String? iosUrl;

  /// Shu build bloklanishi kerakmi.
  bool blocks(int build) => minBuild > 0 && build < minBuild;

  /// Noto‘g‘ri/bo‘sh javob → `null` (bloklanmaydi).
  static AppVersionInfo? tryParse(Object? json) {
    if (json is! Map) return null;
    int? asInt(Object? v) => v is int ? v : (v is num ? v.toInt() : null);
    String? asUrl(Object? v) =>
        v is String && v.trim().isNotEmpty ? v.trim() : null;
    final min = asInt(json['min_build']);
    if (min == null) return null;
    return AppVersionInfo(
      minBuild: min,
      latestBuild: asInt(json['latest_build']) ?? 0,
      androidUrl: asUrl(json['android_url']),
      iosUrl: asUrl(json['ios_url']),
    );
  }
}

/// Ishga tushishda eng kam ruxsat etilgan build’ni so‘raydi. Har qanday
/// xato/oflayn/timeout → `null` (foydalanuvchi hech qachon tarmoq tufayli
/// qulflanmaydi).
abstract interface class AppVersionService {
  Future<AppVersionInfo?> fetch();
}
