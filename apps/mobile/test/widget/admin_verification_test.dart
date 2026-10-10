import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/support.dart';
import 'package:forensic_expert/data/remote/supabase_professional.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/ports/professional_ports.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/domain/professional/review_models.dart';
import 'package:forensic_expert/domain/professional/verification_inbox_models.dart';

import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';
import '../helpers/support_fakes.dart';

const _applicant = '50000000-0000-0000-0000-000000000003';
const _self = '50000000-0000-0000-0000-000000000001';
const _doc1 = '51000000-0000-4000-8000-000000000031';
const _doc2 = '51000000-0000-4000-8000-000000000032';

PendingVerification _app({
  String id = _applicant,
  String name = 'Applicant Three',
  bool isSelf = false,
  List<PendingDocument>? docs,
  Specialty specialty = Specialty.forensicToxicology,
}) => PendingVerification(
  applicantId: id,
  displayName: name,
  position: 'Senior expert',
  organization: 'RSTEIAM',
  country: 'UZ',
  specialty: specialty,
  education: 'MD',
  yearsExperience: 7,
  submittedAt: DateTime.utc(2026, 10, 8),
  isSelf: isSelf,
  documents:
      docs ??
      [
        PendingDocument(
          documentId: _doc1,
          kind: CredentialKind.diploma,
          mimeType: 'application/pdf',
          sizeBytes: 2048,
          sha256: 'a' * 64,
          uploadedAt: DateTime.utc(2026, 10, 7),
        ),
        PendingDocument(
          documentId: _doc2,
          kind: CredentialKind.employmentEvidence,
          mimeType: 'image/png',
          sizeBytes: 99,
          sha256: 'b' * 64,
          uploadedAt: DateTime.utc(2026, 10, 7),
        ),
      ],
);

class _FakeIdentityAdmin implements IdentityAdminService {
  _FakeIdentityAdmin(this.items, {this.failWith});

  final List<PendingVerification> items;
  final IdentityDecisionFailure? failWith;
  final calls =
      <
        ({
          String applicantId,
          IdentityDecision decision,
          ReviewerScope scope,
          List<String> checked,
          String reason,
        })
      >[];

  @override
  bool get isConfigured => true;

  @override
  Future<ProfessionalResult<PendingVerificationPage>> pending({
    int limit = 50,
    int offset = 0,
  }) async => ProfessionalResult.ok(
    PendingVerificationPage(items: List.of(items), total: items.length),
  );

