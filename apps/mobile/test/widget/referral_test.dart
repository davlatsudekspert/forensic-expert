import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/referral.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/share.dart';
import 'package:forensic_expert/app/user_data.dart';
import 'package:forensic_expert/domain/ports/referral_ports.dart';
import 'package:forensic_expert/domain/referral/referral_models.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';
import '../helpers/referral_fakes.dart';

void main() {
  testWidgets('Profil → «Hamkasbingizni taklif qiling» (kirmagan)', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
      overrides: [
        referralServiceProvider.overrideWithValue(FakeReferralService()),
      ],
    );
    final card = find.byKey(const Key('profile.invite'));
    expect(card, findsOneWidget);
    expect(find.text('Invite a colleague'), findsOneWidget);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('referral.header')), findsOneWidget);
    expect(find.byKey(const Key('referral.signIn')), findsOneWidget);
    // Kirmagan foydalanuvchi ham kodni kiritib qo‘ya oladi (lokal saqlanadi).
    expect(find.byKey(const Key('referral.claim')), findsOneWidget);
    expect(find.byKey(const Key('referral.code')), findsNothing);
  });

  testWidgets('backend ulanmagan — halol holat, soxta kod yo‘q', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.referral,
    );
    expect(find.byKey(const Key('referral.notConfigured')), findsOneWidget);
    expect(find.byKey(const Key('referral.code')), findsNothing);
    expect(find.byKey(const Key('referral.claim')), findsNothing);
  });

  testWidgets('kirgan: kod, statistika, 10% izohi, ulashish (native)', (
    tester,
  ) async {
    final share = RecordingShareService();
    final svc = FakeReferralService(
      dashboard: const ReferralDashboard(
        code: 'K7QH2MPX',
        joined: 3,
        verified: 2,
        pending: 1,
      ),
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.referral,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        referralServiceProvider.overrideWithValue(svc),
        shareServiceProvider.overrideWithValue(share),
      ],
    );
    expect(find.text('K7QH2MPX'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('referral.stats')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final stats = find.byKey(const Key('referral.stats'));
    for (final (v, label) in [
      ('3', 'Joined'),
      ('2', 'Verified'),
      ('1', 'Pending'),
      ('0.00', 'FORENSIC Credits'),
    ]) {
      expect(
        find.descendant(of: stats, matching: find.text(v)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: stats, matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(find.textContaining('10% of the purchase value'), findsOneWidget);
    expect(find.textContaining('not cash'), findsOneWidget);
    // Ommaviy domen sozlanmagan — soxta havola yo‘q, kod ulashiladi.
    expect(find.byKey(const Key('referral.noLink')), findsOneWidget);
    expect(find.byKey(const Key('referral.link')), findsNothing);
    // Yangi akkaunt, taklif hali yo‘q → kod kiritish ko‘rinadi.
    expect(find.byKey(const Key('referral.claim')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('referral.share')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('referral.share')));
    await tester.pumpAndSettle();
    expect(share.shared, hasLength(1));
    final (text, subject) = share.shared.single;
    expect(text, contains('K7QH2MPX'));
    expect(subject, 'Invitation to FORENSIC EXPERT');
    // Shaxsiy ma’lumot (email) ulashilmaydi.
    expect(text, isNot(contains('expert@lab.uz')));
  });

  testWidgets('taklif bilan kelgan akkaunt — kod kiritish yashiriladi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.referral,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        referralServiceProvider.overrideWithValue(
          FakeReferralService(
            dashboard: const ReferralDashboard(
              code: 'K7QH2MPX',
              hasReferrer: true,
            ),
          ),
        ),
      ],
    );
    expect(find.byKey(const Key('referral.linked')), findsOneWidget);
    expect(find.byKey(const Key('referral.claim')), findsNothing);
  });

  testWidgets('kod kiritish: o‘z kodi — server rad etadi, xabar ko‘rinadi', (
    tester,
  ) async {
    final svc = FakeReferralService(
      claimOutcome: ReferralClaimOutcome.selfReferral,
    );
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.referral,
      overrides: [
        authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        referralServiceProvider.overrideWithValue(svc),
      ],
    );
    final field = find.byKey(const Key('referral.codeField'));
    await tester.scrollUntilVisible(
      field,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(field, 'abc');
    await tester.tap(find.byKey(const Key('referral.apply')));
    await tester.pumpAndSettle();
    expect(find.textContaining('8-character code'), findsWidgets);
    expect(svc.claims, isEmpty);

    await tester.enterText(field, 'k7qh2mpx');
    await tester.tap(find.byKey(const Key('referral.apply')));
    await tester.pumpAndSettle();
    expect(svc.claims, ['K7QH2MPX']);
    expect(
      find.text('You can’t use your own invitation code.'),
      findsOneWidget,
    );
  });

  testWidgets('deep link /invite/<CODE>: kod saqlanadi → taklif sahifasi', (
    tester,
  ) async {
    final store = InMemoryPendingReferralStore();
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      overrides: [
        referralServiceProvider.overrideWithValue(FakeReferralService()),
        pendingReferralStoreProvider.overrideWithValue(store),
      ],
    );
    c.read(routerProvider).go('/invite/k7qh2mpx');
    await tester.pumpAndSettle();
    expect(store.value, 'K7QH2MPX');
    expect(find.byKey(const Key('referral.header')), findsOneWidget);
    final field = tester.widget<TextField>(
      find.byKey(const Key('referral.codeField')),
    );
    expect(field.controller!.text, 'K7QH2MPX');
  });

  testWidgets('deep link onboarding tugamaganda: kod saqlanadi, til ekrani', (
    tester,
  ) async {
    final store = InMemoryPendingReferralStore();
    final c = await pumpApp(
      tester,
      overrides: [pendingReferralStoreProvider.overrideWithValue(store)],
    );
    c.read(routerProvider).go('/invite/K7QH2MPX');
    await tester.pumpAndSettle();
    expect(store.value, 'K7QH2MPX');
    expect(
      c.read(routerProvider).routerDelegate.currentConfiguration.uri.path,
      Routes.language,
    );
  });

  testWidgets('noto‘g‘ri deep link kodi saqlanmaydi', (tester) async {
    final store = InMemoryPendingReferralStore();
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      overrides: [pendingReferralStoreProvider.overrideWithValue(store)],
    );
    c.read(routerProvider).go('/invite/0000');
    await tester.pumpAndSettle();
    expect(store.value, isNull);
  });

  for (final (lang, title) in [
    ('en', 'Invite a colleague'),
    ('ru', 'Пригласить коллегу'),
    ('uz', 'Hamkasbingizni taklif qiling'),
  ]) {
    testWidgets('lokalizatsiya: $lang', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        initialLocation: Routes.referral,
        overrides: [
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
          referralServiceProvider.overrideWithValue(FakeReferralService()),
        ],
      );
      expect(find.text(title), findsWidgets);
      expect(find.text('K7QH2MPX'), findsOneWidget);
    });
  }

  for (final width in [320.0, 360.0, 390.0, 430.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        testWidgets('moslashuv ${width.toInt()}dp × $scale × ${theme.name}', (
          tester,
        ) async {
          await pumpApp(
            tester,
            settings: completedSettings(theme: theme),
            size: Size(width, 800),
            textScale: scale,
            initialLocation: Routes.referral,
            overrides: [
              authRepositoryProvider.overrideWithValue(
                await signedInMockAuth(),
              ),
              referralServiceProvider.overrideWithValue(
                FakeReferralService(
                  dashboard: const ReferralDashboard(
                    code: 'K7QH2MPX',
                    joined: 12,
                    verified: 10,
                    pending: 2,
                    creditsEarnedMinor: 123456,
                  ),
                ),
              ),
            ],
          );
          expect(tester.takeException(), isNull);
          final list = find.byKey(const Key('referral.list'));
          await tester.drag(list, const Offset(0, -2000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  group('Home: birinchi qadamlar va taklif', () {
    testWidgets('karta ko‘rinadi, yashirish ishlaydi (lokal)', (tester) async {
      final c = await pumpApp(tester, settings: completedSettings());
      expect(find.byKey(const Key('home.firstSteps')), findsOneWidget);
      expect(find.text('0 of 5 done'), findsOneWidget);
      await c.read(userDataProvider.notifier).recordSearch('morphine');
      await c.read(userDataProvider.notifier).toggleFavorite('morphine');
      await tester.pumpAndSettle();
      expect(find.text('2 of 5 done'), findsOneWidget);
      await tester.tap(find.byKey(const Key('home.firstSteps.hide')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home.firstSteps')), findsNothing);
      expect(c.read(userDataProvider).milestones, contains('hidden'));
    });

    testWidgets('fan bo‘limi / AI ochilganda qadam belgilanadi', (
      tester,
    ) async {
      final c = await pumpApp(tester, settings: completedSettings());
      c.read(routerProvider).go(Routes.ai);
      await tester.pumpAndSettle();
      c.read(routerProvider).go(Routes.forensicMedicine);
      await tester.pumpAndSettle();
      expect(
        c.read(userDataProvider).milestones,
        containsAll(['ai', 'discipline']),
      );
    });

    testWidgets('Home’da sokin taklif kartasi bor', (tester) async {
      await pumpApp(tester, settings: completedSettings());
      final invite = find.byKey(const Key('home.invite'));
      await tester.scrollUntilVisible(
        invite,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(invite, findsOneWidget);
    });

    test('birinchi qadam yo‘llari', () {
      expect(
        firstStepFor('/home/disciplines/forensicToxicology'),
        'discipline',
      );
      expect(firstStepFor('/library/source/SRC-1'), 'source');
      expect(firstStepFor('/home/research/R1'), 'source');
      expect(firstStepFor(Routes.ai), 'ai');
      expect(firstStepFor(Routes.disciplines), 'discipline');
      expect(firstStepFor(Routes.module('toxicology')), 'discipline');
      expect(firstStepFor(Routes.home), isNull);
    });
  });

  group('Ilmiy yozuvni ulashish', () {
    late PilotContent pilot;
    setUpAll(() async => pilot = await loadPilotContent());

    testWidgets('manba sahifasi: bibliografiya + DOI, shaxsiy ma’lumot yo‘q', (
      tester,
    ) async {
      final share = RecordingShareService();
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.source('SRC-PMC8400298'),
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          shareServiceProvider.overrideWithValue(share),
          authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
        ],
      );
      await tester.tap(find.byKey(const Key('share.record')));
      await tester.pumpAndSettle();
      final text = share.shared.single.$1;
      expect(text, contains('https://doi.org/'));
      expect(text, contains('Verify against the original source'));
      expect(text, isNot(contains('@')));
    });

    testWidgets('modda sahifasi: nom va manbalar', (tester) async {
      final share = RecordingShareService();
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.libraryEntry('morphine'),
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          shareServiceProvider.overrideWithValue(share),
        ],
      );
      await settleImages(tester);
      await tester.tap(find.byKey(const Key('share.record')));
      await tester.pumpAndSettle();
      final text = share.shared.single.$1;
      expect(text.split('\n').first, 'Morphine');
      expect(text, contains('Sources:'));
    });

    testWidgets('saqlash: animatsiya + tasdiq xabari', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.libraryEntry('morphine'),
        testFixtures: false,
        overrides: pilot.overrides,
      );
      await settleImages(tester);
      await tester.tap(find.byKey(const Key('favorite.morphine')));
      await tester.pumpAndSettle();
      expect(find.text('Saved to your library'), findsOneWidget);
    });
  });
}
