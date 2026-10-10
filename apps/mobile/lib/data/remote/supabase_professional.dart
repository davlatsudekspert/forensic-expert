import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/professional_ports.dart';
import '../../domain/professional/professional_models.dart';
import '../../domain/professional/review_models.dart';
import '../../domain/professional/verification_inbox_models.dart';
import 'supabase_rest.dart';

/// Supabase (PostgREST + Storage) orqali professional tasdiqlash va
/// taqrizlar. Barcha vakolat tekshiruvlari serverda (RLS + `security
/// definer` funksiyalar, `supabase/migrations`). Mijoz faqat so‘rov
/// yuboradi; rol bayroqlari mijozdan olinmaydi.
class _SupabaseSession {
  _SupabaseSession(this.cfg, this.auth, this.http);

  final SupabaseConfig cfg;
  final AuthRepository auth;
  final RestTransport http;

  Future<Map<String, String>?> headers() async {
    final token = await auth.accessToken();
    if (token == null || !auth.current.signedIn) return null;
    return {'apikey': cfg.anonKey, 'Authorization': 'Bearer $token'};
  }

  Uri rest(String path, [Map<String, String>? q]) =>
      cfg.url.resolve('rest/v1/$path').replace(queryParameters: q);

  static ProfessionalFailure failure(RestResponse r) => switch (r.status) {
    401 => ProfessionalFailure.notSignedIn,
    403 => ProfessionalFailure.forbidden,
    400 || 409 || 422 => ProfessionalFailure.invalidInput,
    429 => ProfessionalFailure.server,
    _ => ProfessionalFailure.server,
  };

  Future<ProfessionalResult<T>> guard<T>(
    Future<ProfessionalResult<T>> Function(Map<String, String> h) body,
  ) async {
    final h = await headers();
    if (h == null) {
      return const ProfessionalResult.fail(ProfessionalFailure.notSignedIn);
    }
    try {
      return await body(h);
    } on SocketException {
      return const ProfessionalResult.fail(ProfessionalFailure.offline);
    } on TimeoutException {
      return const ProfessionalResult.fail(ProfessionalFailure.offline);
    } on HandshakeException {
      return const ProfessionalResult.fail(ProfessionalFailure.offline);
    }
  }
}

ReviewerScope? _scope(Object? code) =>
    code is String ? ReviewerScope.fromCode(code) : null;

class SupabaseVerificationService implements ProfessionalVerificationService {
  SupabaseVerificationService({
    required SupabaseConfig config,
    required AuthRepository auth,
    RestTransport? transport,
    Random? random,
  }) : _s = _SupabaseSession(config, auth, transport ?? HttpClientTransport()),
       _rng = random ?? Random.secure();

  final _SupabaseSession _s;
  final Random _rng;

  @override
  bool get isConfigured => true;

  @override
  Future<ProfessionalSnapshot> fetch() async {
    final uid = _s.auth.current.userId;
    final h = await _s.headers();
    if (uid == null || h == null) return ProfessionalSnapshot.empty;
    try {
      final v = await _s.http.send(
        'GET',
        _s.rest('verification', {
          'select': 'status,applicant_message,submitted_at',
          'user_id': 'eq.$uid',
        }),
        headers: h,
      );
      final scopes = await _s.http.send(
        'GET',
        _s.rest('reviewer_scopes', {
          'select': 'scope',
          'user_id': 'eq.$uid',
          'revoked_at': 'is.null',
        }),
        headers: h,
      );
      final verifier = await _s.http.send(
        'GET',
        _s.rest('verifier_grants', {
          'select': 'scope',
          'user_id': 'eq.$uid',
          'revoked_at': 'is.null',
        }),
        headers: h,
      );
      final profile = await _s.http.send(
        'GET',
        _s.rest('professional_profiles', {
          'select': 'display_name,primary_specialty,organization',
          'user_id': 'eq.$uid',
        }),
        headers: h,
      );
      final row = v.list.isEmpty ? const <String, Object?>{} : v.list.first;
      final status = VerificationStatus.fromCode(
        '${(row as Map)['status'] ?? 'UNVERIFIED'}',
      );
      final p = profile.list.isEmpty
          ? const <String, Object?>{}
          : profile.list.first! as Map;
      final identity = ProfessionalIdentity(
        userId: uid,
        displayName: '${p['display_name'] ?? ''}',
        status: status,
        scopes: {for (final r in scopes.list) ?_scope((r as Map)['scope'])},
        verifierScopes: {
          for (final r in verifier.list) ?_scope((r as Map)['scope']),
        },
        specialty: Specialty.values.asNameMap()[p['primary_specialty']],
        organization: p['organization'] as String?,
      );
      final submitted = DateTime.tryParse('${row['submitted_at'] ?? ''}');
      return ProfessionalSnapshot(
        identity: identity,
        application: submitted == null
            ? null
            : ProfessionalApplication(
                applicationId: uid,
                userId: uid,
                status: status,
                declaredSpecialty: identity.specialty ?? Specialty.other,
                submittedAt: submitted,
                applicantMessage: row['applicant_message'] as String?,
              ),
      );
    } on Exception {
      return ProfessionalSnapshot.empty;
    }
  }