  @override
  Future<IdentityDecisionFailure?> decide({
    required String applicantId,
    required IdentityDecision decision,
    required ReviewerScope scope,
    required List<String> checkedDocumentIds,
    required String reason,
    String? applicantMessage,
  }) async {
    calls.add((
      applicantId: applicantId,
      decision: decision,
      scope: scope,
      checked: checkedDocumentIds,
      reason: reason,
    ));
    if (failWith != null) return failWith;
    items.removeWhere((a) => a.applicantId == applicantId);
    return null;
  }
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _pumpAdmin(
  WidgetTester tester,
  _FakeIdentityAdmin svc, {
  Size size = const Size(390, 844),
  bool admin = true,
}) async {
  final c = await pumpApp(
    tester,
    settings: completedSettings(),
    size: size,
    initialLocation: Routes.profile,
    overrides: [
      authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
      accountServiceProvider.overrideWithValue(
        FakeAccountService(access: ServerAccess(isAdmin: admin)),
      ),
      supportServiceProvider.overrideWithValue(
        InMemorySupportService(isAdmin: admin, stats: fixtureAdminStats),
      ),
      identityAdminServiceProvider.overrideWithValue(svc),
    ],
  );
  return c;
}

FilledButton _filled(WidgetTester tester, String key) =>
    tester.widget<FilledButton>(find.byKey(Key(key)));

OutlinedButton _outlined(WidgetTester tester, String key) =>
    tester.widget<OutlinedButton>(find.byKey(Key(key)));

void main() {
  testWidgets('admin: ro‘yxat → tafsilot → tasdiqlash (hujjat + sabab shart)', (
    tester,
  ) async {
    final svc = _FakeIdentityAdmin([
      _app(),
      _app(id: _self, name: 'Admin Self', isSelf: true),
    ]);
    await _pumpAdmin(tester, svc);
    await _tap(tester, find.byKey(const Key('profile.admin')));
    await _tap(tester, find.byKey(const Key('admin.nav.verifications')));

    expect(find.byKey(const Key('adminVerify.list')), findsOneWidget);
    expect(find.text('Applicant Three'), findsOneWidget);
    expect(find.text('Senior expert · RSTEIAM'), findsWidgets);
    expect(find.byKey(const Key('adminVerify.self.$_self')), findsOneWidget);

    await _tap(tester, find.byKey(const Key('adminVerify.card.$_applicant')));
    expect(find.byKey(const Key('adminVerify.detail')), findsOneWidget);
    expect(find.byKey(const Key('adminVerify.doc.$_doc1')), findsOneWidget);
    expect(find.byKey(const Key('adminVerify.doc.$_doc2')), findsOneWidget);
    // Hujjat nomlari tilda; SHA-256 qisqartmasi ko‘rinadi.
    expect(find.textContaining('SHA-256 aaaaaaaaaaaa'), findsOneWidget);

    // Boshida hech narsa belgilanmagan: «Tasdiqlash» ishlamaydi.
    expect(_filled(tester, 'adminVerify.approve').onPressed, isNull);
    // Qisqa sabab (<5) — xato matni, tugma hamon yopiq.
    await tester.enterText(find.byKey(const Key('adminVerify.reason')), 'ok');
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a reason of at least 5 characters.'),
      findsOneWidget,
    );
    await _tap(tester, find.byKey(const Key('adminVerify.doc.$_doc1')));
    expect(_filled(tester, 'adminVerify.approve').onPressed, isNull);
    // Yetarli sabab + hujjat → yoqiladi.
    await tester.enterText(
      find.byKey(const Key('adminVerify.reason')),
      'Diploma and employer checked',
    );
    await tester.pumpAndSettle();
    expect(_filled(tester, 'adminVerify.approve').onPressed, isNotNull);
    // Belgini olib tashlasa — yana yopiladi.
    await _tap(tester, find.byKey(const Key('adminVerify.doc.$_doc1')));
    expect(_filled(tester, 'adminVerify.approve').onPressed, isNull);
    await _tap(tester, find.byKey(const Key('adminVerify.doc.$_doc2')));
    expect(_filled(tester, 'adminVerify.approve').onPressed, isNotNull);

    await _tap(tester, find.byKey(const Key('adminVerify.approve')));
    expect(svc.calls, hasLength(1));
    final call = svc.calls.single;
    expect(call.applicantId, _applicant);
    expect(call.decision, IdentityDecision.verify);
    expect(call.checked, [_doc2]);
    expect(call.scope, ReviewerScope.forensicToxicology);
    expect(call.reason, 'Diploma and employer checked');
    // Ro‘yxatga qaytdi; tasdiqlangan ariza ketdi, o‘z arizasi qoldi.
    expect(find.byKey(const Key('adminVerify.list')), findsOneWidget);
    expect(find.text('Applicant Three'), findsNothing);
    expect(find.text('Admin Self'), findsOneWidget);
    expect(find.text('Application approved.'), findsOneWidget);
  });

  testWidgets('«Qo‘shimcha ma’lumot» va «Rad etish» hujjatsiz ishlaydi', (
    tester,
  ) async {
    final svc = _FakeIdentityAdmin([_app(), _app(id: 'x2', name: 'Second')]);
    final c = await _pumpAdmin(tester, svc, size: const Size(320, 640));
    c.read(routerProvider).go(Routes.adminVerification(_applicant));
    await tester.pumpAndSettle();
    expect(_outlined(tester, 'adminVerify.requestInfo').onPressed, isNull);
    expect(_outlined(tester, 'adminVerify.reject').onPressed, isNull);
    await tester.enterText(
      find.byKey(const Key('adminVerify.reason')),
      'Scan is unreadable',
    );
    await tester.pumpAndSettle();
    // Tasdiqlash hujjatsiz yopiq, qolgan ikkitasi ochiq.
    expect(_filled(tester, 'adminVerify.approve').onPressed, isNull);
    expect(_outlined(tester, 'adminVerify.requestInfo').onPressed, isNotNull);
    await _tap(tester, find.byKey(const Key('adminVerify.requestInfo')));
    expect(svc.calls.single.decision, IdentityDecision.requestMoreInformation);
    expect(svc.calls.single.checked, isEmpty);
    expect(find.text('More information requested.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('o‘z arizasi: qaror shakli yo‘q, tushunarli izoh', (
    tester,
  ) async {
    final svc = _FakeIdentityAdmin([
      _app(id: _self, name: 'Admin Self', isSelf: true),
    ]);
    final c = await _pumpAdmin(tester, svc);
    c.read(routerProvider).go(Routes.adminVerification(_self));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('adminVerify.selfNote')), findsOneWidget);
    expect(
      find.textContaining('You cannot approve your own application'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('adminVerify.approve')), findsNothing);
    expect(find.byKey(const Key('adminVerify.reject')), findsNothing);
    expect(svc.calls, isEmpty);
  });

