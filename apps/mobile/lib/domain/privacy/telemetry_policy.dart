/// Kelajakdagi analitika / crash logging uchun **maxfiylik qoidasi**
/// (PHASE 6). Hozir ilovada telemetriya sink’i YO‘Q — bu siyosat har qanday
/// kelajakdagi integratsiyadan oldin majburiy filtr.
///
/// Hech qachon yuborilmaydi: qidiruv so‘rovlari, AI savollari, ismlar,
/// pasport/ID, ish raqamlari, holat tavsiflari, biologik natijalar, yozuv
/// ID’lari va har qanday erkin matn. Faqat ruxsat etilgan kalitlar va
/// marshrut **shablonlari** (`/library/entry/:id`, ID’siz) o‘tadi.
abstract final class TelemetryPolicy {
  /// Ruxsat etilgan kalitlar (qiymati qisqa enum/shablon bo‘lishi shart).
  static const allowedKeys = {
    'event',
    'route_template',
    'app_version',
    'content_pack_version',
    'locale',
    'theme',
    'platform',
    'error_type',
  };

  /// Hech qachon (hatto tasodifan) o‘tmasligi kerak bo‘lgan kalitlar.
  static const forbiddenKeys = {
    'query',
    'search',
    'question',
    'text',
    'name',
    'case',
    'case_number',
    'passport',
    'result',
    'entity_id',
    'route',
  };

  static final _idSegment = RegExp(
    r'/(entry|research|image|jurisdictions|'
    r'disciplines|tool|section)/[^/?#]+',
  );

  /// Konkret marshrutdan ID’siz shablon: `/library/entry/morphine` →
  /// `/library/entry/:id`. So‘rov parametrlari (`?q=`) olib tashlanadi.
  static String routeTemplate(String location) => location
      .split('?')
      .first
      .replaceAllMapped(_idSegment, (m) => '/${m[1]}/:id');

  /// Faqat ruxsat etilgan kalitlar; qiymatlar 64 belgidan uzun bo‘lsa yoki
  /// raqam/ID ko‘rinishida bo‘lsa — tashlanadi.
  static Map<String, String> sanitize(Map<String, Object?> raw) {
    final out = <String, String>{};
    for (final e in raw.entries) {
      if (!allowedKeys.contains(e.key) || forbiddenKeys.contains(e.key)) {
        continue;
      }
      final v = e.value?.toString() ?? '';
      if (v.isEmpty || v.length > 64) continue;
      out[e.key] = e.key == 'route_template' ? routeTemplate(v) : v;
    }
    return out;
  }
}
