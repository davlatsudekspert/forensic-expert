import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/l10n/uz_alphabet.dart';

void main() {
  test('asosiy harflar (O‘RQ-1184)', () {
    expect(toUzNewAlphabet('O‘zbekiston'), 'Özbekiston');
    expect(toUzNewAlphabet('bog‘liq to‘g‘ri'), 'boğliq töğri');
    expect(toUzNewAlphabet('Shahar, choy, ishonch'), 'Şahar, çoy, işonç');
    expect(toUzNewAlphabet('SHAHAR O‘ZBEKISTON'), 'ŞAHAR ÖZBEKISTON');
    expect(toUzNewAlphabet('ta’lim, ma’lumot'), 'taʼlim, maʼlumot');
    expect(toUzNewAlphabet('oʻzbek gʻalaba'), 'özbek ğalaba');
  });

  test('chet so‘z, formula, qisqartma va havola o‘zgarmaydi', () {
    expect(toUzNewAlphabet('CH3OH va C2H6O'), 'CH3OH va C2H6O');
    expect(toUzNewAlphabet('GC-MS, COHb, ICH'), 'GC-MS, COHb, ICH');
    expect(toUzNewAlphabet('Schiff reaktivi'), 'Schiff reaktivi');
    expect(
      toUzNewAlphabet('https://lex.uz/docs/8548754'),
      'https://lex.uz/docs/8548754',
    );
    expect(toUzNewAlphabet('doi:10.1007/s00414-021'), 'doi:10.1007/s00414-021');
    expect(toUzNewAlphabet('ish@forensic.uz'), 'ish@forensic.uz');
  });

  test('qo‘shtirnoq vazifasidagi belgi tutuqqa aylanmaydi', () {
    expect(toUzNewAlphabet('‘Ish’'), '‘Iş’');
  });

  test('qidiruv: yangi yozuv eskisiga qaytadi', () {
    expect(uzNewToOld('Özbekiston şahar'), 'O‘zbekiston shahar');
    expect(uzNewToOld(toUzNewAlphabet('bog‘liq ma’lumot')), 'bog‘liq ma’lumot');
  });
}
