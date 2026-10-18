import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/features/class_quiz/presentation/class_quiz_hub_screen.dart';

void main() {
  test('kod istalgan joylangan matndan ajratiladi', () {
    expect(ClassCode.fromText('123456'), '123456');
    expect(ClassCode.fromText('123 456'), '123456');
    expect(ClassCode.fromText('forensicexpert://app/join/654321'), '654321');
    expect(ClassCode.fromText('https://x.uz/join/111222'), '111222');
    expect(ClassCode.fromText('https://x.uz/j/?code=333444'), '333444');
    expect(
      ClassCode.fromText(
        'Sinfda test! Kod: 987 654. Havola: forensicexpert://app/join/987654',
      ),
      '987654',
    );
    expect(ClassCode.fromText('Telefon 998901234567'), isNull);
    expect(ClassCode.fromText('salom'), isNull);
  });

  test('formatter: yozish o‘zgarmaydi, joylangan havola kodga aylanadi', () {
    final f = ClassCodeInputFormatter();
    TextEditingValue v(String s) => TextEditingValue(text: s);
    expect(f.formatEditUpdate(v('12'), v('123')).text, '123');
    expect(f.formatEditUpdate(v(''), v('Kod: 555 666, kiring')).text, '555666');
    expect(f.formatEditUpdate(v('12'), v('12a')).text, '12');
  });
}
