import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/offline/offline_ai.dart';
import 'package:forensic_expert/domain/ports/ai_ports.dart';

// TEST DATA — barcha shaxsiy ma’lumotlar sun’iy (haqiqiy shaxslarga tegishli emas).
void main() {
  const scanner = RegexPiiScanner();
  Set<PiiKind> kinds(String s) => scanner.scan(s).map((f) => f.kind).toSet();

  test('email, telefon, pasport', () {
    expect(
      kinds('write to test.user@example.invalid'),
      contains(PiiKind.email),
    );
    expect(kinds('tel +998 90 000 00 00'), contains(PiiKind.phone));
    expect(kinds('pasport AA1234567'), contains(PiiKind.passport));
  });

  test('ish raqamlari (RU/UZ/EN)', () {
    expect(kinds('дело № 45/2026'), contains(PiiKind.caseNumber));
    expect(kinds('ish raqami 77'), contains(PiiKind.caseNumber));
    expect(kinds('case #12'), contains(PiiKind.caseNumber));
  });

  test('to‘liq ism-sharif (otasining ismi bilan)', () {
    expect(kinds('Testov Test Testovich'), contains(PiiKind.personalName));
    expect(kinds('Testova Testa Testovna'), contains(PiiKind.personalName));
  });

  test('oddiy ilmiy savolda PII topilmaydi', () {
    expect(scanner.scan('What are common metabolites of morphine?'), isEmpty);
    expect(scanner.scan('GC-MS va LC-MS/MS farqi nimada?'), isEmpty);
  });

  test('AI javobi manbasiz bo‘lishi mumkin emas (kontrakt)', () {
    const bad = AiAnswer(text: 'x', citations: [], noReliableAnswer: false);
    const honest = AiAnswer(text: '', citations: [], noReliableAnswer: true);
    expect(bad.isWellFormed, isFalse);
    expect(honest.isWellFormed, isTrue);
  });
}
