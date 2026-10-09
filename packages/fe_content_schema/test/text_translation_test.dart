import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

const _src = Source(
  sourceId: 'S1',
  sourceType: SourceType.journalArticle,
  title: 't',
  tier: SourceTier.tier2,
  evidenceLevel: EvidenceLevel.b,
  licenseMode: SourceLicenseMode.openReuse,
);

const _excerpt = 'Methanol oxidation leads to the formation of formaldehyde.';

const _claim = Claim(
  claimId: 'C1',
  entityType: EntityType.substance,
  entityId: 'e1',
  field: 'metabolites',
  value: {'excerpt': _excerpt},
  domain: ContentDomain.tox,
  declaredStatus: ScientificStatus.needsReview,
  evidenceLevel: EvidenceLevel.b,
);

TextTranslation _t({
  String id = 'C1',
  String lang = 'uz',
  String? sha,
  String text =
      'Metanolning oksidlanishi formaldegid hosil bo‘lishiga olib keladi.',
  String status = TextTranslation.machineDraft,
}) => TextTranslation(
  target: TextTranslationTarget.claimExcerpt,
  targetId: id,
  lang: lang,
  sourceSha256: sha ?? TextTranslation.hashOf(_excerpt),
  text: text,
  status: status,
);

Set<String> _codes(List<TextTranslation> tt) => {
  for (final i
      in const ContentValidator()
          .validate(
            ContentBundle(
              channel: BundleChannel.development,
              sources: const [_src],
              claims: const [_claim],
              citations: const [Citation(claimId: 'C1', sourceId: 'S1')],
              knownEntityIds: const {'e1'},
              textTranslations: tt,
            ),
          )
          .issues)
    i.code,
};

void main() {
  test('hashOf — UTF-8 SHA-256 hex', () {
    expect(
      TextTranslation.hashOf('abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
    expect(_t().matches(_excerpt), isTrue);
    expect(_t().matches('$_excerpt '), isFalse);
  });

  test('FE043: machine_draft, mos xesh — xato yo‘q', () {
    expect(
      _codes([_t(), _t(lang: 'ru', text: 'Окисление метанола…')]),
      isNot(contains(RuleCodes.textTranslationInvalid)),
    );
  });

  test('FE043: tekshirilgan/ko‘rib chiqilgan status rad etiladi', () {
    for (final s in ['reviewed', 'verified', 'translated']) {
      expect(
        _codes([_t(status: s)]),
        contains(RuleCodes.textTranslationInvalid),
        reason: s,
      );
    }
  });

  test('FE043: eskirgan xesh, yo‘q manba, til, takror, bo‘sh matn', () {
    expect(
      _codes([_t(sha: TextTranslation.hashOf('old text'))]),
      contains(RuleCodes.textTranslationInvalid),
    );
    expect(
      _codes([_t(id: 'C-MISSING')]),
      contains(RuleCodes.textTranslationInvalid),
    );
    expect(
      _codes([_t(lang: 'en')]),
      contains(RuleCodes.textTranslationInvalid),
    );
    expect(_codes([_t(), _t()]), contains(RuleCodes.textTranslationInvalid));
    expect(
      _codes([_t(text: '  ')]),
      contains(RuleCodes.textTranslationInvalid),
    );
  });

  test('fromJson/toJson aylanishi', () {
    final t = _t();
    final back = TextTranslation.fromJson(t.toJson());
    expect(back.toJson(), t.toJson());
    expect(
      () => TextTranslation.fromJson({...t.toJson(), 'target_type': 'x'}),
      throwsFormatException,
    );
  });
}
