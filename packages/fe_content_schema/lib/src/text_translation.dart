import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:meta/meta.dart';

/// Avtomatik tarjima qilinadigan manba matni turi.
///
/// Asl matn (inglizcha iqtibos yoki sarlavha) — dalil; tarjima faqat
/// o‘qishga yordam, uning o‘rnini bosmaydi.
enum TextTranslationTarget {
  claimExcerpt('claim_excerpt'),
  ruleExcerpt('rule_excerpt'),
  researchTitle('research_title');

  const TextTranslationTarget(this.code);

  final String code;

  static TextTranslationTarget fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown text translation target "$c"'),
  );
}

/// Asl manba matnining bitta tilga avtomatik tarjimasi.
///
/// Status **faqat** `machine_draft` bo‘la oladi (validator FE043, baza
/// CHECK). [sourceSha256] — tarjima qilingan paytdagi asl matn xeshi:
/// asl matn o‘zgarsa, tarjima eskirgan hisoblanadi va ko‘rsatilmaydi.
@immutable
class TextTranslation {
  const TextTranslation({
    required this.target,
    required this.targetId,
    required this.lang,
    required this.sourceSha256,
    required this.text,
    this.status = machineDraft,
  });

  /// Yagona ruxsat etilgan status.
  static const machineDraft = 'machine_draft';

  /// Tarjima qilinadigan tillar (asl til — inglizcha).
  static const languages = {'uz', 'ru'};

  final TextTranslationTarget target;
  final String targetId;
  final String lang;
  final String sourceSha256;
  final String text;
  final String status;

  /// UTF-8 matnning SHA-256 (hex) xeshi.
  static String hashOf(String source) =>
      crypto.sha256.convert(utf8.encode(source)).toString();

  /// Tarjima shu asl matn uchun hali amal qiladimi.
  bool matches(String source) => hashOf(source) == sourceSha256;

  static TextTranslation fromJson(Map<String, Object?> m) {
    String s(String k) => switch (m[k]) {
      final String v => v,
      _ => throw FormatException('text_translations: "$k" missing'),
    };
    return TextTranslation(
      target: TextTranslationTarget.fromCode(s('target_type')),
      targetId: s('target_id'),
      lang: s('lang'),
      sourceSha256: s('source_sha256'),
      text: s('text'),
      status: s('status'),
    );
  }

  Map<String, Object?> toJson() => {
    'target_type': target.code,
    'target_id': targetId,
    'lang': lang,
    'source_sha256': sourceSha256,
    'text': text,
    'status': status,
  };
}
