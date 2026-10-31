import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/app_info.dart';
import 'package:forensic_expert/data/remote/fe_client_headers.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/data/remote/supabase_tts.dart';

import '../helpers/fake_http_client.dart';

void main() {
  final uri = Uri.parse('https://x.supabase.co/rest/v1/rpc/foo');

  setUp(() {
    UpdateRequiredSignal.instance.reset();
    fePlatformOverride = 'android';
  });
  tearDown(() {
    UpdateRequiredSignal.instance.reset();
    fePlatformOverride = null;
  });

  group('sarlavhalar', () {
    test('feClientHeaders: build va platforma', () {
      expect(feClientHeaders(), {
        'x-fe-build': '${AppInfo.build}',
        'x-fe-platform': 'android',
      });
      fePlatformOverride = null;
      expect({
        'android',
        'ios',
        'macos',
        'linux',
        'windows',
        'web',
      }, contains(feClientHeaders()['x-fe-platform']));
    });

    test('HttpClientTransport.send har so‘rovga qo‘shadi', () async {
      final c = FakeHttpClient();
      final t = HttpClientTransport(client: c);
      await t.send('POST', uri, headers: {'apikey': 'k'}, jsonBody: {'a': 1});
      await t.send('GET', uri);
      expect(c.requests, hasLength(2));
      for (final r in c.requests) {
        expect(r.sent['x-fe-build'], '${AppInfo.build}');
        expect(r.sent['x-fe-platform'], 'android');
      }
      expect(c.requests.first.sent['apikey'], 'k');
    });

    test('HttpClientTransport.getBytes (Storage) ham qo‘shadi', () async {
      final c = FakeHttpClient(body: 'abc');
      await HttpClientTransport(client: c)
          .getBytes(Uri.parse('https://x.supabase.co/storage/v1/object/a/b'));
      expect(c.requests.single.sent['x-fe-build'], '${AppInfo.build}');
      expect(c.requests.single.sent['x-fe-platform'], 'android');
    });

    test(
      'HttpClientTtsHttp.postJson (/functions/v1/tts) ham qo‘shadi',
      () async {
        final c = FakeHttpClient(body: 'RIFF');
        await HttpClientTtsHttp(client: c).postJson(
          Uri.parse('https://x.supabase.co/functions/v1/tts'),
          headers: {'apikey': 'k'},
          body: {'text': 't'},
        );
        expect(c.requests.single.sent['x-fe-build'], '${AppInfo.build}');
        expect(c.requests.single.sent['x-fe-platform'], 'android');
      },
    );

    test('adapter sarlavhasi sarlavhalarni bosib o‘tolmaydi', () async {
      final c = FakeHttpClient();
      await HttpClientTransport(client: c)
          .send('GET', uri, headers: {'x-fe-build': '1'});
      expect(c.requests.single.sent['x-fe-build'], '${AppInfo.build}');
    });

    test('statik qamrov: HttpClient faqat ma’lum transportlarda', () {
      // Supabase’ga boradigan HAR BIR so‘rov shu ikki transportdan o‘tadi.
      // Yangi `openUrl`/`HttpClient()` paydo bo‘lsa, shu test yiqiladi va
      // sarlavha qo‘shilishini unutmaslikka majbur qiladi.
      const transports = {'supabase_rest.dart', 'supabase_tts.dart'};
      // Supabase emas (FE_AUTH_BASE_URL — alohida akkaunt backend’i).
      const nonSupabase = {'http_auth_repository.dart'};
      final offenders = <String>[];
      for (final f
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))) {
        final name = f.uri.pathSegments.last;
        final src = f.readAsStringSync();
        final raw = src.contains('openUrl(') || src.contains('HttpClient()');
        if (!raw) continue;
        if (transports.contains(name)) {
          expect(
            src.contains('feClientHeaders()'),
            isTrue,
            reason: '$name sarlavha qo‘shmayapti',
          );
        } else if (!nonSupabase.contains(name)) {
          offenders.add(f.path);
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test('har bir Supabase adapteri faqat umumiy transportdan foydalanadi', () {
      final offenders = <String>[];
      for (final f
          in Directory('lib/data/remote')
              .listSync()
              .whereType<File>()
              .where((f) => f.uri.pathSegments.last.startsWith('supabase_'))) {
        final name = f.uri.pathSegments.last;
        if (name == 'supabase_rest.dart' || name == 'supabase_tts.dart') {
          continue;
        }
        final src = f.readAsStringSync();
        if (RegExp(r'\bHttpClient\b').hasMatch(src)) {
          offenders.add(name);
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test('feHeadersForUrl: Supabase sozlanmagan bo‘lsa null', () {
      expect(feHeadersForUrl('https://x.supabase.co/a.png'), isNull);
    });
  });

  group('yangilash signali', () {
    test('isUpdateRequiredResponse', () {
      expect(isUpdateRequiredResponse(426, null), isTrue);
      expect(
        isUpdateRequiredResponse(400, {'message': 'UPDATE_REQUIRED'}),
        isTrue,
      );
      expect(
        isUpdateRequiredResponse(403, {'error': 'update_required'}),
        isTrue,
      );
      expect(isUpdateRequiredResponse(200, {'ok': true}), isFalse);
      expect(isUpdateRequiredResponse(500, {'message': 'boom'}), isFalse);
      // 2xx qatordagi foydalanuvchi matni signal bermaydi.
      expect(
        isUpdateRequiredResponse(200, {'message': 'UPDATE_REQUIRED'}),
        isFalse,
      );
      expect(isUpdateRequiredResponse(200, [1, 2]), isFalse);
    });

    Future<bool> raisedBy(int status, Object? body) async {
      UpdateRequiredSignal.instance.reset();
      final c = FakeHttpClient(
        status: status,
        body: body == null ? '' : jsonEncode(body),
      );
      await HttpClientTransport(client: c).send('POST', uri, jsonBody: {});
      return UpdateRequiredSignal.instance.required.value;
    }

    test('transport: 426 / UPDATE_REQUIRED / update_required', () async {
      expect(await raisedBy(426, null), isTrue);
      expect(
        await raisedBy(400, {'code': 'P0001', 'message': 'UPDATE_REQUIRED'}),
        isTrue,
      );
      expect(await raisedBy(403, {'error': 'update_required'}), isTrue);
      expect(await raisedBy(200, {'a': 1}), isFalse);
      expect(await raisedBy(500, {'error': 'server'}), isFalse);
    });

    test('getBytes 426 → signal', () async {
      final c = FakeHttpClient(status: 426, body: '');
      final r = await HttpClientTransport(client: c)
          .getBytes(Uri.parse('https://x.supabase.co/storage/v1/object/a/b'));
      expect(r, isNull);
      expect(UpdateRequiredSignal.instance.required.value, isTrue);
    });

    test('TTS: 426 va {"error":"update_required"} → signal', () async {
      for (final (s, b) in [(426, ''), (403, '{"error":"update_required"}')]) {
        UpdateRequiredSignal.instance.reset();
        final c = FakeHttpClient(status: s, body: b);
        await HttpClientTtsHttp(client: c).postJson(
          Uri.parse('https://x.supabase.co/functions/v1/tts'),
          headers: const {},
          body: const {},
        );
        expect(UpdateRequiredSignal.instance.required.value, isTrue, reason: b);
      }
      UpdateRequiredSignal.instance.reset();
      final ok = FakeHttpClient(status: 200, body: 'RIFF');
      await HttpClientTtsHttp(client: ok).postJson(
        Uri.parse('https://x.supabase.co/functions/v1/tts'),
        headers: const {},
        body: const {},
      );
      expect(UpdateRequiredSignal.instance.required.value, isFalse);
    });
  });
}
