import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';

void main() {
  const host = 'abc.supabase.co';
  const ok = 'https://$host/storage/v1/object/public/lesson-images/a.png';

  group('LessonImage.isAllowedUrl', () {
    test('backend hosti va upload.wikimedia.org ruxsat', () {
      expect(LessonImage.isAllowedUrl(ok, backendHost: host), isTrue);
      expect(
        LessonImage.isAllowedUrl(
          'https://upload.wikimedia.org/wikipedia/commons/a/a1/X.jpg',
          backendHost: host,
        ),
        isTrue,
      );
      // backend sozlanmagan bo‘lsa ham wikimedia ishlaydi.
      expect(
        LessonImage.isAllowedUrl('https://upload.wikimedia.org/x.png'),
        isTrue,
      );
    });

    test('boshqa host, http, userinfo, buzuq — rad', () {
      for (final u in [
        'https://evil.example.com/a.png',
        'http://$host/a.png',
        'https://$host.evil.com/a.png',
        'https://evil.com/$host/a.png',
        'https://user:pw@$host/a.png',
        'https://commons.wikimedia.org/a.png',
        'ftp://$host/a.png',
        '//$host/a.png',
        '',
        'not a url',
      ]) {
        expect(
          LessonImage.isAllowedUrl(u, backendHost: host),
          isFalse,
          reason: u,
        );
      }
      expect(LessonImage.isAllowedUrl(ok), isFalse); // backend yo‘q
    });
  });

  group('LessonImage.tryParse / LessonSlide.fromJson', () {
    test('to‘liq maydonlar', () {
      final i = LessonImage.tryParse({
        'url': ok,
        'caption': 'Sarlavha',
        'credit': 'Muallif, CC BY 4.0',
        'kind': 'scheme',
      }, backendHost: host)!;
      expect(i.url, ok);
      expect(i.caption, 'Sarlavha');
      expect(i.credit, 'Muallif, CC BY 4.0');
      expect(i.kind, LessonImageKind.scheme);
    });

    test('kind noma’lum → photo; caption/credit uzunligi kesiladi', () {
      final i = LessonImage.tryParse({
        'url': ok,
        'caption': 'a' * 200,
        'credit': 'b' * 300,
        'kind': '???',
      }, backendHost: host)!;
      expect(i.kind, LessonImageKind.photo);
      expect(i.caption.length, LessonImage.maxCaption);
      expect(i.credit.length, LessonImage.maxCredit);
    });

    test('yo‘q / buzuq / ishonchsiz → null', () {
      for (final raw in <Object?>[
        null,
        42,
        'str',
        <Object?>[],
        <String, Object?>{},
        {'url': 5},
        {'url': 'https://evil.com/a.png'},
        {'caption': 'faqat matn'},
      ]) {
        expect(LessonImage.tryParse(raw, backendHost: host), isNull);
      }
    });

    test('LessonSlide.fromJson: image yo‘q/buzuq bo‘lsa slayd yiqilmaydi', () {
      expect(LessonSlide.fromJson({'title': 'A'}).image, isNull);
      expect(
        LessonSlide.fromJson({'title': 'A', 'image': 'junk'}).image,
        isNull,
      );
      expect(
        LessonSlide.fromJson({
          'title': 'A',
          'image': {'url': 'https://upload.wikimedia.org/a.png'},
        }).image?.url,
        'https://upload.wikimedia.org/a.png',
      );
    });

    test('backendHostOverride ishlaydi', () {
      LessonImage.backendHostOverride = host;
      addTearDown(() => LessonImage.backendHostOverride = null);
      expect(
        LessonSlide.fromJson({
          'title': 'A',
          'image': {'url': ok, 'caption': 'c'},
        }).image?.caption,
        'c',
      );
    });
  });
}
