/// Ilova versiyasi. `pubspec.yaml` dagi `version` bilan mosligi testda
/// tekshiriladi (`test/unit/app_info_test.dart`) — qo‘shimcha plagin kerak emas.
///
/// Ilova versiyasi va ilmiy baza versiyasi ALOHIDA (34-bo‘lim):
/// ilmiy baza versiyasi kontent paketi manifestidan o‘qiladi.
abstract final class AppInfo {
  static const version = '0.1.0';
  static const build = 1;
}
