import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/audio/lesson_audio_remote.dart';

void main() {
  test('URL: ru/en, 2 xonali slayd raqami', () {
    expect(
      lessonAudioUrl(deckId: 'ktp26-u-38', lang: 'en', slide: 1),
      '$kLessonAudioBase/ktp26-u-38/en/01.mp3',
    );
    expect(
      lessonAudioUrl(deckId: 'ktp26-u-38', lang: 'ru', slide: 12),
      endsWith('/ktp26-u-38/ru/12.mp3'),
    );
  });

  test('URL: uz va noma’lum til — null (R2 da uz audio yo‘q)', () {
    expect(lessonAudioUrl(deckId: 'ktp26-u-38', lang: 'uz', slide: 1), isNull);
    expect(lessonAudioUrl(deckId: 'ktp26-u-38', lang: 'de', slide: 1), isNull);
  });

  test('URL: xavfsiz bo‘lmagan deck id va slayd oralig‘i — null', () {
    expect(lessonAudioUrl(deckId: '../x', lang: 'en', slide: 1), isNull);
    expect(lessonAudioUrl(deckId: 'a b', lang: 'en', slide: 1), isNull);
    expect(lessonAudioUrl(deckId: 'ok', lang: 'en', slide: 0), isNull);
    expect(lessonAudioUrl(deckId: 'ok', lang: 'en', slide: 1000), isNull);
  });
}
