import 'package:fe_search_core/fe_search_core.dart';
import 'package:test/test.dart';

import 'fixtures/terminology_test_data.dart';

void main() {
  const n = SearchNormalizer();

  group('normalize', () {
    test('O‘zbek apostrof variantlari birxillashtiriladi', () {
      final forms = ['o‘lim', "o'lim", 'oʻlim', 'o`lim', 'o’lim', 'Oʻlim'];
      expect(forms.map(n.normalize).toSet(), {"o'lim"});
    });

    test('ё → е, registr, bo‘shliq va defislar', () {
      expect(n.normalize('  Ёлка  —  ТЕСТ '), 'елка тест');
      expect(n.normalize('GC-MS'), 'gc ms');
    });
  });

  group('searchKey — tillararo moslash', () {
    void same(List<String> forms) {
      final keys = forms.map(n.searchKey).toSet();
      expect(keys.length, 1, reason: '$forms → $keys');
    }

    test('EN / RU / UZ nomlari bitta kalitga tushadi', () {
      same(['methamphetamine', 'Метамфетамин', 'Metamfetamin']);
      same(['morphine', 'Морфин', 'Morfin']);
      same(['ethanol', 'Этанол', 'Etanol']);
      same(['cocaine', 'Кокаин', 'Kokain']);
      same(['fentanyl', 'Фентанил', 'Fentanil']);
      same(['paracetamol', 'Парацетамол', 'Paratsetamol']);
      same(['codeine', 'Кодеин', 'Kodein']);
    });

    test('o‘zbek kirill va lotin yozuvlari mos keladi', () {
      same(['ўлим', 'o‘lim', "o'lim", 'oʻlim']);
      same(['қон', 'qon']);
    });

    test('kalit bo‘sh satr uchun bo‘sh', () {
      expect(n.searchKey('   '), isEmpty);
    });
  });

  group('Similarity', () {
    test('editDistance transpozitsiyani 1 deb hisoblaydi', () {
      expect(Similarity.editDistance('fentanly', 'fentanyl'), 1);
      expect(Similarity.editDistance('abc', 'abc'), 0);
      expect(Similarity.editDistance('', 'abc'), 3);
    });

    test('allowedEdits qisqa so‘rovlarda xatoga ruxsat bermaydi', () {
      expect(Similarity.allowedEdits(3), 0);
      expect(Similarity.allowedEdits(5), 1);
      expect(Similarity.allowedEdits(10), 2);
    });

    test('trigramDice bir xil satr uchun 1', () {
      expect(Similarity.trigramDice('morfin', 'morfin'), 1);
    });
  });

  group('QueryClassifier', () {
    const c = QueryClassifier();

    test('CAS shakli faqat nazorat raqami to‘g‘ri bo‘lsa aniqlanadi', () {
      // Sintetik raqamlar (haqiqiy moddaga tegishli emas).
      expect(c.classify('12-34-0').kind, QueryKind.casRegistryNumberShape);
      expect(c.classify('12-34-5').kind, QueryKind.text);
    });

    test('kimyoviy formula', () {
      expect(c.classify('C10H15N').kind, QueryKind.formula);
      expect(c.classify('H2S').kind, QueryKind.formula);
      expect(c.classify('Morphine').kind, QueryKind.text);
      expect(c.classify('GC').kind, QueryKind.text);
    });
  });

  group('InMemorySearchIndex', () {
    final index = InMemorySearchIndex(terminologyTestData);

    Future<List<String>> ids(
      String q, {
      SearchCategory? cat,
      String? lang,
    }) async {
      final r = await index.search(SearchQuery(q, preferredLang: lang));
      final list = cat == null ? r.all : (r.byCategory[cat] ?? const []);
      return list.map((h) => h.entityId).toList();
    }

    test('har uch tildagi so‘rov bitta canonical yozuvni topadi', () async {
      for (final q in ['methamphetamine', 'метамфетамин', 'metamfetamin']) {
        expect(
          (await ids(q, cat: SearchCategory.substance)).first,
          'TEST-SUB-METH',
          reason: q,
        );
      }
    });

    test('typo-tolerant: xato yozilgan so‘rov', () async {
      expect(await ids('metamfetamn'), contains('TEST-SUB-METH'));
      expect(await ids('fentanly'), contains('TEST-SUB-FENT'));
      expect(await ids('морфн'), contains('TEST-SUB-MORPH'));
    });

    test('prefiks: yozilayotgan so‘rov', () async {
      expect(await ids('metamf'), contains('TEST-SUB-METH'));
      expect(await ids('парацет'), contains('TEST-SUB-PARA'));
    });

    test('sinonim orqali topish', () async {
      expect(await ids('acetaminophen'), contains('TEST-SUB-PARA'));
      expect(await ids('etil spirti'), contains('TEST-SUB-ETOH'));
      expect(await ids('этиловый спирт'), contains('TEST-SUB-ETOH'));
    });

    test('aniq moslik prefiks raqibidan ustun', () async {
      final r = await index.search(const SearchQuery('amfetamin'));
      expect(
        r.byCategory[SearchCategory.substance]!.first.entityId,
        'TEST-SUB-AMPH',
      );
    });

    test('natijalar kategoriyalarga ajratiladi', () async {
      final r = await index.search(const SearchQuery('GC MS'));
      expect(r.byCategory.keys, contains(SearchCategory.method));
      final calc = await index.search(const SearchQuery('разведение'));
      expect(
        calc.byCategory[SearchCategory.calculator]!.single.entityId,
        'TEST-CALC-C1V1',
      );
    });

    test('o‘zbek apostrofli glossary termini', () async {
      for (final q in ["o'lim vaqti", 'oʻlim vaqti', 'o`lim']) {
        expect(
          await ids(q, cat: SearchCategory.glossary),
          contains('TEST-GLOSS-DEATH'),
          reason: q,
        );
      }
    });

    test('bir yozuv bir kategoriyada faqat bir marta chiqadi', () async {
      final r = await index.search(const SearchQuery('etanol'));
      final subs = r.byCategory[SearchCategory.substance]!;
      expect(subs.where((h) => h.entityId == 'TEST-SUB-ETOH').length, 1);
    });

    test('bo‘sh va mos kelmaydigan so‘rov', () async {
      expect((await index.search(const SearchQuery('  '))).isEmpty, isTrue);
      expect(
        (await index.search(const SearchQuery('zzzzzzqqq'))).isEmpty,
        isTrue,
      );
    });

    test('foydalanuvchi tili afzalligi ballni oshiradi', () async {
      final ru = await index.search(
        const SearchQuery('etanol', preferredLang: 'ru'),
      );
      final uz = await index.search(
        const SearchQuery('etanol', preferredLang: 'uz'),
      );
      final ruHit = ru.byCategory[SearchCategory.substance]!.first;
      final uzHit = uz.byCategory[SearchCategory.substance]!.first;
      expect(ruHit.entityId, uzHit.entityId);
    });
  });
}
