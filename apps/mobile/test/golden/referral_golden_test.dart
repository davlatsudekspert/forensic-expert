import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/referral.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/referral/referral_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

/// «Hamkasbingizni taklif qiling», birinchi qadamlar va ulashish —
/// skrinshot QA. Referral sonlari FIXTURE (soxta xizmat; serverdagi haqiqiy
/// ma’lumot emas). Nusxa: `docs/screenshots/referral/`.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  const dashboard = ReferralDashboard(
    code: 'K7QH2MPX',
    joined: 3,
    verified: 2,
    pending: 1,
  );

  Future<List<Override>> signedIn() async => [
    authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
    referralServiceProvider.overrideWithValue(
      FakeReferralService(dashboard: dashboard),
    ),
  ];

  final cases =
      <
        ({
          String name,
          AppSettings settings,
          String route,
          Size size,
          double scale,
          bool auth,
          Key? scrollTo,
        })
      >[
        (
          name: 'ref_01_invite_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.referral,
          size: const Size(390, 844),
          scale: 1,
          auth: true,
          scrollTo: null,
        ),
        (
          name: 'ref_02_invite_stats_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.referral,
          size: const Size(390, 844),
          scale: 1,
          auth: true,
          scrollTo: const Key('referral.claim'),
        ),
        (
          name: 'ref_03_invite_dark_ru',
          settings: completedSettings(lang: 'ru', theme: ThemeMode.dark),
          route: Routes.referral,
          size: const Size(390, 844),
          scale: 1,
          auth: true,
          scrollTo: null,
        ),
        (
          name: 'ref_04_invite_signed_out_en',
          settings: completedSettings(),
          route: Routes.referral,
          size: const Size(390, 844),
          scale: 1,
          auth: false,
          scrollTo: null,
        ),
        (
          name: 'ref_05_invite_320_x2_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.referral,
          size: const Size(320, 640),
          scale: 2,
          auth: true,
          scrollTo: null,
        ),
        (
          name: 'ref_06_home_first_steps_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.home,
          size: const Size(390, 844),
          scale: 1,
          auth: false,
          scrollTo: null,
        ),
        (
          name: 'ref_07_profile_invite_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.profile,
          size: const Size(390, 844),
          scale: 1,
          auth: false,
          scrollTo: null,
        ),
        (
          name: 'ref_08_home_invite_en_dark',
          settings: completedSettings(theme: ThemeMode.dark),
          route: Routes.home,
          size: const Size(390, 844),
          scale: 1,
          auth: false,
          scrollTo: const Key('home.invite'),
        ),
        (
          name: 'ref_09_source_share_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.source('SRC-PMC8400298'),
          size: const Size(390, 844),
          scale: 1,
          auth: false,
          scrollTo: null,
        ),
      ];

  for (final c in cases) {
    testWidgets(c.name, (tester) async {
      await pumpApp(
        tester,
        settings: c.settings,
        size: c.size,
        textScale: c.scale,
        initialLocation: c.route,
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          entitlementServiceProvider.overrideWithValue(
            FakeStore(withOffers: false),
          ),
          if (c.auth)
            ...await signedIn()
          else
            referralServiceProvider.overrideWithValue(FakeReferralService()),
        ],
      );
      await settleImages(tester);
      final target = c.scrollTo;
      if (target != null) {
        await tester.scrollUntilVisible(
          find.byKey(target),
          300,
          scrollable: find.byType(Scrollable).hitTestable().first,
        );
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${c.name}.png'),
      );
    });
  }
}
