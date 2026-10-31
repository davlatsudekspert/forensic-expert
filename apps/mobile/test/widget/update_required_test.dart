import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/app_info.dart';
import 'package:forensic_expert/app/update_gate.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/remote/fe_client_headers.dart';
import 'package:forensic_expert/domain/ports/app_version_ports.dart';
import 'package:forensic_expert/features/update/presentation/update_required_page.dart';

import '../helpers/pump_app.dart';

Future<void> _pumpPage(
  WidgetTester tester, {
  required String lang,
  VoidCallback? onUpdate,
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(lang),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: FeThemeBuilder.light(),
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: UpdateRequiredPage(onUpdate: onUpdate),
    ),
  );
  await tester.pump();
}

class _Svc implements AppVersionService {
  _Svc([this.info]);

  AppVersionInfo? info;
  int calls = 0;

  @override
  Future<AppVersionInfo?> fetch() async {
    calls++;
    return info;
  }
}

void main() {
  setUp(UpdateRequiredSignal.instance.reset);
  tearDown(UpdateRequiredSignal.instance.reset);

  group('UpdateRequiredPage', () {
    final texts = {
      'uz': (
        'Yangi versiya chiqdi',
        'Ilovaning bu versiyasi eskirgan. Davom etish uchun ilovani yangilang.',
        'Yangilash',
        'App Store’dan yangilang.',
      ),
      'ru': (
        'Вышла новая версия',
        'Эта версия приложения устарела. Чтобы продолжить, обновите приложение.',
        'Обновить',
        'Обновите приложение в App Store.',
      ),
      'en': (
        'A new version is available',
        'This version of the app is out of date. Update the app to continue.',
        'Update',
        'Update the app from the App Store.',
      ),
    };

    for (final e in texts.entries) {
      testWidgets('${e.key}: matn va tugma', (tester) async {
        var taps = 0;
        await _pumpPage(tester, lang: e.key, onUpdate: () => taps++);
        expect(find.text(e.value.$1), findsOneWidget);
        expect(find.text(e.value.$2), findsOneWidget);
        expect(find.text(e.value.$3), findsOneWidget);
        expect(find.text(e.value.$4), findsNothing);
        await tester.tap(find.byKey(const Key('update.button')));
        expect(taps, 1);
      });

      testWidgets('${e.key}: havola yo‘q → tugma yashirin, matn', (
        tester,
      ) async {
        await _pumpPage(tester, lang: e.key);
        expect(find.byKey(const Key('update.button')), findsNothing);
        expect(find.text(e.value.$4), findsOneWidget);
      });
    }

    for (final scale in [1.0, 2.0]) {
      for (final withBtn in [true, false]) {
        testWidgets('320 dp, matn x$scale, tugma=$withBtn: overflow yo‘q', (
          tester,
        ) async {
          await _pumpPage(
            tester,
            lang: 'ru',
            size: const Size(320, 568),
            textScale: scale,
            onUpdate: withBtn ? () {} : null,
          );
          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('update.title')), findsOneWidget);
        });
      }
    }
  });

  group('Ilova ildizi', () {
    testWidgets('bayroq o‘rnatilmagan: ilova odatdagidek', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        overrides: [appVersionServiceProvider.overrideWithValue(_Svc())],
      );
      expect(find.byKey(const Key('update.required')), findsNothing);
    });

    testWidgets('ishga tushganda fonda tekshiradi; build < min → to‘siq; '
        'orqa fondan qaytganda 5 daqiqadan oldin qayta so‘ramaydi', (
      tester,
    ) async {
      var now = DateTime(2026, 11, 1, 10);
      final svc = _Svc(const AppVersionInfo(minBuild: 0, latestBuild: 0));
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        overrides: [
          appVersionServiceProvider.overrideWithValue(svc),
          updateGateClockProvider.overrideWithValue(() => now),
        ],
      );
      expect(svc.calls, 1);
      expect(find.byKey(const Key('update.required')), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(svc.calls, 1); // 5 daqiqa o‘tmagan

      now = now.add(const Duration(minutes: 6));
      svc.info = const AppVersionInfo(
        minBuild: AppInfo.build + 1,
        latestBuild: AppInfo.build + 1,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump();
      expect(svc.calls, 2);
      expect(find.byKey(const Key('update.required')), findsOneWidget);
    });

    testWidgets('signal (426 va h.k.) → to‘siq sahifa; Android tugmasi '
        'Play Market’ni ochadi', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final opened = <Uri>[];
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        overrides: [
          storeLinkLauncherProvider.overrideWithValue((u) async {
            opened.add(u);
            return true;
          }),
        ],
      );
      expect(find.byKey(const Key('update.required')), findsNothing);
      UpdateRequiredSignal.instance.raise();
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('update.required')), findsOneWidget);
      expect(find.text('Yangi versiya chiqdi'), findsOneWidget);
      // Router (Navigator) yashirilgan: ko‘rinmaydi, bosilmaydi, o‘qilmaydi.
      expect(find.byType(Navigator), findsNothing);
      expect(find.byType(Navigator, skipOffstage: false), findsWidgets);
      expect(find.byKey(const Key('update.button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('update.button')));
      expect(
        opened.single.toString(),
        'https://play.google.com/store/apps/details?id=${AppInfo.applicationId}',
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('iOS: havola yo‘q → tugma yo‘q, «App Store’dan yangilang.»', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await pumpApp(tester, settings: completedSettings(lang: 'uz'));
      UpdateRequiredSignal.instance.raise();
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('update.button')), findsNothing);
      expect(find.text('App Store’dan yangilang.'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
