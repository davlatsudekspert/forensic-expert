import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/data/remote/supabase_tts.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/domain/ports/backend_ports.dart';
import 'package:forensic_expert/domain/ports/tts_ports.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_slide_view.dart';

class _Auth implements AuthRepository {
  _Auth(this.token);

  String? token;

  @override
  Future<String?> accessToken() async => token;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<int> _wav([int extra = 200]) => [
  ...'RIFF'.codeUnits,
  ...List.filled(extra, 1),
];

class _Http implements TtsHttp {
  _Http(this.reply);

  Future<TtsHttpResponse> Function(Map<String, Object?> body) reply;
  final calls =
      <({Uri uri, Map<String, String> headers, Map<String, Object?> body})>[];

  @override
  Future<TtsHttpResponse> postJson(
    Uri uri, {
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) {
    calls.add((uri: uri, headers: headers, body: body));
    return reply(body);
  }
}

TtsHttpResponse _json(int status, String error) =>
    TtsHttpResponse(status, utf8.encode(jsonEncode({'error': error})));

void main() {
  late Directory dir;
  final cfg = SupabaseConfig(
    url: Uri.parse('https://x.supabase.co/'),
    anonKey: 'anon-test',
  );

  setUp(() => dir = Directory.systemTemp.createTempSync('fe_tts_test_'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  SupabaseTtsService svc(
    _Http http, {
    String? token = 'tok',
    String voice = '',
  }) => SupabaseTtsService(
    config: cfg,
    auth: _Auth(token),
    http: http,
    cacheDir: () async => Directory('${dir.path}/tts'),
    voice: voice,
  );

  Future<TtsFailure> failure(Future<TtsAudio> f) async {
    try {
      await f;
    } on TtsException catch (e) {
      return e.failure;
    }
    fail('TtsException kutilgan edi');
  }

  group('SupabaseTtsService', () {
    test('200 wav: fayl keshlanadi, ikkinchi marta tarmoqsiz', () async {
      final http = _Http((_) async => TtsHttpResponse(200, _wav()));
      final s = svc(http);
      final a = await s.synthesize('Salom dunyo');
      expect(a.paths, hasLength(1));
      expect(File(a.paths.single).readAsBytesSync(), _wav());
      expect(a.paths.single, endsWith('.wav'));
      expect(http.calls, hasLength(1));
      final c = http.calls.single;
      expect(c.uri.toString(), 'https://x.supabase.co/functions/v1/tts');
      expect(c.headers['apikey'], 'anon-test');
      expect(c.headers['Authorization'], 'Bearer tok');
      expect(c.body, {'text': 'Salom dunyo'}); // voice yo‘q — server standarti

      final b = await s.synthesize('Salom dunyo');
      expect(b.paths, a.paths);
      expect(
        http.calls,
        hasLength(1),
        reason: 'keshdan — tarmoq chaqirilmaydi',
      );
      // Yarim yozilgan fayl qolmaydi.
      expect(
        Directory('${dir.path}/tts').listSync().map((e) => e.path),
        everyElement(endsWith('.wav')),
      );
    });

    test('kesh kirmagan/oflayn holatda ham ishlaydi (yangi nusxa)', () async {
      final http = _Http((_) async => TtsHttpResponse(200, _wav()));
      final first = await svc(http).synthesize('Matn');
      final offline = _Http((_) async => throw const SocketException('x'));
      final out = await svc(offline, token: null).synthesize('Matn');
      expect(out.paths, first.paths);
      expect(offline.calls, isEmpty);
    });

    test(
      'voice berilsa so‘rovga qo‘shiladi va kesh kaliti o‘zgaradi',
      () async {
        final http = _Http((_) async => TtsHttpResponse(200, _wav()));
        final a = await svc(http).synthesize('Matn');
        final b = await svc(http, voice: 'Kore').synthesize('Matn');
        expect(http.calls.last.body, {'text': 'Matn', 'voice': 'Kore'});
        expect(b.paths.single, isNot(a.paths.single));
        expect(
          SupabaseTtsService.cacheKey('Kore', '', 'Matn'),
          hasLength(64), // sha256 hex
        );
      },
    );

    test('429 too_many_requests → dailyLimit', () async {
      final http = _Http((_) async => _json(429, 'too_many_requests'));
      expect(await failure(svc(http).synthesize('a')), TtsFailure.dailyLimit);
    });

    test('429 quota → busy', () async {
      final http = _Http((_) async => _json(429, 'quota'));
      expect(await failure(svc(http).synthesize('a')), TtsFailure.busy);
    });

    test('401 → notSignedIn; token yo‘q → tarmoqsiz notSignedIn', () async {
      final http = _Http((_) async => _json(401, 'unauthorized'));
      expect(await failure(svc(http).synthesize('a')), TtsFailure.notSignedIn);
      final none = _Http((_) async => fail('chaqirilmasligi kerak'));
      expect(
        await failure(svc(none, token: null).synthesize('a')),
        TtsFailure.notSignedIn,
      );
      expect(none.calls, isEmpty);
    });

    test('socket xato → offline; kutish vaqti → busy', () async {
      final off = _Http((_) async => throw const SocketException('no net'));
      expect(await failure(svc(off).synthesize('a')), TtsFailure.offline);
      final to = _Http((_) async => throw TimeoutException('slow'));
      expect(await failure(svc(to).synthesize('a')), TtsFailure.busy);
    });

    test('413/422/502/504/503 kodlari', () async {
      Future<TtsFailure> run(TtsHttpResponse r) =>
          failure(svc(_Http((_) async => r)).synthesize('a'));
      expect(await run(_json(413, 'too_long')), TtsFailure.tooLong);
      expect(await run(_json(422, 'empty')), TtsFailure.empty);
      expect(await run(_json(502, 'upstream')), TtsFailure.busy);
      expect(await run(_json(504, 'timeout')), TtsFailure.busy);
      expect(await run(_json(503, 'not_configured')), TtsFailure.notConfigured);
      expect(await run(const TtsHttpResponse(500, [])), TtsFailure.busy);
    });

    test('xato javob keshga yozilmaydi; 200 lekin wav emas → busy', () async {
      final bad = _Http(
        (_) async => TtsHttpResponse(200, utf8.encode('<html>')),
      );
      expect(await failure(svc(bad).synthesize('a')), TtsFailure.busy);
      final t = Directory('${dir.path}/tts');
      expect(!t.existsSync() || t.listSync().isEmpty, isTrue);
    });

    test('bo‘sh matn → empty (tarmoqsiz)', () async {
      final http = _Http((_) async => fail('chaqirilmasligi kerak'));
      expect(await failure(svc(http).synthesize('  \n ')), TtsFailure.empty);
    });

    test('uzun matn: bo‘laklarga bo‘linib ketma-ket sintez qilinadi', () async {
      final http = _Http((_) async => TtsHttpResponse(200, _wav()));
      final p1 = List.filled(3, 'a' * 1300).join('\n\n'); // ≈ 3900
      final p2 = 'b' * 500;
      final a = await svc(http).synthesize('$p1\n\n$p2');
      expect(a.paths, hasLength(2));
      expect(http.calls.map((c) => (c.body['text'] as String).length), [
        3904,
        500,
      ]);
      // Qayta chaqiruv — to‘liq keshdan.
      await svc(http).synthesize('$p1\n\n$p2');
      expect(http.calls, hasLength(2));
    });
  });

  group('splitTtsText', () {
    test('qisqa matn bitta bo‘lak; bo‘sh — bo‘sh ro‘yxat', () {
      expect(splitTtsText(' Salom '), ['Salom']);
      expect(splitTtsText('  '), isEmpty);
    });

    test('hamma bo‘lak ≤ chegara, matn yo‘qolmaydi', () {
      final text = [
        for (var i = 0; i < 30; i++) 'Gap raqami $i. ' * 40,
        'x' * 9000, // bo‘shliqsiz uzun abzas — qat’iy kesiladi
      ].join('\n\n');
      final parts = splitTtsText(text);
      expect(
        parts.every((p) => p.isNotEmpty && p.length <= ttsMaxChars),
        isTrue,
      );
      String squash(String s) => s.replaceAll(RegExp(r'\s+'), '');
      expect(squash(parts.join()), squash(text));
    });

    test('uzun abzas gap oxirida bo‘linadi', () {
      final text = List.filled(400, 'Bu bir gap.').join(' ');
      final parts = splitTtsText(text, max: 1000);
      expect(parts.length, greaterThan(1));
      expect(parts.every((p) => p.endsWith('.')), isTrue);
    });
  });

  group('lessonListenText', () {
    test('sarlavha + bandlar; eslatma va manba kirmaydi', () {
      const page = LessonPage(
        kind: LessonPageKind.slide,
        title: 'Birinchi slayd · 2/3',
        originalTitle: 'Birinchi slayd',
        bullets: [
          LessonBullet(
            text: 'Asosiy fikr',
            source: LessonSource(author: 'Aliyev', title: 'Kitob', page: '12'),
          ),
          LessonBullet(text: 'Savol?'),
          LessonBullet(text: '  '),
        ],
        notes: 'MAXFIY ESLATMA',
      );
      expect(lessonListenText(page), 'Birinchi slayd.\nAsosiy fikr.\nSavol?');
    });

    test('adabiyotlar sahifasi — bo‘sh', () {
      const page = LessonPage(
        kind: LessonPageKind.references,
        title: 'Adabiyotlar',
        bullets: [LessonBullet(text: 'Aliyev')],
      );
      expect(lessonListenText(page), isEmpty);
    });
  });
}
