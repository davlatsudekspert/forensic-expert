import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/data/remote/supabase_teacher_card.dart';
import 'package:forensic_expert/data/teacher_card/fake_teacher_card_service.dart';
import 'package:forensic_expert/domain/teacher_card/teacher_card.dart';

import '../helpers/referral_fakes.dart';

String? _n(TeacherSocial s, String raw) => TeacherLinks.normalize(s, raw);

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
  group('havola normallashtirish', () {
    test('Telegram/Instagram: @username va oddiy username → to‘liq https', () {
      expect(_n(TeacherSocial.telegram, '@dkarimov'), 'https://t.me/dkarimov');
      expect(_n(TeacherSocial.telegram, 'dkarimov'), 'https://t.me/dkarimov');
      expect(
        _n(TeacherSocial.instagram, '@forensic.teacher'),
        'https://instagram.com/forensic.teacher',
      );
      expect(
        _n(TeacherSocial.instagram, 'forensic.teacher'),
        'https://instagram.com/forensic.teacher',
      );
      expect(_n(TeacherSocial.tiktok, '@dk'), 'https://www.tiktok.com/@dk');
      expect(
        _n(TeacherSocial.linkedin, '@dilshod-k'),
        'https://www.linkedin.com/in/dilshod-k',
      );
    });

    test('sxemasiz domen va to‘liq havola qabul qilinadi', () {
      expect(_n(TeacherSocial.telegram, 't.me/dk'), 'https://t.me/dk');
      expect(
        _n(TeacherSocial.youtube, 'youtube.com/@forensic'),
        'https://youtube.com/@forensic',
      );
      expect(_n(TeacherSocial.youtube, 'youtu.be/abc'), 'https://youtu.be/abc');
      expect(
        _n(TeacherSocial.facebook, 'HTTPS://facebook.com/dk'),
        'https://facebook.com/dk',
      );
      expect(_n(TeacherSocial.website, 'forensic.uz'), 'https://forensic.uz');
      expect(
        _n(TeacherSocial.website, 'https://forensic.uz/a?b=c'),
        'https://forensic.uz/a?b=c',
      );
      expect(_n(TeacherSocial.telegram, '   '), '');
      expect(_n(TeacherSocial.telegram, ''), '');
    });

    test('xavfli yoki noto‘g‘ri havolalar rad (null)', () {
      for (final bad in [
        'javascript:alert(1)',
        'JavaScript:alert(1)',
        'data:text/html,<script>1</script>',
        'http://t.me/dk',
        'ftp://t.me/dk',
        'file:///etc/passwd',
        'intent://x#Intent;end',
        '//t.me/dk',
        'https://evil.example/dk',
        'https://t.me.evil.example/dk',
        'https://evilt.me/dk',
        'https://t.me@evil.example/',
        'https://user:pw@t.me/dk',
        'https://t.me:8443/dk',
        'https://t.me/a b',
        'https://t.me/<x>',
        '@a',
        '@bad name',
        '@@dk',
        'https://l.facebook.com/l.php?u=https://evil.example',
      ]) {
        expect(_n(TeacherSocial.telegram, bad), isNull, reason: bad);
      }
      expect(_n(TeacherSocial.facebook, 'https://l.facebook.com/x'), isNull);
      // «website»da @username ma’nosiz.
      expect(_n(TeacherSocial.website, '@dk'), isNull);
      expect(_n(TeacherSocial.website, 'http://forensic.uz'), isNull);
      expect(_n(TeacherSocial.website, 'https://127.0.0.1/'), isNull);
      expect(_n(TeacherSocial.website, 'https://localhost/'), isNull);
      expect(_n(TeacherSocial.website, 'localhost'), isNull);
      expect(_n(TeacherSocial.website, 'javascript:alert(1)'), isNull);
    });

    test('tarmoq o‘z domenidan boshqasiga yo‘naltirilmaydi', () {
      expect(_n(TeacherSocial.instagram, 'https://t.me/x'), isNull);
      expect(_n(TeacherSocial.telegram, 'https://instagram.com/x'), isNull);
      expect(_n(TeacherSocial.linkedin, 'https://facebook.com/x'), isNull);
    });

    test('255 belgi chegarasi (server bilan bir xil)', () {
      final ok = 'https://forensic.uz/${'a' * 235}';
      expect(ok.length, 255);
      expect(_n(TeacherSocial.website, ok), ok);
      expect(_n(TeacherSocial.website, '${ok}a'), isNull);
    });

    test('ochish: faqat ruxsat etilgan domen (openable)', () {
      expect(
        TeacherLinks.openable(TeacherSocial.telegram, 'https://t.me/dk'),
        Uri.parse('https://t.me/dk'),
      );
      expect(
        TeacherLinks.openable(TeacherSocial.telegram, 'https://evil.example'),
        isNull,
      );
      expect(
        TeacherLinks.openable(TeacherSocial.website, 'javascript:alert(1)'),
        isNull,
      );
      expect(
        TeacherLinks.openable(TeacherSocial.website, 'http://forensic.uz'),
        isNull,
      );
      expect(
        TeacherLinks.openable(TeacherSocial.website, 'https://forensic.uz'),
        isNotNull,
      );
    });

    test('safe(): serverdan kelgan yaroqsiz havola kartaga o‘tmaydi', () {
      final m = TeacherLinks.safe({
        'telegram': 'https://t.me/dk',
        'instagram': 'javascript:alert(1)',
        'website': 'http://forensic.uz',
        'youtube': 5,
        'twitter': 'https://x.com/a',
      });
      expect(m.keys, [TeacherSocial.telegram]);
    });
  });

  group('TeacherCard / draft', () {
    test('fromJson: talaba javobi (ichki maydonlarsiz) va egasi javobi', () {
      final c = TeacherCard.fromJson({
        'teacher_id': 'u1',
        'display_name': 'Dilshod',
        'workplace': 'Markaz',
        'bio': '',
        'photo_path': 'u1/photo-x.png',
        'logo_path': null,
        'socials': {'telegram': 'https://t.me/dk', 'website': 'ftp://x.uz'},
        'updated_at': '2026-10-31T00:00:00Z',
      });
      expect(c.visible, isFalse, reason: 'talabaga visible berilmaydi');
      expect(c.socials.keys, [TeacherSocial.telegram]);
      expect(c.photoPath, 'u1/photo-x.png');
      expect(c.logoPath, isNull);
      final o = TeacherCard.fromJson({
        'teacher_id': 'u1',
        'display_name': 'D',
        'visible': true,
        'hidden_by_admin': true,
      });
      expect(o.visible, isTrue);
      expect(o.hiddenByAdmin, isTrue);
    });

    test('draft: DEFAULT visible=false; chegaralar', () {
      expect(const TeacherCardDraft(displayName: 'Ali').visible, isFalse);
      expect(const TeacherCardDraft(displayName: 'Ali').error, isNull);
      expect(
        const TeacherCardDraft(displayName: 'A').error,
        TeacherCardDraftError.name,
      );
      expect(
        TeacherCardDraft(displayName: 'a' * 61).error,
        TeacherCardDraftError.name,
      );
      expect(
        TeacherCardDraft(displayName: 'Ali', workplace: 'w' * 121).error,
        TeacherCardDraftError.workplace,
      );
      expect(
        TeacherCardDraft(displayName: 'Ali', bio: 'b' * 301).error,
        TeacherCardDraftError.bio,
      );
      expect(
        TeacherCardDraft(displayName: 'Ali', bio: 'b' * 300).error,
        isNull,
      );
      expect(
        TeacherCardDraft(
          displayName: 'Ali',
          photo: Uint8List(TeacherCardLimits.imageBytes + 1),
        ).error,
        TeacherCardDraftError.image,
      );
      expect(
        const TeacherCardDraft(
          displayName: 'Ali',
          socials: {TeacherSocial.telegram: 'https://evil.example/x'},
        ).error,
        TeacherCardDraftError.social,
      );
    });

    test('rasm turi bayt boshidan aniqlanadi', () {
      expect(TeacherImageKind.of(_png), TeacherImageKind.png);
      expect(
        TeacherImageKind.of(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0])),
        TeacherImageKind.jpeg,
      );
      expect(
        TeacherImageKind.of(
          Uint8List.fromList([
            ...'RIFF'.codeUnits,
            0,
            0,
            0,
            0,
            ...'WEBP'.codeUnits,
          ]),
        ),
        TeacherImageKind.webp,
      );
      expect(
        TeacherImageKind.of(Uint8List.fromList('GIF89a....'.codeUnits)),
        isNull,
      );
    });
  });

  group('FakeTeacherCardService (server qoidalari nusxasi)', () {
    late FakeTeacherCardBackend be;
    String? me;
    late FakeTeacherCardService svc;
    setUp(() {
      be = FakeTeacherCardBackend(
        isTeacher: (u) => u == 'teacher',
        teacherOf: (u, g) =>
            (g == 'g1' && (u == 'stu' || u == 'teacher')) ? 'teacher' : null,
      );
      svc = FakeTeacherCardService(be, userIdOf: () => me);
    });

    test('talaba yoza olmaydi; kirmagan — notSignedIn', () async {
      me = null;
      expect(
        (await svc.save(const TeacherCardDraft(displayName: 'Ali'))).failure,
        TeacherCardFailure.notSignedIn,
      );
      me = 'stu';
      expect(
        (await svc.save(const TeacherCardDraft(displayName: 'Ali'))).failure,
        TeacherCardFailure.forbidden,
      );
    });

    test('visible=false: a’zo kartani ko‘rmaydi; yoqilgach ko‘radi', () async {
      me = 'teacher';
      final saved = await svc.save(
        const TeacherCardDraft(
          displayName: 'Dilshod',
          workplace: 'Markaz',
          socials: {TeacherSocial.telegram: 'https://t.me/dk'},
        ),
      );
      expect(saved.ok, isTrue);
      expect(saved.value!.visible, isFalse);
      me = 'stu';
      expect((await svc.forGroup('g1')).value, isNull);
      me = 'teacher';
      await svc.save(
        const TeacherCardDraft(displayName: 'Dilshod', visible: true),
      );
      me = 'stu';
      final r = await svc.forGroup('g1');
      expect(r.value!.displayName, 'Dilshod');
      expect(r.value!.visible, isFalse, reason: 'talabaga ichki maydon yo‘q');
    });

    test('a’zo bo‘lmagan talaba — forbidden', () async {
      me = 'outsider';
      expect((await svc.forGroup('g1')).failure, TeacherCardFailure.forbidden);
    });

    test('admin yashirgan: ko‘rinmaydi va ustoz qayta yoqa olmaydi', () async {
      me = 'teacher';
      await svc.save(
        const TeacherCardDraft(displayName: 'Dilshod', visible: true),
      );
      be.hidden.add('teacher');
      me = 'stu';
      expect((await svc.forGroup('g1')).value, isNull);
      me = 'teacher';
      expect(
        (await svc.save(
          const TeacherCardDraft(displayName: 'Dilshod', visible: true),
        )).failure,
        TeacherCardFailure.hiddenByAdmin,
      );
      expect((await svc.mine()).value!.hiddenByAdmin, isTrue);
    });

    test(
      'rasm: almashtirilsa eski fayl o‘chadi; delete hammasini tozalaydi',
      () async {
        me = 'teacher';
        final a = await svc.save(
          TeacherCardDraft(displayName: 'Dilshod', photo: _png),
        );
        final p1 = a.value!.photoPath!;
        expect(be.files.containsKey(p1), isTrue);
        final b = await svc.save(
          TeacherCardDraft(displayName: 'Dilshod', photo: _png),
          previous: a.value,
        );
        expect(be.files.containsKey(p1), isFalse);
        expect(be.files.length, 1);
        final c = await svc.save(
          const TeacherCardDraft(displayName: 'Dilshod', removePhoto: true),
          previous: b.value,
        );
        expect(c.value!.photoPath, isNull);
        expect(be.files, isEmpty);
        await svc.save(TeacherCardDraft(displayName: 'Dilshod', logo: _png));
        expect(be.files.length, 1);
        await svc.delete();
        expect(be.files, isEmpty);
        expect((await svc.mine()).value, isNull);
      },
    );
  });

  group('SupabaseTeacherCardService', () {
    test('kirmagan — tarmoqqa chiqmaydi', () async {
      final t = _Transport((m, p, b) => const RestResponse(200, {}));
      final s = SupabaseTeacherCardService(
        config: _cfg,
        auth: MockAuthRepository(),
        transport: t,
      );
      expect((await s.mine()).failure, TeacherCardFailure.notSignedIn);
      expect(
        (await s.save(const TeacherCardDraft(displayName: 'Ali'))).failure,
        TeacherCardFailure.notSignedIn,
      );
      expect(await s.image('x/photo-1.png'), isNull);
      expect(t.calls, isEmpty);
    });

    test('RPC nomlari va tanasi; rasm o‘z papkasiga, so‘ng karta', () async {
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
            'teacher_id': uid,
            'display_name': 'Dilshod',
            'photo_path': body['p_photo_path'],
            'socials': body['p_socials'],
            'visible': body['p_visible'],
          },
        });
      });
      final s = SupabaseTeacherCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final r = await s.save(
        TeacherCardDraft(
          displayName: ' Dilshod ',
          workplace: 'Markaz',
          socials: const {TeacherSocial.telegram: 'https://t.me/dk'},
          photo: _png,
        ),
      );
      expect(r.ok, isTrue);
      expect(t.calls.first.method, 'POST');
      expect(
        t.calls.first.path,
        matches(
          '^/storage/v1/object/teacher-cards/$uid/photo-'
          r'[0-9a-f-]{36}\.png$',
        ),
      );
      expect(t.calls.first.bytes, _png);
      final rpc = t.calls.last;
      expect(rpc.path, '/rest/v1/rpc/teacher_card_upsert');
      final body = rpc.body! as Map;
      expect(body['p_display_name'], 'Dilshod');
      expect(body['p_visible'], false, reason: 'default yopiq');
      expect(body['p_socials'], {'telegram': 'https://t.me/dk'});
      expect(body['p_logo_path'], isNull);
      expect(r.value!.socials[TeacherSocial.telegram], 'https://t.me/dk');
    });

    test(
      'RPC rad etsa yuklangan rasm o‘chiriladi (yetim fayl qolmaydi)',
      () async {
        final auth = await signedInMockAuth();
        final t = _Transport((m, p, b) {
          if (p.startsWith('/storage/')) return const RestResponse(200, {});
          return const RestResponse(200, {
            'ok': false,
            'error': 'invalid_social',
            'field': 'website',
          });
        });
        final s = SupabaseTeacherCardService(
          config: _cfg,
          auth: auth,
          transport: t,
        );
        final r = await s.save(
          TeacherCardDraft(displayName: 'Ali', photo: _png),
        );
        expect(r.failure, TeacherCardFailure.invalidSocial);
        final del = t.calls.where((c) => c.method == 'DELETE');
        expect(del.length, 1);
        expect(del.single.path, contains('/storage/v1/object/teacher-cards/'));
      },
    );

    test('almashtirilgan eski rasm saqlangach o‘chiriladi', () async {
      final auth = await signedInMockAuth();
      final uid = auth.current.account!.userId;
      final t = _Transport((m, p, b) {
        if (p.startsWith('/storage/')) return const RestResponse(200, {});
        return RestResponse(200, {
          'ok': true,
          'card': {
            'teacher_id': uid,
            'display_name': 'Ali',
            'photo_path': (b! as Map)['p_photo_path'],
          },
        });
      });
      final s = SupabaseTeacherCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final old = TeacherCard(
        teacherId: uid,
        displayName: 'Ali',
        photoPath: '$uid/photo-11111111-1111-4111-8111-111111111111.png',
      );
      await s.save(
        TeacherCardDraft(displayName: 'Ali', photo: _png),
        previous: old,
      );
      final del = t.calls.where((c) => c.method == 'DELETE').single;
      expect(del.path, endsWith(old.photoPath!));
    });

    test('noto‘g‘ri rasm turi/hajmi yuklanmaydi', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((m, p, b) => const RestResponse(200, {'ok': true}));
      final s = SupabaseTeacherCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final gif = Uint8List.fromList('GIF89a....'.codeUnits);
      expect(
        (await s.save(TeacherCardDraft(displayName: 'Ali', photo: gif)))
            .failure,
        TeacherCardFailure.invalidImage,
      );
      expect(
        (await s.save(
          TeacherCardDraft(
            displayName: 'Ali',
            photo: Uint8List(TeacherCardLimits.imageBytes + 1),
          ),
        )).failure,
        TeacherCardFailure.imageTooLarge,
      );
      expect(t.calls, isEmpty);
    });

    test(
      'HTTP 403 → forbidden; 404 → notConfigured; for_group; delete',
      () async {
        final auth = await signedInMockAuth();
        var status = 403;
        final t = _Transport((m, p, b) => RestResponse(status, {'ok': true}));
        final s = SupabaseTeacherCardService(
          config: _cfg,
          auth: auth,
          transport: t,
        );
        expect((await s.mine()).failure, TeacherCardFailure.forbidden);
        status = 404;
        expect(
          (await s.forGroup('g')).failure,
          TeacherCardFailure.notConfigured,
        );
        status = 200;
        final tt = _Transport(
          (m, p, b) => p.endsWith('teacher_card_for_group')
              ? const RestResponse(200, {'ok': true, 'card': null})
              : const RestResponse(200, {
                  'ok': true,
                  'deleted': true,
                  'photo_path': 'u/photo-1.png',
                  'logo_path': null,
                }),
        );
        final s2 = SupabaseTeacherCardService(
          config: _cfg,
          auth: auth,
          transport: tt,
        );
        final r = await s2.forGroup('g-1');
        expect(r.ok, isTrue);
        expect(r.value, isNull);
        expect((tt.calls.single.body! as Map)['p_group'], 'g-1');
        expect((await s2.delete()).ok, isTrue);
        expect(
          tt.calls.where((c) => c.method == 'DELETE').single.path,
          endsWith('/teacher-cards/u/photo-1.png'),
        );
      },
    );

    test('server {ok:false,error} → aniq xato', () async {
      final auth = await signedInMockAuth();
      final t = _Transport(
        (m, p, b) =>
            const RestResponse(200, {'ok': false, 'error': 'hidden_by_admin'}),
      );
      final s = SupabaseTeacherCardService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      expect(
        (await s.save(
          const TeacherCardDraft(displayName: 'Ali', visible: true),
        )).failure,
        TeacherCardFailure.hiddenByAdmin,
      );
    });
  });
}
