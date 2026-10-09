import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/evidence/citation_format.dart';
import 'package:forensic_expert/domain/evidence/evidence_models.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

/// Iqtibos eksporti: aniq kutilgan satrlar (GOST / Vancouver / APA).
void main() {
  // references.json’dagi haqiqiy yozuv (PubMed orqali tekshirilgan).
  final article = CitationData.fromGuidelineReference(
    GuidelineReference.fromJson({
      'key': 'kugelberg2007',
      'type': 'journal_article',
      'authors': ['Kugelberg FC', 'Jones AW'],
      'title':
          'Interpreting results of ethanol analysis in postmortem specimens: '
          'a review of the literature',
      'journal': 'Forensic Science International',
      'year': 2007,
      'volume': '165',
      'issue': '1',
      'pages': '10-29',
      'doi': '10.1016/j.forsciint.2006.05.004',
      'pmid': '16782292',
      'verified_on': '2026-10-08',
    }),
  );

  final web = CitationData.fromSource(
    SourceView(
      sourceId: 'SRC-PUBCHEM-702',
      title: 'PubChem Compound Summary for CID 702 (ethanol)',
      sourceType: 'database',
      evidenceLevel: 'C',
      licenseMode: 'openReuse',
      identifierVerified: true,
      organization: 'National Center for Biotechnology Information (NCBI)',
      url: 'https://pubchem.ncbi.nlm.nih.gov/compound/702',
      accessedDate: DateTime(2026, 10, 4),
    ),
  );

  const textbook = CitationData(
    kind: CitationKind.book,
    authors: ['Yuldashev Z.A. va boshq.'],
    title: 'Giyohvand moddalar tahlili',
    subtitle: 'O‘quv qo‘llanma',
    place: 'Toshkent',
    publisher: 'TFI',
    year: '2024',
  );

  group('jurnal maqolasi (DOI + PMID)', () {
    test('GOST', () {
      expect(
        formatCitation(article, CitationStyle.gost),
        'Kugelberg F.C., Jones A.W. Interpreting results of ethanol analysis '
        'in postmortem specimens: a review of the literature // Forensic '
        'Science International. – 2007. – Vol. 165, No. 1. – P. 10–29. – '
        'DOI: 10.1016/j.forsciint.2006.05.004. – PMID: 16782292.',
      );
    });
    test('Vancouver', () {
      expect(
        formatCitation(article, CitationStyle.vancouver),
        'Kugelberg FC, Jones AW. Interpreting results of ethanol analysis in '
        'postmortem specimens: a review of the literature. Forensic Science '
        'International. 2007;165(1):10-29. '
        'doi:10.1016/j.forsciint.2006.05.004. PMID: 16782292.',
      );
    });
    test('APA 7', () {
      expect(
        formatCitation(article, CitationStyle.apa),
        'Kugelberg, F. C., & Jones, A. W. (2007). Interpreting results of '
        'ethanol analysis in postmortem specimens: a review of the '
        'literature. Forensic Science International, 165(1), 10–29. '
        'https://doi.org/10.1016/j.forsciint.2006.05.004',
      );
    });
    test('4+ muallif: GOST sarlavhadan boshlanadi, [et al.]', () {
      final six = CitationData.fromGuidelineReference(
        GuidelineReference.fromJson({
          'key': 'lin2020',
          'authors': ['Lin Z', 'Wang H', 'Jones AW', 'Wang F', 'Zhang Y'],
          'title': 'Evaluation of ways to differentiate sources of ethanol',
          'journal': 'International Journal of Legal Medicine',
          'year': 2020,
          'volume': '134',
          'issue': '6',
          'pages': '2081-2093',
          'doi': '10.1007/s00414-020-02415-9',
        }),
      );
      expect(
        formatCitation(six, CitationStyle.gost),
        'Evaluation of ways to differentiate sources of ethanol / Z. Lin, '
        'H. Wang, A.W. Jones [et al.] // International Journal of Legal '
        'Medicine. – 2020. – Vol. 134, No. 6. – P. 2081–2093. – '
        'DOI: 10.1007/s00414-020-02415-9.',
      );
    });
    test('ruscha manba: Т./№/С. va ruscha belgilar', () {
      const ru = CitationData(
        kind: CitationKind.article,
        authors: ['Иванов И.И.', 'Петров П.П.'],
        title: 'Определение этанола в крови',
        container: 'Судебно-медицинская экспертиза',
        year: '2019',
        volume: '62',
        issue: '3',
        pages: '45-48',
      );
      expect(
        formatCitation(ru, CitationStyle.gost, lang: CitationLang.ru),
        'Иванов И.И., Петров П.П. Определение этанола в крови // '
        'Судебно-медицинская экспертиза. – 2019. – Т. 62, № 3. – С. 45–48.',
      );
    });
  });

  group('veb-manba (murojaat sanasi bilan)', () {
    test('GOST uz: [Elektron resurs], URL, murojaat sanasi', () {
      expect(
        formatCitation(web, CitationStyle.gost),
        'PubChem Compound Summary for CID 702 (ethanol) [Elektron resurs] / '
        'National Center for Biotechnology Information (NCBI). – '
        'URL: https://pubchem.ncbi.nlm.nih.gov/compound/702 '
        '(murojaat sanasi: 04.10.2026).',
      );
    });
    test('GOST ru: [Электронный ресурс], дата обращения', () {
      expect(
        formatCitation(web, CitationStyle.gost, lang: CitationLang.ru),
        'PubChem Compound Summary for CID 702 (ethanol) '
        '[Электронный ресурс] / National Center for Biotechnology '
        'Information (NCBI). – URL: '
        'https://pubchem.ncbi.nlm.nih.gov/compound/702 '
        '(дата обращения: 04.10.2026).',
      );
    });
    test('Vancouver', () {
      expect(
        formatCitation(web, CitationStyle.vancouver),
        'National Center for Biotechnology Information (NCBI). PubChem '
        'Compound Summary for CID 702 (ethanol) [Internet]. '
        '[cited 2026 Oct 4]. Available from: '
        'https://pubchem.ncbi.nlm.nih.gov/compound/702',
      );
    });
    test('APA 7: yil yo‘q — (n.d.)', () {
      expect(
        formatCitation(web, CitationStyle.apa),
        'National Center for Biotechnology Information (NCBI). (n.d.). '
        'PubChem Compound Summary for CID 702 (ethanol). Retrieved '
        'October 4, 2026, from https://pubchem.ncbi.nlm.nih.gov/compound/702',
      );
    });
    test('standart (tashkilot muallif, nashriyot, yil, URL)', () {
      final asb = CitationData.fromGuidelineReference(
        GuidelineReference.fromJson({
          'key': 'asb036_2019',
          'type': 'standard',
          'authors': ['AAFS Standards Board (ASB)'],
          'title': 'ANSI/ASB Standard 036',
          'publisher': 'American Academy of Forensic Sciences',
          'year': 2019,
          'url': 'https://www.aafs.org/asb-standard/x',
          'verified_on': '2026-10-08',
        }),
      );
      expect(
        formatCitation(asb, CitationStyle.gost),
        'ANSI/ASB Standard 036 [Elektron resurs] / AAFS Standards Board '
        '(ASB). – American Academy of Forensic Sciences, 2019. – '
        'URL: https://www.aafs.org/asb-standard/x '
        '(murojaat sanasi: 08.10.2026).',
      );
    });
  });

  group('kitob / o‘quv qo‘llanma', () {
    test('GOST: «va boshq.» → [va boshq.], joy : nashriyot, yil', () {
      expect(
        formatCitation(textbook, CitationStyle.gost),
        'Yuldashev Z.A. Giyohvand moddalar tahlili : o‘quv qo‘llanma / '
        'Z.A. Yuldashev [va boshq.]. – Toshkent : TFI, 2024.',
      );
    });
    test('Vancouver', () {
      expect(
        formatCitation(textbook, CitationStyle.vancouver),
        'Yuldashev ZA, et al. Giyohvand moddalar tahlili: O‘quv qo‘llanma. '
        'Toshkent: TFI; 2024.',
      );
    });
    test('APA 7', () {
      expect(
        formatCitation(textbook, CitationStyle.apa),
        'Yuldashev, Z. A., et al. (2024). Giyohvand moddalar tahlili '
        '[O‘quv qo‘llanma]. TFI.',
      );
    });
    test('kontent manbasi (book): mualliflar ro‘yxatidan', () {
      final s = CitationData.fromSource(
        const SourceView(
          sourceId: 'SRC-BOOK',
          title: 'Toksikologik kimyo',
          sourceType: 'book',
          evidenceLevel: 'C',
          licenseMode: 'citeOnly',
          identifierVerified: false,
          organization: 'TFI',
          year: 2025,
          authors: ['Yuldashev Z.A.', 'va boshq.'],
        ),
      );
      expect(
        formatCitation(s, CitationStyle.gost),
        'Yuldashev Z.A. Toksikologik kimyo / Z.A. Yuldashev [va boshq.]. – '
        'TFI, 2025.',
      );
    });
  });

  group('yo‘q maydonlar uydirilmaydi', () {
    const bare = CitationData(
      kind: CitationKind.article,
      title: 'Ethanol Forensic Toxicology',
    );
    test('faqat sarlavha', () {
      expect(
        formatCitation(bare, CitationStyle.gost),
        'Ethanol Forensic Toxicology.',
      );
      expect(
        formatCitation(bare, CitationStyle.vancouver),
        'Ethanol Forensic Toxicology.',
      );
      expect(
        formatCitation(bare, CitationStyle.apa),
        'Ethanol Forensic Toxicology. (n.d.).',
      );
    });
    test('PubMed yozuvi: PMID bor, DOI yo‘q — URL takrorlanmaydi', () {
      final r = CitationData.fromResearch(
        ResearchEntry(
          id: 'RS-1',
          kind: ResearchKind.journalArticle,
          title: 'Ethanol Forensic Toxicology',
          evidenceLevel: 'B',
          peerReviewed: true,
          status: ScientificStatus.needsReview,
          authors: const ['Perry PJ', 'Doroudgar S', 'Van Dyke P'],
          container:
              'The journal of the American Academy of Psychiatry '
              'and the Law',
          year: '2017',
          pmid: '29282233',
          url: 'https://pubmed.ncbi.nlm.nih.gov/29282233/',
          accessedDate: DateTime(2026, 10, 4),
        ),
      );
      final g = formatCitation(r, CitationStyle.gost);
      expect(
        g,
        'Perry P.J., Doroudgar S., Van Dyke P. Ethanol Forensic Toxicology '
        '// The journal of the American Academy of Psychiatry and the Law. '
        '– 2017. – PMID: 29282233.',
      );
      expect(g, isNot(contains('Vol.')));
      expect(g, isNot(contains('URL')));
    });
    test('raqamlangan ro‘yxat', () {
      expect(
        formatReferenceList([textbook, bare], CitationStyle.gost),
        '1. Yuldashev Z.A. Giyohvand moddalar tahlili : o‘quv qo‘llanma / '
        'Z.A. Yuldashev [va boshq.]. – Toshkent : TFI, 2024.\n'
        '2. Ethanol Forensic Toxicology.',
      );
    });
    test('standart uslub: uz/ru — GOST, en — APA', () {
      expect(defaultCitationStyle('uz'), CitationStyle.gost);
      expect(defaultCitationStyle('ru'), CitationStyle.gost);
      expect(defaultCitationStyle('en'), CitationStyle.apa);
    });
  });
}
