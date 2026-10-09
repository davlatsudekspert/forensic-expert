import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

/// Asl iqtibos va sarlavhalarning avtomatik tarjimalari indeksi.
///
/// Ilmiy halollik qoidalari:
/// * asl matn (inglizcha) — dalil; u hech qachon almashtirilmaydi, tarjima
///   faqat uning **ostida** ko‘rsatiladi;
/// * faqat `machine_draft` status qabul qilinadi — «tekshirilgan» tarjima
///   bu qatlamda mavjud emas (boshqa status kelsa, tarjima e’tiborsiz);
/// * tarjima qilingan paytdagi asl matn xeshi joriy matnga mos kelmasa,
///   tarjima eskirgan va ko‘rsatilmaydi;
/// * ingliz tilida tarjima ko‘rsatilmaydi (asl til).
@immutable
class MachineTranslations {
  const MachineTranslations(this._byKey);

  static const empty = MachineTranslations({});

  final Map<String, TextTranslation> _byKey;

  factory MachineTranslations.of(Iterable<TextTranslation> rows) =>
      MachineTranslations({
        for (final t in rows)
          if (t.status == TextTranslation.machineDraft)
            _key(t.target, t.targetId, t.lang): t,
      });

  static String _key(TextTranslationTarget target, String id, String lang) =>
      '${target.code}|$id|$lang';

  bool get isEmpty => _byKey.isEmpty;
  int get length => _byKey.length;

  /// [source] — ekranda ko‘rsatilayotgan asl matn. Tarjima faqat shu matn
  /// uchun qilingan bo‘lsa (xesh mos) qaytariladi.
  String? lookup({
    required TextTranslationTarget target,
    required String id,
    required String source,
    required String lang,
  }) {
    if (!TextTranslation.languages.contains(lang)) return null;
    final t = _byKey[_key(target, id, lang)];
    if (t == null || t.status != TextTranslation.machineDraft) return null;
    if (!t.matches(source)) return null;
    final text = t.text.trim();
    return text.isEmpty || text == source.trim() ? null : text;
  }
}
