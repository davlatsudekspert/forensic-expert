import '../../domain/ports/ai_ports.dart';

/// PHASE 1: AI ulanmagan. Hech qanday tarmoq so‘rovi yo‘q.
class UnavailableAiAssistant implements AiAssistant {
  const UnavailableAiAssistant();

  @override
  AiAvailability get availability => AiAvailability.notConfigured;

  @override
  Future<AiAnswer> ask(AiQuestion question) async =>
      const AiAnswer(text: '', citations: [], noReliableAnswer: true);
}

/// Qoidalarga asoslangan PII detektori (skelet).
///
/// Bu **birinchi himoya qatlami**: server tarafda ikkinchi filtr bo‘ladi.
/// Detektor ataylab «ko‘proq ogohlantiradi» tomonga sozlangan — noto‘g‘ri
/// ogohlantirish ma’lumot sizib chiqishidan arzonroq.
class RegexPiiScanner implements PiiScanner {
  const RegexPiiScanner();

  static final _patterns = <PiiKind, RegExp>{
    PiiKind.email: RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+'),
    // Xalqaro va mahalliy telefon formatlari (kamida 9 raqam).
    PiiKind.phone: RegExp(r'(?:\+?\d[\s\-()]*){9,15}\d'),
    // O‘zbekiston pasporti / ID karta: 2 lotin harf + 7 raqam (masalan AA1234567).
    PiiKind.passport: RegExp(r'\b[A-Z]{2}\s?\d{7}\b'),
    // Ish/case raqamlari: «№ 123», «дело № 45/2026», «ish raqami 77», «case #12».
    PiiKind.caseNumber: RegExp(
      r'(?:№|N[o°º]\.?|#|дело\s*№?|ish\s+raqami|case\s*(?:no\.?|number|#)?)\s*\d[\d/\-.]*',
      caseSensitive: false,
    ),
    // Familiya + ism + otasining ismi (rus/o‘zbek otchestvo qo‘shimchalari).
    PiiKind.personalName: RegExp(
      r'\b[A-ZА-ЯЁЎҚҒҲ][a-zа-яёўқғҳ‘ʻ]+\s+[A-ZА-ЯЁЎҚҒҲ][a-zа-яёўқғҳ‘ʻ]+\s+'
      r'[A-ZА-ЯЁЎҚҒҲ][a-zа-яёўқғҳ‘ʻ]+(?:ovich|evich|ovna|evna|вич|вна|o‘g‘li|qizi)\b',
    ),
  };

  @override
  List<PiiFinding> scan(String text) {
    final findings = <PiiFinding>[];
    for (final entry in _patterns.entries) {
      for (final m in entry.value.allMatches(text)) {
        findings.add(PiiFinding(entry.key, m.start, m.end));
      }
    }
    findings.sort((a, b) => a.start.compareTo(b.start));
    return findings;
  }
}
