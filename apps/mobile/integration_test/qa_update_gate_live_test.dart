// Majburiy yangilash — JONLI sinov (haqiqiy Supabase, haqiqiy transport).
// Faqat qo‘lda: --dart-define=FE_SUPABASE_URL=... --dart-define=FE_SUPABASE_ANON_KEY=...
// Prod’dagi min_build o‘zgartirilmaydi: rad javobi `x-fe-check: probe` bilan
// faqat shu so‘rov uchun olinadi.
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/app_info.dart';
import 'package:forensic_expert/data/remote/fe_client_headers.dart';
import 'package:forensic_expert/data/remote/supabase_app_version.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live: app_version_info + 426 signal', (tester) async {
    final cfg = SupabaseConfig.fromEnvironment();
    if (cfg == null) {
      markTestSkipped('Supabase sozlamasi yo‘q');
      return;
    }
    // 1) Ishga tushishdagi tekshiruv: haqiqiy server javobi.
    final info = await SupabaseAppVersionService(config: cfg).fetch();
    expect(info, isNotNull);
    // ignore: avoid_print
    print('LIVE info min=${info!.minBuild} latest=${info.latestBuild} '
        'android=${info.androidUrl} build=${AppInfo.build}');
    expect(info.minBuild <= AppInfo.build, isTrue, reason: 'joriy build bloklanmasin');
    expect(UpdateRequiredSignal.instance.required.value, isFalse);

    // 2) Oddiy so‘rov — signal ko‘tarilmaydi.
    final http = HttpClientTransport(timeout: const Duration(seconds: 20));
    final ok = await http.send(
      'POST',
      cfg.url.resolve('rest/v1/rpc/app_version_info'),
      headers: {'apikey': cfg.anonKey, 'Authorization': 'Bearer ${cfg.anonKey}'},
      jsonBody: const <String, Object?>{},
    );
    expect(ok.status, 200);
    expect(UpdateRequiredSignal.instance.required.value, isFalse);

    // 3) Server 426 qaytarsa (probe) — global signal ko‘tariladi.
    final r = await http.send(
      'POST',
      cfg.url.resolve('rest/v1/rpc/app_version_info'),
      headers: {
        'apikey': cfg.anonKey,
        'Authorization': 'Bearer ${cfg.anonKey}',
        'x-fe-check': 'probe',
      },
      jsonBody: const <String, Object?>{},
    );
    // ignore: avoid_print
    print('LIVE probe status=${r.status} json=${r.json}');
    expect(r.status, 426);
    expect(UpdateRequiredSignal.instance.required.value, isTrue);
  });
}
