import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/domain/ports/professional_ports.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/professional_fixtures.dart';
import '../helpers/pump_app.dart';

/// YAKUNIY skrinshot QA — «Shield of Evidence» brendi, email OTP,
/// 3 bosqichli profil, manba sahifasi. HAQIQIY pilot paket bilan. FIXTURE
/// belgili ekranlar faqat test uchun (tasdiqlangan foydalanuvchi va taqriz
/// ilovada yo‘q). MOCK auth — xat yuborilmaydi (UI «TEST» deb belgilaydi).
/// Nusxa: `docs/screenshots/final/`.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  const proProfile = LocalUserProfile(
    professional: ProfessionalProfile(
      fullName: 'Sample Name',
      country: 'UZ',
      organization: 'Forensic laboratory',
      position: 'Forensic chemist',
      primarySpecialty: Specialty.forensicChemistry,
      education: 'MSc, analytical chemistry',
      yearsExperience: 8,
    ),
  );
  final pending = ProfessionalSnapshot(
    application: ProfessionalApplication(
      applicationId: 'fixture',
      userId: 'fixture',
      status: VerificationStatus.applicationPending,
      declaredSpecialty: Specialty.forensicChemistry,
      submittedAt: DateTime.utc(2026, 10, 5),
    ),
  );

  AppSettings onboarding(String lang, {bool disclaimer = false}) => AppSettings(
    locale: Locale(lang),
    acceptedDisclaimerVersion: disclaimer ? currentDisclaimerVersion : null,
  );

  Future<void> next(WidgetTester t) async {
    final b = find.byKey(const Key('profileEdit.next'));
    await t.ensureVisible(b);
    await t.pumpAndSettle();
    await t.tap(b);
    await t.pumpAndSettle();
  }

  Future<void> sendCode(WidgetTester t) async {
    await t.enterText(
      find.byKey(const Key('auth.email')),
      'expert@example.org',
    );
    await t.tap(find.byKey(const Key('emailCode.send')));
    await t.pumpAndSettle();
  }

  final mockAuth = <Override>[
    authRepositoryProvider.overrideWithValue(MockAuthRepository()),
  ];
  final proExtra = <Override>[
    initialProfileProvider.overrideWithValue(proProfile),
  ];

  final cases =
      <
        ({
          String name,
          AppSettings settings,
          String? route,
          Key? scrollTo,
          List<Override> extra,
          Future<void> Function(WidgetTester)? act,
        })
      >[
        (
          name: 'fin_01_language',
          settings: const AppSettings(),
          route: null,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_02_disclaimer_uz',
          settings: onboarding('uz'),
          route: null,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_03_mode_uz',
          settings: onboarding('uz', disclaimer: true),
          route: null,
          scrollTo: null,
          extra: const [],
          act: (t) async {
            await t.tap(find.byKey(const Key('mode.professional')));
            await t.pumpAndSettle();
          },
        ),
        (
          name: 'fin_04_account_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.welcomeAccount,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_05_email_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.welcomeEmailCode,
          scrollTo: null,
          extra: mockAuth,
          act: null,
        ),
        (
          name: 'fin_06_otp_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.welcomeEmailCode,
          scrollTo: null,
          extra: mockAuth,
          act: sendCode,
        ),
        (
          name: 'fin_07_home_student_uz',
          settings: completedSettings(lang: 'uz', mode: UserMode.student),
          route: Routes.home,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_08_home_pro_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.home,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_09_profile_step1_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.profileEdit,
          scrollTo: null,
          extra: proExtra,
          act: null,
        ),
        (
          name: 'fin_10_profile_step2_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.profileEdit,
          scrollTo: null,
          extra: proExtra,
          act: next,
        ),
        (
          name: 'fin_11_profile_step3_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.profileEdit,
          scrollTo: null,
          extra: proExtra,
          act: (t) async {
            await next(t);
            await next(t);
          },
        ),
        (
          name: 'fin_12_upload_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.verificationDocuments,
          scrollTo: const Key('credentials.notUploaded'),
          extra: [
            credentialFilePickerProvider.overrideWithValue(
              FakeFilePicker(
                const PickedFile(name: 'diplom.pdf', bytes: pdfBytes),
              ),
            ),
          ],
          act: (t) async {
            final pick = find.byKey(const Key('credentials.pick'));
            await t.ensureVisible(pick);
            await t.pumpAndSettle();
            await t.tap(pick);
            await t.pumpAndSettle();
          },
        ),
        (
          name: 'fin_13_pending_FIXTURE_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.verification,
          scrollTo: null,
          extra: [
            professionalSnapshotProvider.overrideWith((ref) async => pending),
            ...proExtra,
          ],
          act: null,
        ),
        (
          name: 'fin_14_verified_FIXTURE_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.profile,
          scrollTo: null,
          extra: [
            professionalSnapshotProvider.overrideWith(
              (ref) async =>
                  const ProfessionalSnapshot(identity: fixtureToxReviewer),
            ),
            ...proExtra,
          ],
          act: null,
        ),
        (
          name: 'fin_15_toxicology_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.module('toxicology'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_16_forensic_medicine_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.forensicMedicine,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_17_laboratory_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.module('laboratory'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_18_substance_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.libraryEntry('morphine'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_19_method_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.knowledgeEntry('method-gcms'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_20_research_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.researchEntry('RS-582d32d8a823'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_21_source_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.source('SRC-PMC8400298'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_22_review_FIXTURE_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.libraryEntry('morphine'),
          scrollTo: const Key('review.write.morphine'),
          extra: [
            professionalIdentityProvider.overrideWithValue(fixtureToxReviewer),
            professionalReviewServiceProvider.overrideWithValue(
              FixtureReviewService(
                identity: fixtureToxReviewer,
                reviews: [
                  fixtureReview(recordId: 'morphine', version: '2026.10.8'),
                ],
              ),
            ),
          ],
          act: null,
        ),
        (
          name: 'fin_23_search_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.searchWith('Метамфетамин'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_24_ai_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.ai,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_25_profile_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.profile,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_26_home_dark_uz',
          settings: completedSettings(lang: 'uz', theme: ThemeMode.dark),
          route: Routes.home,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_27_home_ru',
          settings: completedSettings(lang: 'ru'),
          route: Routes.home,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_28_home_en',
          settings: completedSettings(),
          route: Routes.home,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_29_about_en',
          settings: completedSettings(),
          route: Routes.about,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'fin_30_substance_dark_ru',
          settings: completedSettings(lang: 'ru', theme: ThemeMode.dark),
          route: Routes.libraryEntry('morphine'),
          scrollTo: const Key('source.SRC-PMC8400298'),
          extra: const [],
          act: null,
        ),
        (
          // Baza holati Home’dan «Ilova haqida»ga ko‘chirildi.
          name: 'fin_31_about_database_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.about,
          scrollTo: const Key('about.db.humanVerified'),
          extra: const [],
          act: null,
        ),
      ];

  for (final c in cases) {
    testWidgets(c.name, (tester) async {
      await pumpApp(
        tester,
        settings: c.settings,
        initialLocation: c.route,
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          entitlementServiceProvider.overrideWithValue(
            FakeStore(withOffers: false),
          ),
          ...c.extra,
        ],
      );
      await settleImages(tester);
      if (c.act case final act?) await act(tester);
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
