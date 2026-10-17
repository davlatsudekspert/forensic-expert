/// Tahlil usulining qisqa nomi (chip va ixcham ro‘yxatlar uchun).
///
/// Yangi ma’lumot to‘qilmaydi: qisqartma faqat to‘liq nomning o‘zidan
/// olinadi — boshidagi qisqartma («GC-FID (alanga…)» → «GC-FID») yoki
/// oxiridagi qavs ichidagi qisqartma («… mass-spektrometriya (GC-MS)» →
/// «GC-MS»). Qisqartma topilmasa — to‘liq nom o‘zgarmaydi. To‘liq nom
/// tafsilot sahifasida va semantik yorliqda qoladi.
String methodShortName(String fullName) {
  final s = fullName.trim();
  final lead = RegExp(
    r'^([\p{L}\p{N}]+(?:[-–/+][\p{L}\p{N}]+)*)\s*(?:\(|—|–|:)',
    unicode: true,
  ).firstMatch(s);
  if (lead != null && _isAbbreviation(lead.group(1)!)) return lead.group(1)!;
  final tail = RegExp(
    r'\(([\p{L}\p{N}][\p{L}\p{N}\-–/+ ]{0,20}[\p{L}\p{N}])\)\s*$',
    unicode: true,
  ).firstMatch(s);
  if (tail != null && _isAbbreviation(tail.group(1)!)) return tail.group(1)!;
  return s;
}

/// Kamida 2 ta bosh harf/raqam, bo‘sh joysiz va kichik harflar ulushi kam
/// (masalan, «GC-MS», «LC-MS/MS», «HPLC-DAD», «ГХ-МС», «UV-Vis»).
bool _isAbbreviation(String t) {
  if (t.contains(' ') || t.length > 16) return false;
  final upper = RegExp(r'[\p{Lu}\p{N}]', unicode: true).allMatches(t).length;
  final lower = RegExp(r'\p{Ll}', unicode: true).allMatches(t).length;
  return upper >= 2 && lower <= upper;
}
