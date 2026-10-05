import '../professional/professional_models.dart';
import '../professional/review_models.dart';

/// Profil — faqat qurilmada (bulutga yuborilmaydi, analitikaga tushmaydi).
abstract interface class LocalProfileStore {
  Future<LocalUserProfile> load();

  Future<void> save(LocalUserProfile profile);

  Future<void> clear();
}

/// Bulut xizmati xatolari (UI lokalizatsiya qiladi).
enum ProfessionalFailure {
  /// Production server ulanmagan — halol aytiladi.
  serviceNotConnected,
  notSignedIn,
  invalidInput,
  tooManyFiles,
  invalidFile,
  forbidden,
  offline,
  server,
}

class ProfessionalResult<T> {
  const ProfessionalResult.ok(T this.value) : failure = null;
  const ProfessionalResult.fail(ProfessionalFailure this.failure)
    : value = null;

  final T? value;
  final ProfessionalFailure? failure;

  bool get ok => failure == null;
}

/// Professional maqom holatining mijozdagi surati (server manbai).
class ProfessionalSnapshot {
  const ProfessionalSnapshot({this.identity, this.application});

  static const empty = ProfessionalSnapshot();

  final ProfessionalIdentity? identity;
  final ProfessionalApplication? application;

  VerificationStatus get status =>
      application?.status ?? identity?.status ?? VerificationStatus.unverified;
}

/// Professional tasdiqlash xizmati (server).
///
/// Server majburiyatlari (`docs/PROFESSIONAL_VERIFICATION.md`):
/// * hujjatlar faqat xususiy omborda, ochiq URL yo‘q;
/// * maqomni faqat identity admin o‘zgartiradi;
/// * soha vakolatini faqat alohida rol beradi;
/// * mijozdagi rol bayroqlariga ishonilmaydi.
abstract interface class ProfessionalVerificationService {
  /// `false` — production server ulanmagan; UI buni ochiq ko‘rsatadi.
  bool get isConfigured;

  Future<ProfessionalSnapshot> fetch();

  /// Ariza (va ixtiyoriy hujjatlar) yuborish. Faqat akkaunt bilan.
  Future<ProfessionalResult<ProfessionalApplication>> submit({
    required ProfessionalProfile profile,
    required List<CredentialFile> documents,
  });
}

/// Taqriz navbatlari (taqrizchi ish joyi).
enum ReviewQueue {
  needsReview,
  assignedToMe,
  reviewedByMe,
  conflicts,
  reReview,
}

class ReviewQueueItem {
  const ReviewQueueItem({
    required this.subject,
    required this.title,
    required this.discipline,
    required this.claimCount,
    required this.sourceCount,
    required this.state,
    this.evidenceLevel,
  });

  final ReviewSubject subject;
  final String title;
  final String discipline;
  final int claimCount;
  final int sourceCount;
  final ReviewState state;
  final String? evidenceLevel;
}

/// Mutaxassis taqrizlari xizmati (server).
abstract interface class ProfessionalReviewService {
  bool get isConfigured;

  /// Material uchun saqlangan taqrizlar (barcha versiyalar — tarix).
  Future<ProfessionalResult<List<ProfessionalReview>>> reviewsFor(
    String recordId,
  );

  /// Taqriz yuborish. Server vakolatni qayta tekshiradi.
  Future<ProfessionalResult<ProfessionalReview>> submit({
    required ReviewSubject subject,
    required ReviewAction action,
    required String note,
    String? sourceReference,
  });

  Future<ProfessionalResult<List<ReviewQueueItem>>> queue(ReviewQueue q);
}

/// Tanlangan fayl (faqat xotirada).
class PickedFile {
  const PickedFile({required this.name, required this.bytes});

  final String name;
  final List<int> bytes;
}

/// Qurilmadan PDF/JPG/PNG tanlash. Fayl nusxasi ilova xotirasida
/// saqlanmaydi va diskka yozilmaydi.
abstract interface class CredentialFilePicker {
  Future<PickedFile?> pick();
}
