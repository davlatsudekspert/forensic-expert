import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart' show authRepositoryProvider;
import 'routes.dart';

/// «Avval ro‘yxatdan o‘ting, keyin foydalaning» (egasi qarori, 2026-11-03,
/// test: 60 talaba). Server sozlangan bo‘lsa (Supabase) va foydalanuvchi
/// kirmagan bo‘lsa, hamma sahifa o‘rniga kirish ekrani ochiladi.
///
/// Yig‘ishda o‘chiriladi: `--dart-define=FE_REQUIRE_LOGIN=false` (masalan,
/// do‘kon talabi bo‘lsa — Apple 5.1.1(v): akkauntsiz ishlaydigan funksiya).
const kRequireLogin = bool.fromEnvironment(
  'FE_REQUIRE_LOGIN',
  defaultValue: true,
);

/// Qoida yoqilganmi: faqat HAQIQIY serverga ulangan ilovada (sinov/mock va
/// oflayn rejimda — yo‘q; testlar va real-ilova sinovlari o‘zgarmaydi).
final loginGateEnabledProvider = Provider<bool>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return kRequireLogin && auth.isConfigured && !auth.isTestBackend;
});

/// Qurilmada saqlangan sessiya bor edimi (ilova ochilganda aniqlanadi).
/// Oflayn ochilganda tiklash uzilsa ham, ilgari kirgan foydalanuvchi
/// kirish ekraniga tushib qolmasin.
final hadSavedSessionProvider = Provider<bool>((ref) => false);

/// Majburiy kirish qoidasi (sof funksiya). `null` — aralashmaydi.
String? loginGateRedirect({
  required bool enabled,
  required bool onboardingDone,
  required bool signedIn,
  required bool hadSession,
  required String location,
}) {
  if (!enabled || !onboardingDone) return null;
  final path = Uri.parse(location).path;
  if (signedIn) {
    // Kirgach kirish ekranida qolmaydi.
    return path == Routes.welcomeAccount ? Routes.home : null;
  }
  final onAccount =
      path.startsWith('/welcome') || path.startsWith('/profile/account');
  if (hadSession || onAccount) return null;
  return Routes.welcomeAccount;
}
