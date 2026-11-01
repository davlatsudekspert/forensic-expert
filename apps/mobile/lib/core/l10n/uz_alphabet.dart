/// O‘zbek lotin yozuvi → yangi alifbo (O‘RQ-1184, 21.10.2026; 22.04.2027 dan
/// majburiy): o‘ → ö, g‘ → ğ, sh → ş, ch → ç, tutuq → ʼ (U+02BC).
///
/// Faqat ko‘rsatish uchun: ma’lumot (kontent paketi, server, qidiruv indeksi)
/// asl yozuvda qoladi. Chet tildagi so‘zlar (w, «c» yolg‘iz, «sch», «ph»),
/// raqamli tokenlar (formula: CH3OH), havolalar, email va DOI
/// o‘zgartirilmaydi. Egasi qarori (2026-11-01): Profildagi tugma, standart —
/// o‘chiq.
library;

final _token = RegExp(r"[A-Za-zÀ-ɏ‘ʻ’'`ʼ\-]+|[^A-Za-zÀ-ɏ‘ʻ’'`ʼ\-]+");
final _protected = RegExp(
  r'(https?://|www\.|doi\.org|\b10\.\d{4,}/|@)',
  caseSensitive: false,
);
final _foreign = RegExp(r'[wW]|[cC](?![hH])|[sS][cC][hH]|[pP][hH]');
const _marks = '‘ʻ’\'`ʼ';

bool _isMark(String ch) => _marks.contains(ch);

/// Matnni yangi alifboga o‘giradi. Bo‘sh yoki o‘zgartirib bo‘lmaydigan
/// matn o‘zicha qaytadi.
String toUzNewAlphabet(String input) {
  if (input.isEmpty) return input;
  final out = StringBuffer();
  // URL / email / DOI bor qism — bo‘shliq bilan ajratilgan bo‘laklar bo‘yicha
  // himoyalanadi.
  for (final chunk in input.split(RegExp(r'(?<=\s)|(?=\s)'))) {
    // Formula va kodlar (CH3OH, C2H6O, ICH Q2): raqam + bosh harf.
    if (_protected.hasMatch(chunk) ||
        (RegExp(r'\d').hasMatch(chunk) && RegExp(r'[A-Z]').hasMatch(chunk))) {
      out.write(chunk);
      continue;
    }
    for (final m in _token.allMatches(chunk)) {
      out.write(_word(m.group(0)!));
    }
  }
  return out.toString();
}

String _word(String w) {
  if (!RegExp(r'[A-Za-zÀ-ɏ]').hasMatch(w)) return w;
  if (_foreign.hasMatch(w)) return w;
  // Qisqartma (ICH, SHB…): 4 harfgacha bosh harflar, belgisiz.
  if (w.length <= 4 && w == w.toUpperCase() && !w.split('').any(_isMark)) {
    return w;
  }
  final b = StringBuffer();
  var i = 0;
  while (i < w.length) {
    final ch = w[i];
    final next = i + 1 < w.length ? w[i + 1] : '';
    final lower = ch.toLowerCase();
    if ((lower == 'o' || lower == 'g') && next.isNotEmpty && _isMark(next)) {
      final up = ch != lower;
      b.write(lower == 'o' ? (up ? 'Ö' : 'ö') : (up ? 'Ğ' : 'ğ'));
      i += 2;
      continue;
    }
    if ((lower == 's' || lower == 'c') && (next == 'h' || next == 'H')) {
      final up = ch != lower;
      b.write(lower == 's' ? (up ? 'Ş' : 'ş') : (up ? 'Ç' : 'ç'));
      i += 2;
      continue;
    }
    if (_isMark(ch)) {
      // Tutuq: so‘z ichida (ikki harf orasida) — ʼ; boshqa joyda (qo‘shtirnoq
      // vazifasida) o‘zgarmaydi.
      final prevLetter = i > 0 && RegExp(r'[A-Za-zÀ-ɏ]').hasMatch(w[i - 1]);
      final nextLetter = RegExp(r'[A-Za-zÀ-ɏ]').hasMatch(next);
      b.write(prevLetter && nextLetter ? 'ʼ' : ch);
      i += 1;
      continue;
    }
    b.write(ch);
    i += 1;
  }
  return b.toString();
}

/// Qidiruv uchun: yangi alifbodagi so‘rovni eski yozuvga keltiradi, shunda
/// «şahar» ham, «shahar» ham bir xil topiladi.
String uzNewToOld(String input) => input
    .replaceAll('ö', 'o‘')
    .replaceAll('Ö', 'O‘')
    .replaceAll('ğ', 'g‘')
    .replaceAll('Ğ', 'G‘')
    .replaceAll('ş', 'sh')
    .replaceAll('Ş', 'Sh')
    .replaceAll('ç', 'ch')
    .replaceAll('Ç', 'Ch')
    .replaceAll('ʼ', '’');
