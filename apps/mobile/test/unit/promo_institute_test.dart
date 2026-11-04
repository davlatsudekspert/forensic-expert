// Promokod, qurilmalar limiti va admin institut modeli (sof
// parse) + Supabase adapterlarining RPC shartnomasi.
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_promo.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/admin/institute_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/plan/promo_models.dart';
import 'package:forensic_expert/domain/ports/plan_ports.dart';

import '../helpers/referral_fakes.dart';

class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(String path, Object? body) handler;
  final calls = <({String path, Object? body})>[];

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls.add((path: uri.path, body: jsonBody));
    return handler(uri.path, jsonBody);
  }
}

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);

void main() {
  group('kodni normallashtirish', () {
    test('katta harf; bo‘shliq, defis va boshqa belgilar tashlanadi', () {
      expect(normalizePromoCode(' a1b2-c3 d4e5 '), 'A1B2C3D4E5');
      expect(normalizePromoCode('abc_def.12'), 'ABCDEF12');
      expect(normalizePromoCode('  - '), '');
    });
  });

  group('PromoOutcome', () {
    test('natijalar xaritasi', () {
      for (final (wire, res) in [
        ('OK', PromoResult.ok),
        ('INVALID', PromoResult.invalid),
        ('USED', PromoResult.used),
        ('ALREADY_YOURS', PromoResult.alreadyYours),
        ('EXPIRED', PromoResult.expired),
        ('REVOKED', PromoResult.revoked),
        ('TOO_MANY', PromoResult.tooMany),
        ('NOT_SIGNED', PromoResult.notSigned),
        ('???', PromoResult.unknown),
      ]) {
        expect(PromoResult.fromWire(wire), res, reason: wire);
      }
    });

    test('OK javobi: label, sana, reja', () {
      final o = PromoOutcome.fromJson({
        'result': 'OK',
        'kind': 'institute',
        'label': 'institut: ADTI',
        'until': '2027-03-01T00:00:00Z',
        'plan': 'teacher',
      });
      expect(o.result, PromoResult.ok);
      expect(o.kind, 'institute');
      expect(o.label, 'institut: ADTI');
      expect(o.plan, Plan.teacher);
      expect(o.until!.toUtc(), DateTime.utc(2027, 3, 1));
    });

    test('INVALID javobida qo‘shimcha maydon yo‘q', () {
      final o = PromoOutcome.fromJson({'result': 'INVALID'});
      expect(o.result, PromoResult.invalid);
      expect(o.label, isNull);
      expect(o.until, isNull);
    });
  });

  group('PromoLabel', () {
    test('institut va sovg‘a', () {
      final a = PromoLabel.parse('institut: Andijon davlat tibbiyot instituti');
      expect(a!.kind, PromoKind.institute);
      expect(a.name, 'Andijon davlat tibbiyot instituti');
      final b = PromoLabel.parse('sovg‘a: Ali Valiyev');
      expect(b!.kind, PromoKind.gift);
      expect(b.name, 'Ali Valiyev');
      expect(PromoLabel.parse("sovg'a: X")!.kind, PromoKind.gift);
    });

    test('noma’lum yozuv — o‘z holicha; bo‘sh — null', () {
      expect(PromoLabel.parse('boshqa')!.kind, PromoKind.other);
      expect(PromoLabel.parse('  '), isNull);
      expect(PromoLabel.parse(null), isNull);
    });
  });

  group('Entitlements.label', () {
    test('my_plan label o‘qiladi; bo‘sh/yo‘q — null', () {
      expect(
        Entitlements.fromJson({'plan': 'teacher', 'label': 'institut: A'})
            .label,
        'institut: A',
      );
      expect(Entitlements.fromJson({'plan': 'teacher'}).label, isNull);
      expect(Entitlements.fromJson({'label': ' '}).label, isNull);
    });

    test('eski kalitlar o‘zgarmagan', () {
      final e = Entitlements.fromJson({
        'plan': 'expert',
        'source': 'admin',
        'expires_at': '2099-01-01T00:00:00Z',
        'auto_renew': false,
        'trial_available': false,
        'label': null,
      });
      expect(e.plan, Plan.expert);
      expect(e.source, PlanSource.admin);
      expect(e.label, isNull);
    });
  });

  group('qurilmalar', () {
    test('register_device ok=false: ro‘yxat', () {
      final r = DeviceRegistration.fromJson({
        'ok': false,
        'limit': 3,
        'devices': [
          {'hash': 'a', 'label': 'iOS', 'last_seen': '2026-11-01T10:00:00Z'},
          {'hash': 'b', 'label': null, 'last_seen': null},
          {'label': 'hash yo‘q'},
        ],
      });
      expect(r.ok, isFalse);
      expect(r.limit, 3);
      expect(r.devices.map((d) => d.hash), ['a', 'b']);
      expect(r.devices.first.label, 'iOS');
      expect(r.devices.first.lastSeen, isNotNull);
      expect(r.devices.last.label, isNull);
    });

    test('ok=true devices’siz', () {
      final r = DeviceRegistration.fromJson({'ok': true, 'limit': 3});
      expect(r.ok, isTrue);
      expect(r.devices, isEmpty);
    });
  });

  group('tashkilot formasi', () {
    test('forma: nom + o‘rin + muddat', () {
      const d = InstituteDraft(name: 'ADTI', seats: 10, months: 12);
      expect(d.isValid, isTrue);
    });

    test('forma chegaralari', () {
      bool ok(int seats, int months, {String name = 'ADTI'}) =>
          InstituteDraft(name: name, seats: seats, months: months).isValid;
      expect(ok(1, 1), isTrue);
      expect(ok(500, 60), isTrue);
      expect(ok(0, 12), isFalse);
      expect(ok(501, 12), isFalse);
      expect(ok(10, 0), isFalse);
      expect(ok(10, 61), isFalse);
      expect(ok(10, 12, name: 'A'), isFalse);
    });

    test('archived: bor bo‘lsa o‘qiladi, eski javobda false', () {
      expect(
        InstituteSummary.tryParse({'id': 'a', 'archived': true})!.archived,
        isTrue,
      );
      expect(InstituteSummary.tryParse({'id': 'a'})!.archived, isFalse);
      expect(
        InstituteExtension.tryParse({
          'result': 'OK',
          'term_end': '2027-12-10T00:00:00Z',
          'plans_extended': 2,
        })!.plansExtended,
        2,
      );
      expect(InstituteExtension.tryParse({'result': 'INVALID'}), isNull);
    });

    test('kod holatlari', () {
      final free = InstituteCode.tryParse({'n': 1, 'code': 'AAA'})!;
      final used = InstituteCode.tryParse({
        'n': 2,
        'code': 'BBB',
        'redeemed_at': '2026-11-02T00:00:00Z',
        'email': 'a@b.uz',
      })!;
      final revoked = InstituteCode.tryParse({
        'n': 3,
        'code': 'CCC',
        'revoked': true,
      })!;
      expect(free.status, InstituteCodeStatus.free);
      expect(used.status, InstituteCodeStatus.redeemed);
      expect(used.email, 'a@b.uz');
      expect(revoked.status, InstituteCodeStatus.revoked);
      expect(InstituteCode.tryParse({'n': 4}), isNull);
    });
  });

  group('SupabasePromoService', () {
    test('kirmagan foydalanuvchi — tarmoqqa chiqmaydi', () async {
      final t = _Transport((p, b) => const RestResponse(200, {}));
      final s = SupabasePromoService(
        config: _cfg,
        auth: MockAuthRepository(),
        transport: t,
      );
      expect((await s.redeemPromoCode('ABC')).failure, PlanFailure.notSignedIn);
      expect(t.calls, isEmpty);
    });

    test('redeem_promo_code: RPC nomi, parametr va javob', () async {
      final auth = await signedInMockAuth();
      final t = _Transport(
        (p, b) => const RestResponse(200, {
          'result': 'OK',
          'kind': 'gift',
          'label': 'sovg‘a: Ali',
          'until': '2027-01-01T00:00:00Z',
          'plan': 'teacher',
        }),
      );
      final s = SupabasePromoService(config: _cfg, auth: auth, transport: t);
      final r = await s.redeemPromoCode('A1B2');
      expect(t.calls.single.path, '/rest/v1/rpc/redeem_promo_code');
      expect(t.calls.single.body, {'p_code': 'A1B2'});
      expect(r.value!.result, PromoResult.ok);
      expect(r.value!.label, 'sovg‘a: Ali');
    });

    test('register_device / my_devices / remove_my_device', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((p, b) {
        if (p.endsWith('register_device')) {
          return const RestResponse(200, {
            'ok': false,
            'limit': 3,
            'devices': [
              {'hash': 'h1', 'label': 'Android', 'last_seen': null},
            ],
          });
        }
        if (p.endsWith('my_devices')) {
          return const RestResponse(200, [
            {'hash': 'h1', 'label': 'Android', 'last_seen': null},
          ]);
        }
        return const RestResponse(204, null);
      });
      final s = SupabasePromoService(config: _cfg, auth: auth, transport: t);
      final reg = await s.registerDevice(deviceHash: 'h0', label: 'iOS');
      expect(reg.value!.ok, isFalse);
      expect(t.calls.last.body, {'p_device_hash': 'h0', 'p_label': 'iOS'});
      expect((await s.myDevices()).value!.single.hash, 'h1');
      final rm = await s.removeMyDevice('h1');
      expect(rm.ok, isTrue);
      expect(t.calls.last.path, '/rest/v1/rpc/remove_my_device');
      expect(t.calls.last.body, {'p_device_hash': 'h1'});
    });

    test('server xatosi — PlanFailure.server', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((p, b) => const RestResponse(500, null));
      final s = SupabasePromoService(config: _cfg, auth: auth, transport: t);
      expect((await s.redeemPromoCode('X')).failure, PlanFailure.server);
    });
  });

  group('SupabaseAdminInstituteService', () {
    test('arxiv va uzaytirish: RPC nomlari va parametrlari', () async {
      final auth = await signedInMockAuth();
      final t = _Transport(
        (p, b) => p.endsWith('set_archived')
            ? const RestResponse(200, {'result': 'OK', 'archived': true})
            : const RestResponse(200, {
                'result': 'OK',
                'term_end': '2027-12-10T00:00:00Z',
                'plans_extended': 3,
              }),
      );
      final s = SupabaseAdminInstituteService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final a = await s.setArchived('i1', archived: true);
      expect(a.value, isTrue);
      expect(t.calls.last.path, '/rest/v1/rpc/admin_institute_set_archived');
      expect(t.calls.last.body, {'p_id': 'i1', 'p_archived': true});
      final e = await s.extend('i1', 3);
      expect(e.value!.plansExtended, 3);
      expect(t.calls.last.path, '/rest/v1/rpc/admin_institute_extend');
      expect(t.calls.last.body, {'p_id': 'i1', 'p_months': 3});
    });

    test('NOT_FOUND / INVALID — invalid xato', () async {
      final auth = await signedInMockAuth();
      final t = _Transport(
        (p, b) => const RestResponse(200, {'result': 'NOT_FOUND'}),
      );
      final s = SupabaseAdminInstituteService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      expect(
        (await s.setArchived('x', archived: false)).failure,
        PlanFailure.invalid,
      );
      expect((await s.extend('x', 1)).failure, PlanFailure.invalid);
    });

    test('admin_institute_create: parametrlar va kodlar', () async {
      final auth = await signedInMockAuth();
      final t = _Transport(
        (p, b) => const RestResponse(200, {
          'result': 'OK',
          'institute_id': 'i1',
          'codes': ['AAA', 'BBB'],
        }),
      );
      final s = SupabaseAdminInstituteService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final r = await s.create(
        const InstituteDraft(name: ' ADTI ', seats: 2, months: 12),
      );
      expect(t.calls.single.path, '/rest/v1/rpc/admin_institute_create');
      final body = t.calls.single.body! as Map;
      expect(body['p_name'], 'ADTI');
      expect(body['p_seats'], 2);
      expect(body['p_months'], 12);
      for (final k in [
        'p_price',
        'p_contract_no',
        'p_contract_date',
        'p_director',
        'p_phone',
        'p_stir',
        'p_bank',
        'p_account',
        'p_mfo',
        'p_address',
      ]) {
        expect(body.containsKey(k), isTrue, reason: k);
        expect(body[k], isNull, reason: k);
      }
      expect(r.value!.instituteId, 'i1');
      expect(r.value!.codes, ['AAA', 'BBB']);
    });

    test('INVALID → PlanFailure.invalid', () async {
      final auth = await signedInMockAuth();
      final t = _Transport(
        (p, b) => const RestResponse(200, {'result': 'INVALID'}),
      );
      final s = SupabaseAdminInstituteService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final r = await s.createGiftCodes(
        from: 'Ali',
        count: 1,
        days: 30,
        plan: Plan.teacher,
      );
      expect(t.calls.single.body, {
        'p_from': 'Ali',
        'p_count': 1,
        'p_days': 30,
        'p_plan': 'teacher',
      });
      expect(r.failure, PlanFailure.invalid);
    });

    test('list / codes / revoke', () async {
      final auth = await signedInMockAuth();
      final t = _Transport((p, b) {
        if (p.endsWith('admin_list_institutes')) {
          return const RestResponse(200, [
            {
              'id': 'i1',
              'name': 'ADTI',
              'seats': 10,
              'redeemed': 3,
              'revoked': 1,
              'term_end': '2027-11-04T00:00:00Z',
              'price_per_seat': 25000,
            },
          ]);
        }
        if (p.endsWith('admin_institute_codes')) {
          return const RestResponse(200, [
            {'n': 1, 'code': 'AAA', 'revoked': false},
          ]);
        }
        return const RestResponse(200, {'result': 'REVOKED'});
      });
      final s = SupabaseAdminInstituteService(
        config: _cfg,
        auth: auth,
        transport: t,
      );
      final list = (await s.list()).value!;
      expect(list.single.name, 'ADTI');
      expect(list.single.redeemed, 3);
      expect((await s.codes('i1')).value!.single.code, 'AAA');
      expect((await s.revokeCode('AAA')).value, isTrue);
    });
  });
}
