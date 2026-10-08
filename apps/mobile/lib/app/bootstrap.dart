import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/perf/startup_metrics.dart';
import '../core/settings/settings_controller.dart';
import '../core/settings/settings_repository.dart';
import '../data/auth/mock_auth_repository.dart';
import '../data/auth/secure_session_store.dart';
import '../data/billing/in_app_purchase_client.dart';
import '../data/billing/store_entitlement_service.dart';
import '../data/local/profile_store.dart';
import '../data/local/referral_store.dart';
import '../data/local/user_data_repository.dart';
import '../data/offline/offline_backend.dart';
import '../data/remote/http_auth_repository.dart';
import '../data/remote/http_purchase_verifier.dart';
import '../data/remote/supabase_account.dart';
import '../data/remote/supabase_ai_provider.dart';
import '../data/remote/supabase_auth_repository.dart';
import '../data/remote/supabase_professional.dart';
import '../data/remote/supabase_publications.dart';
import '../data/remote/supabase_referral.dart';
import '../data/remote/supabase_rest.dart';
import '../domain/ports/backend_ports.dart';
import '../domain/ports/billing_ports.dart';
import 'account.dart';
import 'app.dart';
import 'app_info.dart';
import 'professional.dart';
import 'providers.dart';
import 'publications.dart';
import 'referral.dart';
import 'user_data.dart';

/// Ilovani ishga tushirish.
///
/// Startup yo‘lida faqat **lokal** va tez ishlar: sozlamalarni o‘qish.
/// Tarmoq so‘rovi, kontent bazasini ochish yoki og‘ir hisob yo‘q —
/// ular birinchi kadrdan keyin, kerak bo‘lganda bajariladi.
Future<void> bootstrap() async {
  final metrics = StartupMetrics.instance..start();
  WidgetsFlutterBinding.ensureInitialized();

  _registerFontLicenses();

  final prefs = await metrics.measure(
    PerfMarks.settingsLoad,
    SharedPreferences.getInstance,
  );
  final repo = SharedPrefsSettingsRepository(prefs);
  final settings = await repo.load();
  // Saralanganlar va qidiruv tarixi — faqat lokal.
  final userDataRepo = SharedPrefsUserDataRepository(prefs);
  final userData = await userDataRepo.load();
  // Ixtiyoriy profil — faqat qurilmada.
  final profileStore = SharedPrefsProfileStore(prefs);
  final profile = await profileStore.load();
  metrics.mark(PerfMarks.settingsLoaded);

  final auth = _authRepository();
  // Professional tasdiqlash / taqriz — Supabase sozlangan bo‘lsagina.
  final supabase = SupabaseConfig.fromEnvironment();

  SchedulerBinding.instance.addPostFrameCallback((_) {
    metrics.mark(PerfMarks.firstFrame);
    // Sessiyani tiklash birinchi kadrdan keyin (tarmoq startup’ni
    // to‘xtatmaydi; oflayn ilmiy funksiyalar bunga bog‘liq emas).
    unawaited(auth.restoreSession());
  });

  runApp(
    ProviderScope(
      overrides: [
        initialSettingsProvider.overrideWithValue(settings),
        settingsRepositoryProvider.overrideWithValue(repo),
        userDataRepositoryProvider.overrideWithValue(userDataRepo),
        initialUserDataProvider.overrideWithValue(userData),
        profileStoreProvider.overrideWithValue(profileStore),
        initialProfileProvider.overrideWithValue(profile),
        authRepositoryProvider.overrideWithValue(auth),
        // Kutilayotgan taklif kodi (deep link) — faqat lokal.
        pendingReferralStoreProvider.overrideWithValue(
          SharedPrefsPendingReferralStore(prefs),
        ),
        // Server AI (Gemini, kalit faqat Edge Function’da) — faqat yoqilganda.
        if (SupabaseAiProvider.fromEnvironment(auth) case final ai?) ...[
          aiProviderProvider.overrideWithValue(ai),
          aiAssistantProvider.overrideWithValue(RemoteAiAssistant(auth)),
          aiEntitlementServiceProvider.overrideWithValue(
            SignedInBetaAiEntitlementService(auth),
          ),
        ],
        if (supabase != null) ...[
          professionalVerificationServiceProvider.overrideWithValue(
            SupabaseVerificationService(config: supabase, auth: auth),
          ),
          professionalReviewServiceProvider.overrideWithValue(
            SupabaseReviewService(config: supabase, auth: auth),
          ),
          referralServiceProvider.overrideWithValue(
            SupabaseReferralService(config: supabase, auth: auth),
          ),
          accountServiceProvider.overrideWithValue(
            SupabaseAccountService(config: supabase, auth: auth),
          ),
          publicationServiceProvider.overrideWithValue(
            SupabasePublicationService(config: supabase, auth: auth),
          ),
        ],
        // Obunalar: faqat mobil store’larda. Boshqa platformada — store yo‘q.
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
          entitlementServiceProvider.overrideWithValue(
            StoreEntitlementService(
              client: InAppPurchaseStoreClient(),
              verifier: HttpPurchaseVerifier.fromEnvironment(
                bundleId: AppInfo.applicationId,
                accessToken: auth.accessToken,
              ),
              platformSource: Platform.isIOS
                  ? EntitlementSource.appStore
                  : EntitlementSource.playStore,
            ),
          ),
      ],
      child: const ForensicExpertApp(),
    ),
  );
}

/// Akkaunt backend’i: `FE_SUPABASE_URL` + `FE_SUPABASE_ANON_KEY` bo‘lsa —
/// Supabase Auth (email OTP); `FE_AUTH_BASE_URL` (HTTPS) bo‘lsa — HTTP adapter;
/// release bo‘lmagan yig‘mada `FE_AUTH_MODE=mock` — MOCK (xat
/// yuborilmaydi, UI belgilaydi); aks holda — ulanmagan (halol holat).
AuthRepository _authRepository() {
  final supabase = SupabaseAuthRepository.fromEnvironment(SecureSessionStore());
  if (supabase != null) return supabase;
  final http = HttpAuthRepository.fromEnvironment(SecureSessionStore());
  if (http != null) return http;
  const mode = String.fromEnvironment('FE_AUTH_MODE');
  if (!kReleaseMode && mode == 'mock') return MockAuthRepository();
  return const OfflineAuthRepository();
}

/// Ilovaga o‘rnatilgan shriftlar litsenziyasi (SIL OFL 1.1) — «Licenses»
/// sahifasida ko‘rinadi.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (pkg, path) in const [
      ('Inter', 'assets/fonts/inter/OFL.txt'),
      ('JetBrains Mono', 'assets/fonts/jetbrains_mono/OFL.txt'),
    ]) {
      final text = await rootBundle.loadString(path);
      yield LicenseEntryWithLineBreaks([pkg], text);
    }
  });
}
