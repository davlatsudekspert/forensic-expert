import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_repository.dart';
import 'package:forensic_expert/data/local/profile_store.dart';
import 'package:forensic_expert/domain/auth/auth_models.dart';
import 'package:forensic_expert/domain/ports/backend_ports.dart';
import 'package:forensic_expert/domain/ports/professional_ports.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/domain/professional/review_models.dart';
import 'package:forensic_expert/features/home/presentation/home_screen.dart';
import 'package:forensic_expert/features/professional/presentation/account_choice_screen.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/professional_fixtures.dart';
import '../helpers/pump_app.dart';

/// Ro‘yxatdan o‘tish, rejim ≠ maqom, malaka hujjati, mutaxassis taqrizi,
/// soha vakolati, taqrizchi ish joyi.
void main() {
  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  group('onboarding: til → ogohlantirish → rejim → hisob', () {
    testWidgets('til birinchi; Mutaxassis tanlansa maqom tasdiqlanmagani '
        'aytiladi; hisobsiz davom etish Home’ga olib boradi', (tester) async {
      final repo = InMemorySettingsRepository();
      await pumpApp(tester, repository: repo);
      // 1. Til
      expect(find.byKey(const Key('language.option.en')), findsOneWidget);
      await tapKey(tester, 'language.option.en');
      await tapKey(tester, 'language.continue');
      // 2. Ogohlantirish
      await tapKey(tester, 'disclaimer.accept');
      // 3. Rejim
      expect(find.text('How will you use FORENSIC EXPERT?'), findsOneWidget);
      expect(find.byKey(const Key('mode.proNote')), findsNothing);
      await tapKey(tester, 'mode.professional');
      expect(find.byKey(const Key('mode.proNote')), findsOneWidget);
      expect(
        find.text(
          'Choosing Professional mode does not mean that your professional '
          'status is verified.',
        ),
        findsOneWidget,
      );
      await tapKey(tester, 'mode.roles');
      await tapKey(tester, 'role.forensicToxicologist');
      await tapKey(tester, 'mode.continue');
      expect(repo.value.userMode, UserMode.professional);
      expect(repo.value.declaredRole, 'forensicToxicologist');
      // 4. Hisob (ixtiyoriy) — server yo‘q: tugma o‘chiq va sababi aytiladi.
      expect(find.byType(AccountChoiceScreen), findsOneWidget);
      final create = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('account.create')),
      );
      expect(create.onPressed, isNull);
      expect(find.byKey(const Key('account.unavailable')), findsOneWidget);
      await tapKey(tester, 'account.skip');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Talaba tanlash — rol saqlanadi', (tester) async {
      final repo = InMemorySettingsRepository(
        const AppSettings(
          locale: Locale('uz'),
          acceptedDisclaimerVersion: currentDisclaimerVersion,
        ),
      );
      await pumpApp(tester, repository: repo, settings: repo.value);
      expect(
        find.text('FORENSIC EXPERT’dan qanday foydalanasiz?'),
        findsOneWidget,
      );
      await tapKey(tester, 'mode.student');
      expect(find.byKey(const Key('mode.proNote')), findsNothing);
      await tapKey(tester, 'mode.roles');
      await tapKey(tester, 'role.residentTrainee');
      await tapKey(tester, 'mode.continue');
      expect(repo.value.userMode, UserMode.student);
      expect(repo.value.declaredRole, 'residentTrainee');
      expect(find.text('Hisobsiz davom etish'), findsOneWidget);
    });

    testWidgets('rejim tanlanmasa davom etib bo‘lmaydi', (tester) async {
      await pumpApp(
        tester,
        settings: const AppSettings(
          locale: Locale('en'),
          acceptedDisclaimerVersion: currentDisclaimerVersion,
        ),
      );
      final b = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('mode.continue')),
      );
      expect(b.onPressed, isNull);
    });
  });

  group('profil', () {
    testWidgets('professional profil saqlanadi, lekin maqom «Tasdiqlanmagan» '
        'bo‘lib qoladi', (tester) async {
      final store = InMemoryProfileStore();
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profileEdit,
        overrides: [profileStoreProvider.overrideWithValue(store)],
      );
      expect(
        find.byKey(const Key('profileEdit.notVerifiedNote')),
        findsOneWidget,
      );
      // 1 / 3 — bo‘sh «Keyingi»: xatolar, keyingi qadamga o‘tmaydi.
      expect(find.text('1 / 3'), findsOneWidget);
      await tapKey(tester, 'profileEdit.next');
      expect(find.byKey(const Key('profileEdit.errors')), findsOneWidget);
      expect(find.text('Required field'), findsWidgets);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(store.value.isEmpty, isTrue);

      await tester.enterText(
        find.byKey(const Key('profileEdit.fullName')),
        'Test Expert',
      );
      await tapKey(tester, 'profileEdit.country');
      await tester.enterText(find.byKey(const Key('country.search')), 'Uzbek');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('country.UZ')));
      await tester.pumpAndSettle();
      await tapKey(tester, 'profileEdit.next');
      // 2 / 3 — qoralama qurilmada saqlangan.
      expect(find.text('2 / 3'), findsOneWidget);
      expect(store.value.professional?.fullName, 'Test Expert');
      for (final (k, v) in [
        ('organization', 'Forensic laboratory'),
        ('position', 'Forensic chemist'),
        ('education', 'Pharmacy, MSc'),
        ('years', '7'),
      ]) {
        final f = find.byKey(Key('profileEdit.$k'));
        await tester.ensureVisible(f);
        await tester.enterText(f, v);
      }
      await tapKey(tester, 'profileEdit.next');
      expect(find.text('3 / 3'), findsOneWidget);
      // «Orqaga» ma’lumotni yo‘qotmaydi.
      await tapKey(tester, 'profileEdit.back');
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('Forensic laboratory'), findsOneWidget);
      await tapKey(tester, 'profileEdit.next');
      await tapKey(tester, 'profileEdit.save');
      final saved = store.value.professional!;
      expect(saved.fullName, 'Test Expert');
      expect(saved.country, 'UZ');
      expect(saved.yearsExperience, 7);
      expect(saved.showOrganizationPublicly, isFalse);
    });

    testWidgets('Profil: bo‘limlar va maqom chipi; tasdiqlanmagan '
        'foydalanuvchida taqrizchi ish joyi yo‘q', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.profile,
      );
      expect(find.byKey(const Key('profile.identityCard')), findsOneWidget);
      expect(find.byKey(const Key('verif.chip.unverified')), findsOneWidget);
      expect(find.byKey(const Key('profile.reviewDashboard')), findsNothing);
      for (final h in [
        'Verification',
        'Preferences',
        'Account',
        'Subscription',
        'Data and privacy',
        'About and legal',
      ]) {
        await tester.scrollUntilVisible(
          find.text(h),
          200,
          scrollable: find.byType(Scrollable).hitTestable().first,
        );
        expect(find.text(h), findsOneWidget, reason: h);
      }
    });

    testWidgets('rejimni Talabaga almashtirish tasdiqlangan maqomni '
        'o‘chirmaydi', (tester) async {
      final repo = InMemorySettingsRepository(completedSettings());
      await pumpApp(
        tester,
        settings: completedSettings(),
        repository: repo,
        initialLocation: Routes.profileMode,
        overrides: [
          professionalSnapshotProvider.overrideWith(
            (ref) async =>
                const ProfessionalSnapshot(identity: fixtureToxReviewer),
          ),
        ],
      );
      expect(find.byKey(const Key('picker.mode.note')), findsOneWidget);
      await tapKey(tester, 'picker.mode.student');
      expect(repo.value.userMode, UserMode.student);
      final c = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(c);
      expect(
        container.read(professionalIdentityProvider)?.isVerifiedProfessional,
        isTrue,
      );
    });
  });

  group('tasdiqlash va malaka hujjati', () {
    testWidgets('server ulanmagan: holat «Tasdiqlanmagan», yuborish o‘chiq, '
        'sababi aytiladi', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.verification,
      );
      expect(find.byKey(const Key('verif.chip.unverified')), findsOneWidget);
      expect(
        find.byKey(const Key('verification.notConnected')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('verification.humanOnly')), findsOneWidget);
      final submit = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('verification.submit')),
      );
      expect(submit.onPressed, isNull);
    });

    testWidgets('hujjat tanlash: PDF qabul qilinadi, noto‘g‘ri tur rad '
        'etiladi; yuklanmagani ochiq aytiladi', (tester) async {
      final picker = FakeFilePicker(
        const PickedFile(name: 'certificate.pdf', bytes: pdfBytes),
      );
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.verificationDocuments,
        overrides: [credentialFilePickerProvider.overrideWithValue(picker)],
      );
      expect(find.byKey(const Key('credentials.privacy')), findsOneWidget);
      expect(find.byKey(const Key('credentials.noCaseData')), findsOneWidget);
      await tapKey(tester, 'credentials.kind.diploma');
      await tapKey(tester, 'credentials.pick');
      expect(find.byKey(const Key('credentials.file.0')), findsOneWidget);
      expect(find.text('certificate.pdf'), findsOneWidget);
      expect(find.byKey(const Key('credentials.notUploaded')), findsOneWidget);

      picker.next = const PickedFile(name: 'evil.exe', bytes: [0x4D, 0x5A, 0]);
      await tapKey(tester, 'credentials.pick');
      expect(find.byKey(const Key('credentials.error')), findsOneWidget);
      expect(find.byKey(const Key('credentials.file.1')), findsNothing);
    });

    testWidgets('ulangan (FIXTURE) xizmat: ariza yuboriladi → «Tekshiruv '
        'kutilmoqda», tasdiqlangan emas', (tester) async {
      final service = FixtureVerificationService(ProfessionalSnapshot.empty);
      final c = await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.verification,
        overrides: [
          professionalVerificationServiceProvider.overrideWithValue(service),
          authStateProvider.overrideWith(_SignedIn.new),
          initialProfileProvider.overrideWithValue(
            const LocalUserProfile(
              professional: ProfessionalProfile(
                fullName: 'Applicant',
                country: 'UZ',
                organization: 'Lab',
                position: 'Chemist',
                primarySpecialty: Specialty.forensicChemistry,
                education: 'MSc',
              ),
            ),
          ),
        ],
      );
      await tapKey(tester, 'verification.submit');
      expect(service.submissions, hasLength(1));
      await tester.pumpAndSettle();
      expect(
        c.read(professionalSnapshotProvider).value?.status,
        VerificationStatus.applicationPending,
      );
      expect(
        find.byKey(const Key('verif.chip.applicationPending')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('badge.verifiedProfessional')), findsNothing);
    });
  });

  group('mutaxassis taqrizi (haqiqiy pilot paket)', () {
    late PilotContent pilot;
    setUpAll(() async => pilot = await loadPilotContent());

    Future<ProviderContainer> openEntry(
      WidgetTester tester, {
      ProfessionalIdentity? identity,
      ProfessionalReviewService? reviews,
      UserMode mode = UserMode.professional,
    }) => pumpApp(
      tester,
      settings: completedSettings(mode: mode),
      initialLocation: Routes.libraryEntry('morphine'),
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
        professionalIdentityProvider.overrideWithValue(identity),
        if (reviews != null)
          professionalReviewServiceProvider.overrideWithValue(reviews),
      ],
    );

    Future<void> seeSection(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.byKey(const Key('review.section.morphine')),
        400,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('taqriz yo‘q — halol bo‘sh holat; oddiy foydalanuvchida '
        'taqriz amallari yo‘q; tekshiruv qatlamlari alohida', (tester) async {
      await openEntry(tester);
      await seeSection(tester);
      expect(find.byKey(const Key('review.empty.morphine')), findsOneWidget);
      expect(
        find.text(
          'This material has not yet been reviewed by a qualified '
          'professional.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('review.write.morphine')), findsNothing);
      for (final k in ['source', 'identifier', 'professional', 'human']) {
        expect(find.byKey(Key('review.layer.$k')), findsOneWidget);
      }
      expect(find.text('0 of 2 independent approvals'), findsOneWidget);
    });

    testWidgets('soha vakolati: DNK taqrizchisi moddani taqriz qila olmaydi', (
      tester,
    ) async {
      await openEntry(
        tester,
        identity: fixtureDnaReviewer,
        reviews: FixtureReviewService(identity: fixtureDnaReviewer),
      );
      await seeSection(tester);
      expect(find.byKey(const Key('review.write.morphine')), findsNothing);
      expect(
        find.text('You do not have review rights for this specialty.'),
        findsOneWidget,
      );
    });

    testWidgets('talaba UI rejimida tasdiqlangan mutaxassis ham taqriz '
        'yozmaydi (vakolat saqlanadi)', (tester) async {
      await openEntry(
        tester,
        identity: fixtureToxReviewer,
        mode: UserMode.student,
        reviews: FixtureReviewService(identity: fixtureToxReviewer),
      );
      await seeSection(tester);
      expect(find.byKey(const Key('review.write.morphine')), findsNothing);
    });

    testWidgets('FIXTURE toksikolog taqriz yozadi; bitta taqriz HUMAN '
        'VERIFIED qilmaydi', (tester) async {
      final service = FixtureReviewService(identity: fixtureToxReviewer);
      await openEntry(tester, identity: fixtureToxReviewer, reviews: service);
      await seeSection(tester);
      await tapKey(tester, 'review.write.morphine');
      expect(find.byKey(const Key('review.composer')), findsOneWidget);
      await tapKey(tester, 'review.action.approve');
      // Qisqa izoh rad etiladi.
      await tester.enterText(find.byKey(const Key('review.note')), 'ok');
      await tapKey(tester, 'review.submit');
      expect(find.text('At least 20 characters are required.'), findsOneWidget);
      expect(service.submitted, isEmpty);
      await tester.enterText(
        find.byKey(const Key('review.note')),
        'Consistent with the cited primary sources for this record.',
      );
      await tapKey(tester, 'review.submit');
      expect(service.submitted, hasLength(1));
      expect(service.submitted.single.contentVersion, isNotEmpty);
      await seeSection(tester);
      expect(
        find.byKey(Key('review.card.${service.submitted.single.reviewId}')),
        findsOneWidget,
      );
      expect(find.text('1 of 2 independent approvals'), findsOneWidget);
    });

    testWidgets('to‘ldirilgan FIXTURE taqriz: belgi, qaror, versiya; eski '
        'versiya taqrizi «qayta taqriz» deb belgilanadi', (tester) async {
      await openEntry(
        tester,
        reviews: FixtureReviewService(
          reviews: [
            fixtureReview(recordId: 'morphine', version: '2026.10.7'),
            fixtureReview(
              recordId: 'morphine',
              version: '2026.01.1',
              action: ReviewAction.approve,
              id: 'fixture-old',
            ),
          ],
        ),
      );
      await seeSection(tester);
      await tester.scrollUntilVisible(
        find.byKey(const Key('review.card.fixture-review-1')),
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(find.byKey(const Key('badge.verifiedProfessional')), findsWidgets);
      expect(find.text('Decision: Correction required'), findsOneWidget);
      expect(find.byKey(const Key('review.stale.fixture-old')), findsOneWidget);
      expect(
        find.byKey(const Key('review.stale.fixture-review-1')),
        findsNothing,
      );
    });
  });

  group('taqrizchi ish joyi', () {
    testWidgets('oddiy foydalanuvchi uchun yopiq', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.reviewDashboard,
      );
      expect(find.byKey(const Key('dashboard.forbidden')), findsOneWidget);
      expect(
        find.byKey(const Key('dashboard.queue.needsReview')),
        findsNothing,
      );
    });

    testWidgets('FIXTURE taqrizchi navbatlarni ko‘radi', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.reviewDashboard,
        overrides: [
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
                  title: 'FIXTURE record',
                  discipline: 'Toxicology',
                  claimCount: 3,
                  sourceCount: 2,
                  state: ReviewState.needsReview,
                  evidenceLevel: 'C',
                ),
              ],
            ),
          ),
        ],
      );
      for (final q in ReviewQueue.values) {
        expect(find.byKey(Key('dashboard.queue.${q.name}')), findsOneWidget);
      }
      expect(
        find.byKey(const Key('dashboard.item.fixture-record')),
        findsOneWidget,
      );
      await tapKey(tester, 'dashboard.queue.conflicts');
      expect(find.text('No records in this queue.'), findsOneWidget);
    });
  });

  group('ilmiy haqiqat', () {
    test('ilovaga o‘rnatilgan paketda HUMAN VERIFIED = 0', () {
      final b = jsonDecode(
        File('../../content/pilot/bundle.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final verified = [
        for (final c in (b['claims']! as List).cast<Map<String, Object?>>())
          if (c['status'] == 'VERIFIED') c['claim_id'],
      ];
      expect(verified, isEmpty);
      // Ilovada taqriz ma’lumoti jo‘natilmaydi: oflayn xizmat bo‘sh.
      expect(ReviewEvaluator.humanVerifiedCount(const []), 0);
    });

    test('lib/ ichida FIXTURE taqrizchi yoki tasdiqlangan foydalanuvchi '
        'yo‘q', () {
      final offenders = <String>[];
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final s = f.readAsStringSync();
        if (s.contains('fixture-reviewer') ||
            RegExp(r'status:\s*VerificationStatus\.verifiedProfessional')
                .hasMatch(s)) {
          offenders.add(f.path);
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });
  });
}

class _SignedIn extends AuthStateNotifier {
  @override
  AuthState build() => const AuthState(
    AuthStatus.signedIn,
    account: AuthAccount(
      userId: 'u',
      email: 'u@example.org',
      emailVerified: true,
    ),
  );
}
