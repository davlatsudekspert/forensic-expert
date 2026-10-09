import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/evidence/machine_translations.dart';
import 'package:forensic_expert/features/evidence/presentation/source_quote.dart';

const _src = 'Methanol oxidation leads to the formation of formaldehyde.';
const _uz =
    'Metanolning oksidlanishi formaldegid hosil bo‘lishiga olib keladi.';

TextTranslation _t({
  String lang = 'uz',
  String text = _uz,
  String? sha,
  String status = TextTranslation.machineDraft,
  TextTranslationTarget target = TextTranslationTarget.claimExcerpt,
}) => TextTranslation(
  target: target,
  targetId: 'C1',
  lang: lang,
  sourceSha256: sha ?? TextTranslation.hashOf(_src),
  text: text,
  status: status,
);

String? _lookup(
  MachineTranslations m, {
  String lang = 'uz',
  String source = _src,
  TextTranslationTarget target = TextTranslationTarget.claimExcerpt,
}) => m.lookup(target: target, id: 'C1', source: source, lang: lang);

void main() {
  group('MachineTranslations.lookup', () {
    test('mos xesh va machine_draft — tarjima qaytadi', () {
      expect(_lookup(MachineTranslations.of([_t()])), _uz);
    });

    test('asl matn o‘zgargan (eskirgan xesh) — tarjima ko‘rsatilmaydi', () {
      final m = MachineTranslations.of([_t()]);
      expect(_lookup(m, source: '$_src Updated.'), isNull);
      final stale = MachineTranslations.of([
        _t(sha: TextTranslation.hashOf('older excerpt')),
      ]);
      expect(_lookup(stale), isNull);
    });

    test('status hech qachon «tekshirilgan» emas — boshqa status rad', () {
      for (final s in ['reviewed', 'verified', 'translated']) {
        final m = MachineTranslations.of([_t(status: s)]);
        expect(m.isEmpty, isTrue, reason: s);
        expect(_lookup(m), isNull, reason: s);
      }
    });

    test('ingliz tilida va boshqa maqsad turida tarjima yo‘q', () {
      final m = MachineTranslations.of([
        _t(),
        _t(lang: 'ru', text: 'Окисление'),
      ]);
      expect(_lookup(m, lang: 'en'), isNull);
      expect(_lookup(m, lang: 'ru'), 'Окисление');
      expect(_lookup(m, target: TextTranslationTarget.researchTitle), isNull);
    });

    test('bo‘sh yoki asl bilan bir xil matn — ko‘rsatilmaydi', () {
      expect(_lookup(MachineTranslations.of([_t(text: ' ')])), isNull);
      expect(_lookup(MachineTranslations.of([_t(text: _src)])), isNull);
    });
  });

  group('bo‘lim nomlari', () {
    test('BioC kodlari lokallashtiriladi, erkin matn o‘zgarmaydi', () async {
      final uz = await AppLocalizations.delegate.load(const Locale('uz'));
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      expect(localizedSectionName(uz, 'DISCUSS'), 'Muhokama');
      expect(localizedSectionName(uz, 'INTRO'), 'Kirish');
      expect(localizedSectionName(uz, 'ABSTRACT'), 'Annotatsiya');
      expect(localizedSectionName(ru, 'RESULTS'), 'Результаты');
      expect(
        localizedSectionName(ru, 'Computed Properties'),
        'Вычисленные свойства',
      );
      expect(localizedSectionRef(uz, 'METHODS'), '§ Usullar');
      for (final free in [
        '3. Toxicokinetic',
        'Metabolism of APAP',
        "(untitled opening section, before 'ADH Variants')",
      ]) {
        expect(localizedSectionName(uz, free), free);
      }
    });
  });
}
