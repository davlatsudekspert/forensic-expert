// Admin «Tashkilotlar»: ro‘yxat, yangi tashkilot (nom + o‘rinlar + muddat),
// promokodlar, bekor qilish, sovg‘a promokod.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/institutes.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/plan/fake_institute_service.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/admin/institute_models.dart';
import 'package:forensic_expert/domain/ports/plan_ports.dart';

import '../helpers/pump_app.dart';

final _inst = InstituteDetail(
  id: 'i1',
  name: 'ADTI',
  seats: 3,
  months: 12,
  termStart: DateTime(2026, 11, 10),
  termEnd: DateTime(2027, 11, 10),
);

void main() {
  late FakeAdminInstituteService svc;

  Future<void> open(
    WidgetTester tester,
    String location, {
    bool admin = true,
    bool seed = true,
  }) async {
    svc = FakeAdminInstituteService();
    if (seed) {
      svc.seed(_inst, [
        const InstituteCode(n: 1, code: 'AAAA111111', revoked: false),
        InstituteCode(
          n: 2,
          code: 'BBBB222222',
          revoked: false,
          redeemedAt: DateTime(2026, 11, 12),
          email: 'ali@lab.uz',
        ),
        const InstituteCode(n: 3, code: 'CCCC333333', revoked: true),
      ]);
    }
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      size: const Size(390, 1600),
      initialLocation: location,
      overrides: [
        serverAccessProvider.overrideWith(
          (ref) async => ServerAccess(isAdmin: admin),
        ),
        adminDashboardProvider.overrideWith(
          (ref) async => const AdminDashboard(totals: {}),
        ),
        adminInstituteServiceProvider.overrideWithValue(svc),
      ],
    );
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String key, String text) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.enterText(f, text);
    await tester.pump();
  }

  group('faqat admin', () {
    for (final loc in [
      Routes.adminInstitutes,
      Routes.adminInstituteNew,
      Routes.adminGiftCodes,
      Routes.adminInstitute('i1'),
    ]) {
      testWidgets('admin emas: $loc ochilmaydi', (tester) async {
        await open(tester, loc, admin: false);
        expect(find.byKey(const Key('admin.forbidden')), findsOneWidget);
        expect(find.byKey(const Key('adminInst.list')), findsNothing);
        expect(find.byKey(const Key('adminInstForm.list')), findsNothing);
        expect(find.byKey(const Key('adminInstDetail.list')), findsNothing);
        expect(find.text('AAAA111111'), findsNothing);
      });
    }

    testWidgets('oddiy foydalanuvchi profilida admin bo‘limi yo‘q', (
      tester,
    ) async {
      await open(tester, Routes.profile, admin: false);
      expect(find.byKey(const Key('profile.admin')), findsNothing);
      expect(find.text('Tashkilotlar'), findsNothing);
    });

    testWidgets('admin panelda «Tashkilotlar» bo‘limi bor', (tester) async {
      await open(tester, Routes.admin);
      await tester.ensureVisible(find.byKey(const Key('admin.nav.institutes')));
      expect(find.byKey(const Key('admin.nav.institutes')), findsOneWidget);
    });
  });

  group('ro‘yxat va yangi tashkilot', () {
    testWidgets('ro‘yxat: nomi, o‘rinlar, ishlatilgan, tugash sanasi', (
      tester,
    ) async {
      await open(tester, Routes.adminInstitutes);
      expect(find.byKey(const Key('adminInst.row.i1')), findsOneWidget);
      expect(find.text('ADTI'), findsOneWidget);
      expect(find.text('O‘rinlar: 3 · ishlatilgan: 1'), findsOneWidget);
      expect(find.textContaining('gacha'), findsOneWidget);
    });

    testWidgets('forma: faqat nom, o‘rinlar, muddat va boshlanish sanasi', (
      tester,
    ) async {
      await open(tester, Routes.adminInstituteNew, seed: false);
      for (final k in ['name', 'seats', 'months']) {
        expect(find.byKey(Key('adminInstForm.$k')), findsOneWidget);
      }
      expect(find.byKey(const Key('adminInstForm.termStart')), findsOneWidget);
      for (final k in [
        'price',
        'total',
        'address',
        'stir',
        'bank',
        'account',
        'mfo',
        'director',
        'phone',
        'contractNo',
        'contractDate',
      ]) {
        expect(find.byKey(Key('adminInstForm.$k')), findsNothing, reason: k);
      }
    });

    testWidgets('noto‘g‘ri forma: xato, serverga so‘rov yo‘q', (tester) async {
      await open(tester, Routes.adminInstituteNew, seed: false);
      await type(tester, 'adminInstForm.name', 'ADTI');
      await tapKey(tester, 'adminInstForm.save');
      expect(find.byKey(const Key('adminInstForm.error')), findsOneWidget);
      expect(svc.calls.where((c) => c.startsWith('create')), isEmpty);
    });

    testWidgets('saqlash: kodlar ro‘yxati ochiq, nusxalash tugmalari bor', (
      tester,
    ) async {
      await open(tester, Routes.adminInstituteNew, seed: false);
      await type(tester, 'adminInstForm.name', 'ADTI');
      await type(tester, 'adminInstForm.seats', '3');
      await type(tester, 'adminInstForm.months', '12');
      await tapKey(tester, 'adminInstForm.save');
      expect(svc.calls, contains('create:ADTI:3'));
      expect(find.byKey(const Key('adminInstForm.created')), findsOneWidget);
      expect(
        find.text('Tashkilot saqlandi. 3 ta promokod tayyorlandi.'),
        findsOneWidget,
      );
      for (var i = 1; i <= 3; i++) {
        expect(find.byKey(Key('adminInstForm.codes.row.$i')), findsOneWidget);
        expect(find.byKey(Key('adminInstForm.codes.copy.$i')), findsOneWidget);
      }
    });

    testWidgets('kodni nusxalash buferga yoziladi', (tester) async {
      String? clip;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clip = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await open(tester, Routes.adminInstitute('i1'));
      await tapKey(tester, 'adminInstDetail.copy.1');
      expect(clip, 'AAAA111111');
      await tapKey(tester, 'adminInstDetail.copyAll');
      expect(clip, 'AAAA111111');
    });
  });

  group('tashkilot sahifasi', () {
    testWidgets('kodlar jadvali: bo‘sh / ishlatilgan+email / bekor', (
      tester,
    ) async {
      await open(tester, Routes.adminInstitute('i1'));
      expect(find.text('AAAA111111'), findsOneWidget);
      expect(find.text('Bo‘sh'), findsOneWidget);
      expect(find.text('Ishlatilgan: ali@lab.uz'), findsOneWidget);
      expect(find.text('Bekor qilingan'), findsOneWidget);
      expect(
        find.text('O‘rinlar: 3 · ishlatilgan: 1 · bekor: 1'),
        findsOneWidget,
      );
      // Bekor qilish faqat bo‘sh kodda.
      expect(find.byKey(const Key('adminInstDetail.revoke.1')), findsOneWidget);
      expect(find.byKey(const Key('adminInstDetail.revoke.2')), findsNothing);
      expect(find.byKey(const Key('adminInstDetail.revoke.3')), findsNothing);
    });

    testWidgets('kodni bekor qilish: tasdiq → holat o‘zgaradi', (tester) async {
      await open(tester, Routes.adminInstitute('i1'));
      await tapKey(tester, 'adminInstDetail.revoke.1');
      expect(find.text('Promokod bekor qilinsinmi?'), findsOneWidget);
      await tapKey(tester, 'adminInst.revoke.yes');
      expect(svc.calls, contains('revoke:AAAA111111'));
      expect(find.text('Promokod bekor qilindi.'), findsOneWidget);
      expect(find.text('Bekor qilingan'), findsNWidgets(2));
      expect(find.byKey(const Key('adminInstDetail.revoke.1')), findsNothing);
    });

    testWidgets('bekor qilmaslik: so‘rov yo‘q', (tester) async {
      await open(tester, Routes.adminInstitute('i1'));
      await tapKey(tester, 'adminInstDetail.revoke.1');
      await tapKey(tester, 'adminInst.revoke.no');
      expect(svc.calls.where((c) => c.startsWith('revoke')), isEmpty);
    });
  });

  group('arxiv va uzaytirish', () {
    testWidgets('arxivga olish: tasdiq matni, bo‘lim, qaytarish', (
      tester,
    ) async {
      await open(tester, Routes.adminInstitute('i1'));
      expect(find.byKey(const Key('adminInstDetail.restore')), findsNothing);
      await tapKey(tester, 'adminInstDetail.archive');
      expect(
        find.text(
          'Arxivlangan tashkilot kodlari yangi foydalanuvchiga ishlamaydi. '
          'Mavjud a’zolar muddati tugaguncha qoladi. Hech narsa o‘chirilmaydi.',
        ),
        findsOneWidget,
      );
      await tapKey(tester, 'adminInst.archive.yes');
      expect(svc.calls, contains('archive:i1:true'));
      expect(find.text('Tashkilot arxivga olindi.'), findsOneWidget);
      expect(find.byKey(const Key('adminInstDetail.restore')), findsOneWidget);
      expect(find.byKey(const Key('adminInstDetail.archive')), findsNothing);
      // Arxivda ham uzaytirish ishlaydi.
      expect(find.byKey(const Key('adminInstDetail.extend')), findsOneWidget);
      await tapKey(tester, 'adminInstDetail.restore');
      expect(svc.calls, contains('archive:i1:false'));
      expect(find.text('Tashkilot arxivdan qaytarildi.'), findsOneWidget);
      expect(find.byKey(const Key('adminInstDetail.archive')), findsOneWidget);
    });

    testWidgets('tasdiqlamasa: so‘rov yo‘q', (tester) async {
      await open(tester, Routes.adminInstitute('i1'));
      await tapKey(tester, 'adminInstDetail.archive');
      await tapKey(tester, 'adminInst.archive.no');
      expect(svc.calls.where((c) => c.startsWith('archive')), isEmpty);
    });

    testWidgets('arxiv bo‘limi: yig‘ilgan, ochilganda xiralashgan qator', (
      tester,
    ) async {
      svc = FakeAdminInstituteService();
      svc.seed(_inst, const []);
      svc.seed(
        const InstituteDetail(id: 'i2', name: 'Eski', seats: 1, months: 1),
        const [],
      );
      await svc.setArchived('i2', archived: true);
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        size: const Size(390, 1600),
        initialLocation: Routes.adminInstitutes,
        overrides: [
          serverAccessProvider.overrideWith(
            (ref) async => const ServerAccess(isAdmin: true),
          ),
          adminInstituteServiceProvider.overrideWithValue(svc),
        ],
      );
      expect(find.byKey(const Key('adminInst.row.i1')), findsOneWidget);
      expect(find.byKey(const Key('adminInst.row.i2')), findsNothing);
      expect(find.text('Arxivdagilar (1)'), findsOneWidget);
      await tapKey(tester, 'adminInst.archivedToggle');
      expect(find.byKey(const Key('adminInst.row.i2')), findsOneWidget);
      expect(find.byKey(const Key('adminInst.badge.i2')), findsOneWidget);
      expect(find.text('Arxivda'), findsOneWidget);
      await tapKey(tester, 'adminInst.row.i2');
      expect(find.byKey(const Key('adminInstDetail.restore')), findsOneWidget);
    });

    testWidgets('uzaytirish: tanlov, yangi sana va xabar', (tester) async {
      await open(tester, Routes.adminInstitute('i1'));
      await tapKey(tester, 'adminInstDetail.extend');
      for (final m in [1, 3, 6, 12]) {
        expect(find.byKey(Key('adminInst.extend.m.$m')), findsOneWidget);
      }
      await tester.tap(find.byKey(const Key('adminInst.extend.m.3')));
      await tester.pump();
      await tapKey(tester, 'adminInst.extend.yes');
      expect(svc.calls, contains('extend:i1:3'));
      expect(
        find.textContaining(
          'Kod kiritgan ustozlarning muddati ham yangilandi (1).',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Muddat uzaytirildi:'), findsOneWidget);
      expect(find.textContaining('2028'), findsWidgets);
    });

    testWidgets('xato: tushunarli xabar', (tester) async {
      await open(tester, Routes.adminInstitute('i1'));
      svc.actionFailure = PlanFailure.server;
      await tapKey(tester, 'adminInstDetail.extend');
      await tapKey(tester, 'adminInst.extend.yes');
      expect(
        find.text('Amalni bajarib bo‘lmadi. Qayta urinib ko‘ring.'),
        findsOneWidget,
      );
    });

    testWidgets('admin emas: arxiv/uzaytirish tugmalari ko‘rinmaydi', (
      tester,
    ) async {
      await open(tester, Routes.adminInstitute('i1'), admin: false);
      expect(find.byKey(const Key('adminInstDetail.archive')), findsNothing);
      expect(find.byKey(const Key('adminInstDetail.extend')), findsNothing);
    });

    for (final lang in ['uz', 'ru', 'en']) {
      for (final w in [320.0, 360.0]) {
        testWidgets('overflow yo‘q: $lang $w', (tester) async {
          svc = FakeAdminInstituteService();
          svc.seed(_inst, const []);
          await pumpApp(
            tester,
            settings: completedSettings(lang: lang),
            size: Size(w, 900),
            initialLocation: Routes.adminInstitute('i1'),
            overrides: [
              serverAccessProvider.overrideWith(
                (ref) async => const ServerAccess(isAdmin: true),
              ),
              adminInstituteServiceProvider.overrideWithValue(svc),
            ],
          );
          await tapKey(tester, 'adminInstDetail.extend');
          expect(tester.takeException(), isNull);
          await tapKey(tester, 'adminInst.extend.yes');
          expect(tester.takeException(), isNull);
          await tapKey(tester, 'adminInstDetail.archive');
          expect(tester.takeException(), isNull);
          await tapKey(tester, 'adminInst.archive.yes');
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('sovg‘a promokod', () {
    testWidgets('tayyorlash: promokodlar ko‘rinadi', (tester) async {
      await open(tester, Routes.adminGiftCodes, seed: false);
      await type(tester, 'adminGift.from', 'Ali Valiyev');
      await type(tester, 'adminGift.count', '2');
      await type(tester, 'adminGift.days', '90');
      await tapKey(tester, 'adminGift.plan.premium');
      await tapKey(tester, 'adminGift.create');
      expect(svc.calls, contains('gift:Ali Valiyev:2:90:premium'));
      expect(find.text('2 ta promokod tayyorlandi.'), findsOneWidget);
      expect(find.byKey(const Key('adminGift.codes.row.2')), findsOneWidget);
    });

    testWidgets('soni 1–50 dan tashqarida: xato', (tester) async {
      await open(tester, Routes.adminGiftCodes, seed: false);
      await type(tester, 'adminGift.from', 'Ali');
      await type(tester, 'adminGift.count', '51');
      await tapKey(tester, 'adminGift.create');
      expect(find.byKey(const Key('adminGift.error')), findsOneWidget);
      expect(svc.calls.where((c) => c.startsWith('gift')), isEmpty);
    });
  });
}
