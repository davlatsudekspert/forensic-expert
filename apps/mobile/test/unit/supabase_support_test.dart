import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/data/remote/supabase_support.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/domain/ports/support_ports.dart';
import 'package:forensic_expert/domain/support/support_models.dart';
import 'package:forensic_expert/features/support/support_image_picker.dart';

import '../helpers/referral_fakes.dart';

/// Soxta transport: so‘rovlarni yozib oladi; tarmoq yo‘q.
class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(String path, Object? body) handler;
  final calls =
      <
        ({
          String path,
          Map<String, String> headers,
          Object? body,
          List<int>? bytes,
          String? contentType,
        })
      >[];

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls.add((
      path: uri.path,
      headers: headers,
      body: jsonBody,
      bytes: bytes,
      contentType: contentType,
    ));
    return handler(uri.path, jsonBody);
  }
}

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);

final _jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4]);

void main() {
  group('SupabaseSupportService', () {
    test('kirmagan — tarmoqqa chiqmaydi', () async {
      final t = _Transport((p, b) => const RestResponse(200, []));
      final s = SupabaseSupportService(
        config: _cfg,
        auth: MockAuthRepository(),
        transport: t,
      );
      expect(await s.myThreads(), isNull);
      expect(await s.unreadCount(), 0);
      expect(
        (await s.createThread(
          const SupportDraft(
            category: SupportCategory.bug,
            subject: 's',
            body: 'b',
            consent: true,
          ),
        )).outcome,
        SupportCreateOutcome.failed,
      );
      expect(t.calls, isEmpty);
    });

    test('murojaat: rasm o‘z papkasiga, so‘ng RPC (rozilik, entity)', () async {
      final auth = await signedInMockAuth();
      final uid = auth.current.account!.userId;
      final t = _Transport(
        (p, b) => p.startsWith('/storage/')
            ? const RestResponse(200, {'Key': 'ok'})
            : const RestResponse(200, {'result': 'CREATED', 'id': 'th-1'}),
      );
      final s = SupabaseSupportService(config: _cfg, auth: auth, transport: t);
      final r = await s.createThread(
        SupportDraft(
          category: SupportCategory.scientificError,
          subject: '  Morphine  ',
          body: ' Half-life looks wrong ',
          consent: true,
          relatedEntity: 'substance:morphine',
          attachment: SupportAttachment(bytes: _jpeg, mimeType: 'image/jpeg'),
        ),
      );
      expect(r.outcome, SupportCreateOutcome.created);
      expect(r.id, 'th-1');
      final up = t.calls.first;
      expect(
        up.path,
        matches(
          RegExp(
            '^/storage/v1/object/support-attachments/$uid/'
            r'[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.jpg$',
          ),
        ),
      );
      expect(up.contentType, 'image/jpeg');
      expect(up.bytes, _jpeg);
      expect(up.headers['Authorization'], startsWith('Bearer '));
      final rpc = t.calls.last;
      expect(rpc.path, '/rest/v1/rpc/create_support_thread');
      final body = rpc.body! as Map;
      expect(body['p_category'], 'SCIENTIFIC_ERROR');
      expect(body['p_subject'], 'Morphine');
      expect(body['p_body'], 'Half-life looks wrong');
      expect(body['p_consent'], isTrue);
      expect(body['p_related_entity'], 'substance:morphine');
      expect(
        body['p_attachment_path'],
        up.path.replaceFirst('/storage/v1/object/support-attachments/', ''),
      );
    });

    test('yuklash xatosi — RPC chaqirilmaydi; server kodlari', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((p, b) => const RestResponse(400, {}));
      final s = SupabaseSupportService(config: _cfg, auth: auth, transport: t);
      final r = await s.createThread(
        SupportDraft(
          category: SupportCategory.bug,
          subject: 's',
          body: 'b',
          consent: true,
          attachment: SupportAttachment(bytes: _jpeg, mimeType: 'image/jpeg'),
        ),
      );
      expect(r.outcome, SupportCreateOutcome.failed);
      expect(t.calls.single.path, startsWith('/storage/'));
      // GIF / boshqa tur — tarmoqqa chiqmaydi.
      final t2 = _Transport((p, b) => const RestResponse(200, {}));
      final s2 = SupabaseSupportService(
        config: _cfg,
        auth: auth,
        transport: t2,
      );
      await s2.sendMessage(
        'x',
        'hi',
        attachment: SupportAttachment(bytes: _jpeg, mimeType: 'image/gif'),
      );
      expect(t2.calls, isEmpty);
      expect(
        SupportCreateResult.fromJson({'result': 'CONSENT_REQUIRED'}).outcome,
        SupportCreateOutcome.consentRequired,
      );
      expect(
        SupportCreateResult.fromJson({'result': 'RATE_LIMITED'}).outcome,
        SupportCreateOutcome.rateLimited,
      );
      expect(
        SupportCreateResult.fromJson({'result': 'CREATED'}).outcome,
        SupportCreateOutcome.failed,
        reason: 'id yo‘q — muvaffaqiyat deb hisoblanmaydi',
      );
      expect(SupportSendResult.fromWire('CLOSED'), SupportSendResult.closed);
      expect(SupportSendResult.fromWire('??'), SupportSendResult.failed);
    });

    test('ro‘yxat, murojaat, o‘qilmagan, imzolangan havola', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((p, b) {
        return switch (p) {
          '/rest/v1/rpc/my_support_threads' => const RestResponse(200, [
            {
              'id': 't1',
              'category': 'BUG',
              'subject': 'Crash',
              'status': 'ANSWERED',
              'unread': 2,
              'message_count': '3',
              'last_message': 'Fixed',
            },
          ]),
          '/rest/v1/rpc/support_thread' => const RestResponse(200, {
            'id': 't1',
            'category': 'HACK',
            'subject': 'Crash',
            'status': 'WEIRD',
            'messages': [
              {'id': 1, 'sender_role': 'USER', 'body': 'a', 'mine': true},
              {
                'id': 2,
                'sender_role': 'ADMIN',
                'body': 'b',
                'attachment_path': null,
              },
            ],
          }),
          '/rest/v1/rpc/support_unread_count' => const RestResponse(200, 4),
          '/storage/v1/object/sign/support-attachments/u/x.jpg' =>
            const RestResponse(200, {
              'signedURL': '/object/sign/support-attachments/u/x.jpg?token=t',
            }),
          _ => const RestResponse(200, true),
        };
      });
      final s = SupabaseSupportService(config: _cfg, auth: auth, transport: t);
      final list = (await s.myThreads())!;
      expect(list.single.status, SupportStatus.answered);
      expect(list.single.unread, 2);
      expect(list.single.messageCount, 3);
      final th = (await s.thread('t1'))!;
      expect(
        th.category,
        SupportCategory.general,
        reason: 'noma’lum → general',
      );
      expect(th.status, SupportStatus.newRequest);
      expect(th.messages.last.fromAdmin, isTrue);
      expect(th.messages.first.mine, isTrue);
      expect(await s.unreadCount(), 4);
      await s.markRead('t1');
      expect(t.calls.last.body, {'p_thread_id': 't1'});
      expect(
        (await s.attachmentUrl('u/x.jpg')).toString(),
        'https://fe-test.supabase.co/storage/v1/object/sign/support-attachments/u/x.jpg?token=t',
      );
    });

    test('admin RPC’lar: parametrlar va javoblar', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((p, b) {
        return switch (p) {
          '/rest/v1/rpc/admin_support_inbox' => const RestResponse(200, {
            'total': 7,
            'items': [
              {
                'id': 't9',
                'category': 'SUGGESTION',
                'subject': 'Dark mode',
                'status': 'NEW',
                'author_email': 'a@b.uz',
                'unread': 1,
                'has_attachment': true,
              },
            ],
          }),
          '/rest/v1/rpc/admin_reply_support' => const RestResponse(200, 'SENT'),
          '/rest/v1/rpc/admin_set_support_status' => const RestResponse(
            200,
            'CLOSED',
          ),
          '/rest/v1/rpc/admin_stats' => const RestResponse(200, {
            'users': {'total': 10, 'new_today': 1, 'new_7d': 3, 'new_30d': 9},
            'modes': {'students': null, 'experts': null},
            'tiers': {'pro': 2, 'free': 8},
            'active': {'d7': 4, 'd30': 6},
            'support': {
              'awaiting': 3,
              'new': 2,
              'in_review': 1,
              'by_category': {'BUG': 2, 'SCIENTIFIC_ERROR': 1},
            },
            'publications': {'awaiting_moderation': 5},
            'ai': {'total': 50, 'd7': 12},
            'daily': [
              {'day': '2026-10-08', 'signups': 1, 'ai': 3},
            ],
          }),
          '/rest/v1/rpc/admin_users' => const RestResponse(200, {
            'total': 1,
            'items': [
              {
                'id': 'u1',
                'email': 'e@x.uz',
                'roles': ['identity_admin'],
                'status': 'UNCONFIRMED',
                'platforms': 'android,ios',
              },
            ],
          }),
          '/rest/v1/rpc/admin_audit_log' => const RestResponse(200, [
            {
              'id': 3,
              'action': 'SUPPORT_REPLY',
              'detail': {'length': 12},
            },
          ]),
          _ => const RestResponse(403, {'message': 'forbidden'}),
        };
      });
      final s = SupabaseSupportService(config: _cfg, auth: auth, transport: t);
      final inbox = (await s.adminInbox(
        const SupportInboxFilter(
          status: 'AWAITING',
          category: SupportCategory.bug,
          query: '  crash ',
        ),
        limit: 25,
        offset: 25,
      ))!;
      expect(t.calls.last.body, {
        'p_status': 'AWAITING',
        'p_category': 'BUG',
        'p_query': 'crash',
        'p_limit': 25,
        'p_offset': 25,
      });
      expect(inbox.total, 7);
      expect(inbox.items.single.authorEmail, 'a@b.uz');
      expect(inbox.items.single.hasAttachment, isTrue);
      expect(await s.adminReply('t9', ' Thanks '), SupportSendResult.sent);
      expect(t.calls.last.body, {'p_thread_id': 't9', 'p_body': 'Thanks'});
      expect(
        await s.adminSetStatus('t9', SupportStatus.closed),
        SupportStatus.closed,
      );
      expect(
        await s.adminSetStatus('t9', SupportStatus.answered),
        isNull,
        reason: 'server boshqa holat qaytardi',
      );
      final st = (await s.adminStats())!;
      expect(st.usersTotal, 10);
      expect(st.students, isNull);
      expect(st.experts, isNull);
      expect(st.supportByStatus[SupportStatus.inReview], 1);
      expect(st.supportByCategory[SupportCategory.bug], 2);
      expect(st.publicationsAwaiting, 5);
      expect(st.daily.single.ai, 3);
      final users = (await s.adminUsers(
        const AdminUserFilter(search: ' e@x ', role: 'admin', offset: 25),
      ))!;
      expect(t.calls.last.body, {
        'p_search': 'e@x',
        'p_role': 'admin',
        'p_tier': null,
        'p_limit': AdminUserFilter.pageSize,
        'p_offset': 25,
      });
      expect(users.items.single.isAdmin, isTrue);
      expect(users.items.single.status, AdminAccountStatus.unconfirmed);
      expect(users.items.single.platforms, ['android', 'ios']);
      expect((await s.adminAuditLog())!.single.action, 'SUPPORT_REPLY');
    });

    test('server rad etsa (403) — null, istisno yo‘q', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((p, b) => const RestResponse(403, {}));
      final s = SupabaseSupportService(config: _cfg, auth: auth, transport: t);
      expect(await s.adminStats(), isNull);
      expect(await s.adminInbox(const SupportInboxFilter()), isNull);
      expect(await s.adminUsers(const AdminUserFilter()), isNull);
      expect(await s.adminAuditLog(), isNull);
      expect(await s.adminReply('x', 'y'), SupportSendResult.failed);
      expect(await s.thread('x'), isNull);
    });
  });

  group('Unconfigured / InMemory', () {
    test('Unconfigured: hech narsa qilmaydi', () async {
      const s = UnconfiguredSupportService();
      expect(s.isConfigured, isFalse);
      expect(await s.myThreads(), isNull);
      expect(await s.adminStats(), isNull);
    });

    test('InMemory: muallif, admin va o‘qilmaganlar', () async {
      final s = InMemorySupportService();
      final r = await s.createThread(
        const SupportDraft(
          category: SupportCategory.bug,
          subject: 'a',
          body: 'b',
          consent: false,
        ),
      );
      expect(r.outcome, SupportCreateOutcome.consentRequired);
      final ok = await s.createThread(
        const SupportDraft(
          category: SupportCategory.bug,
          subject: 'a',
          body: 'b',
          consent: true,
        ),
      );
      final other = s.seedThread(
        category: SupportCategory.general,
        subject: 'other',
        body: 'x',
      );
      expect((await s.myThreads())!.length, 1);
      expect(await s.thread(other), isNull, reason: 'boshqa muallif');
      expect(await s.adminInbox(const SupportInboxFilter()), isNull);
      s.isAdmin = true;
      expect((await s.adminInbox(const SupportInboxFilter()))!.total, 2);
      expect(await s.adminReply(ok.id!, 'hello'), SupportSendResult.sent);
      expect(await s.unreadCount(), 1);
      await s.markRead(ok.id!);
      expect(await s.unreadCount(), 0);
      expect(s.audit.first.action, 'SUPPORT_REPLY');
    });
  });

  test('rasm turi baytlardan aniqlanadi', () {
    expect(sniffImageMime(_jpeg), 'image/jpeg');
    expect(
      sniffImageMime(
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0]),
      ),
      'image/png',
    );
    expect(sniffImageMime(Uint8List.fromList('GIF89a....'.codeUnits)), isNull);
    expect(sanitizeRelatedEntity('guideline:RG 25/ä'), 'guideline:RG_25/_');
  });
}
