import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/credential_file_picker.dart';
import '../data/local/profile_store.dart';
import '../data/offline/offline_professional.dart';
import '../domain/ports/professional_ports.dart';
import '../domain/professional/professional_models.dart';
import '../domain/professional/review_models.dart';
import 'providers.dart';

/// Profil ombori (bootstrap’da SharedPreferences bilan override qilinadi).
final profileStoreProvider = Provider<LocalProfileStore>(
  (ref) => InMemoryProfileStore(),
);

final initialProfileProvider = Provider<LocalUserProfile>(
  (ref) => const LocalUserProfile(),
);

final localProfileProvider =
    NotifierProvider<LocalProfileController, LocalUserProfile>(
      LocalProfileController.new,
    );

/// Qurilmadagi profil (ixtiyoriy). Faqat foydalanuvchining o‘zi
/// to‘ldiradi; hech qanday maqom bermaydi.
class LocalProfileController extends Notifier<LocalUserProfile> {
  @override
  LocalUserProfile build() => ref.read(initialProfileProvider);

  Future<void> _set(LocalUserProfile next) async {
    state = next;
    await ref.read(profileStoreProvider).save(next);
  }

  Future<void> saveStudent(StudentProfile p) => _set(state.withStudent(p));

  Future<void> saveProfessional(ProfessionalProfile p) =>
      _set(state.withProfessional(p));

  Future<void> clear() async {
    state = const LocalUserProfile();
    await ref.read(profileStoreProvider).clear();
  }
}

/// Production server ulanmagan bo‘lsa — oflayn (halol) implementatsiya.
final professionalVerificationServiceProvider =
    Provider<ProfessionalVerificationService>(
      (ref) => const OfflineProfessionalVerificationService(),
    );

final professionalReviewServiceProvider = Provider<ProfessionalReviewService>(
  (ref) => const OfflineProfessionalReviewService(),
);

/// Server bergan maqom. Akkauntsiz — har doim bo‘sh (tasdiqlanmagan).
final professionalSnapshotProvider = FutureProvider<ProfessionalSnapshot>((
  ref,
) async {
  final signedIn = ref.watch(authStateProvider.select((s) => s.signedIn));
  final service = ref.watch(professionalVerificationServiceProvider);
  if (!signedIn || !service.isConfigured) return ProfessionalSnapshot.empty;
  return service.fetch();
});

/// Joriy foydalanuvchining server tomonidagi identifikatsiyasi (bo‘lsa).
final professionalIdentityProvider = Provider<ProfessionalIdentity?>(
  (ref) => ref.watch(professionalSnapshotProvider).value?.identity,
);

/// Material uchun taqrizlar.
final reviewsForProvider =
    FutureProvider.family<ProfessionalResult<List<ProfessionalReview>>, String>(
      (ref, recordId) =>
          ref.watch(professionalReviewServiceProvider).reviewsFor(recordId),
    );

/// Taqriz navbati (faqat tasdiqlangan taqrizchi uchun ochiladi).
final reviewQueueProvider =
    FutureProvider.family<
      ProfessionalResult<List<ReviewQueueItem>>,
      ReviewQueue
    >((ref, q) => ref.watch(professionalReviewServiceProvider).queue(q));

/// Malaka hujjatini tanlash (testlarda soxta implementatsiya bilan).
final credentialFilePickerProvider = Provider<CredentialFilePicker>(
  (ref) => const SystemCredentialFilePicker(),
);
