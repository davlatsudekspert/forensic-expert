import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/ports/professional_ports.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/domain/professional/review_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/professional_fixtures.dart';
import '../helpers/pump_app.dart';

/// Ro‘yxatdan o‘tish / professional tasdiqlash / taqriz skrinshotlari —
/// HAQIQIY pilot paket bilan. FIXTURE belgili ekranlar faqat test uchun
/// (tasdiqlangan foydalanuvchi va taqriz ilovada yo‘q).
/// Nusxa: `docs/screenshots/registration/`.
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
          name: 'reg_01_language',
          settings: const AppSettings(),
          route: null,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_02_disclaimer_uz',
          settings: onboarding('uz'),
          route: null,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_03_role_uz',
          settings: onboarding('uz', disclaimer: true),
          route: null,
          scrollTo: const Key('mode.continue'),
          extra: const [],
          act: (t) async {
            await t.tap(find.byKey(const Key('mode.professional')));
            await t.pumpAndSettle();
            await t.tap(find.byKey(const Key('role.forensicChemist')));
            await t.pumpAndSettle();
          },
        ),
        (
          name: 'reg_04_student_profile_uz',
          settings: completedSettings(lang: 'uz', mode: UserMode.student),
          route: Routes.profileEdit,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_05_pro_profile_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.profileEdit,
          scrollTo: null,
          extra: [initialProfileProvider.overrideWithValue(proProfile)],
          act: null,
        ),
        (
          name: 'reg_06_verification_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.verification,
          scrollTo: null,
          extra: [initialProfileProvider.overrideWithValue(proProfile)],
          act: null,
        ),
        (
          name: 'reg_07_upload_uz',
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
          name: 'reg_08_pending_FIXTURE_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.verification,
          scrollTo: null,
          extra: [
            professionalSnapshotProvider.overrideWith((ref) async => pending),
            initialProfileProvider.overrideWithValue(proProfile),
          ],
          act: null,
        ),
        (
          name: 'reg_09_verified_profile_FIXTURE_en',
          settings: completedSettings(),
          route: Routes.profile,
          scrollTo: const Key('profile.reviewDashboard'),
          extra: [
            professionalSnapshotProvider.overrideWith(
              (ref) async =>
                  const ProfessionalSnapshot(identity: fixtureToxReviewer),
            ),
          ],
          act: null,
        ),
        (
          name: 'reg_10_home_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.home,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_11_disciplines_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.disciplines,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_12_substance_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.libraryEntry('morphine'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_13_provenance_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.libraryEntry('morphine'),
          scrollTo: const Key('entry.provenance'),
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_14_research_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.researchEntry('RS-582d32d8a823'),
          scrollTo: const Key('review.section.RS-582d32d8a823'),
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_15_review_empty_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.libraryEntry('morphine'),
          scrollTo: const Key('review.permission.morphine'),
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_16_review_FIXTURE_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.libraryEntry('morphine'),
          scrollTo: const Key('review.write.morphine'),
          extra: [
            professionalIdentityProvider.overrideWithValue(fixtureToxReviewer),
            professionalReviewServiceProvider.overrideWithValue(
              FixtureReviewService(
                identity: fixtureToxReviewer,
                reviews: [
                  fixtureReview(recordId: 'morphine', version: '2026.10.7'),
                ],
              ),
            ),
          ],
          act: null,
        ),
        (
          name: 'reg_17_methods_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.knowledge('method'),
          scrollTo: const Key('methods.standardsLink'),
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_18_forensic_medicine_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.forensicMedicine,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_19_search_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.searchWith('morfin'),
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_20_ai_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.ai,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_21_profile_uz',
          settings: completedSettings(lang: 'uz'),
          route: Routes.profile,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_22_dashboard_FIXTURE_en',
          settings: completedSettings(),
          route: Routes.reviewDashboard,
          scrollTo: null,
          extra: [
            professionalIdentityProvider.overrideWithValue(fixtureToxReviewer),
            professionalReviewServiceProvider.overrideWithValue(
              FixtureReviewService(
                identity: fixtureToxReviewer,
                queueItems: const [
                  ReviewQueueItem(
                    subject: ReviewSubject(
                      recordId: 'fixture-record',
                      kind: ReviewSubjectKind.substance,
                      contentVersion: '2026.10.7',
                      scopes: {ReviewerScope.forensicToxicology},
                    ),
                    title: 'FIXTURE record (not real content)',
                    discipline: 'Forensic toxicology',
                    claimCount: 3,
                    sourceCount: 2,
                    state: ReviewState.needsReview,
                    evidenceLevel: 'C',
                  ),
                ],
              ),
            ),
          ],
          act: null,
        ),
        (
          name: 'reg_23_module_tox_dark_uz',
          settings: completedSettings(lang: 'uz', theme: ThemeMode.dark),
          route: Routes.module('toxicology'),
          scrollTo: const Key('moduleHub.sourcedNote'),
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_24_role_ru',
          settings: onboarding('ru', disclaimer: true),
          route: null,
          scrollTo: const Key('mode.continue'),
          extra: const [],
          act: (t) async {
            await t.tap(find.byKey(const Key('mode.student')));
            await t.pumpAndSettle();
          },
        ),
        (
          name: 'reg_25_account_en',
          settings: completedSettings(),
          route: Routes.welcomeAccount,
          scrollTo: null,
          extra: const [],
          act: null,
        ),
        (
          name: 'reg_26_profile_ru_dark',
          settings: completedSettings(lang: 'ru', theme: ThemeMode.dark),
          route: Routes.profile,
          scrollTo: null,
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