  String _uuid() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  @override
  Future<ProfessionalResult<ProfessionalApplication>> submit({
    required ProfessionalProfile profile,
    required List<CredentialFile> documents,
  }) => _s.guard((h) async {
    final uid = _s.auth.current.userId!;
    if (ProfileValidation.professional(profile).isNotEmpty) {
      return const ProfessionalResult.fail(ProfessionalFailure.invalidInput);
    }
    if (documents.length > CredentialFilePolicy.maxFiles) {
      return const ProfessionalResult.fail(ProfessionalFailure.tooManyFiles);
    }
    // 1) Profil (upsert; faqat o‘z qatori — RLS).
    final up = await _s.http.send(
      'POST',
      _s.rest('professional_profiles'),
      headers: {...h, 'Prefer': 'resolution=merge-duplicates'},
      jsonBody: {
        'user_id': uid,
        'display_name': profile.fullName,
        'country_code': profile.country,
        'city': profile.city,
        'languages': profile.languages,
        'organization': profile.organization,
        'show_organization': profile.showOrganizationPublicly,
        'position': profile.position,
        'primary_specialty': profile.primarySpecialty.name,
        'additional_specialties': [
          for (final s in profile.additionalSpecialties) s.name,
        ],
        'years_experience': profile.yearsExperience,
        'education': profile.education,
        'work_email': profile.workEmail,
        'license_number': profile.licenseNumber,
        'bio': profile.bio,
        'interests': profile.interests,
      },
    );
    if (!up.ok) return ProfessionalResult.fail(_SupabaseSession.failure(up));
    // 2) Hujjatlar — xususiy bucket, faqat o‘z papkasi (storage RLS).
    final meta = <CredentialDocumentMeta>[];
    for (final d in documents) {
      final type = CredentialFilePolicy.detect(d.bytes);
      if (CredentialFilePolicy.validate(d.bytes) != null || type == null) {
        return const ProfessionalResult.fail(ProfessionalFailure.invalidFile);
      }
      final id = _uuid();
      final key = '$uid/$id';
      final mime = switch (type) {
        CredentialFileType.pdf => 'application/pdf',
        CredentialFileType.jpeg => 'image/jpeg',
        CredentialFileType.png => 'image/png',
      };
      final put = await _s.http.send(
        'POST',
        _s.cfg.url.resolve('storage/v1/object/credentials/$key'),
        headers: h,
        bytes: d.bytes,
        contentType: mime,
      );
      if (!put.ok) {
        return ProfessionalResult.fail(_SupabaseSession.failure(put));
      }
      final ins = await _s.http.send(
        'POST',
        _s.rest('credential_documents'),
        headers: {...h, 'Prefer': 'return=minimal'},
        jsonBody: {
          'document_id': id,
          'user_id': uid,
          'kind': d.kind.name,
          'mime_type': mime,
          'size_bytes': d.sizeBytes,
          'sha256': sha256.convert(d.bytes).toString(),
          'storage_key': key,
        },
      );
      if (!ins.ok) {
        return ProfessionalResult.fail(_SupabaseSession.failure(ins));
      }
      meta.add(
        CredentialDocumentMeta(
          documentId: id,
          kind: d.kind,
          type: type,
          sizeBytes: d.sizeBytes,
          uploadedAt: DateTime.now().toUtc(),
        ),
      );
    }
    // 3) Ariza — server avtomatik APPLICATION_PENDING qiladi.
    final rpc = await _s.http.send(
      'POST',
      _s.rest('rpc/submit_application'),
      headers: h,
      jsonBody: const <String, Object?>{},
    );
    if (!rpc.ok) return ProfessionalResult.fail(_SupabaseSession.failure(rpc));
    return ProfessionalResult.ok(
      ProfessionalApplication(
        applicationId: uid,
        userId: uid,
        status: VerificationStatus.applicationPending,
        declaredSpecialty: profile.primarySpecialty,
        submittedAt: DateTime.now().toUtc(),
        documents: meta,
      ),
    );
  });
}

