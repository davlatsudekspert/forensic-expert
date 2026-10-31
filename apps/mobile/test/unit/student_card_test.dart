import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/data/remote/supabase_student_card.dart';
import 'package:forensic_expert/data/student_card/fake_student_card_service.dart';
import 'package:forensic_expert/domain/student_card/student_card.dart';

import '../helpers/referral_fakes.dart';

class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(String method, String path, Object? body) handler;
  final calls =
      <({String method, String path, Object? body, List<int>? bytes})>[];

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls.add((method: method, path: uri.path, body: jsonBody, bytes: bytes));
    return handler(method, uri.path, jsonBody);
  }
}

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);
final _png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  1,
]);

void main() {
  // Server (`private.student_card_text_ok`) bilan bir xil holatlar
  // (supabase/tests/student_card_test.sql: txtcases).
  group('matn filtri (aloqa ma’lumoti)', () {
    const clean = [
      'Dilshod',
      'Ali (Toshkent)',
      'Men 3-kurs talabasiman',
      '2024-2025 o‘quv yili',
      'Dr. Karimov',
      'Toksikologiya va kimyo, 2-kurs',
      'Instantly',
      'Guruh 12',
      'Ali Valiyev',
      'Олим Каримов',
      '',
    ];
    const dirty = {
      'https://example.org': 'https havola',
      'HTTP bilan': 'http katta harf',
      'www.site': 'www',
      'mening saytim site.uz': 'domen .uz',
      'site . com': 'bo‘shliqli domen',
      't.me/abc': 't.me',
      '@ali': '@username',
      'ali@mail.ru': 'email',
      'ali＠mail': 'to‘liq kenglikdagi @',
      'Telegram: ali': 'telegram',
      'instagram ali': 'instagram',
      'Insta ali': 'insta',
      'whatsapp': 'whatsapp',
      'Инстаграм': 'kirill instagram',
      'телеграм': 'kirill telegram',
      'tg: ali': 'tg',
      '+998901234567': '+998',
      '+998 90 123 45 67': '+998 bo‘shliqli',
      '+7 (999) 123': '+ bilan',
      '90 123 45 67': '9 raqam guruhlangan',
      '901234567': '9 raqam',
      '123-45-67': 'uy raqami',
      '1234567': '7 ketma-ket raqam',
      'tel 12 34 56 78': '8 raqam 4 guruh',
      '(90) 123-45-67': 'qavsli raqam',
      'Youtube kanal': 'youtube',
    };
    for (final t in clean) {
      test('toza: «$t»', () => expect(StudentCardText.isClean(t), isTrue));
    }
    for (final e in dirty.entries) {
      test(
        'rad: «${e.key}» (${e.value})',
        () => expect(StudentCardText.isClean(e.key), isFalse),
      );
    }
    test('so‘z bilan yozilgan «dot com» — filtr ushlamaydi (hujjatlangan)', () {
      expect(StudentCardText.isClean('ali dot com'), isTrue);
    });
  });

  group('draft chegaralari', () {
    test('ism 2–40, bio ≤150, boshqaruv belgisi', () {
      StudentCardDraftError? e(String n, [String b = '']) =>
          StudentCardDraft(displayName: n, bio: b).error;
      expect(e('A'), StudentCardDraftError.name);
      expect(e('Al'), isNull);
      expect(e('a' * 40), isNull);
      expect(e('a' * 41), StudentCardDraftError.name);
      expect(e('Is\u0001m'), StudentCardDraftError.name);
      expect(e('Ali', 'b' * 150), isNull);
      expect(e('Ali', 'b' * 151), StudentCardDraftError.bio);
      expect(e('Ali', 'ikki\nqator'), isNull);
      expect(e('Ali', 'x\u0007y'), StudentCardDraftError.bio);
    });
    test('aloqa ma’lumoti ism va bioda rad etiladi', () {
      expect(
        const StudentCardDraft(displayName: 'Ali t.me/ali').error,
        StudentCardDraftError.contactName,
      );
      expect(
        const StudentCardDraft(displayName: 'Ali', bio: 'yoz @ali').error,
        StudentCardDraftError.contactBio,
      );
      expect(
        StudentCardFailure.fromDraft(StudentCardDraftError.contactBio),
        StudentCardFailure.contactInfo,
      );
    });
    test('rasm 1 MB dan katta bo‘lsa rad', () {
      expect(
        StudentCardDraft(
          displayName: 'Ali',
          photo: Uint8List(StudentCardLimits.imageBytes + 1),
        ).error,
        StudentCardDraftError.image,
      );
    });
    test('default: yopiq, rasmsiz', () {
      const d = StudentCardDraft(displayName: 'Ali');
      expect(d.visible, isFalse);
      expect(d.photo, isNull);
    });
  });

  group('modellar', () {
    test('fromServer xato kodlari', () {
      expect(
        StudentCardFailure.fromServer('contact_info'),
        StudentCardFailure.contactInfo,
      );
      expect(
        StudentCardFailure.fromServer('hidden_by_admin'),
        StudentCardFailure.hiddenByAdmin,
      );
      expect(
        StudentCardFailure.fromServer('invalid_name'),
        StudentCardFailure.invalidName,
      );
      expect(
        StudentCardFailure.fromServer('invalid_bio'),
        StudentCardFailure.invalidBio,
      );
      expect(
        StudentCardFailure.fromServer('invalid_photo'),
        StudentCardFailure.invalidImage,
      );
      expect(StudentCardFailure.fromServer('limit'), StudentCardFailure.limit);
      expect(
        StudentCardFailure.fromServer('not_found'),
        StudentCardFailure.notFound,
      );
      expect(
        StudentCardFailure.fromServer('boshqa'),
        StudentCardFailure.server,
      );
    });
    test(
      'fromJson: havola/ijtimoiy maydon YO‘Q; noma’lum kalitlar e’tiborsiz',
      () {
        final c = StudentCard.fromJson({
          'student_id': 's',
          'display_name': 'Ali',
          'bio': 'Kimyo',
          'socials': {'telegram': 'https://t.me/x'},
          'workplace': 'X',
        });
        expect(c.displayName, 'Ali');
        expect(c.bio, 'Kimyo');
        expect(c.visible, isFalse);
        expect(c.groupHidden, isFalse);
      },
    );
    test('StudentGroupCards.fromJson + byMember', () {
      final g = StudentGroupCards.fromJson({
        'cards': [
          {'student_id': 'a', 'display_name': 'A1', 'member_id': 'm1'},
          {
            'student_id': 'b',
            'display_name': 'B2',
            'group_hidden': true,
            'member_id': 'm2',
          },
        ],
        'hidden_ids': ['c'],
      });
      expect(g.cards.length, 2);
      expect(g.hiddenIds, ['c']);
      expect(g.byMember('m2')!.groupHidden, isTrue);
      expect(g.byMember('zzz'), isNull);
      expect(StudentGroupCards.fromJson(const {}).isEmpty, isTrue);
    });
  });

  group('FakeStudentCardService: server qoidalari nusxasi', () {
    // g1 (ustoz t1): s1, s2.  g2 (t3): s1, s6.  g3 (t2): s3.  s4 — guruhsiz.
    late FakeStudentCardBackend be;
    String? me;
    late FakeStudentCardService svc;
    setUp(() {
      be = FakeStudentCardBackend(
        groups: {
          'g1': FakeStudentGroup(
            teacherId: 't1',
            members: {'m1': 's1', 'm2': 's2'},
          ),
          'g2': FakeStudentGroup(
            teacherId: 't3',
            members: {'m3': 's1', 'm6': 's6'},
          ),
          'g3': FakeStudentGroup(teacherId: 't2', members: {'m4': 's3'}),
        },
      );
      svc = FakeStudentCardService(be, userIdOf: () => me);
      me = 's1';
    });

    Future<void> card({bool visible = true}) async {
      me = 's1';
      final r = await svc.save(
        StudentCardDraft(
          displayName: 'Dilshod',
          bio: 'Kimyo',
          visible: visible,
        ),
      );
      expect(r.ok, isTrue);
    }

    Future<StudentGroupCards?> cardsFor(String viewer, String group) async {
      me = viewer;
      return (await svc.forGroup(group)).value;
    }

    test(
      'har qanday kirgan hisob yoza oladi (ustoz roli shart emas)',
      () async {
        await card(visible: false);
        expect(be.cards['s1']!.visible, isFalse, reason: 'DEFAULT yopiq');
      },
    );

    test('visible=false: ustoz ham, guruhdosh ham ko‘rmaydi', () async {
      await card(visible: false);
      expect((await cardsFor('t1', 'g1'))!.cards, isEmpty);
      expect((await cardsFor('s2', 'g1'))!.cards, isEmpty);
    });

    test('ko‘rinish matritsasi', () async {
      await card();
      expect(
        (await cardsFor('t1', 'g1'))!.cards.single.memberId,
        'm1',
        reason: 'ustoz',
      );
      expect(
        (await cardsFor('s2', 'g1'))!.cards.single.displayName,
        'Dilshod',
        reason: 'guruhdosh',
      );
      expect((await cardsFor('s2', 'g1'))!.cards.single.memberId, isNull);
      expect(
        (await cardsFor('s3', 'g1')),
        isNull,
        reason: 'boshqa guruh talabasi',
      );
      expect((await cardsFor('t2', 'g1')), isNull, reason: 'boshqa ustoz');
      expect((await cardsFor('s4', 'g1')), isNull, reason: 'guruhsiz');
      expect(be.visibleTo('s2', be.cards['s1']!), isTrue);
      expect(be.visibleTo('s3', be.cards['s1']!), isFalse);
      expect(be.visibleTo('s4', be.cards['s1']!), isFalse);
      expect(
        be.visibleTo('s1', be.cards['s1']!),
        isFalse,
        reason: 'egasi mine() orqali',
      );
    });

    test(
      'admin yashirgan karta hech kimga ko‘rinmaydi; qayta yoqib bo‘lmaydi',
      () async {
        await card();
        be.adminHidden.add('s1');
        expect((await cardsFor('t1', 'g1'))!.cards, isEmpty);
        expect((await cardsFor('s2', 'g1'))!.cards, isEmpty);
        me = 's1';
        expect(
          (await svc.save(
            const StudentCardDraft(displayName: 'Dilshod', visible: true),
          )).failure,
          StudentCardFailure.hiddenByAdmin,
        );
        expect((await svc.mine()).value!.hiddenByAdmin, isTrue);
      },
    );

    test(
      '«o‘zim uchun yashirish»: faqat o‘sha ko‘ruvchiga; qaytarish bor',
      () async {
        await card();
        me = 's2';
        expect((await svc.hideForMe('s1')).ok, isTrue);
        final mine = await cardsFor('s2', 'g1');
        expect(mine!.cards, isEmpty);
        expect(mine.hiddenIds, ['s1']);
        expect(
          (await cardsFor('t1', 'g1'))!.cards,
          hasLength(1),
          reason: 'ustozga ta’sir yo‘q',
        );
        expect(
          (await cardsFor('s6', 'g2'))!.cards,
          hasLength(1),
          reason: 'boshqa guruhdoshga ta’sir yo‘q',
        );
        me = 's2';
        expect((await svc.hideForMe('s1', hide: false)).ok, isTrue);
        expect((await cardsFor('s2', 'g1'))!.cards, hasLength(1));
        expect((await cardsFor('s2', 'g1'))!.hiddenIds, isEmpty);
      },
    );

    test('aloqasiz foydalanuvchi yashira olmaydi', () async {
      await card();
      me = 's3';
      expect((await svc.hideForMe('s1')).failure, StudentCardFailure.forbidden);
    });

    test('ustoz moderatsiyasi: guruhdan yashiradi; ustoz o‘zi ko‘radi; egasi qayta yoqa olmaydi', () async {
      await card();
      me = 't1';
      expect(
        (await svc.hideInGroup('g1', 's1', reason: 'nomaqbul')).ok,
        isTrue,
      );
      final t = await cardsFor('t1', 'g1');
      expect(t!.cards.single.groupHidden, isTrue);
      expect((await cardsFor('s2', 'g1'))!.cards, isEmpty);
      me = 's1';
      expect(
        (await svc.save(
          const StudentCardDraft(displayName: 'Dilshod', visible: true),
        )).ok,
        isTrue,
      );
      expect((await svc.mine()).value!.hiddenInGroups, 1);
      expect(
        (await cardsFor('s2', 'g1'))!.cards,
        isEmpty,
        reason: 'egasi qayta yoqa olmaydi',
      );
      expect(
        (await cardsFor('s6', 'g2'))!.cards,
        hasLength(1),
        reason: 'boshqa guruhda hamon ko‘rinadi',
      );
      me = 't1';
      expect((await svc.hideInGroup('g1', 's1', hide: false)).ok, isTrue);
      expect((await cardsFor('s2', 'g1'))!.cards, hasLength(1));
    });

    test('ustoz moderatsiyasi: faqat guruh ustozi', () async {
      await card();
      for (final who in ['s2', 't2', 't3', 's4']) {
        me = who;
        expect(
          (await svc.hideInGroup('g1', 's1')).failure,
          StudentCardFailure.forbidden,
          reason: who,
        );
      }
      me = 't1';
      expect(
        (await svc.hideInGroup('g1', 's3')).failure,
        StudentCardFailure.notFound,
      );
    });

    test('o‘chirish kartani va rasmni olib tashlaydi', () async {
      me = 's1';
      await svc.save(
        StudentCardDraft(displayName: 'Ali', photo: _png, visible: true),
      );
      final p = be.cards['s1']!.photoPath!;
      expect(be.files[p], isNotNull);
      expect(p, matches(r'^s1/photo-[0-9a-f-]{36}\.png$'));
      await svc.delete();
      expect(be.files, isEmpty);
      expect((await svc.mine()).value, isNull);
    });

    test('rasm almashtirilsa eski fayl o‘chadi', () async {
      me = 's1';
      await svc.save(StudentCardDraft(displayName: 'Ali', photo: _png));
      final first = be.cards['s1']!.photoPath!;
      await svc.save(
        StudentCardDraft(
          displayName: 'Ali',
          photo: Uint8List.fromList([..._png, 2]),
        ),
        previous: be.cards['s1'],
      );
      expect(be.files.containsKey(first), isFalse);
      expect(be.files, hasLength(1));
    });

    test('aloqa ma’lumotli matn serverda saqlanmaydi', () async {
      me = 's1';
      final r = await svc.save(
        const StudentCardDraft(displayName: 'Ali', bio: 'tel +998901234567'),
      );
      expect(r.failure, StudentCardFailure.contactInfo);
      expect(be.cards, isEmpty);
    });
  });

  group('SupabaseStudentCardService', () {
    test('kirmagan — tarmoqqa chiqmaydi', () async {
      final t = _Transport((m, p, b) => const RestResponse(200, {}));
      final s = SupabaseStudentCardService(
        config: _cfg,
        auth: MockAuthRepository(),
        transport: t,
      );
      expect((await s.mine()).failure, StudentCardFailure.notSignedIn);
      expect((await s.forGroup('g')).failure, StudentCardFailure.notSignedIn);
      expect((await s.hideForMe('x')).failure, StudentCardFailure.notSignedIn);
      expect(
        (await s.save(const StudentCardDraft(displayName: 'Ali'))).failure,
        StudentCardFailure.notSignedIn,
      );
      expect(await s.image('x/photo-1.png'), isNull);
      expect(t.calls, isEmpty);
    });

    test('RPC nomlari va tanasi; rasm o‘z papkasiga, so‘ng karta; havola maydoni yo‘q', () async {
      final auth = await signedInMockAuth();
      final uid = auth.current.account!.userId;
      final t = _Transport((m, p, b) {
        if (p.startsWith('/storage/')) {
          return const RestResponse(200, {'Key': 'ok'});
        }
        final body = b! as Map;
        return RestResponse(200, {
          'ok': true,
          'card': {
            'student_id': uid,
            'display_name': 'Dilshod',
            'photo_path': body['p_photo_path'],
            'visible': body['p_visible'],
          },
        });
      });
      final s = SupabaseStudentCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final r = await s.save(
        StudentCardDraft(displayName: ' Dilshod ', bio: 'Kimyo', photo: _png),
      );
      expect(r.ok, isTrue);
      expect(t.calls.first.method, 'POST');
      expect(
        t.calls.first.path,
        matches(
          '^/storage/v1/object/student-cards/$uid/photo-[0-9a-f-]{36}\\.png\$',
        ),
      );
      expect(t.calls.first.bytes, _png);
      final rpc = t.calls.last;
      expect(rpc.path, '/rest/v1/rpc/student_card_upsert');
      final body = rpc.body! as Map;
      expect(body.keys.toSet(), {
        'p_display_name',
        'p_bio',
        'p_photo_path',
        'p_visible',
      });
      expect(body['p_display_name'], 'Dilshod');
      expect(body['p_visible'], false, reason: 'default yopiq');
    });

    test('mijoz filtri tarmoqqa chiqmasdan rad etadi', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((m, p, b) => const RestResponse(200, {'ok': true}));
      final s = SupabaseStudentCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final r = await s.save(
        StudentCardDraft(displayName: 'Ali', bio: 'https://x.org', photo: _png),
      );
      expect(r.failure, StudentCardFailure.contactInfo);
      expect(t.calls, isEmpty, reason: 'rasm ham yuklanmaydi');
    });

    test(
      'server contact_info qaytarsa rasm o‘chiriladi (yetim fayl qolmaydi)',
      () async {
        final auth = await signedInMockAuth();
        final t = _Transport((m, p, b) {
          if (p.startsWith('/storage/')) return const RestResponse(200, {});
          return const RestResponse(200, {
            'ok': false,
            'error': 'contact_info',
            'field': 'bio',
          });
        });
        final s = SupabaseStudentCardService(
          config: _cfg,
          auth: auth,
          transport: t,
        );
        final r = await s.save(
          StudentCardDraft(displayName: 'Ali', photo: _png),
        );
        expect(r.failure, StudentCardFailure.contactInfo);
        final del = t.calls.where((c) => c.method == 'DELETE');
        expect(del.single.path, contains('/storage/v1/object/student-cards/'));
      },
    );

    test('forGroup, hideForMe, hideInGroup: RPC nomlari va tanalari', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((m, p, b) {
        if (p.endsWith('student_cards_for_group')) {
          return const RestResponse(200, {
            'ok': true,
            'cards': [
              {'student_id': 'a', 'display_name': 'Ali', 'member_id': 'm1'},
            ],
            'hidden_ids': ['b'],
          });
        }
        return const RestResponse(200, {'ok': true});
      });
      final s = SupabaseStudentCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final g = (await s.forGroup('g1')).value!;
      expect(g.cards.single.displayName, 'Ali');
      expect(g.hiddenIds, ['b']);
      expect(t.calls.last.path, '/rest/v1/rpc/student_cards_for_group');
      expect(t.calls.last.body, {'p_group': 'g1'});
      expect((await s.hideForMe('a')).ok, isTrue);
      expect(t.calls.last.path, '/rest/v1/rpc/student_card_hide_for_me');
      expect(t.calls.last.body, {'p_student': 'a', 'p_hide': true});
      expect((await s.hideForMe('a', hide: false)).ok, isTrue);
      expect(t.calls.last.body, {'p_student': 'a', 'p_hide': false});
      expect((await s.hideInGroup('g1', 'a', reason: 'x')).ok, isTrue);
      expect(t.calls.last.path, '/rest/v1/rpc/group_student_card_hide');
      expect(t.calls.last.body, {
        'p_group': 'g1',
        'p_student': 'a',
        'p_hide': true,
        'p_reason': 'x',
      });
    });

    test('HTTP 403 / 404 / xato kodlari', () async {
      final auth = await signedInMockAuth();
      var status = 403;
      final t = _Transport((m, p, b) => RestResponse(status, const {}));
      final s = SupabaseStudentCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      expect((await s.forGroup('g')).failure, StudentCardFailure.forbidden);
      status = 404;
      expect((await s.mine()).failure, StudentCardFailure.notConfigured);
      status = 500;
      expect((await s.mine()).failure, StudentCardFailure.server);
      final t2 = _Transport(
        (m, p, b) => const RestResponse(200, {'ok': false, 'error': 'limit'}),
      );
      final s2 = SupabaseStudentCardService(
        config: _cfg,
        auth: auth,
        transport: t2,
      );
      expect((await s2.hideForMe('x')).failure, StudentCardFailure.limit);
    });

    test('delete: server qaytargan rasm Storage’dan o‘chiriladi', () async {
      final auth = await signedInMockAuth();
      final uid = auth.current.account!.userId;
      final t = _Transport((m, p, b) {
        if (p.startsWith('/storage/')) return const RestResponse(200, {});
        return RestResponse(200, {
          'ok': true,
          'deleted': true,
          'photo_path': '$uid/photo-x.png',
        });
      });
      final s = SupabaseStudentCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      expect((await s.delete()).ok, isTrue);
      expect(t.calls.last.method, 'DELETE');
      expect(
        t.calls.last.path,
        '/storage/v1/object/student-cards/$uid/photo-x.png',
      );
    });
  });
}
