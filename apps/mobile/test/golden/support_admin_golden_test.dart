import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/account.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/support.dart';
import 'package:forensic_expert/data/support/in_memory_support_service.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/support/support_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';
import '../helpers/support_fakes.dart';

/// «Taklif va murojaatlar» va admin panel — skrinshot QA. Barcha murojaat,
/// statistika va foydalanuvchilar FIXTURE (soxta xizmat; server ma’lumoti emas).
void main() {
  InMemorySupportService seeded({bool admin = false}) {
    final s = InMemorySupportService(isAdmin: admin, stats: fixtureAdminStats)
      ..users.addAll(fixtureAdminUsers);
    final a = s.seedThread(
      category: SupportCategory.scientificError,
      subject: 'Morfin: yarim chiqarilish davri',
      body: 'Kartadagi qiymat keltirilgan manbadagidan farq qiladi.',
      relatedEntity: 'substance:morphine',
      mine: true,
    );
    s.simulateAdminReply(
      a,
      'Rahmat! Manbani tekshirdik — keyingi kontent yangilanishida tuzatiladi.',
    );
    s.seedThread(
      category: SupportCategory.suggestion,
      subject: 'Tungi navbat uchun qorong‘i mavzu',
      body: 'Laboratoriyada kechasi ishlash uchun to‘qroq mavzu kerak.',
      mine: true,
    );
    s.seedThread(
      category: SupportCategory.bug,
      subject: 'Qidiruvda ilova yopilib qoladi',
      body: '«morfin» yozilganda ilova yopiladi (Android 14).',
      authorEmail: 'student@univ.test',
    );
    return s;
  }

  final cases =
      <({String name, String route, ThemeMode theme, bool admin, Size size})>[
        (
          name: 'support_01_inbox_uz',
          route: Routes.support,
          theme: ThemeMode.light,
          admin: false,
          size: const Size(390, 844),
        ),
        (
          name: 'support_02_thread_dark_uz',
          route: Routes.supportThread('thread-1'),
          theme: ThemeMode.dark,
          admin: false,
          size: const Size(390, 844),
        ),
        (
          name: 'admin_01_dashboard_uz',
          route: Routes.admin,
          theme: ThemeMode.light,
          admin: true,
          size: const Size(390, 844),
        ),
        (
          name: 'admin_02_users_tablet_uz',
          route: Routes.adminUsers,
          theme: ThemeMode.light,
          admin: true,
          size: const Size(834, 1112),
        ),
      ];

  for (final c in cases) {
    testWidgets(c.name, (tester) async {
      final svc = seeded(admin: c.admin);
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', theme: c.theme),
        platformBrightness: c.theme == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
        size: c.size,
        initialLocation: c.route,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          entitlementServiceProvider.overrideWithValue(
            FakeStore(withOffers: false),
          ),
          accountServiceProvider.overrideWithValue(
            FakeAccountService(access: ServerAccess(isAdmin: c.admin)),
          ),
          supportServiceProvider.overrideWithValue(svc),
        ],
      );
      await settleImages(tester);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${c.name}.png'),
      );
    });
  }
}
