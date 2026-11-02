import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/lessons/narration_overlay.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';

LessonDeck _deck({String lang = 'uz', String n0 = ''}) => LessonDeck(
  topicId: 't',
  title: 'T',
  course: 'c',
  deckId: 'd',
  sourceLang: lang,
  slides: [
    LessonSlide(title: 'Kirish', narration: n0),
    const LessonSlide(title: 'Ikkinchi'),
    const LessonSlide(title: 'Uchinchi'),
  ],
);

void main() {
  const items = [
    (title: 'Kirish', text: 'Kirish matni'),
    (title: 'Boshqa sarlavha', text: 'Mos emas'),
    (title: 'Uchinchi', text: ' Uchinchi matn '),
  ];

  test('fills empty narration only where the title matches', () {
    final d = applyNarration(_deck(), items);
    expect(d.slides.map((s) => s.narration), [
      'Kirish matni',
      '',
      'Uchinchi matn',
    ]);
    expect(d.slides[0].title, 'Kirish');
  });

  test('keeps server narration', () {
    final d = applyNarration(_deck(n0: 'Server'), items);
    expect(d.slides[0].narration, 'Server');
  });

  test('ignores non-Uzbek decks and missing data', () {
    final ru = _deck(lang: 'ru');
    expect(identical(applyNarration(ru, items), ru), isTrue);
    final uz = _deck();
    expect(identical(applyNarration(uz, null), uz), isTrue);
  });

  test('asset source rejects unsafe ids', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await const AssetNarrationSource().load('../x'), isNull);
    expect(await const AssetNarrationSource().load('no-such-deck'), isNull);
  });
}
