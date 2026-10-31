import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import '../../app/app_info.dart';
import 'supabase_rest.dart';

/// Eski versiyani o‘chirish («majburiy yangilash») kelishuvi: ilovaning
/// Supabase’ga ketadigan HAR BIR so‘rovi `x-fe-build` va `x-fe-platform`
/// sarlavhalarini olib boradi. Sarlavhalar bitta joyda — shu yerda — yig‘iladi
/// va ikkala transport ([HttpClientTransport], `HttpClientTtsHttp`) ularni
/// o‘zi qo‘shadi; adapterlar alohida hech narsa qilmaydi.

/// Joriy platforma nomi: android|ios|macos|linux|windows|web.
String fePlatformName() {
  final o = fePlatformOverride;
  if (o != null) return o;
  if (kIsWeb) return 'web';
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  return 'linux';
}

/// Faqat testlar uchun.
@visibleForTesting
String? fePlatformOverride;

/// `x-fe-build` + `x-fe-platform`.
Map<String, String> feClientHeaders() => {
  'x-fe-build': '${AppInfo.build}',
  'x-fe-platform': fePlatformName(),
};

/// Tashqaridan (Image.network) yuklanadigan URL uchun: sarlavhalar faqat
/// ilovaning o‘z Supabase hostiga ketadi (boshqa hostlarga — hech narsa).
Map<String, String>? feHeadersForUrl(String url) {
  final cfg = SupabaseConfig.fromEnvironment();
  final host = Uri.tryParse(url)?.host;
  if (cfg == null || host == null || host != cfg.url.host) return null;
  return feClientHeaders();
}

/// Server «ilova versiyasi eskirgan» desa ko‘tariladigan global signal.
/// Transportlar (soxta emas, haqiqiylari) shu yerga yozadi; ilova qatlami
/// (`updateRequiredProvider`) tinglaydi.
class UpdateRequiredSignal {
  UpdateRequiredSignal._();

  static final instance = UpdateRequiredSignal._();

  final ValueNotifier<bool> _required = ValueNotifier(false);
  ValueListenable<bool> get required => _required;

  void raise() => _required.value = true;

  @visibleForTesting
  void reset() => _required.value = false;
}

/// Javob «yangilash kerak» ekanini bildiradimi?
/// * HTTP 426;
/// * PostgREST xatosi: `{"message":"UPDATE_REQUIRED"}`;
/// * edge-funksiya: `{"error":"update_required"}`.
bool isUpdateRequiredResponse(int status, Object? json) {
  if (status == 426) return true;
  if (json is Map) {
    // `message` — faqat xato javobida (2xx qatorda foydalanuvchi matni
    // tasodifan shu so‘z bo‘lishi mumkin).
    final msg = json['message'];
    if (status >= 400 && msg is String && msg.trim() == 'UPDATE_REQUIRED') {
      return true;
    }
    final err = json['error'];
    if (err is String && err.trim().toLowerCase() == 'update_required') {
      return true;
    }
  }
  return false;
}

/// [isUpdateRequiredResponse] true bo‘lsa signalni ko‘taradi.
void reportIfUpdateRequired(int status, Object? json) {
  if (isUpdateRequiredResponse(status, json)) {
    UpdateRequiredSignal.instance.raise();
  }
}
