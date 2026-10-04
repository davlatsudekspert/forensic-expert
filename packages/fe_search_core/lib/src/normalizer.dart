/// Matnni qidiruv uchun normallashtiradi.
///
/// Ikki daraja:
/// * [normalize] — ko‘rinishdagi farqlarni yo‘qotadi (registr, apostrof
///   variantlari, diakritika, bo‘shliqlar), lekin yozuv tizimini saqlaydi.
/// * [searchKey] — yozuv tizimi va tillararo imlo farqlarini «buklaydi»
///   (kirill → lotin, `ph → f`, `th → t`, oxirgi `e` va h.k.), shunda
///   `methamphetamine`, `метамфетамин` va `metamfetamin` bitta kalitga tushadi.
///
/// Muhim: kalit faqat **moslash** uchun. U hech qachon foydalanuvchiga
/// ko‘rsatilmaydi va canonical nomni almashtirmaydi.
class SearchNormalizer {
  const SearchNormalizer();

  /// O‘zbek apostrofi va unga o‘xshash belgilar.
  static const _apostrophes = {
    'ʻ', // ʻ  (o‘zbek lotin standarti)
    'ʼ', // ʼ
    '‘', // ‘
    '’', // ’
    '`', // `
    '´', // ´
    'ʹ', // ʹ
  };

  static const _latinDiacritics = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'ą': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'ę': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ø': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
    'ş': 's',
    'ğ': 'g',
    'ı': 'i',
    'ß': 'ss',
    'α': 'alpha',
    'β': 'beta',
    'γ': 'gamma',
    'δ': 'delta',
  };

  /// Ko‘rinish darajasidagi normalizatsiya.
  String normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      if (_apostrophes.contains(ch)) {
        buffer.write("'");
      } else if (ch == 'ё') {
        buffer.write('е');
      } else if (_latinDiacritics.containsKey(ch)) {
        buffer.write(_latinDiacritics[ch]);
      } else if (_isSeparator(ch)) {
        buffer.write(' ');
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _isSeparator(String ch) =>
      ch == '-' ||
      ch == '_' ||
      ch == '/' ||
      ch == ',' ||
      ch == '.' ||
      ch == '(' ||
      ch == ')' ||
      ch == '‐' ||
      ch == '‑' ||
      ch == '–' ||
      ch == '—' ||
      ch == ' ';

  /// Tillararo moslash kaliti (bo‘shliqsiz).
  String searchKey(String input) {
    final latin = _transliterate(normalize(input));
    return _fold(latin);
  }

  // Rus va o‘zbek kirill alifbolari uchun yagona jadval (o‘zbek lotin
  // imlosiga yaqin: х → x, ж → j, ц → ts).
  static const _cyrillic = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ж': 'j',
    'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n',
    'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f',
    'х': 'x', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'sh', 'ъ': '', 'ы': 'i',
    'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
    // O‘zbek kirill harflari
    'ў': 'o', 'қ': 'q', 'ғ': 'g', 'ҳ': 'h',
  };

  String _transliterate(String s) {
    final b = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      b.write(_cyrillic[ch] ?? ch);
    }
    return b.toString();
  }

  /// Lotin yozuvidagi tillararo imlo farqlarini buklash.
  String _fold(String s) {
    var t = s.replaceAll("'", '').replaceAll(' ', '');
    // O‘zbek digraflari (o‘, g‘ apostrof bilan allaqachon olib tashlangan).
    t = t
        .replaceAll('ph', 'f')
        .replaceAll('th', 't')
        .replaceAll('kh', 'x')
        .replaceAll('ts', 's')
        .replaceAll('w', 'v')
        .replaceAll('y', 'i')
        .replaceAll('q', 'k');
    // c → s (e/i oldidan), aks holda k. `ch` saqlanadi.
    final b = StringBuffer();
    for (var i = 0; i < t.length; i++) {
      final c = t[i];
      if (c == 'c') {
        final next = i + 1 < t.length ? t[i + 1] : '';
        if (next == 'h') {
          b.write('ch');
          i++;
        } else if (next == 'e' || next == 'i') {
          b.write('s');
        } else {
          b.write('k');
        }
      } else {
        b.write(c);
      }
    }
    t = b.toString();
    // Ikki marta takrorlangan harflarni bittaga.
    t = t.replaceAllMapped(RegExp(r'([a-z])\1+'), (m) => m[1]!);
    // Inglizcha oxirgi jim `e` (morphine → morfin, cocaine → kokain).
    if (t.length > 4 && t.endsWith('e') && !t.endsWith('ee')) {
      t = t.substring(0, t.length - 1);
    }
    return t;
  }
}
