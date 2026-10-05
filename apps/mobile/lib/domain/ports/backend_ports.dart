/// Backend abstraksiyasi (`docs/00_ARXITEKTURA_REJASI.md`, 25-bo‘lim).
///
/// Qoidalar:
/// * Feature’lar faqat shu interfeyslarni biladi. Supabase (yoki boshqa
///   provayder) SDK’si **faqat** `lib/data/remote/<provider>/` ichida
///   import qilinishi mumkin — `test/architecture` buni tekshiradi.
/// * Kontent, qidiruv va kalkulyatorlar backend’ga bog‘liq emas: backend
///   ishlamasa ham ular ishlaydi (offline kafolat testi).
library;

import 'package:flutter/foundation.dart';

import '../auth/auth_models.dart';

enum AuthStatus { signedOut, signedIn }

@immutable
class AuthState {
  const AuthState(this.status, {this.account});

  static const signedOut = AuthState(AuthStatus.signedOut);

  final AuthStatus status;

  /// Faqat email va tasdiqlash holati (boshqa PII yo‘q).
  final AuthAccount? account;

  String? get userId => account?.userId;

  bool get signedIn => status == AuthStatus.signedIn && account != null;

  /// Akkaunt xizmatlari (sinxronlash, bulutdagi huquq) uchun.
  bool get verified => signedIn && account!.emailVerified;
}

/// Akkaunt ixtiyoriy: oflayn ilmiy ma’lumotnoma akkauntsiz ishlaydi
/// (Apple 5.1.1(v)). Akkaunt faqat bulutdagi huquq / sinxronlash / AI
/// xizmatlari uchun kerak.
///
/// Xavfsizlik: parol faqat so‘rov tanasida serverga yuboriladi (TLS),
/// mijozda saqlanmaydi va jurnalga yozilmaydi; refresh token —
/// [SessionStore] (Keychain / Android Keystore); kodlar va tokenlar
/// jurnalga yozilmaydi. «Parolni unutdim» email mavjudligini oshkor
/// qilmaydi; ro‘yxatdan o‘tishda band email ham bir xil javob oladi
/// (server egasiga xat yuboradi).
abstract interface class AuthRepository {
  Stream<AuthState> watch();

  AuthState get current;

  /// Backend ulanganmi. `false` — akkaunt funksiyalari halol
  /// «xizmat hali ulanmagan» holatini ko‘rsatadi.
  bool get isConfigured;

  /// TEST/MOCK backend (haqiqiy xat yuborilmaydi) — UI buni belgilaydi.
  bool get isTestBackend;

  /// Ilova ishga tushganda saqlangan sessiyani tiklash.
  Future<void> restoreSession();

  /// Parolsiz kirish / ro‘yxatdan o‘tish: emailga 6 xonali kod yuboriladi
  /// (akkaunt bo‘lmasa server yaratadi). Javob har doim bir xil — email
  /// bormi-yo‘qmi oshkor qilinmaydi. Kod jurnalga yozilmaydi.
  Future<AuthOutcome> requestEmailCode(String email, {String? locale});

  /// Kod to‘g‘ri va muddati o‘tmagan bo‘lsa sessiya ochiladi (email
  /// tasdiqlangan hisoblanadi). Email tasdig‘i professional maqom EMAS.
  Future<AuthOutcome> verifyEmailCode({
    required String email,
    required String code,
  });

  /// Yaroqli kirishda har doim `ok` (email band bo‘lsa ham — server egasiga
  /// xabar xati yuboradi). Sessiya bermaydi: akkaunt email kodi bilan
  /// tasdiqlangach faollashadi ([verifyEmail]).
  Future<AuthOutcome> register({
    required String email,
    required String password,
    required String acceptedTermsVersion,
  });

  /// `invalidCredentials` yoki tasdiqlanmagan akkauntda
  /// `emailNotVerified` (parol to‘g‘ri bo‘lgandagina).
  Future<AuthOutcome> signIn({required String email, required String password});

  /// Tasdiqlash kodini qayta yuborish (bir xil javob; oraliq cheklovi).
  Future<AuthOutcome> resendVerification(String email);

  /// Kod to‘g‘ri bo‘lsa akkaunt faollashadi va sessiya ochiladi.
  Future<AuthOutcome> verifyEmail({
    required String email,
    required String code,
  });

  /// Har doim bir xil javob (email bormi-yo‘qmi oshkor qilinmaydi).
  Future<AuthOutcome> requestPasswordReset(String email);

  Future<AuthOutcome> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> signOut();

  /// Akkauntni o‘chirish (Apple 5.1.1(v), Google Play account deletion).
  /// Parol qayta so‘raladi. Lokal qurilma ma’lumotlarini o‘chirish — alohida
  /// amal (`UserDataController.deleteAllLocalData`).
  Future<AuthOutcome> deleteAccount({required String password});

  /// Server so‘rovlari uchun qisqa muddatli token (bo‘lmasa `null`).
  Future<String?> accessToken();
}

/// Refresh token uchun xavfsiz saqlash (Keychain / EncryptedSharedPrefs).
abstract interface class SessionStore {
  Future<String?> read();
  Future<void> write(String refreshToken);
  Future<void> clear();
}

/// Bookmark va progressni sinxronlash (ixtiyoriy, akkaunt bo‘lsa).
abstract interface class SyncRepository {
  bool get isAvailable;

  Future<void> syncNow();
}

@immutable
class RemoteContentInfo {
  const RemoteContentInfo({
    required this.packVersion,
    required this.manifestUrl,
    required this.critical,
  });

  final String packVersion;
  final Uri manifestUrl;
  final bool critical;
}

/// Kontent paketi yangilanishini tekshirish. Paketning o‘zi doim
/// `fe_content_package` orqali imzo bilan tekshiriladi — transportga
/// ishonilmaydi.
abstract interface class ContentUpdateRepository {
  Future<RemoteContentInfo?> checkForUpdate({required String? currentVersion});
}
