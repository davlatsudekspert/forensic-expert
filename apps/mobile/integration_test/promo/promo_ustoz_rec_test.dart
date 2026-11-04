// PROMO 1: Ustoz (teacher) — haqiqiy ilova, MOCK akkaunt, haqiqiy dars
// ma’lumotlari PROMO_DECKS dan. Sahna ID lari narration_ustoz.json bilan mos.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo ustoz', (tester) async {
    final p = Promo(tester, 'ustoz');
    await p.launch(
      mode: 'teacher',
      overrides: [
        // «DEMO 1..3» ishtirokchilari ko‘rinmasin: bot yo‘q, DEMO mavzu yo‘q.
        classQuizDemoBackendProvider.overrideWith((ref) {
          final load = ref.watch(classQuizBankLoaderProvider);
          return FakeClassQuizBackend(
            teachers: {'demo-user'},
            allowSelfJoin: true,
            demoBots: 0,
            topics: classQuizLocalTopics(
              ClassQuizBank.empty,
              includeDemo: false,
            ),
            topicLoader: () async => ClassQuizBank.parse(await load()).variants,
          );
        }),
      ],
    );

    // ---------------------------------------------------------- signin
    await p.scene('signin', () async {
      await p.go(Routes.profile, after: 500);
      await p.reveal(
        p.byKeyStr('profile.emailCode'),
        alignment: 0.15,
        after: 500,
      );
      await p.tapKey('profile.emailCode', after: 900);
      await p.type(
        find.byKey(const Key('auth.email')),
        'ustoz@example.uz',
        after: 600,
      );
      await p.tapKey('emailCode.send', after: 1300);
      final auth = p.container.read(authRepositoryProvider);
      if (auth is MockAuthRepository && auth.outbox.isNotEmpty) {
        await p.type(
          find.byKey(const Key('emailCode.code')),
          auth.outbox.last.code ?? "123456",
          after: 500,
        );
      }
      p.screen('signin: kod kiritildi');
      await p.tapKey('emailCode.verify', after: 1800);
    });

    // ------------------------------------------------------------ desk
    await p.scene('desk', () async {
      await p.go(Routes.home, after: 1500);
      await p.reveal(p.byKeyStr('desk.teacher'), alignment: 0.04, after: 1500);
      p.screen('desk');
    });

    // --------------------------------------------------------- lessons
    await p.scene('lessons', () async {
      await p.tapKey('workbench.teachLessons', after: 1200);
      p.screen('lessons');
      await p.scroll(520, ms: 2200);
      await p.scrollTop();
      await p.tapKey('lessons.course.Davolash ishi fakulteti', after: 900);
    });

    // ----------------------------------------------------------- slide
    await p.scene('slide', () async {
      await p.reveal(p.byKeyStr('lessons.row.4-kurs-davolash-10'));
      await p.tapKey('lessons.row.4-kurs-davolash-10', after: 2000);
      p.screen('slide0');
      await p.tapKey('lesson.next', after: 1500);
      p.screen('slide1');
    });

    // ---------------------------------------------------------- slide2
    await p.scene('slide2', () async {
      await p.tapKey('lesson.next', after: 1500);
      await p.tapKey('lesson.next', after: 1500);
      p.screen('slide3');
      await p.tapKey('lesson.projectorButton', after: 2000);
      p.screen('projector');
      if (p.has('lesson.projectorExit')) {
        await p.tapKey('lesson.projectorExit', after: 1000);
      }
    });

    // --------------------------------------------------------- classtest
    await p.scene('classtest', () async {
      await p.go(Routes.home, after: 900);
      await p.tapKey('workbench.teachRun', after: 1200);
      p.screen('teacher panel');
      if (p.has('teacher.run')) await p.tapKey('teacher.run', after: 1200);
      await p.type(
        find.byKey(const Key('class.topicSearch')),
        'toksik',
        after: 600,
      );
      await p.tapKey('class.topic.4-kurs-davolash-10', after: 900);
      await p.tapKey('class.createSubmit', after: 2500);
      p.screen('class code');
    });

    // ------------------------------------------------------------ oral
    await p.scene('oral', () async {
      await p.go(Routes.home, after: 700);
      await p.tapKey('workbench.teachOral', after: 1000);
      await p.waitKey('toral.search');
      await p.type(find.byKey(const Key('toral.search')), 'toksi', after: 400);
      await p.tapKey('toral.topic.4-kurs-davolash-10', after: 700);
      await p.scrollTop();
      await p.type(find.byKey(const Key('toral.search')), 'travma', after: 400);
      await p.tapKey('toral.topic.5-kurs-tibbiy-profilaktika-03', after: 900);
      p.screen('oral picked');
      await p.tapKey('toral.build', after: 1500);
      p.screen('oral pool');
      await p.tapKey('oral.draw', after: 1500);
      p.screen('oral ticket');
    });

    // ----------------------------------------------------------- oral2
    await p.scene('oral2', () async {
      for (final (i, f) in [0.9, 0.75, 0.95].indexed) {
        await p.dragSlider('oral.slider.$i', f, ms: 700);
      }
      await p.tapKey('oral.key.0', after: 2000);
      p.screen('oral key');
    });

    // --------------------------------------------------------- results
    await p.scene('results', () async {
      await p.go(Routes.teacherResults, after: 1500);
      p.screen('results');
    });

    // --------------------------------------------------------- library
    await p.scene('library', () async {
      await p.go(Routes.library, after: 1800);
      p.screen('library');
      await p.scroll(700, ms: 3000);
    });

    p.finish();
  });
}