/// Admin: `admin_pending_verifications` (ro‘yxat) va `decide_identity`
/// (qaror). Ikkalasi ham serverda identity_admin / vakolatni tekshiradi;
/// o‘zini tasdiqlash serverda taqiqlangan.
class SupabaseIdentityAdminService implements IdentityAdminService {
  SupabaseIdentityAdminService({
    required SupabaseConfig config,
    required AuthRepository auth,
    RestTransport? transport,
  }) : _s = _SupabaseSession(config, auth, transport ?? HttpClientTransport());

  final _SupabaseSession _s;

  @override
  bool get isConfigured => true;

  @override
  Future<ProfessionalResult<PendingVerificationPage>> pending({
    int limit = 50,
    int offset = 0,
  }) => _s.guard((h) async {
    final r = await _s.http.send(
      'POST',
      _s.rest('rpc/admin_pending_verifications'),
      headers: h,
      jsonBody: {'p_limit': limit, 'p_offset': offset},
    );
    if (!r.ok) return ProfessionalResult.fail(_SupabaseSession.failure(r));
    final m = r.map;
    final items = [
      for (final x in (m['items'] as List? ?? const []))
        ?PendingVerification.fromJson(x),
    ];
    return ProfessionalResult.ok(
      PendingVerificationPage(
        items: items,
        total: (m['total'] as num?)?.toInt() ?? items.length,
      ),
    );
  });

  static String _wire(IdentityDecision d) => switch (d) {
    IdentityDecision.verify => 'VERIFY',
    IdentityDecision.requestMoreInformation => 'REQUEST_MORE_INFORMATION',
    IdentityDecision.reject => 'REJECT',
    IdentityDecision.suspend => 'SUSPEND',
  };

  @override
  Future<IdentityDecisionFailure?> decide({
    required String applicantId,
    required IdentityDecision decision,
    required ReviewerScope scope,
    required List<String> checkedDocumentIds,
    required String reason,
    String? applicantMessage,
  }) async {
    // Oldindan tekshiruv (server baribir qayta tekshiradi).
    if (!IdentityDecisionRules.reasonOk(reason)) {
      return IdentityDecisionFailure.invalidInput;
    }
    if (decision == IdentityDecision.verify && checkedDocumentIds.isEmpty) {
      return IdentityDecisionFailure.noCredentialChecked;
    }
    final h = await _s.headers();
    if (h == null) return IdentityDecisionFailure.notSignedIn;
    try {
      final r = await _s.http.send(
        'POST',
        _s.rest('rpc/decide_identity'),
        headers: h,
        jsonBody: {
          'applicant': applicantId,
          'p_decision': _wire(decision),
          'p_scope': scope.code,
          'p_checked': checkedDocumentIds,
          'p_reason': reason.trim(),
          'p_message': applicantMessage?.trim(),
        },
      );
      if (r.ok) return null;
      final f = IdentityDecisionFailure.fromServerMessage(
        '${r.map['message'] ?? ''}',
      );
      if (f == IdentityDecisionFailure.server && r.status == 403) {
        return IdentityDecisionFailure.forbidden;
      }
      return f;
    } on SocketException {
      return IdentityDecisionFailure.offline;
    } on TimeoutException {
      return IdentityDecisionFailure.offline;
    } on HandshakeException {
      return IdentityDecisionFailure.offline;
    }
  }
}

class SupabaseReviewService implements ProfessionalReviewService {
  SupabaseReviewService({
    required SupabaseConfig config,
    required AuthRepository auth,
    RestTransport? transport,
  }) : _s = _SupabaseSession(config, auth, transport ?? HttpClientTransport());

  final _SupabaseSession _s;

  @override
  bool get isConfigured => true;

  static ProfessionalReview? _review(Object? raw) {
    if (raw is! Map) return null;
    final scope = _scope(raw['reviewer_scope']);
    final action = ReviewAction.values
        .where((a) => a.code == raw['action'])
        .firstOrNull;
    final created = DateTime.tryParse('${raw['created_at']}');
    if (scope == null || action == null || created == null) return null;
    return ProfessionalReview(
      reviewId: '${raw['review_id']}',
      recordId: '${raw['record_id']}',
      claimId: raw['claim_id'] as String?,
      contentVersion: '${raw['content_version']}',
      reviewerUserId: '${raw['reviewer_user_id']}',
      reviewerDisplayName: '${raw['reviewer_display_name']}',
      reviewerSpecialty:
          Specialty.values.asNameMap()[raw['reviewer_specialty']] ??
          Specialty.other,
      reviewerScope: scope,
      reviewerVerificationStatus: VerificationStatus.fromCode(
        '${raw['reviewer_status_at_review']}',
      ),
      reviewerOrganization: raw['reviewer_organization'] as String?,
      action: action,
      text: '${raw['review_text']}',
      sourceReference: raw['source_reference'] as String?,
      createdAt: created,
      withdrawn: raw['withdrawn_at'] != null,
    );
  }