  testWidgets('server rad etsa — tushunarli xato, ariza joyida qoladi', (
    tester,
  ) async {
    final svc = _FakeIdentityAdmin([
      _app(),
    ], failWith: IdentityDecisionFailure.forbidden);
    final c = await _pumpAdmin(tester, svc);
    c.read(routerProvider).go(Routes.adminVerification(_applicant));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('adminVerify.doc.$_doc1')));
    await tester.enterText(
      find.byKey(const Key('adminVerify.reason')),
      'Checked the diploma',
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('adminVerify.approve')));
    expect(
      find.text('You have no authority to verify in this area.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('adminVerify.detail')), findsOneWidget);
  });

  testWidgets('hujjatsiz ariza: ogohlantirish, tasdiqlab bo‘lmaydi', (
    tester,
  ) async {
    final svc = _FakeIdentityAdmin([_app(docs: const [])]);
    final c = await _pumpAdmin(tester, svc);
    c.read(routerProvider).go(Routes.adminVerification(_applicant));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('adminVerify.noDocs')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('adminVerify.reason')),
      'No evidence at all',
    );
    await tester.pumpAndSettle();
    expect(_filled(tester, 'adminVerify.approve').onPressed, isNull);
  });

  testWidgets('bo‘sh ro‘yxat va oddiy foydalanuvchi', (tester) async {
    final c = await _pumpAdmin(tester, _FakeIdentityAdmin([]));
    c.read(routerProvider).go(Routes.adminVerifications);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('adminVerify.empty')), findsOneWidget);
    expect(find.text('No applications are waiting.'), findsOneWidget);
  });

  testWidgets('oddiy foydalanuvchi: bo‘lim va marshrutlar yopiq', (
    tester,
  ) async {
    final svc = _FakeIdentityAdmin([_app()]);
    final c = await _pumpAdmin(tester, svc, admin: false);
    expect(find.byKey(const Key('profile.admin')), findsNothing);
    for (final r in [
      Routes.admin,
      Routes.adminVerifications,
      Routes.adminVerification(_applicant),
    ]) {
      c.read(routerProvider).go(r);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('admin.forbidden')),
        findsOneWidget,
        reason: r,
      );
      expect(find.byKey(const Key('adminVerify.list')), findsNothing);
      expect(find.byKey(const Key('adminVerify.detail')), findsNothing);
      expect(find.text('Applicant Three'), findsNothing);
      expect(find.byKey(const Key('admin.nav.verifications')), findsNothing);
    }
    expect(svc.calls, isEmpty);
  });

  group('xato xaritasi', () {
    test('server xabari → sabab', () {
      expect(
        IdentityDecisionFailure.fromServerMessage('self approval'),
        IdentityDecisionFailure.selfApproval,
      );
      expect(
        IdentityDecisionFailure.fromServerMessage('forbidden'),
        IdentityDecisionFailure.forbidden,
      );
      expect(
        IdentityDecisionFailure.fromServerMessage('no credential checked'),
        IdentityDecisionFailure.noCredentialChecked,
      );
      expect(
        IdentityDecisionFailure.fromServerMessage('invalid transition'),
        IdentityDecisionFailure.invalidTransition,
      );
      expect(
        IdentityDecisionFailure.fromServerMessage('boom'),
        IdentityDecisionFailure.server,
      );
    });
  });

  group('SupabaseIdentityAdminService', () {
    Future<(SupabaseIdentityAdminService, List<(String, Object?)>)> make(
      RestResponse Function(String path) reply,
    ) async {
      final calls = <(String, Object?)>[];
      final svc = SupabaseIdentityAdminService(
        config: SupabaseConfig(
          url: Uri.parse('https://fe-test.supabase.co/'),
          anonKey: 'anon',
        ),
        auth: await signedInMockAuth(),
        transport: _Transport((path, body) {
          calls.add((path, body));
          return reply(path);
        }),
      );
      return (svc, calls);
    }

    test('pending: RPC javobi modelga aylanadi', () async {
      final (svc, calls) = await make(
        (p) => RestResponse(200, {
          'total': 1,
          'items': [
            {
              'applicant_id': _applicant,
              'display_name': 'Applicant Three',
              'position': 'Expert',
              'organization': 'RSTEIAM',
              'country_code': 'UZ',
              'primary_specialty': 'forensicToxicology',
              'additional_specialties': ['forensicChemistry'],
              'years_experience': 7,
              'education': 'MD',
              'submitted_at': '2026-10-08T00:00:00Z',
              'is_self': false,
              'credential_documents': [
                {
                  'document_id': _doc1,
                  'kind': 'diploma',
                  'mime_type': 'application/pdf',
                  'size_bytes': 1234,
                  'sha256': 'a' * 64,
                  'uploaded_at': '2026-10-07T00:00:00Z',
                },
              ],
            },
          ],
        }),
      );
      final r = await svc.pending();
      expect(calls.single.$1, endsWith('/rpc/admin_pending_verifications'));
      final a = r.value!.items.single;
      expect(a.displayName, 'Applicant Three');
      expect(a.specialty, Specialty.forensicToxicology);
      expect(a.additionalSpecialties, [Specialty.forensicChemistry]);
      expect(a.suggestedScope, ReviewerScope.forensicToxicology);
      expect(a.documents.single.kind, CredentialKind.diploma);
      expect(r.value!.total, 1);
    });

    test('pending: 403 → forbidden', () async {
      final (svc, _) = await make((p) => const RestResponse(403, {}));
      expect((await svc.pending()).failure, ProfessionalFailure.forbidden);
    });

    test('decide: oldindan tekshiruv — tarmoqqa chiqmaydi', () async {
      final (svc, calls) = await make((p) => const RestResponse(200, 'x'));
      expect(
        await svc.decide(
          applicantId: _applicant,
          decision: IdentityDecision.verify,
          scope: ReviewerScope.forensicToxicology,
          checkedDocumentIds: const [],
          reason: 'long enough reason',
        ),
        IdentityDecisionFailure.noCredentialChecked,
      );
      expect(
        await svc.decide(
          applicantId: _applicant,
          decision: IdentityDecision.reject,
          scope: ReviewerScope.forensicToxicology,
          checkedDocumentIds: const [],
          reason: 'no',
        ),
        IdentityDecisionFailure.invalidInput,
      );
      expect(calls, isEmpty);
    });

    test('decide: to‘g‘ri RPC tanasi va server xabarlari', () async {
      var message = '';
      final (svc, calls) = await make(
        (p) => message.isEmpty
            ? const RestResponse(200, 'VERIFIED_PROFESSIONAL')
            : RestResponse(400, {'message': message}),
      );
      Future<IdentityDecisionFailure?> run() => svc.decide(
        applicantId: _applicant,
        decision: IdentityDecision.verify,
        scope: ReviewerScope.forensicToxicology,
        checkedDocumentIds: const [_doc1],
        reason: '  diploma checked  ',
        applicantMessage: 'Welcome',
      );
      expect(await run(), isNull);
      final (path, body) = calls.single;
      expect(path, endsWith('/rpc/decide_identity'));
      expect(body, {
        'applicant': _applicant,
        'p_decision': 'VERIFY',
        'p_scope': 'FORENSIC_TOXICOLOGY',
        'p_checked': [_doc1],
        'p_reason': 'diploma checked',
        'p_message': 'Welcome',
      });
      message = 'self approval';
      expect(await run(), IdentityDecisionFailure.selfApproval);
      message = 'forbidden';
      expect(await run(), IdentityDecisionFailure.forbidden);
      message = 'no credential checked';
      expect(await run(), IdentityDecisionFailure.noCredentialChecked);
    });
  });
}

class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(String path, Object? body) handler;

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async => handler(uri.path, jsonBody);
}
