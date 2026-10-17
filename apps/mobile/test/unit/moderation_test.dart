import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/local/report_device_key.dart';
import 'package:forensic_expert/data/remote/supabase_moderation.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/data/support/in_memory_moderation_service.dart';
import 'package:forensic_expert/domain/moderation/moderation_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/referral_fakes.dart';

class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(String path, Object? body) handler;
  final calls = <({String path, Map<String, String> headers, Object? body})>[];

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls.add((path: uri.path, headers: headers, body: jsonBody));
    return handler(uri.path, jsonBody);
  }
}

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);

void main() {
  group('ReportDraft', () {
    test('uzunlik tekshiruvi: 5..2000 belgi, bo‘sh joylar hisoblanmaydi', () {
      expect(
        const ReportDraft(kind: ReportKind.bug, body: '    ab   ').error,
        ReportDraftError.bodyTooShort,
      );
      expect(
        const ReportDraft(kind: ReportKind.bug, body: 'abcde').error,
        isNull,
      );
      expect(
        ReportDraft(kind: ReportKind.bug, body: 'x' * 2001).error,
        ReportDraftError.bodyTooLong,
      );
      expect(
        ReportDraft(
          kind: ReportKind.other,
          body: 'valid text',
          contact: 'a' * 201,
        ).error,
        ReportDraftError.contactTooLong,
      );
    });

    test('server natijalari', () {
      expect(ReportResult.fromWire('CREATED'), ReportResult.created);
      expect(ReportResult.fromWire('RATE_LIMITED'), ReportResult.rateLimited);
      expect(ReportResult.fromWire('SUSPENDED'), ReportResult.suspended);
      expect(ReportResult.fromWire('???'), ReportResult.failed);
      expect(
        RoleChangeResult.fromWire('LAST_ADMIN'),
        RoleChangeResult.lastAdmin,
      );
      expect(RoleChangeResult.fromWire(null), RoleChangeResult.failed);
      expect(
        SuspensionResult.fromWire('CANNOT_SUSPEND_ADMIN'),
        SuspensionResult.cannotSuspendAdmin,
      );
      expect(BlockResult.fromWire('SELF'), BlockResult.self);
    });

    test('statistika: serverga ko‘rinmaydiganlar "mavjud emas" bo‘ladi', () {
      final s = AdminStatsExt.fromJson(const {
        'roles': {'identity_admin': 2, 'publication_moderator': 1},
        'reports': {'open': 3, 'resolved': 4},
        'qa': {'questions': 9, 'answers': 12, 'in_moderation': 1},
        'suspended': 2,
        'blocks': 5,
        'casebooks': {'stored_server_side': false},
        'downloads': {'available': false},
        'sales': {'available': false, 'payment_system': false},
        'online_now': {'available': false},
      });
      expect(s.admins, 2);
      expect(s.reportsOpen, 3);
      expect(s.qaAnswers, 12);
      expect(s.onlineNowAvailable, isFalse);
      expect(s.salesAvailable, isFalse);
      expect(s.downloadsAvailable, isFalse);
      expect(s.casebooksOnServer, isFalse);
      // Bo‘sh javob — hammasi 0/false, o‘ylab topilgan son yo‘q.
      expect(AdminStatsExt.fromJson(const {}).reportsOpen, 0);
    });
  });

  group('SupabaseModerationService', () {
    test(
      'kirmagan foydalanuvchi shikoyat yuboradi (anon kalit bilan)',
      () async {
        final t = _Transport(
          (p, b) => const RestResponse(200, {'result': 'CREATED', 'id': 'r1'}),
        );
        final s = SupabaseModerationService(
          config: _cfg,
          auth: MockAuthRepository(),
          deviceKey: () async => 'device-key-12345',
          transport: t,
        );
        final r = await s.submitReport(
          const ReportDraft(
            kind: ReportKind.advertising,
            body: 'Spam reklama yuborilmoqda',
            contact: ' me@x.uz ',
            target: ReportTarget.qaQuestion,
            targetId: 'q-1',
          ),
        );
        expect(r, ReportResult.created);
        final call = t.calls.single;
        expect(call.path, '/rest/v1/rpc/submit_report');
        expect(call.headers['Authorization'], 'Bearer anon-public-test-key');
        expect(call.body, {
          'p_kind': 'ADVERTISING',
          'p_body': 'Spam reklama yuborilmoqda',
          'p_target_type': 'qa_question',
          'p_target_id': 'q-1',
          'p_contact': 'me@x.uz',
          'p_device_key': 'device-key-12345',
        });
      },
    );

    test(
      'noto‘g‘ri matn tarmoqqa chiqmaydi; limit va to‘xtatish xaritasi',
      () async {
        var answer = 'RATE_LIMITED';
        final t = _Transport((p, b) => RestResponse(200, {'result': answer}));
        final s = SupabaseModerationService(
          config: _cfg,
          auth: MockAuthRepository(),
          deviceKey: () async => 'device-key-12345',
          transport: t,
        );
        expect(
          await s.submitReport(
            const ReportDraft(kind: ReportKind.bug, body: 'ab'),
          ),
          ReportResult.invalid,
        );
        expect(t.calls, isEmpty);
        const d = ReportDraft(kind: ReportKind.bug, body: 'real problem');
        expect(await s.submitReport(d), ReportResult.rateLimited);
        answer = 'SUSPENDED';
        expect(await s.submitReport(d), ReportResult.suspended);
      },
    );

    test('tarmoq xatosi — failed', () async {
      final s = SupabaseModerationService(
        config: _cfg,
        auth: MockAuthRepository(),
        deviceKey: () async => 'device-key-12345',
        transport: _Transport((p, b) => const RestResponse(500, null)),
      );
      expect(
        await s.submitReport(
          const ReportDraft(kind: ReportKind.bug, body: 'real problem'),
        ),
        ReportResult.failed,
      );
    });

    test(
      'admin RPC’lar kirmagan holda tarmoqqa chiqmaydi (401 mantiqi)',
      () async {
        final t = _Transport((p, b) => const RestResponse(200, []));
        final s = SupabaseModerationService(
          config: _cfg,
          auth: MockAuthRepository(),
          deviceKey: () async => 'device-key-12345',
          transport: t,
        );
        expect(await s.adminReports(const AdminReportFilter()), isNull);
        expect(await s.adminStatsExt(), isNull);
        expect(await s.myReports(), isNull);
        expect(await s.myBlocks(), isNull);
        expect(
          await s.adminSetRole(
            'u',
            ManagedRole.publicationModerator,
            grant: true,
            reason: 'sabab bor',
          ),
          RoleChangeResult.failed,
        );
        expect(
          await s.adminSetSuspension('u', suspend: true, reason: 'sabab bor'),
          SuspensionResult.failed,
        );
        expect(t.calls, isEmpty);
      },
    );

    test(
      'server 403 (admin emas) — natija null/failed, ruxsat berilmaydi',
      () async {
        final auth = await signedInMockAuth();
        final s = SupabaseModerationService(
          config: _cfg,
          auth: auth,
          deviceKey: () async => 'device-key-12345',
          transport: _Transport((p, b) => const RestResponse(403, null)),
        );
        expect(await s.adminReports(const AdminReportFilter()), isNull);
        expect(await s.adminStatsExt(), isNull);
        expect(await s.adminResolveReport('r1'), isFalse);
        expect(
          await s.adminSetSuspension('u', suspend: true, reason: 'sabab bor'),
          SuspensionResult.failed,
        );
      },
    );

    test(
      'qidiruv matni xom yuboriladi (%, _, \\ ni server ekranlaydi)',
      () async {
        final auth = await signedInMockAuth();
        final t = _Transport(
          (p, b) => const RestResponse(200, {'total': 0, 'items': <Object?>[]}),
        );
        final s = SupabaseModerationService(
          config: _cfg,
          auth: auth,
          deviceKey: () async => 'device-key-12345',
          transport: t,
        );
        await s.adminReports(
          const AdminReportFilter(query: r'  100%_a\b  ', kind: ReportKind.bug),
        );
        final body = t.calls.single.body! as Map<String, Object?>;
        expect(body['p_query'], r'100%_a\b');
        expect(body['p_status'], 'OPEN');
        expect(body['p_kind'], 'BUG');
      },
    );

    test('rol va to‘xtatish: parametrlar va natija xaritasi', () async {
      final auth = await signedInMockAuth();
      var answer = 'GRANTED';
      final t = _Transport((p, b) => RestResponse(200, answer));
      final s = SupabaseModerationService(
        config: _cfg,
        auth: auth,
        deviceKey: () async => 'device-key-12345',
        transport: t,
      );
      expect(
        await s.adminSetRole(
          'user-1',
          ManagedRole.publicationModerator,
          grant: true,
          reason: '  Tahrir uchun  ',
        ),
        RoleChangeResult.granted,
      );
      expect(t.calls.last.path, '/rest/v1/rpc/admin_set_role');
      expect(t.calls.last.body, {
        'p_user': 'user-1',
        'p_role': 'publication_moderator',
        'p_grant': true,
        'p_reason': 'Tahrir uchun',
      });
      answer = 'CANNOT_SUSPEND_ADMIN';
      expect(
        await s.adminSetSuspension(
          'admin-1',
          suspend: true,
          reason: 'sabab bor',
        ),
        SuspensionResult.cannotSuspendAdmin,
      );
      expect(t.calls.last.path, '/rest/v1/rpc/admin_set_suspension');
    });

    test('blok va qoidalar qabuli', () async {
      final auth = await signedInMockAuth();
      Object? json = 'BLOCKED';
      final t = _Transport((p, b) => RestResponse(200, json));
      final s = SupabaseModerationService(
        config: _cfg,
        auth: auth,
        deviceKey: () async => 'device-key-12345',
        transport: t,
      );
      expect(
        await s.blockAuthor(ReportTarget.qaAnswer, 'a-1'),
        BlockResult.blocked,
      );
      expect(t.calls.last.body, {
        'p_target_type': 'answer',
        'p_target_id': 'a-1',
      });
      json = [
        {'doc': 'ugc_rules', 'version': CommunityTerms.version},
      ];
      expect(await s.communityTermsAccepted(), isTrue);
      json = [
        {'doc': 'ugc_rules', 'version': 'eski'},
      ];
      expect(
        await s.communityTermsAccepted(),
        isFalse,
        reason: 'versiya o‘zgarsa qayta qabul kerak',
      );
      json = 'ACCEPTED';
      expect(await s.acceptCommunityTerms(), isTrue);
    });
  });

  group('InMemoryModerationService (server qoidalari mantiqi)', () {
    ReportDraft draft(int n) =>
        ReportDraft(kind: ReportKind.complaint, body: 'Shikoyat matni $n');

    test(
      'soatiga 5 ta: oltinchisi rad etiladi, soat o‘tgach yana mumkin',
      () async {
        var now = DateTime.utc(2026, 10, 17, 10);
        final s = InMemoryModerationService(now: () => now);
        for (var i = 0; i < 5; i++) {
          expect(await s.submitReport(draft(i)), ReportResult.created);
        }
        expect(await s.submitReport(draft(6)), ReportResult.rateLimited);
        now = now.add(const Duration(hours: 1, minutes: 1));
        expect(await s.submitReport(draft(7)), ReportResult.created);
      },
    );

    test(
      'foydalanuvchi faqat o‘z shikoyatini ko‘radi; kirmagan — null',
      () async {
        final anon = InMemoryModerationService(signedIn: false);
        await anon.submitReport(draft(1));
        expect(await anon.myReports(), isNull);
        final user = InMemoryModerationService();
        await user.submitReport(draft(1));
        expect((await user.myReports())!.single.resolved, isFalse);
      },
    );

    test('admin bo‘lmasa admin amallari ishlamaydi', () async {
      final s = InMemoryModerationService();
      await s.submitReport(draft(1));
      expect(await s.adminReports(const AdminReportFilter()), isNull);
      expect(await s.adminStatsExt(), isNull);
      expect(await s.adminResolveReport('r0'), isFalse);
      expect(
        await s.adminSetSuspension('x', suspend: true, reason: 'sabab bor'),
        SuspensionResult.failed,
      );
    });

    test('admin: hal qilish, izoh, qidiruv matni harfma-harf', () async {
      final s = InMemoryModerationService(isAdmin: true);
      await s.submitReport(
        const ReportDraft(kind: ReportKind.bug, body: 'chegirma 100% emas'),
      );
      await s.submitReport(
        const ReportDraft(kind: ReportKind.bug, body: 'oddiy xato matni'),
      );
      Future<int> found(String q) async => (await s.adminReports(
        AdminReportFilter(query: q, status: AdminReportStatus.all),
      ))!.total;
      expect(await found('100%'), 1);
      expect(await found('%'), 1, reason: '% maxsus belgi emas');
      expect(await found('_'), 0);
      expect(await found(r'\'), 0);
      expect(await s.adminResolveReport('r0', note: 'Tuzatildi'), isTrue);
      final open = await s.adminReports(const AdminReportFilter());
      expect(open!.total, 1);
      final done = await s.adminReports(
        const AdminReportFilter(status: AdminReportStatus.resolved),
      );
      expect(done!.items.single.adminNote, 'Tuzatildi');
      expect(await s.adminReportNote('r0', ''), isFalse);
    });

    test('admin to‘xtatilmaydi, o‘zini o‘zgartira olmaydi', () async {
      final s = InMemoryModerationService(isAdmin: true, selfId: 'me')
        ..admins.add('boss');
      expect(
        await s.adminSetSuspension('boss', suspend: true, reason: 'sabab bor'),
        SuspensionResult.cannotSuspendAdmin,
      );
      expect(
        await s.adminSetSuspension('me', suspend: true, reason: 'sabab bor'),
        SuspensionResult.cannotSuspendSelf,
      );
      expect(
        await s.adminSetSuspension('u1', suspend: true, reason: 'sabab bor'),
        SuspensionResult.suspended,
      );
      expect(
        await s.adminSetSuspension('u1', suspend: false, reason: 'xato edi'),
        SuspensionResult.restored,
      );
      expect(
        await s.adminSetRole(
          'me',
          ManagedRole.identityAdmin,
          grant: false,
          reason: 'sabab bor',
        ),
        RoleChangeResult.selfAdminChange,
      );
      expect(
        await s.adminSetRole(
          'u2',
          ManagedRole.identityAdmin,
          grant: true,
          reason: 'sabab bor',
        ),
        RoleChangeResult.forbiddenRole,
        reason: 'admin berish ilovadan emas — faqat server',
      );
    });
  });

  group('reportDeviceKey', () {
    test('bir marta yaratiladi va barqaror qoladi', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final a = await reportDeviceKey(prefs, random: Random(1));
      final b = await reportDeviceKey(prefs, random: Random(2));
      expect(a, b);
      expect(RegExp(r'^[A-Za-z0-9_-]{8,64}$').hasMatch(a), isTrue);
      expect(prefs.getString(reportDeviceKeyPref), a);
    });
  });
}
