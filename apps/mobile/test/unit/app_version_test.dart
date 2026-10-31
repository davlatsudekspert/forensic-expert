import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/app_info.dart';
import 'package:forensic_expert/app/update_gate.dart';
import 'package:forensic_expert/data/remote/fe_client_headers.dart';
import 'package:forensic_expert/data/remote/supabase_app_version.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/ports/app_version_ports.dart';

class _Transport implements RestTransport {
  _Transport(this.reply);

  Future<RestResponse> Function() reply;
  Uri? uri;
  String? method;
  Map<String, String>? headers;
  Object? body;

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) {
    this.method = method;
    this.uri = uri;
    this.headers = headers;
    body = jsonBody;
    return reply();
  }
}

class _Service implements AppVersionService {
  _Service(this.result);

  AppVersionInfo? result;
  int calls = 0;

  @override
  Future<AppVersionInfo?> fetch() async {
    calls++;
    return result;
  }
}

const _cfg = (url: 'https://x.supabase.co', key: 'anon');

void main() {
  final config = SupabaseConfig(url: Uri.parse(_cfg.url), anonKey: _cfg.key);

  setUp(UpdateRequiredSignal.instance.reset);
  tearDown(UpdateRequiredSignal.instance.reset);

  group('AppVersionInfo', () {
    test('tahlil', () {
      final i = AppVersionInfo.tryParse({
        'min_build': 36,
        'latest_build': 40,
        'android_url': 'https://play.google.com/x',
        'ios_url': null,
      })!;
      expect(i.minBuild, 36);
      expect(i.latestBuild, 40);
      expect(i.androidUrl, 'https://play.google.com/x');
      expect(i.iosUrl, isNull);
    });

    test('noto‘g‘ri javob → null', () {
      expect(AppVersionInfo.tryParse(null), isNull);
      expect(AppVersionInfo.tryParse('x'), isNull);
      expect(AppVersionInfo.tryParse({'latest_build': 3}), isNull);
      expect(AppVersionInfo.tryParse({'min_build': 'abc'}), isNull);
    });

    test('blocks: 0 → bloklamaydi; build < min → bloklaydi', () {
      const none = AppVersionInfo(minBuild: 0, latestBuild: 0);
      expect(none.blocks(1), isFalse);
      const m = AppVersionInfo(minBuild: AppInfo.build + 1, latestBuild: 99);
      expect(m.blocks(AppInfo.build), isTrue);
      const eq = AppVersionInfo(minBuild: AppInfo.build, latestBuild: 99);
      expect(eq.blocks(AppInfo.build), isFalse);
    });
  });

  group('SupabaseAppVersionService', () {
    test(
      'so‘rov shakli: POST rpc/app_version_info, apikey + Bearer, {}',
      () async {
        final t = _Transport(
          () async => const RestResponse(200, {
            'min_build': 5,
            'latest_build': 6,
            'android_url': null,
            'ios_url': null,
          }),
        );
        final i = await SupabaseAppVersionService(
          config: config,
          transport: t,
        ).fetch();
        expect(i!.minBuild, 5);
        expect(t.method, 'POST');
        expect(
          t.uri.toString(),
          'https://x.supabase.co/rest/v1/rpc/app_version_info',
        );
        expect(t.headers, {'apikey': 'anon', 'Authorization': 'Bearer anon'});
        expect(t.body, isEmpty);
      },
    );

    test('massiv ko‘rinishidagi javob ham o‘qiladi', () async {
      final t = _Transport(
        () async => const RestResponse(200, [
          {'min_build': 7, 'latest_build': 7},
        ]),
      );
      final i = await SupabaseAppVersionService(
        config: config,
        transport: t,
      ).fetch();
      expect(i!.minBuild, 7);
    });

    test('tarmoq xatosi / 500 / timeout → null (bloklamaydi)', () async {
      expect(
        await SupabaseAppVersionService(
          config: config,
          transport: _Transport(() async => throw StateError('offline')),
        ).fetch(),
        isNull,
      );
      expect(
        await SupabaseAppVersionService(
          config: config,
          transport: _Transport(() async => const RestResponse(500, null)),
        ).fetch(),
        isNull,
      );
      expect(
        await SupabaseAppVersionService(
          config: config,
          timeout: const Duration(milliseconds: 20),
          transport: _Transport(
            () => Completer<RestResponse>().future, // hech qachon tugamaydi
          ),
        ).fetch(),
        isNull,
      );
    });
  });

  group('UpdateGateNotifier', () {
    ProviderContainer make(_Service? s, {DateTime Function()? clock}) {
      final c = ProviderContainer(
        overrides: [
          appVersionServiceProvider.overrideWithValue(s),
          if (clock != null) updateGateClockProvider.overrideWithValue(clock),
        ],
      );
      addTearDown(c.dispose);
      c.read(updateGateProvider); // signalga obuna
      return c;
    }

    test('min_build 0 → bloklanmaydi', () async {
      final c = make(
        _Service(const AppVersionInfo(minBuild: 0, latestBuild: 0)),
      );
      await c.read(updateGateProvider.notifier).check();
      expect(c.read(updateGateProvider).required, isFalse);
    });

    test('build < min_build → bloklanadi, URL’lar saqlanadi', () async {
      final c = make(
        _Service(
          const AppVersionInfo(
            minBuild: AppInfo.build + 1,
            latestBuild: AppInfo.build + 1,
            androidUrl: 'https://play.google.com/a',
            iosUrl: 'https://apps.apple.com/b',
          ),
        ),
      );
      await c.read(updateGateProvider.notifier).check();
      final g = c.read(updateGateProvider);
      expect(g.required, isTrue);
      expect(g.androidUrl, 'https://play.google.com/a');
      expect(g.iosUrl, 'https://apps.apple.com/b');
    });

    test('xizmat null (xato/oflayn) → bloklanmaydi', () async {
      final c = make(_Service(null));
      await c.read(updateGateProvider.notifier).check();
      expect(c.read(updateGateProvider).required, isFalse);
    });

    test('xizmat ulanmagan (Supabase yo‘q) → hech narsa qilmaydi', () async {
      final c = make(null);
      await c.read(updateGateProvider.notifier).check(force: true);
      expect(c.read(updateGateProvider).required, isFalse);
    });

    test('signal (426/UPDATE_REQUIRED/update_required) → bloklanadi', () {
      final c = make(_Service(null));
      expect(c.read(updateGateProvider).required, isFalse);
      UpdateRequiredSignal.instance.raise();
      expect(c.read(updateGateProvider).required, isTrue);
    });

    test('signal oldindan ko‘tarilgan bo‘lsa ham bloklanadi', () {
      UpdateRequiredSignal.instance.raise();
      final c = make(null);
      expect(c.read(updateGateProvider).required, isTrue);
    });

    test('qayta tekshirish 5 daqiqada bir martadan ko‘p emas', () async {
      var now = DateTime(2026, 11, 1, 10);
      final s = _Service(const AppVersionInfo(minBuild: 0, latestBuild: 0));
      final c = make(s, clock: () => now);
      final n = c.read(updateGateProvider.notifier);
      await n.check();
      await n.check();
      expect(s.calls, 1);
      now = now.add(const Duration(minutes: 4));
      await n.check();
      expect(s.calls, 1);
      now = now.add(const Duration(minutes: 2));
      await n.check();
      expect(s.calls, 2);
      await n.check(force: true);
      expect(s.calls, 3);
    });

    test('bloklangandan keyin keyingi yaxshi javob qulfni ochmaydi', () async {
      final s = _Service(
        const AppVersionInfo(minBuild: AppInfo.build + 1, latestBuild: 99),
      );
      final c = make(s);
      final n = c.read(updateGateProvider.notifier);
      await n.check(force: true);
      s.result = const AppVersionInfo(minBuild: 0, latestBuild: 99);
      await n.check(force: true);
      expect(c.read(updateGateProvider).required, isTrue);
    });
  });

  group('storeUriFor', () {
    test('Android: server URL yoki Play Market standarti', () {
      expect(
        storeUriFor(
          const UpdateGate(androidUrl: 'https://play.google.com/z'),
          TargetPlatform.android,
        ).toString(),
        'https://play.google.com/z',
      );
      expect(
        storeUriFor(const UpdateGate(), TargetPlatform.android).toString(),
        'https://play.google.com/store/apps/details?id=${AppInfo.applicationId}',
      );
    });

    test('iOS: URL bo‘lmasa null; faqat https', () {
      expect(storeUriFor(const UpdateGate(), TargetPlatform.iOS), isNull);
      expect(
        storeUriFor(
          const UpdateGate(iosUrl: 'javascript:alert(1)'),
          TargetPlatform.iOS,
        ),
        isNull,
      );
      expect(
        storeUriFor(
          const UpdateGate(iosUrl: 'https://apps.apple.com/app/id1'),
          TargetPlatform.iOS,
        ).toString(),
        'https://apps.apple.com/app/id1',
      );
    });

    test('AppInfo.applicationId android/app/build.gradle bilan mos', () {
      final f = [
        'android/app/build.gradle.kts',
        'android/app/build.gradle',
      ].map(File.new).firstWhere((f) => f.existsSync());
      expect(
        f.readAsStringSync(),
        contains('applicationId = "${AppInfo.applicationId}"'),
      );
    });
  });
}
