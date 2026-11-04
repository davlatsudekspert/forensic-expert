// PROMO video yozuvi uchun yordamchi: haqiqiy ilova (bootstrap), MOCK akkaunt,
// tarmoq o‘chiq. Odamdek sekin harakat (silliq scroll, pauzalar) va izoh
// (caption) vaqt jadvali (JSON) — video post-produksiyasi uchun.
//
// Ilova kodi o‘zgartirilmaydi; faqat yangi test fayllar.
// promo_rec.dart: promo_env.dart nusxasi + ustoz rejimi, haqiqiy dars
// ma’lumotlari (PROMO_DECKS), sahna jadvali (PROMO_PLAN).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/bootstrap.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart'
    show ClassFailure, ClassResult;
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/domain/ports/lessons_ports.dart';
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

  /// Sekinlashtirish koeffitsienti (PROMO_DILATION): dasturiy renderda kadr
  /// sekin chiqadi, shuning uchun ilova vaqti k marta sekinlashtirib yoziladi,
  /// post-produksiyada k marta tezlashtiriladi (30 fps silliq).
  final double k =
      double.tryParse(Platform.environment['PROMO_DILATION'] ?? '') ?? 1;

  /// Epoch ms (chiziq bo‘yicha sinxronizatsiya uchun).
  int get nowMs => DateTime.now().millisecondsSinceEpoch;

  Future<void> launch({
    required String mode, // student | professional | teacher
    bool pro = false,
    String theme = 'light',
    List<Override> overrides = const [],
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
    final decks = Platform.environment['PROMO_DECKS'];
    await bootstrap(
      testOverrides: <Override>[
        if (decks != null)
          lessonsServiceProvider.overrideWithValue(PromoLessonsService(decks)),
        ...overrides,
      ],
    );
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
    timeDilation = k;
    _t0 = nowMs;
    _events.add({'type': 'start', 'epoch': _t0, 'k': k});
  }

  static int _ptr = 100;

  /// Test-kursorsiz (yashil xoch chizilmaydigan) qurilma-turi ko‘rsatkich.
  Future<TestGesture> down(Offset p) async {
    tester.binding.shouldPropagateDevicePointerEvents = true;
    final g = TestGesture(
      dispatcher: (e) async => tester.binding.handlePointerEventForSource(
        e,
        source: TestBindingEventSource.device,
      ),
      pointer: _ptr++,
      kind: PointerDeviceKind.touch,
    );
    await g.down(p);
    return g;
  }

  Future<void> tapAt(Offset p) async {
    final g = await down(p);
    await tester.pump(const Duration(milliseconds: 60));
    await g.up();
  }

  /// Real vaqtda kadrlar chizib turadi (video harakatni ko‘rsin).
  Future<void> wait(int ms) async {
    final end = DateTime.now().millisecondsSinceEpoch + (ms * k).round();
    while (DateTime.now().millisecondsSinceEpoch < end) {
      await tester.pump(const Duration(milliseconds: 33));
    }
  }

  Future<void> settle({int maxMs = 3000}) async {
    maxMs = (maxMs * k).round();
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
    await settle(maxMs: 1200);
    await wait(after);
  }

  /// Hozirgi marshrut bo‘yicha push (orqaga qaytish mumkin).
  Future<void> push(String route, {int after = 1500}) async {
    _navMark = nowMs;
    unawaited(container.read(routerProvider).push(route));
    await settle(maxMs: 1200);
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

  /// Sahna: [id] boshlanishi/oxiri epoch’i yoziladi; kamida PROMO_PLAN[id] ms
  /// davom etadi (ovoz + zaxira), kerak bo‘lsa oxirgi ekranda turadi.
  Future<void> scene(String id, Future<void> Function() body) async {
    final start = nowMs;
    _navMark = null;
    await body();
    final minMs = _plan[id] ?? 0;
    final left = ((minMs * k).round() - (nowMs - start)) ~/ k;
    if (left > 0) await wait(left);
    _events.add({'type': 'scene', 'id': id, 'start': start, 'end': nowMs});
    debugPrint('PROMO scene $id ${nowMs - start} ms (min $minMs)');
    flush();
  }

  static final Map<String, int> _plan = () {
    final f = Platform.environment['PROMO_PLAN'];
    if (f == null || !File(f).existsSync()) return <String, int>{};
    final m = jsonDecode(File(f).readAsStringSync()) as Map<String, Object?>;
    return {for (final e in m.entries) e.key: (e.value as num).toInt()};
  }();

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
    final realMs = ms * k;
    while (sw.elapsedMilliseconds < realMs) {
      final t = (sw.elapsedMilliseconds / realMs).clamp(0.0, 1.0);
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
    final t0 = nowMs;
    final d = f.toString().split('\n').first;
    try {
      return await _tap(f, after, scrollIntoView);
    } finally {
      debugPrint('PROMO step tap $d ${nowMs - t0} ms');
    }
  }

  Future<bool> _tap(Finder f, int after, bool scrollIntoView) async {
    if (f.evaluate().isEmpty) {
      // Avval qisqa kutamiz (ro‘yxat/ekran qurilishi), keyin aylantiramiz.
      for (var i = 0; i < 12 && f.evaluate().isEmpty; i++) {
        await wait(100);
      }
    }
    if (f.evaluate().isEmpty && scrollIntoView) await scrollTo(f);
    if (f.evaluate().isEmpty) {
      debugPrint('PROMO tap: topilmadi $f');
      return false;
    }
    await tester.ensureVisible(f.first);
    await settle(maxMs: 800);
    await tapAt(tester.getCenter(f.first));
    await settle(maxMs: 300);
    // Bosish va kadr chizish ~0.7 s olgani uchun kutishdan ayiriladi.
    await wait(after > 900 ? after - 700 : 200);
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
    await tapAt(tester.getCenter(f.first));
    await settle(maxMs: 150);
    // Odamdek yozish: harfma-harf.
    var cur = '';
    for (final ch in s.characters) {
      cur += ch;
      await tester.enterText(f.first, cur);
      await tester.pump(Duration(milliseconds: (50 * k).round()));
    }
    await settle(maxMs: 400);
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

  void flush() {
    final dir = Platform.environment['PROMO_OUT'] ?? '/tmp/promo_out';
    Directory(dir).createSync(recursive: true);
    File('$dir/$name.events.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(_events));
  }

  void finish() {
    tester.binding.shouldPropagateDevicePointerEvents = false;
    timeDilation = 1.0;
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

/// PROMO_DECKS (JSON, repoga kirmaydi) dan o‘qiydigan darslar xizmati:
/// `{decks: {topic_id: lesson_get obyekti}, topics: [ro‘yxat qatorlari]}`.
class PromoLessonsService implements LessonsService {
  PromoLessonsService(String path) {
    final j = jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
    _decks = (j['decks'] as Map).cast<String, Object?>();
    _topics = [
      for (final t in (j['topics'] as List))
        LessonSummary.fromJson((t as Map).cast<String, Object?>()),
    ];
  }

  late final Map<String, Object?> _decks;
  late final List<LessonSummary> _topics;

  @override
  bool get isConfigured => true;
  @override
  bool get isDemo => false;

  @override
  Future<ClassResult<List<LessonSummary>>> list({String? query}) async {
    final q = (query ?? '').trim().toLowerCase();
    return ClassResult.ok([
      for (final s in _topics)
        if (q.isEmpty ||
            s.title.toLowerCase().contains(q) ||
            s.course.toLowerCase().contains(q))
          s,
    ]);
  }

  @override
  Future<ClassResult<LessonDeck>> get(String topicId) async {
    final j = _decks[topicId];
    if (j is! Map) return const ClassResult.fail(ClassFailure.notFound);
    return ClassResult.ok(LessonDeck.fromJson(j.cast<String, Object?>()));
  }
}

/// Qo‘shimcha yordamchilar (ustoz/talaba/yuldashev testlari uchun).
extension PromoExtras on Promo {
  Future<void> waitKey(String key, {int maxMs = 8000}) async {
    final end = DateTime.now().millisecondsSinceEpoch + (maxMs * k).round();
    while (!has(key) && DateTime.now().millisecondsSinceEpoch < end) {
      await wait(150);
    }
  }

  Finder byKeyStr(String k) => find.byKey(Key(k));

  bool has(String key) => find.byKey(Key(key)).evaluate().isNotEmpty;

  /// Slayderni asta-sekin [frac] (0..1) joyga suradi.
  Future<void> dragSlider(String key, double frac, {int ms = 900}) async {
    final f = find.byKey(Key(key));
    if (f.evaluate().isEmpty) return;
    await tester.ensureVisible(f.first);
    await settle(maxMs: 600);
    final r = tester.getRect(f.first);
    final y = r.center.dy;
    final x0 = r.left + 28;
    final x1 = r.left + 28 + (r.width - 56) * frac;
    final g = await down(Offset(x0, y));
    const steps = 18;
    for (var i = 1; i <= steps; i++) {
      await g.moveTo(Offset(x0 + (x1 - x0) * i / steps, y));
      await wait(ms ~/ steps);
    }
    await g.up();
    await settle(maxMs: 800);
  }

  /// PageView/slayd uchun: o‘ng→chap silliq surish.
  Future<void> swipeLeft({int ms = 700}) async {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final y = size.height * 0.45;
    final g = await down(Offset(size.width * 0.85, y));
    const steps = 14;
    for (var i = 1; i <= steps; i++) {
      await g.moveTo(Offset(size.width * (0.85 - 0.6 * i / steps), y));
      await wait(ms ~/ steps);
    }
    await g.up();
    await settle(maxMs: 1500);
  }
}
