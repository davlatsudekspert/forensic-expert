import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/ports/class_quiz_ports.dart';

import '../helpers/pump_app.dart';

/// Server mashq savollarini beradi (yoki kirish talab qiladi).
class _Svc extends UnconfiguredClassQuizService {
  const _Svc({this.signedIn = true});

  final bool signedIn;

  @override
  Future<ClassResult<List<Map<String, Object?>>>> practiceQuestions(
    String topicId, {
    int count = 10,
  }) async {
    if (!signedIn) return const ClassResult.fail(ClassFailure.notSignedIn);
    return ClassResult.ok([
      for (var i = 0; i < 3; i++)
        {
          'id': 'srv-$i',
          'question': 'Server savoli raqam $i?',
          'options': ['A$i', 'B$i', 'C$i', 'D$i'],
          'correct_index': 1,
          'explanation': 'Izoh',
          'source': {'author': 'Muallif', 'title': 'Kitob', 'page': '12'},
          'topic_title': 'Dars mavzusi',
        },
    ]);
  }
}

void main() {
  Future<void> open(WidgetTester tester, {required bool signedIn}) => pumpApp(
    tester,
    settings: completedSettings(lang: 'uz'),
    initialLocation: Routes.groupPractice('ktp26-u-50'),
    proEnabled: false,
    overrides: [
      classQuizBankLoaderProvider.overrideWithValue(
        () async => '{"groups": [], "topics": []}',
      ),
      classQuizServiceProvider.overrideWithValue(_Svc(signedIn: signedIn)),
    ],
  );

  testWidgets('dars savollari ilovada yo‘q — serverdan olinadi', (
    tester,
  ) async {
    await open(tester, signedIn: true);
    expect(find.textContaining('Server savoli raqam'), findsWidgets);
    expect(find.byKey(const Key('grp.testError')), findsNothing);
  });

  testWidgets('kirmagan foydalanuvchi — «Hisobga kirish» tugmasi', (
    tester,
  ) async {
    await open(tester, signedIn: false);
    expect(find.byKey(const Key('grp.practiceSignIn')), findsOneWidget);
    expect(find.text('Hisobga kirish'), findsOneWidget);
  });
}
