import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/features/class_groups/presentation/test_screens.dart';

GroupAttempt _attempt() => GroupAttempt(
  assignment: const GroupAssignment(
    id: 'as1',
    groupId: 'g1',
    topicId: 't1',
    topicTitle: 'Mavzu',
    questionCount: 10,
    variantMode: false,
    reveal: RevealPolicy.afterClose,
    closed: false,
    revealed: false,
  ),
  finished: false,
  questions: [
    for (var i = 0; i < 10; i++)
      GroupQuestion(id: 'q$i', text: 'Savol $i', options: const ['a', 'b']),
  ],
  answers: const {'q3': 1},
);

void main() {
  test('har talabaga tartib alohida, to‘plam va javoblar o‘zgarmaydi', () {
    final a = _attempt();
    final s1 = groupOrderForStudent(a, 'talaba-1')!;
    final s2 = groupOrderForStudent(a, 'talaba-2')!;
    List<String> ids(GroupAttempt x) => [for (final q in x.questions) q.id];
    expect(ids(s1), isNot(ids(s2)));
    expect(ids(s1)..sort(), ids(a)..sort());
    expect(ids(s2)..sort(), ids(a)..sort());
    expect(s1.answers, {'q3': 1});
    // Bir talaba uchun doim bir xil (qayta ochganda tartib o‘zgarmaydi).
    expect(ids(groupOrderForStudent(a, 'talaba-1')!), ids(s1));
  });

  test('identifikator yo‘q yoki 1 savol: serverdagi tartib', () {
    final a = _attempt();
    expect(groupOrderForStudent(a, null), same(a));
    expect(groupOrderForStudent(null, 'x'), isNull);
  });
}
