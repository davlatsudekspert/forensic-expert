// TEST DATA — fixture nomlari; ilmiy qiymat yo‘q. Shaxsiy ma’lumotlar sun’iy.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/user_data.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:forensic_expert/features/home/presentation/search_screen.dart';
import 'package:forensic_expert/features/learn/presentation/learn_screens.dart';
import 'package:forensic_expert/features/legal/presentation/jurisdiction_screens.dart';
import 'package:forensic_expert/features/library/presentation/entry_detail_screen.dart';
import 'package:forensic_expert/features/profile/presentation/paywall_screen.dart';

import '../helpers/fake_store.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  group('Global Search', () {
    testWidgets('guruhlangan natijalar, tarix va tozalash', (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.search,
      );
      await tester.enterText(find.byKey(const Key('search.field')), 'Etanol');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('search.hit.TEST-SUB-ETOH')), findsOneWidget);
      // «Rejalashtirilgan» tashqi qidiruv bloki ko‘rsatilmaydi.
      expect(find.byKey(const Key('search.external')), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(c.read(userDataProvider).recentSearches, ['Etanol']);

      await tester.enterText(find.byKey(const Key('search.field')), '');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('search.recent')), findsOneWidget);
      await tester.tap(find.text('Clear history'));
      await tester.pumpAndSettle();
      expect(c.read(userDataProvider).recentSearches, isEmpty);
      expect(find.byKey(const Key('search.recent')), findsNothing);
    });

    testWidgets('natija yo‘q holati', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.searchWith('zzzzqqqxx'),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('search.noResults')), findsOneWidget);
    });

    testWidgets('Home qidiruvi qidiruv ekranini ochadi', (tester) async {
      await pumpApp(tester, settings: completedSettings());
      await tapKey(tester, 'home.search');
      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });

  group('Vositalar', () {
    testWidgets('C₁V₁ kalkulyatori: hisoblash va so‘nggi vositalar', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.tool('tool.lab.dilution'),
      );
      expect(c.read(userDataProvider).recentTools, ['tool.lab.dilution']);
      Future<void> enter(String field, String v) async {
        final f = find.descendant(
          of: find.byKey(Key('calc.field.$field')),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(f);
        await tester.enterText(f, v);
      }

      // Noma’lum: V₁. Sof algebra (ilmiy qiymat emas).
      await enter('c1', '10');
      await enter('c2', '1');
      await enter('v2', '10');
      await tapKey(tester, 'calc.calculate');
      final result = tester.widget<Text>(find.byKey(const Key('calc.result')));
      expect(result.data, contains('1'));
      expect(result.data, contains('mL'));
    });

    testWidgets('noto‘g‘ri kiritish — xato, natija yo‘q', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.tool('tool.lab.dilution'),
      );
      await tapKey(tester, 'calc.calculate');
      expect(find.byKey(const Key('calc.result')), findsNothing);
    });

    testWidgets('saralanganlar Home’da ko‘rinadi', (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.tools,
      );
      await tapKey(tester, 'favorite.tool.lab.dilution');
      expect(c.read(userDataProvider).favorites, ['tool.lab.dilution']);
      c.read(routerProvider).go(Routes.home);
      await tester.pumpAndSettle();
      final fav = find.byKey(const Key('home.favorites'));
      await tester.ensureVisible(fav);
      expect(
        find.descendant(of: fav, matching: find.textContaining('Dilution')),
        findsOneWidget,
      );
    });
  });

  group('Forensic AI prototipi', () {
    testWidgets('PII jonli aniqlanadi; real API yo‘q', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.ai,
      );
      expect(find.byKey(const Key('ai.piiWarning')), findsOneWidget);
      expect(find.byKey(const Key('ai.piiDetected')), findsNothing);
      await tester.enterText(
        find.byKey(const Key('ai.input')),
        'Testov Test Testovich, case #12',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ai.piiDetected')), findsOneWidget);
      // Javob namunasi iqtiboslar bilan ko‘rsatiladi.
      await tester.ensureVisible(find.byKey(const Key('ai.answerPreview')));
      expect(find.byKey(const Key('ai.answerPreview')), findsOneWidget);
    });
  });

  group('Kutubxona va yurisdiksiya qatlami', () {
    testWidgets(
      'modda kartochkasi: TEST DATA, ilmiy va huquqiy qatlam alohida',
      (tester) async {
        await pumpApp(
          tester,
          settings: completedSettings(),
          initialLocation: Routes.libraryEntry('TEST-SUB-ETOH'),
        );
        expect(find.byType(EntryDetailScreen), findsOneWidget);
        expect(find.text('SAMPLE'), findsWidgets);
        final sci = find.byKey(const Key('entry.layer.scientific'));
        final jur = find.byKey(const Key('entry.layer.jurisdiction'));
        await tester.ensureVisible(sci);
        expect(sci, findsOneWidget);
        await tester.ensureVisible(jur);
        expect(jur, findsOneWidget);
        // Ilmiy qatlam yurisdiksiya blokidan oldin va undan tashqarida.
        expect(find.descendant(of: jur, matching: sci), findsNothing);
        expect(tester.getTopLeft(sci).dy, lessThan(tester.getTopLeft(jur).dy));
        expect(
          find.descendant(
            of: jur,
            matching: find.textContaining('Jurisdiction layer: International'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('yurisdiksiya tanlash Profil va kartochkaga ta’sir qiladi', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profile,
      );
      await tapKey(tester, 'profile.jurisdiction');
      // PHASE 6: global tanlovchi (249 ISO davlati). «Compare
      // jurisdictions» endi «Huquq va yurisdiksiyalar» hub’ida (PHASE 4 dan
      // beri ishlaydi) — tanlovchidagi o‘chirilgan yozuv olib tashlandi.
      expect(find.byType(JurisdictionSelectScreen), findsOneWidget);
      // 249 davlat — lazy ro‘yxat: avval qidiruv, keyin tanlash.
      await tester.enterText(
        find.byKey(const Key('jurisdictions.search')),
        'Uzbek',
      );
      await tester.pumpAndSettle();
      await tapKey(tester, 'picker.jurisdiction.UZ');
      expect(c.read(settingsControllerProvider).jurisdictionId, 'UZ');
      await tester.scrollUntilVisible(
        find.text('Uzbekistan'),
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(find.text('Uzbekistan'), findsOneWidget);

      c.read(routerProvider).go(Routes.libraryEntry('TEST-SUB-ETOH'));
      await tester.pumpAndSettle();
      final jur = find.byKey(const Key('entry.layer.jurisdiction'));
      await tester.ensureVisible(jur);
      expect(
        find.descendant(
          of: jur,
          matching: find.textContaining('Jurisdiction layer: Uzbekistan'),
        ),
        findsOneWidget,
      );
      // Qonun yuklanmagan — halol bo‘sh holat, uydirma maqom yo‘q.
      expect(
        find.descendant(
          of: jur,
          matching: find.textContaining('No legal or procedural content'),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('noma’lum saqlangan yurisdiksiya xalqaroga qaytadi', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings().copyWith(jurisdictionId: 'XX'),
        initialLocation: Routes.profile,
      );
      expect(find.text('International'), findsOneWidget);
    });
  });

  group('Profil, obuna, rejim', () {
    testWidgets('Paywall: store yo‘q — narx yo‘q, tugmalar o‘chiq', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.purchase,
      );
      expect(find.byType(PaywallScreen), findsOneWidget);
      expect(find.text('Plans'), findsWidgets);
      expect(
        find.byKey(const Key('purchase.storeUnavailable')),
        findsOneWidget,
      );
      for (final t in ['free', 'studentPro', 'professionalPro']) {
        expect(find.byKey(Key('paywall.tier.$t')), findsOneWidget);
      }
      expect(find.byKey(const Key('paywall.tier.institution')), findsNothing);
      for (final t in ['studentPro', 'professionalPro']) {
        final b = find.byKey(Key('paywall.buyDisabled.$t'));
        await tester.ensureVisible(b);
        expect(tester.widget<FilledButton>(b).onPressed, isNull);
        expect(find.byKey(Key('paywall.noPrice.$t')), findsOneWidget);
      }
      // Narx kodda yo‘q: hech qanday valyuta belgisi ko‘rinmaydi.
      for (final banned in [r'$', '€', '£', 'Lifetime', 'One-time']) {
        expect(find.textContaining(banned), findsNothing, reason: banned);
      }
      await tester.ensureVisible(find.byKey(const Key('purchase.restore')));
      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.byKey(const Key('purchase.terms')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('purchase.aiNote')));
      expect(find.byKey(const Key('purchase.aiNote')), findsOneWidget);
    });

    testWidgets('Paywall: narx va davr store’dan; xarid tanlangan mahsulot', (
      tester,
    ) async {
      final store = FakeStore(price: 'TEST-PRICE 1.00');
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.purchase,
        overrides: [entitlementServiceProvider.overrideWithValue(store)],
      );
      expect(find.byKey(const Key('purchase.storeUnavailable')), findsNothing);
      expect(find.text('TEST-PRICE 1.00 · Monthly'), findsNWidgets(2));
      expect(find.text('TEST-PRICE 1.00 · Yearly'), findsNWidgets(2));
      final buy = find.byKey(
        const Key('paywall.buy.${ProductIds.studentYearly}'),
      );
      await tester.ensureVisible(buy);
      await tester.pumpAndSettle();
      await tester.tap(buy);
      await tester.pumpAndSettle();
      expect(store.purchased, [ProductIds.studentYearly]);
      expect(find.text('Purchase cancelled.'), findsOneWidget);
    });

    testWidgets('Professional Pro egasi: joriy tarif, boshqarish, Profil', (
      tester,
    ) async {
      final store = FakeStore(owned: true);
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.purchase,
        overrides: [entitlementServiceProvider.overrideWithValue(store)],
      );
      expect(
        find.byKey(const Key('paywall.current.professionalPro')),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byKey(const Key('purchase.manage')));
      expect(find.byKey(const Key('purchase.manage')), findsOneWidget);
      c.read(routerProvider).go(Routes.profile);
      await tester.pumpAndSettle();
      final row = find.byKey(const Key('profile.purchase'));
      await tester.ensureVisible(row);
      expect(
        find.descendant(of: row, matching: find.text('Professional Pro')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('profile.subscriptionStatus')),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Delete Account akkaunt yo‘qligida ko‘rinmaydi', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profile,
      );
      expect(find.byKey(const Key('profile.deleteAccount')), findsNothing);
      for (final key in [
        'profile.language',
        'profile.mode',
        'profile.jurisdiction',
        'profile.theme',
        'profile.contrast',
        'profile.purchase',
        'profile.privacy',
        'profile.terms',
        'profile.disclaimer',
        'profile.licenses',
        'profile.about',
      ]) {
        await tester.ensureVisible(find.byKey(Key(key)));
        expect(find.byKey(Key(key)), findsOneWidget, reason: key);
      }
    });

    testWidgets('yuqori kontrast tanlansa HC mavzu qo‘llanadi', (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profile,
      );
      BuildContext ctx() =>
          tester.element(find.byKey(const Key('profile.theme')));
      expect(FeTheme.isHighContrast(ctx()), isFalse);
      await c
          .read(settingsControllerProvider.notifier)
          .setContrast(ContrastPreference.high);
      await tester.pumpAndSettle();
      expect(FeTheme.isHighContrast(ctx()), isTrue);
    });

    testWidgets('system kontrast OS sozlamasini hurmat qiladi', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(highContrast: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profile,
      );
      expect(
        FeTheme.isHighContrast(
          tester.element(find.byKey(const Key('profile.theme'))),
        ),
        isTrue,
      );
    });

    testWidgets('talaba rejimi: Learn kirish nuqtasi va o‘quv ekrani', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(mode: UserMode.student),
      );
      // Ta’lim — modullar to‘ridagi bitta kirish (takroriy karta yo‘q).
      expect(find.byKey(const Key('home.continueLearning')), findsNothing);
      await tapKey(tester, 'home.module.learn');
      expect(find.byType(LearnScreen), findsOneWidget);
      expect(find.text('SAMPLE'), findsWidgets);
      c.read(routerProvider).go(Routes.home);
      await tester.pumpAndSettle();
    });

    testWidgets('professional rejimda «Continue learning» kartasi yo‘q', (
      tester,
    ) async {
      await pumpApp(tester, settings: completedSettings());
      expect(find.byKey(const Key('home.continueLearning')), findsNothing);
    });
  });
}

/// TEST: store adapteri o‘rnida (narx — ma’nosiz TEST qiymat).
