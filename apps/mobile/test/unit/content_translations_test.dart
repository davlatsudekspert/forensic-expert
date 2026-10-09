import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/features/evidence/presentation/scientific_image.dart';
import 'package:forensic_expert/features/evidence/presentation/source_quote.dart';

const _src = 'Methanol oxidation leads to the formation of formaldehyde.';
const _uz =
    'Metanolning oksidlanishi formaldegid hosil bo‘lishiga olib keladi.';

ContentTranslationRow _t({
  String lang = 'uz',
  String text = _uz,
  String? sha,
  String status = 'machine_draft',
  String kind = ContentTextKind.claimExcerpt,
  String id = 'C1',
}) => ContentTranslationRow.tryParse(
  kind: kind,
  id: id,
  lang: lang,
  sourceSha256: sha ?? TextTranslation.hashOf(_src),
  text: text,
  status: status,
)!;

LocalizedContent _resolve(
  ContentTranslations m, {
  String lang = 'uz',
  String source = _src,
  String kind = ContentTextKind.claimExcerpt,
  String? originalLang,
}) => m.resolve(
  kind,
  'C1',
  source: source,
  lang: lang,
  originalLang: originalLang,
);

void main() {
  group('ContentTranslations.resolve', () {
    test('mos xesh — tarjima birinchi, asl matn saqlanadi', () {
      final r = _resolve(ContentTranslations.of([_t()]));
      expect(r.isTranslation, isTrue);
      expect(r.text, _uz);
      expect(r.textLang, 'uz');
      expect(r.original, _src);
      expect(r.originalLang, 'en');
      expect(r.status, ContentTranslationStatus.machineDraft);
      expect(r.needsReviewLabel, isTrue);
      expect(r.missingTranslation, isFalse);
    });

    test('eskirgan xesh — asl matn va «tarjima yo‘q»', () {
      final m = ContentTranslations.of([_t()]);
      final changed = _resolve(m, source: '$_src Updated.');
      expect(changed.isTranslation, isFalse);
      expect(changed.text, '$_src Updated.');
      expect(changed.missingTranslation, isTrue);
      final stale = ContentTranslations.of([
        _t(sha: TextTranslation.hashOf('older excerpt')),
      ]);
      expect(_resolve(stale).isTranslation, isFalse);
    });

    test('UI tili = asl til — har doim asl matn, belgisiz', () {
      final m = ContentTranslations.of([_t(), _t(lang: 'en', text: 'x')]);
      final r = _resolve(m, lang: 'en');
      expect(r.isTranslation, isFalse);
      expect(r.missingTranslation, isFalse);
      expect(r.text, _src);
      // Rus tilidagi asl manba — en UI uchun tarjima ishlatiladi.
      final ru = _resolve(
        ContentTranslations.of([_t(lang: 'en', text: 'English gloss')]),
        lang: 'en',
        originalLang: 'ru',
      );
      expect(ru.text, 'English gloss');
      expect(ru.originalLang, 'ru');
    });

    test('fallback: tarjima yo‘q tilda asl matn + missingTranslation', () {
      final m = ContentTranslations.of([_t()]);
      final r = _resolve(m, lang: 'ru');
      expect(r.text, _src);
      expect(r.textLang, 'en');
      expect(r.requestedLang, 'ru');
      expect(r.missingTranslation, isTrue);
      expect(r.needsReviewLabel, isFalse);
      // Boshqa tur so‘ralsa — tarjima ishlatilmaydi.
      expect(
        _resolve(m, kind: ContentTextKind.researchTitle).isTranslation,
        isFalse,
      );
    });

    test('noma’lum tur, status va til — xato emas, e’tiborsiz', () {
      for (final s in ['verified', 'translated', '', 'REVIEWED']) {
        expect(
          ContentTranslationRow.tryParse(
            kind: ContentTextKind.claimExcerpt,
            id: 'C1',
            lang: 'uz',
            sourceSha256: TextTranslation.hashOf(_src),
            text: _uz,
            status: s,
          ),
          isNull,
          reason: s,
        );
      }
      expect(
        ContentTranslationRow.tryParse(
          kind: 'future_kind',
          id: 'X',
          lang: 'uz',
          sourceSha256: TextTranslation.hashOf(_src),
          text: _uz,
          status: 'machine_draft',
        ),
        isNotNull,
      );
      for (final bad in [
        (lang: 'kk', sha: TextTranslation.hashOf(_src)),
        (lang: 'uz', sha: 'short'),
      ]) {
        expect(
          ContentTranslationRow.tryParse(
            kind: 'claim_excerpt',
            id: 'C1',
            lang: bad.lang,
            sourceSha256: bad.sha,
            text: _uz,
            status: 'machine_draft',
          ),
          isNull,
        );
      }
      expect(
        ContentTranslationRow.tryParse(
          kind: null,
          id: 1,
          lang: 'uz',
          sourceSha256: null,
          text: _uz,
          status: 'machine_draft',
        ),
        isNull,
      );
    });

    test(
      'faqat reviewed/official «tekshirilmagan» belgisini olib tashlaydi',
      () {
        for (final (code, label) in [
          ('machine_draft', true),
          ('terminology_checked', true),
          ('claim_checked', true),
          ('reviewed', false),
          ('official', false),
        ]) {
          final r = _resolve(ContentTranslations.of([_t(status: code)]));
          expect(r.isTranslation, isTrue, reason: code);
          expect(r.needsReviewLabel, label, reason: code);
        }
      },
    );

    test('bo‘sh yoki asl bilan bir xil matn — tarjima emas', () {
      expect(
        ContentTranslationRow.tryParse(
          kind: 'claim_excerpt',
          id: 'C1',
          lang: 'uz',
          sourceSha256: TextTranslation.hashOf(_src),
          text: ' ',
          status: 'machine_draft',
        ),
        isNull,
      );
      expect(
        _resolve(ContentTranslations.of([_t(text: _src)])).isTranslation,
        isFalse,
      );
    });
  });

  group('resolveLocalizedMap (hujjat/idora nomlari)', () {
    const titles = {
      'en': 'Law on Narcotic Drugs',
      'ru': 'Закон о наркотических средствах',
      'uz': 'Giyohvandlik vositalari to‘g‘risidagi qonun',
      '_date_precision': 'day',
    };
    test('lang → asl (rasmiy) → en tartibi', () {
      final uz = resolveLocalizedMap(
        titles,
        lang: 'uz',
        originalLang: 'ru',
        translationStatus: 'machine_draft',
      );
      expect(uz.text, titles['uz']);
      expect(uz.original, titles['ru']);
      expect(uz.needsReviewLabel, isTrue);
      final ru = resolveLocalizedMap(titles, lang: 'ru', originalLang: 'ru');
      expect(ru.isTranslation, isFalse);
      expect(ru.missingTranslation, isFalse);
      // Faqat inglizcha + rasmiy nemischa: uz → rasmiy asl (de), en emas.
      final de = resolveLocalizedMap(
        const {'en': 'Narcotics Act', 'de': 'Betäubungsmittelgesetz'},
        lang: 'uz',
        originalLang: 'de',
      );
      expect(de.text, 'Betäubungsmittelgesetz');
      expect(de.missingTranslation, isTrue);
      // Asl tili ko‘rsatilmagan — en.
      final en = resolveLocalizedMap(const {'en': 'Green List'}, lang: 'ru');
      expect(en.text, 'Green List');
      expect(en.originalLang, 'en');
      expect(en.missingTranslation, isTrue);
    });

    test('noma’lum translation_status — tekshirilmagan deb olinadi', () {
      final r = resolveLocalizedMap(
        titles,
        lang: 'uz',
        originalLang: 'en',
        translationStatus: 'translated',
      );
      expect(r.status, ContentTranslationStatus.machineDraft);
      expect(r.needsReviewLabel, isTrue);
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
      for (final free in ['3. Toxicokinetic', 'Metabolism of APAP']) {
        expect(localizedSectionName(uz, free), free);
      }
      // Real-ilova QA (2026-10-09): pipeline izohi va raqamli standart
      // bo‘limlar ham lokallashtiriladi.
      expect(
        localizedSectionName(
          uz,
          "(untitled opening section, before 'ADH Variants')",
        ),
        'Kirish',
      );
      expect(localizedSectionName(uz, '1. Introduction'), 'Kirish');
    });
  });

  group('rasm atribusiyasi (real-ilova QA)', () {
    test(
      'standart shablonlar lokallashtiriladi, boshqalar o‘zgarmaydi',
      () async {
        final uz = await AppLocalizations.delegate.load(const Locale('uz'));
        expect(
          localizedAttribution(
            uz,
            'Structure drawn from PubChem CID 702 SMILES with RDKit',
          ),
          'Struktura PubChem CID 702 SMILES asosida RDKit bilan chizilgan',
        );
        expect(
          localizedAttribution(uz, 'Original schematic — FORENSIC EXPERT'),
          'Asl sxema — FORENSIC EXPERT',
        );
        const other = 'Bertol E et al., Journal of enzyme inhibition';
        expect(localizedAttribution(uz, other), other);
      },
    );
  });
}