  /// O‘qish — ochiq (akkauntsiz ham), anon kalit bilan.
  @override
  Future<ProfessionalResult<List<ProfessionalReview>>> reviewsFor(
    String recordId,
  ) async {
    try {
      final h = await _s.headers() ?? {'apikey': _s.cfg.anonKey};
      final r = await _s.http.send(
        'GET',
        _s.rest('professional_reviews', {
          'select': '*',
          'record_id': 'eq.$recordId',
          'order': 'created_at.asc',
        }),
        headers: h,
      );
      if (!r.ok) return ProfessionalResult.fail(_SupabaseSession.failure(r));
      return ProfessionalResult.ok([for (final x in r.list) ?_review(x)]);
    } on SocketException {
      return const ProfessionalResult.fail(ProfessionalFailure.offline);
    } on TimeoutException {
      return const ProfessionalResult.fail(ProfessionalFailure.offline);
    }
  }

  @override
  Future<ProfessionalResult<ProfessionalReview>> submit({
    required ReviewSubject subject,
    required ReviewAction action,
    required String note,
    String? sourceReference,
  }) => _s.guard((h) async {
    final errors = ReviewDraftValidation.validate(
      note: note,
      sourceReference: sourceReference,
    );
    if (errors.isNotEmpty) {
      return const ProfessionalResult.fail(ProfessionalFailure.invalidInput);
    }
    // Soha — serverda qayta tekshiriladi; mijoz faqat mos birinchisini oladi.
    final scope = subject.scopes.isEmpty ? null : subject.scopes.first;
    if (scope == null) {
      return const ProfessionalResult.fail(ProfessionalFailure.forbidden);
    }
    final r = await _s.http.send(
      'POST',
      _s.rest('rpc/submit_review'),
      headers: h,
      jsonBody: {
        'p_record': subject.recordId,
        'p_claim': subject.claimId,
        'p_version': subject.contentVersion,
        'p_scope': scope.code,
        'p_action': action.code,
        'p_text': note.trim(),
        'p_source': sourceReference,
      },
    );
    if (!r.ok) return ProfessionalResult.fail(_SupabaseSession.failure(r));
    final list = await reviewsFor(subject.recordId);
    final mine = list.value
        ?.where((x) => x.reviewId == '${r.json}')
        .firstOrNull;
    return mine == null
        ? const ProfessionalResult.fail(ProfessionalFailure.server)
        : ProfessionalResult.ok(mine);
  });

  @override
  Future<ProfessionalResult<List<ReviewQueueItem>>> queue(ReviewQueue q) =>
      _s.guard((h) async {
        final r = await _s.http.send(
          'GET',
          _s.rest('content_records', {'select': '*'}),
          headers: h,
        );
        if (!r.ok) return ProfessionalResult.fail(_SupabaseSession.failure(r));
        final items = <ReviewQueueItem>[];
        for (final raw in r.list) {
          if (raw is! Map) continue;
          final scopes = {
            for (final s in (raw['scopes'] as List? ?? const [])) ?_scope(s),
          };
          items.add(
            ReviewQueueItem(
              subject: ReviewSubject(
                recordId: '${raw['record_id']}',
                kind: ReviewSubjectKind.claim,
                contentVersion: '${raw['published_version']}',
                scopes: scopes,
                risk: raw['risk'] == 'high'
                    ? RiskLevel.high
                    : RiskLevel.standard,
              ),
              title: '${raw['record_id']}',
              discipline: scopes.map((s) => s.code).join(', '),
              claimCount: 0,
              sourceCount: 0,
              state: ReviewState.needsReview,
            ),
          );
        }
        // Hozircha faqat «taqriz kerak» navbati serverdan to‘liq; qolgan
        // navbatlar uchun server ko‘rinishlari migratsiyada qo‘shiladi.
        return ProfessionalResult.ok(
          q == ReviewQueue.needsReview ? items : const <ReviewQueueItem>[],
        );
      });
}
