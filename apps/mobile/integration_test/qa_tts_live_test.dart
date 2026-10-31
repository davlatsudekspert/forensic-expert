// «Tinglash» — JONLI sinov (haqiqiy `tts` Edge Function + haqiqiy audioplayers).
//
// Faqat qo‘lda ishga tushiriladi (CI’da emas): foydalanuvchi tokeni kerak.
//   flutter test integration_test/qa_tts_live_test.dart -d linux \
//     --dart-define=FE_SUPABASE_URL=... --dart-define=FE_SUPABASE_ANON_KEY=... \
//     --dart-define=QA_TTS_JWT=<access token>
// Token bo‘lmasa test o‘tkazib yuboriladi. Token jurnalga yozilmaydi.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/tts.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/data/remote/supabase_tts.dart';
import 'package:forensic_expert/domain/ports/backend_ports.dart';
import 'package:forensic_expert/features/tts/presentation/listen_button.dart';
import 'package:integration_test/integration_test.dart';

const _jwt = String.fromEnvironment('QA_TTS_JWT');

class _TokenAuth implements AuthRepository {
  @override
  Future<String?> accessToken() async => _jwt;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live: Tinglash — server → kesh → ijro → qayta tinglash', (tester) async {
    final cfg = SupabaseConfig.fromEnvironment();
    if (_jwt.isEmpty || cfg == null) {
      markTestSkipped('QA_TTS_JWT / Supabase sozlamasi yo‘q');
      return;
    }
    final cache = Directory.systemTemp.createTempSync('tts_live_');
    final service = SupabaseTtsService(
      config: cfg,
      auth: _TokenAuth(),
      cacheDir: () async => cache,
    );
    const text = 'Sud-tibbiy toksikologiya. Qondagi etanol miqdori gaz '
        'xromatografiya usulida aniqlanadi.';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [ttsServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(
          locale: Locale('uz'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: Center(child: ListenButton(text: text))),
        ),
      ),
    );

    Future<void> waitFor(Finder f, {int seconds = 90}) async {
      final end = DateTime.now().add(Duration(seconds: seconds));
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 200));
        if (f.evaluate().isNotEmpty) return;
      }
      fail('kutilgan holat chiqmadi: $f');
    }

    final sw = Stopwatch()..start();
    await tester.tap(find.byType(ListenButton));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await waitFor(find.byIcon(Icons.pause_rounded));
    final first = sw.elapsedMilliseconds;
    final wavs = cache.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.wav')).toList();
    expect(wavs, hasLength(1));
    final head = wavs.single.openSync().readSync(4);
    expect(String.fromCharCodes(head), 'RIFF');
    debugPrint('TTS_LIVE first=${first}ms bytes=${wavs.single.lengthSync()}');

    // Oxirigacha eshitiladi → «Qayta tinglash».
    await waitFor(find.byIcon(Icons.replay_rounded), seconds: 60);
    debugPrint('TTS_LIVE finished after ${sw.elapsedMilliseconds}ms');

    // Ikkinchi marta: qurilma keshidan (tarmoqsiz) — darhol ijro.
    sw.reset();
    await tester.tap(find.byType(ListenButton));
    await waitFor(find.byIcon(Icons.pause_rounded), seconds: 10);
    debugPrint('TTS_LIVE replay_from_cache=${sw.elapsedMilliseconds}ms');
    await tester.tap(find.byType(ListenButton)); // pauza
    await tester.pump(const Duration(milliseconds: 300));
    cache.deleteSync(recursive: true);
  });
}
