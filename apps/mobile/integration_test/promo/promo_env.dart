// PROMO video yozuvi uchun yordamchi: haqiqiy ilova (bootstrap), MOCK akkaunt,
// tarmoq o‘chiq. Odamdek sekin harakat (silliq scroll, pauzalar) va izoh
// (caption) vaqt jadvali (JSON) — video post-produksiyasi uchun.
//
// Ilova kodi o‘zgartirilmaydi; faqat yangi test fayllar.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/bootstrap.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoNet extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..connectionFactory = (uri, proxyHost, proxyPort) =>
            Future.error(const SocketException('promo: tarmoq o‘chiq'));
}

class Promo {
  Promo(this.tester, this.name);

  final WidgetTester tester;
  final String name;
  final _events = <Map<String, Object?>>[];
  final _sw = Stopwatch();
  int _t0 = 0;
  int? _navMark;

  /// Epoch ms (chiziq bo‘yicha sinxronizatsiya uchun).
  int get nowMs => DateTime.now().millisecondsSinceEpoch;

  Future<void> launch({
    required String mode, // student | professional
    bool pro = false,
    String theme = 'light',
  }) async {
    HttpOverrides.global = NoNet();
    // rec.sh oynani 390x844 (2x) qilib, yozuvni boshlagach shu faylni yaratadi.
    final ready = Platform.environment['PROMO_READY'];
    if (ready != null) {
      final sw = Stopwatch()..start();
      while (!File(ready).existsSync() && sw.elapsed.inSeconds < 180) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
      }
    }
    SharedPreferences.setMockInitialValues({
      'fe.settings.locale': 'uz',
      'fe.settings.theme': theme,
      'fe.settings.mode': mode,
      'fe.settings.disclaimer_version': 1,
    });
    await bootstrap(testOverrides: <Override>[]);
    await settle(maxMs: 8000);
    // Sinxronizatsiya belgisi: 800 ms davomida to‘liq ekran magenta
    // (post-produksiyada aniqlanadi va kesib tashlanadi).
    final overlay = tester.state<OverlayState>(find.byType(Overlay).first);
    final entry = OverlayEntry(
      builder: (_) =>
          const Positioned.fill(child: ColoredBox(color: Color(0xFFFF00FF))),
    );
    final markEpoch = nowMs;
    overlay.insert(entry);
    _events.add({'type': 'marker', 'epoch': markEpoch});
    await wait(800);
    entry.remove();
    await wait(500);
    _sw.start();
    _t0 = nowMs;
    _events.add({'type': 'start', 'epoch': _t0});
  }

  /// Real vaqtda kadrlar chizib turadi (video harakatni ko‘rsin).
  Future<void> wait(int ms) async {
    final end = DateTime.now().millisecondsSinceEpoch + ms;
    while (DateTime.now().millisecondsSinceEpoch < end) {
      await tester.pump(const Duration(milliseconds: 33));
    }
  }

  Future<void> settle({int maxMs = 3000}) async {
    final sw = Stopwatch()..start();
    await tester.pump(const Duration(milliseconds: 50));
    while (sw.elapsedMilliseconds < maxMs) {
      await tester.pump(const Duration(milliseconds: 100));
      if (!tester.binding.hasScheduledFrame) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        await tester.pump();
        if (!tester.binding.hasScheduledFrame) break;
      }
    }
  }

  ProviderContainer get container =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

  Future<void> go(String route, {int after = 1500}) async {
    _navMark = nowMs;
    container.read(routerProvider).go(route);
    await settle(maxMs: 6000);
    await wait(after);
  }

  /// Hozirgi marshrut bo‘yicha push (orqaga qaytish mumkin).
  Future<void> push(String route, {int after = 1500}) async {
    _navMark = nowMs;
    unawaited(container.read(routerProvider).push(route));
    await settle(maxMs: 6000);
    await wait(after);
  }

  Future<void> back({int after = 1200}) async {
    _navMark = nowMs;
    await tester.binding.handlePopRoute();
    await settle(maxMs: 3000);
    await wait(after);
  }

  /// Izoh: [text] ekranda [ms] davomida ko‘rinadi (post-produksiyada
  /// ffmpeg drawtext). Ichida [body] bajariladi.
  Future<void> caption(String text, Future<void> Function() body) async {
    final start = _navMark ?? nowMs;
    _navMark = null;
    await body();
    _navMark = null;
    final end = nowMs;
    _events.add({'type': 'caption', 'text': text, 'start': start, 'end': end});
  }

  /// Hozirgi paytdan boshlab [ms] davomida izoh ko‘rsatiladi (ekranda
  /// qolgan holda).
  Future<void> hold(String text, int ms) => caption(text, () => wait(ms));

  /// Qo‘l bilan silliq scroll: [dy] piksel [ms] ichida.
  Future<void> scroll(double dy, {int ms = 1800}) async {
    final st = mainScrollable();
    if (st == null) return;
    final p = st.position;
    final from = p.pixels;
    final to = (from + dy).clamp(p.minScrollExtent, p.maxScrollExtent);
    if (to == from) return;
    final sw = Stopwatch()..start();
    while (sw.elapsedMilliseconds < ms) {
      final t = (sw.elapsedMilliseconds / ms).clamp(0.0, 1.0);
      final e = Curves.easeInOut.transform(t);
      p.jumpTo(from + (to - from) * e);
      await tester.pump(const Duration(milliseconds: 16));
    }
    p.jumpTo(to);
    await tester.pump(const Duration(milliseconds: 16));
  }

  Future<void> scrollTop() async {
    final st = mainScrollable();
    st?.position.jumpTo(0);
    await settle(maxMs: 1000);
  }

  ScrollableState? mainScrollable() {
    ScrollableState? best;
    var bestArea = 0.0;
    for (final e in find.byType(Scrollable).evaluate()) {
      final st = (e as StatefulElement).state as ScrollableState;
      if (st.position.axis != Axis.vertical) continue;
      final box = e.renderObject as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final area = box.size.width * box.size.height;
      if (area > bestArea) {
        bestArea = area;
        best = st;
      }
    }
    return best;
  }

  Finder text(Pattern t) {
    if (t is String) {
      final exact = find.text(t, findRichText: true);
      if (exact.evaluate().isNotEmpty) return exact;
    }
    return find.textContaining(t, findRichText: true);
  }

  /// Ko‘rinmasa, silliq pastga aylantirib qidiradi.
  Future<bool> scrollTo(
    Finder f, {
    int maxSteps = 25,
    double step = 320,
  }) async {
    for (var i = 0; i < maxSteps && f.hitTestable().evaluate().isEmpty; i++) {
      final st = mainScrollable();
      if (st == null) return f.evaluate().isNotEmpty;
      if (f.evaluate().isNotEmpty) {
        await tester.ensureVisible(f.first);
        await settle(maxMs: 800);
        break;
      }
      if (st.position.pixels >= st.position.maxScrollExtent) return false;
      await scroll(step, ms: 700);
    }
    return f.evaluate().isNotEmpty;
  }

  Future<bool> tap(
    Finder f, {
    int after = 1500,
    bool scrollIntoView = true,
  }) async {
    if (f.evaluate().isEmpty && scrollIntoView) await scrollTo(f);
    if (f.evaluate().isEmpty) {
      debugPrint('PROMO tap: topilmadi $f');
      return false;
    }
    await tester.ensureVisible(f.first);
    await settle(maxMs: 800);
    await tester.tap(f.first, warnIfMissed: false);
    await settle(maxMs: 3000);
    await wait(after);
    return true;
  }

  Future<bool> tapText(Pattern t, {int index = 0, int after = 1500}) =>
      tap(text(t).at(index), after: after);

  Future<bool> tapKey(String k, {int after = 1500}) =>
      tap(find.byKey(Key(k)), after: after);

  Future<bool> tapTooltip(String t, {int after = 1500}) =>
      tap(find.byTooltip(t), after: after);

  Future<void> type(Finder f, String s, {int after = 1200}) async {
    await tester.ensureVisible(f.first);
    await tester.tap(f.first, warnIfMissed: false);
    await settle(maxMs: 800);
    // Odamdek yozish: harfma-harf.
    var cur = '';
    for (final ch in s.characters) {
      cur += ch;
      await tester.enterText(f.first, cur);
      await tester.pump(const Duration(milliseconds: 90));
    }
    await settle(maxMs: 3000);
    await wait(after);
  }

  /// Elementni silliq aylantirib ekran o‘rtasiga olib keladi.
  Future<bool> reveal(
    Finder f, {
    double alignment = 0.3,
    int after = 800,
  }) async {
    if (f.evaluate().isEmpty) await scrollTo(f);
    if (f.evaluate().isEmpty) return false;
    final fut = Scrollable.ensureVisible(
      tester.element(f.first),
      alignment: alignment,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
    );
    await wait(1000);
    await fut.timeout(const Duration(seconds: 3), onTimeout: () {});
    await wait(after);
    return true;
  }

  Future<void> calc({int after = 1500}) async {
    await tap(find.byKey(const Key('calc.calculate')), after: 800);
    await reveal(
      find.byKey(const Key('calc.result')),
      alignment: 0.2,
      after: after,
    );
  }

  bool shows(Pattern p) {
    for (final e in find.byType(Text).evaluate()) {
      final w = e.widget as Text;
      final v = w.data ?? w.textSpan?.toPlainText();
      if (v != null && v.contains(p)) return true;
    }
    for (final e in find.byType(RichText).evaluate()) {
      if ((e.widget as RichText).text.toPlainText().contains(p)) return true;
    }
    return false;
  }

  /// Ekrandagi barcha matnlar (README/audit uchun).
  List<String> visibleTexts() {
    final out = <String>{};
    for (final e in find.byType(Text).evaluate()) {
      final w = e.widget as Text;
      final v = w.data ?? w.textSpan?.toPlainText();
      if (v != null && v.trim().isNotEmpty) out.add(v.trim());
    }
    return out.toList();
  }

  /// Hozirgi ekranni belgilaydi (README hisoboti) va ekrandagi matnlarni
  /// yozib qo‘yadi.
  void screen(String title) {
    _events.add({
      'type': 'screen',
      'title': title,
      'epoch': nowMs,
      'texts': visibleTexts().take(40).toList(),
    });
    debugPrint('PROMO screen: $title');
  }

  void finish() {
    _events.add({'type': 'end', 'epoch': nowMs});
    final dir = Platform.environment['PROMO_OUT'] ?? '/tmp/promo_out';
    Directory(dir).createSync(recursive: true);
    File('$dir/$name.events.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(_events));
    debugPrint('PROMO events -> $dir/$name.events.json');
  }
}

void clearSnackBars(WidgetTester tester) {
  for (final e in find.byType(ScaffoldMessenger).evaluate()) {
    final st = (e as StatefulElement).state;
    if (st is ScaffoldMessengerState) st.clearSnackBars();
  }
}
