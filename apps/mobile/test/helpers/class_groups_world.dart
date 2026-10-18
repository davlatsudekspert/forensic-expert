import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_groups.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_groups/fake_class_groups_service.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_demo_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/auth/auth_models.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/ports/backend_ports.dart';

import 'pump_app.dart';

/// Kirgan foydalanuvchi holati (testlarda qo‘lda almashtiriladi).
class TestAuth extends AuthStateNotifier {
  TestAuth(this.initial);

  final AuthState initial;

  @override
  AuthState build() => initial;

  void set(AuthState s) => state = s;
}

AuthState signedInAs(String uid) => AuthState(
  AuthStatus.signedIn,
  account: AuthAccount(
    userId: uid,
    email: '$uid@test.example',
    emailVerified: true,
  ),
);

/// Haqiqiy mazmunga o‘xshash mavzu (uz), manba va bet bilan.
ClassBankTopic groupTestTopic(String id, String title, int n) => ClassBankTopic(
  id: id,
  title: title,
  questions: [
    for (var i = 1; i <= n; i++)
      ClassBankQuestion(
        question:
            'CO bilan zaharlanish: $i-savol. Qondagi COHb ulushi qaysi '
            'holatda og‘ir zaharlanishga mos keladi?',
        options: ['10% gacha', '20–30%', '50% va undan yuqori', '5% gacha'],
        correctIndex: 2,
        explanation: 'COHb 50% dan yuqori bo‘lsa — og‘ir zaharlanish.',
        source: const ClassSource(
          author: 'Muallif',
          title: 'Sud tibbiyoti darsligi',
          page: '41',
        ),
      ),
  ],
);

/// Bitta «server» (xotirada) va bir nechta foydalanuvchi.
class GroupsWorld {
  GroupsWorld({List<ClassBankTopic>? topics}) {
    this.topics =
        topics ??
        [
          groupTestTopic('tox-co', 'Toksikologiya: CO bilan zaharlanish', 24),
          groupTestTopic('tox-small', 'Kichik mavzu', 6),
        ];
    backend = FakeClassGroupsBackend(
      topics: () async => this.topics,
      teachers: {'teacher'},
      clock: () => now,
    );
    quiz = FakeClassQuizBackend(topics: this.topics, teachers: {'teacher'});
  }

  var now = DateTime(2026, 10, 18, 10);
  late final List<ClassBankTopic> topics;
  late final FakeClassGroupsBackend backend;
  late final FakeClassQuizBackend quiz;

  /// Ilovani [uid] (yoki kirmagan — `null`) nomidan ochadi.
  Future<ProviderContainer> open(
    WidgetTester tester, {
    String? uid,
    String? location,
    AppSettings? settings,
    Size size = const Size(390, 844),
    bool iphone = true,
  }) async {
    if (iphone) {
      // iPhone 12–15: 390×844, DPR 3, notch (47) va home indicator (34).
      tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
      tester.view.viewPadding = const FakeViewPadding(
        top: 47 * 3,
        bottom: 34 * 3,
      );
    }
    final c = await pumpApp(
      tester,
      settings: settings ?? completedSettings(lang: 'uz'),
      size: size,
      overrides: [
        authStateProvider.overrideWith(
          () => TestAuth(uid == null ? AuthState.signedOut : signedInAs(uid)),
        ),
        classGroupsServiceProvider.overrideWith(
          (ref) => FakeClassGroupsService(
            backend,
            demo: false,
            userIdOf: () {
              final s = ref.read(authStateProvider);
              return s.signedIn ? s.userId : null;
            },
          ),
        ),
        classQuizServiceProvider.overrideWithValue(
          FakeClassQuizService(quiz, userId: uid ?? 'nobody', demo: false),
        ),
        groupPollIntervalProvider.overrideWithValue(
          const Duration(milliseconds: 200),
        ),
        groupNowProvider.overrideWithValue(() => now),
        classScannerAvailableProvider.overrideWithValue(false),
        classLandscapePromptEnabledProvider.overrideWithValue(false),
      ],
    );
    if (location != null) {
      c.read(routerProvider).go(location);
      await frames(tester);
    }
    return c;
  }
}

Future<void> frames(WidgetTester tester, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Polling va taymerlarni to‘xtatadi (test oxirida).
Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  debugDefaultTargetPlatformOverride = null;
}
