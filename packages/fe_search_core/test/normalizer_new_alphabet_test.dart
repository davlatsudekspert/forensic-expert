import 'package:fe_search_core/fe_search_core.dart';
import 'package:test/test.dart';

void main() {
  const n = SearchNormalizer();
  test('yangi alifbo eski yozuv bilan bir xil kalit beradi', () {
    expect(n.normalize('Özbekiston şahar'), n.normalize('O‘zbekiston shahar'));
    expect(n.normalize('boğliq çoy'), n.normalize('bog‘liq choy'));
    expect(n.searchKey('maʼlumot'), n.searchKey('ma’lumot'));
  });
}
