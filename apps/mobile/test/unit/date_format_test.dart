import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/l10n/date_format.dart';

void main() {
  test('o‘zbekcha sana: «2026-yil 4-oktabr»', () {
    expect(feDateUz(DateTime(2026, 10, 4)), '2026-yil 4-oktabr');
    expect(feDateUz(DateTime(2018, 1, 31)), '2018-yil 31-yanvar');
    expect(feDateUz(DateTime(2020, 12, 1)), '2020-yil 1-dekabr');
  });
}
