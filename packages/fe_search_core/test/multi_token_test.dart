import 'package:fe_search_core/fe_search_core.dart';
import 'package:test/test.dart';

import 'fixtures/terminology_test_data.dart';

// TEST DATA — faqat nomlar; ilmiy qiymat yo‘q.
SearchTerm _t(
  String id,
  SearchCategory cat,
  String term, [
  TermKind kind = TermKind.localized,
  String? lang,
]) =>
    SearchTerm(entityId: id, category: cat, term: term, kind: kind, lang: lang);

void main() {
  group('QuerySynonyms', () {
    final s = QuerySynonyms.standard;

    test('kundalik va boshqa tildagi nomlar etanol guruhiga tushadi', () {
      for (final q in ['alkogol', 'spirt', 'алкоголь', 'спирт', 'alcohol']) {
        expect(
          s.equivalentsOf(q),
          containsAll(['ethanol', 'etanol', 'этанол']),
          reason: q,
        );
      }
    });

    test('o‘zi ro‘yxatga kirmaydi', () {
      expect(s.equivalentsOf('alkogol'), isNot(contains('alkogol')));
    });

    test('qon / кровь / blood, siydik / моча, jigar / печень', () {
      expect(s.equivalentsOf('qon'), containsAll(['blood', 'кровь']));
      expect(s.equivalentsOf('Кровь'), containsAll(['blood', 'qon']));
      expect(s.equivalentsOf('siydik'), containsAll(['urine', 'моча']));
      expect(s.equivalentsOf('печень'), containsAll(['liver', 'jigar']));
    });

    test('metod qisqartmalari: YuQX / ТСХ / TLC, GX / ГХ / GC', () {
      expect(s.equivalentsOf('YuQX'), containsAll(['TLC', 'ТСХ']));
      expect(s.equivalentsOf('тсх'), containsAll(['TLC', 'YuQX']));
      expect(s.equivalentsOf('GX'), containsAll(['GC', 'ГХ']));
      expect(s.equivalentsOf('XMS'), containsAll(['GC-MS', 'ГХ-МС']));
      expect(s.equivalentsOf('gc ms'), contains('GX-MS'));
      expect(s.equivalentsOf('thin layer chromatography'), contains('TLC'));
    });

    test('qisqa shakllar yozuv tizimini hisobga oladi (SX ≠ ТСХ)', () {
      // O‘zbekcha «SX» (suyuqlik xromatografiyasi) va kirill «ТСХ» bir xil
      // `sx` kalitiga tushadi — sinonim bo‘lib qolmasligi kerak.
      expect(s.equivalentsOf('SX'), isEmpty);
    });

    test('qo‘shimchali shakl: faqat uzun o‘zak uchun', () {
      expect(s.equivalentsOf('qondagi', allowSuffix: true), isEmpty);
      expect(s.equivalentsOf('qonun', allowSuffix: true), isEmpty);
      expect(
        s.equivalentsOf('крови', allowSuffix: true),
        containsAll(['blood', 'qon']),
      );
      expect(s.equivalentsOf('spirtli', allowSuffix: true), contains('etanol'));
      expect(s.equivalentsOf('spirtli'), isEmpty);
    });

    test('aloqasiz so‘z — bo‘sh', () {
      expect(s.equivalentsOf('morfin'), isEmpty);
      expect(QuerySynonyms.none.equivalentsOf('alkogol'), isEmpty);
    });
  });

  group('MultiTokenSearchIndex.plan', () {
    final index = MultiTokenSearchIndex(const []);

    test('so‘zlarga bo‘linadi, yordamchi so‘zlar tashlanadi', () {
      expect(index.plan('methanol in blood').map((s) => s.text), [
        'methanol',
        'blood',
      ]);
      expect(index.plan('of').map((s) => s.text), ['of']);
    });

    test('sinonim iborasi bitta qism bo‘ladi', () {
      final p = index.plan('etil spirti qonda');
      expect(p.map((s) => s.text), ['etil spirti', 'qonda']);
      expect(p.first.equivalents, contains('alkogol'));
    });
  });

  group('MultiTokenSearchIndex', () {
    final index = MultiTokenSearchIndex([
      ...terminologyTestData,
      _t(
        'G-ETOH',
        SearchCategory.guideline,
        'Ethanol in blood by GC', //
        TermKind.localized,
        'en',
      ),
      _t(
        'G-ETOH',
        SearchCategory.guideline,
        'qondagi alkogol', //
        TermKind.synonym,
        'uz',
      ),
      _t(
        'G-ETOH',
        SearchCategory.guideline,
        'HS-GC-FID', //
        TermKind.synonym,
      ),
      _t('M-HS', SearchCategory.method, 'Headspace gas chromatography'),
      _t('M-TLC', SearchCategory.method, 'Thin-layer chromatography'),
      _t('M-TLC', SearchCategory.method, 'ТСХ', TermKind.abbreviation, 'ru'),
      _t('M-LC', SearchCategory.method, 'SX-MS', TermKind.abbreviation, 'uz'),
      _t(
        'S-METH',
        SearchCategory.substance,
        'Methanol', //
        TermKind.canonical,
        'en',
      ),
      _t(
        'SP-BLOOD',
        SearchCategory.specimen,
        'Blood', //
        TermKind.localized,
        'en',
      ),
      _t(
        'SP-URINE',
        SearchCategory.specimen,
        'Urine', //
        TermKind.localized,
        'en',
      ),
    ]);

    Future<List<SearchHit>> all(String q, {String? lang}) async {
      final r = await index.search(SearchQuery(q, preferredLang: lang));
      return r.all..sort((a, b) => b.score.compareTo(a.score));
    }

    Future<List<String>> ids(String q) async => [
      for (final h in await all(q)) h.entityId,
    ];

    test('kundalik «alkogol» / «spirt» etanolni topadi (3 tilda)', () async {
      for (final q in ['alkogol', 'spirt', 'алкоголь', 'спирт', 'alcohol']) {
        final found = await ids(q);
        expect(found, contains('TEST-SUB-ETOH'), reason: q);
        expect(found, contains('G-ETOH'), reason: q);
      }
    });

    test('foydalanuvchi yozgan shakl sinonimdan yuqori turadi', () async {
      final hits = await all('qon');
      expect(hits.map((h) => h.entityId), contains('SP-BLOOD'));
      final r = await all('blood');
      expect(r.first.entityId, 'SP-BLOOD');
    });

    test('YuQX / ТСХ / TLC → yupqa qatlamli xromatografiya', () async {
      for (final q in ['YuQX', 'ТСХ', 'TLC']) {
        expect(await ids(q), contains('M-TLC'), reason: q);
      }
      // ТСХ ↔ SX (LC) chalkashmaydi.
      expect(await ids('TLC'), isNot(contains('M-LC')));
    });

    test('GX / ГХ → GC (termin ichidagi so‘z)', () async {
      for (final q in ['GX', 'ГХ']) {
        expect(await ids(q), contains('G-ETOH'), reason: q);
      }
    });

    test('ko‘p so‘zli so‘rov: barcha so‘zga mos yozuv birinchi', () async {
      final hits = await all('etanol qon');
      expect(hits, isNotEmpty);
      expect(hits.first.entityId, 'G-ETOH');
      // Faqat bitta so‘zga mos yozuvlar ham qoladi (natija bo‘sh emas).
      final found = hits.map((h) => h.entityId).toList();
      expect(found, containsAll(['TEST-SUB-ETOH', 'SP-BLOOD']));
      final top = hits.first.score;
      for (final h in hits.skip(1)) {
        expect(h.score, lessThan(top));
      }
    });

    test(
      '«methanol GC»: ikkala so‘z ham mos bo‘lmasa ham natija bor',
      () async {
        final found = await ids('methanol GC');
        expect(found, contains('S-METH'));
        expect(found, contains('G-ETOH'));
      },
    );

    test('to‘liq ibora uchramasa ham bo‘sh emas', () async {
      expect(await ids('urine zzzzqqq'), contains('SP-URINE'));
    });

    test('barcha so‘zga mos ball darajasi har doim yuqori', () async {
      final hits = await all('ethanol blood');
      final both = hits.firstWhere((h) => h.entityId == 'G-ETOH');
      final one = hits.where((h) => h.entityId != 'G-ETOH');
      for (final h in one) {
        expect(both.score, greaterThan(h.score), reason: '$h');
      }
    });

    test('oldingi xatti-harakat saqlanadi: typo, prefiks, sinonim', () async {
      expect(await ids('metamfetamn'), contains('TEST-SUB-METH'));
      expect(await ids('fentanly'), contains('TEST-SUB-FENT'));
      expect(await ids('metamf'), contains('TEST-SUB-METH'));
      expect(await ids('этиловый спирт'), contains('TEST-SUB-ETOH'));
      expect(await ids("o'lim vaqti"), contains('TEST-GLOSS-DEATH'));
      expect((await ids('amfetamin')).first, 'TEST-SUB-AMPH');
      expect(await ids('zzzzzzqqq'), isEmpty);
      expect(await ids('   '), isEmpty);
    });

    test('termin ichidagi so‘z: «chromatography»', () async {
      expect(await ids('chromatography'), containsAll(['M-HS', 'M-TLC']));
    });
  });
}
