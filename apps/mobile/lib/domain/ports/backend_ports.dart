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

enum AuthStatus { signedOut, signedIn }

@immutable
class AuthState {
  const AuthState(this.status, {this.userId});

  static const signedOut = AuthState(AuthStatus.signedOut);

  final AuthStatus status;

  /// Ichki identifikator. Ism, email va boshqa PII domen modelida saqlanmaydi.
  final String? userId;
}

/// Akkaunt majburiy emas (Apple 5.1.1(v) — `docs/01_EVIDENCE_AUDIT.md`, C-03).
abstract interface class AuthRepository {
  Stream<AuthState> watch();

  AuthState get current;

  Future<void> signOut();

  /// Akkauntni o‘chirish (Apple 5.1.1(v), Google Play account deletion).
  Future<void> deleteAccount();
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
