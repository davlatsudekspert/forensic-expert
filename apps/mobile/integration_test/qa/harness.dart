// Real-ilova QA harness’i (Linux desktop, haqiqiy Flutter dvigateli).
//
// Har bir qadam: amal → ekran barqarorlashadi → skrinshot (PNG) →
// ekrandagi barcha matnlar yig‘iladi → til tekshiruvi (uz rejimida inglizcha
// so‘z / xom kod) → overflow xatolari → natija (PASS/FAIL) JSON’ga yoziladi.
//
// Ishga tushirish: `tool/qa_real_app.sh` (README’dagi «Real-ilova QA»).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bitta qadam natijasi.
class QaStep {
  QaStep(this.id, this.title);

  final String id;
  final String title;
  bool passed = true;
  final notes = <String>[];
  String? screenshot;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'result': passed ? 'PASS' : 'FAIL',
    'notes': notes,
    'screenshot': screenshot,
  };
}

/// Uz rejimida ko‘rinmasligi kerak bo‘lgan inglizcha UI so‘zlari (kontent
/// emas — tugma/sarlavha so‘zlari). Topilganlari qo‘lda ko‘rib chiqiladi:
/// manba iqtibosi (asl ingliz matni) va xalqaro nomlar ataylab qoldirilgan.
const _englishUiWords = {
  'the',
  'and',
  'search',
  'settings',
  'cancel',
  'continue',
  'save',
  'open',
  'close',
  'back',
  'next',
  'loading',
  'error',
  'sign',
  'account',
  'profile',
  'library',
  'tools',
  'home',
  'favorites',
  'saved',
  'submit',
  'retry',
  'language',
  'subscription',
  'unlock',
  'locked',
  'free',
  'source',
  'sources',
  'method',
  'methods',
  'guidelines',
  'results',
  'no',
  'not',
  'found',
  'please',
  'try',
  'again',
  'your',
  'you',
  'with',
  'from',
  'this',
  'where',
  'does',
  'come',
  'data',
  'details',
  'show',
  'more',
  'less',
  'privacy',
  'terms',
  'about',
  'delete',
  'edit',
  'add',
  'remove',
  'share',
  'copy',
  'done',
  'ok',
  'yes',
  'select',
  'choose',
  'student',
  'expert',
  'professional',
  'email',
  'password',
  'code',
  'verify',
  'register',
  'today',
  'yesterday',
  'unknown',
  'other',
  'all',
  'none',
  'calculator',
};

final _rawCode = RegExp(
  r'(^[a-z]+(_[a-z0-9]+)+$)|(^[a-z]+\.[a-z_]+(\.[a-z_]+)*$)|(\{[a-zA-Z]+\})',
);

class QaRun {
  QaRun(this.tester, {required this.role, required this.outDir});

  final WidgetTester tester;
  final String role;
  final Directory outDir;
  final steps = <QaStep>[];
  final _pendingErrors = <String>[];
  int _counter = 0;

  /// Uz rejimidagi til tekshiruvi yoqilganmi.
  String lang = 'uz';

  FlutterExceptionHandler? _savedOnError;

  /// Overflow va boshqa render xatolarini testni yiqitmasdan yig‘adi.
  void installErrorCollector() {
    _savedOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString().split('\n').first;
      _pendingErrors.add(msg);
    };
  }

  void restoreErrorHandler() {
    FlutterError.onError = _savedOnError;
  }

  /// Ekran barqarorlashguncha kadr chizadi (cheksiz animatsiyada osilmaydi).
  Future<void> settle({int maxMs = 6000}) async {
    final sw = Stopwatch()..start();
    await tester.pump(const Duration(milliseconds: 50));
    while (sw.elapsedMilliseconds < maxMs) {
      await tester.pump(const Duration(milliseconds: 100));
      if (!tester.binding.hasScheduledFrame) {
        // Asinxron I/O (SQLite, asset) tugashiga imkon.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        await tester.pump();
        if (!tester.binding.hasScheduledFrame) break;
      }
    }
  }

  /// Ekran o‘lchami (mantiqiy piksel), DPR 1 — PNG kichik bo‘lsin.
  Future<void> setSize(Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    await settle();
  }

  /// Qadam: [body] bajariladi, xato bo‘lsa FAIL; oxirida skrinshot.
  Future<void> step(
    String title,
    Future<void> Function(QaStep s) body, {
    bool shot = true,
    bool langCheck = true,
  }) async {
    final s = QaStep(
      '${role[0]}${(++_counter).toString().padLeft(2, '0')}',
      title,
    );
    steps.add(s);
    try {
      await body(s);
      await settle();
    } catch (e) {
      s.passed = false;
      s.notes.add('ERROR: ${e.toString().split('\n').take(3).join(' ')}');
      await settle();
    }
    if (_pendingErrors.isNotEmpty) {
      s.passed = false;
      s.notes.addAll(_pendingErrors.map((e) => 'FLUTTER: $e'));
      _pendingErrors.clear();
    }
    if (langCheck && lang == 'uz') {
      final flagged = languageFindings();
      if (flagged.isNotEmpty) s.notes.add('LANG? ${flagged.join(' | ')}');
    }
    if (shot) s.screenshot = await screenshot(s.id, title);
    debugPrint('QA ${s.id} ${s.passed ? 'PASS' : 'FAIL'} $title ${s.notes}');
  }

  /// Ekrandagi (onstage) barcha matnlar.
  List<String> visibleTexts() {
    final out = <String>{};
    for (final e in find.byType(Text).evaluate()) {
      final w = e.widget as Text;
      final v = w.data ?? w.textSpan?.toPlainText();
      if (v != null && v.trim().isNotEmpty) out.add(v.trim());
    }
    for (final e in find.byType(RichText).evaluate()) {
      final v = (e.widget as RichText).text.toPlainText();
      if (v.trim().isNotEmpty) out.add(v.trim());
    }
    for (final e in find.byType(EditableText).evaluate()) {
      final v = (e.widget as EditableText).controller.text;
      if (v.trim().isNotEmpty) out.add(v.trim());
    }
    return out.toList();
  }

  bool showsText(Pattern p) => visibleTexts().any((t) => t.contains(p));

  /// Uz rejimida shubhali (inglizcha UI so‘zi yoki xom kod) matnlar.
  List<String> languageFindings() {
    final out = <String>[];
    for (final t in visibleTexts()) {
      if (_rawCode.hasMatch(t)) {
        out.add('RAW:"$t"');
        continue;
      }
      final words = t
          .toLowerCase()
          .split(RegExp(r'[^a-z‘’ʻʼ]+'))
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.length < 2) {
        if (words.length == 1 &&
            _englishUiWords.contains(words.first) &&
            t.length < 20) {
          out.add('EN:"$t"');
        }
        continue;
      }
      final hits = words.where(_englishUiWords.contains).length;
      if (hits >= 2 && hits / words.length >= 0.25) {
        out.add('EN:"${t.length > 70 ? '${t.substring(0, 70)}…' : t}"');
      }
    }
    return out;
  }

  /// Ildiz qatlamdan PNG (haqiqiy dvigatel chizgan kadr).
  Future<String?> screenshot(String id, String title) async {
    try {
      final view = tester.binding.renderViews.first;
      final layer = view.debugLayer! as OffsetLayer;
      final size = view.size;
      final image = await tester.runAsync(
        () => layer.toImage(Offset.zero & size, pixelRatio: 1),
      );
      final bytes = await tester.runAsync(
        () => image!.toByteData(format: ui.ImageByteFormat.png),
      );
      final slug = title
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');
      final name =
          '${id}_${slug.length > 40 ? slug.substring(0, 40) : slug}.png';
      File('${outDir.path}/$name')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
      return name;
    } catch (e) {
      debugPrint('QA screenshot failed: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------- amallar

  Future<void> tapText(
    Pattern text, {
    int index = 0,
    bool scroll = true,
  }) async {
    final f = _textFinder(text);
    if (scroll && f.evaluate().isEmpty) await scrollUntil(f);
    expect(f, findsWidgets, reason: 'matn topilmadi: $text');
    final target = f.at(index);
    await tester.ensureVisible(target);
    await settle();
    await tester.tap(target, warnIfMissed: false);
    await settle();
  }

  Future<void> tapFinder(Finder f, {bool scroll = true}) async {
    if (scroll && f.evaluate().isEmpty) await scrollUntil(f);
    expect(f, findsWidgets);
    await tester.ensureVisible(f.first);
    await settle();
    await tester.tap(f.first, warnIfMissed: false);
    await settle();
  }

  Future<void> tapIcon(IconData icon) => tapFinder(find.byIcon(icon));

  Future<void> tapTooltip(String tooltip) => tapFinder(find.byTooltip(tooltip));

  /// Aniq moslik bo‘lsa — u (masalan «Tasdiqlash» tugmasi «Tasdiqlash
  /// kodi» yorlig‘idan ustun), aks holda matn qismi bo‘yicha.
  Finder _textFinder(Pattern text) {
    if (text is String) {
      final exact = find.text(text, findRichText: true);
      if (exact.evaluate().isNotEmpty) return exact;
    }
    return find.textContaining(text, findRichText: true);
  }

  /// Asosiy (eng katta vertikal viewport) Scrollable holati.
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

  /// Asosiy Scrollable’ni pastga aylantirib [f] ni qidiradi.
  Future<void> scrollUntil(Finder f, {int maxSteps = 30}) async {
    for (var i = 0; i < maxSteps && f.evaluate().isEmpty; i++) {
      final st = mainScrollable();
      if (st == null) return;
      final p = st.position;
      if (p.pixels >= p.maxScrollExtent) return;
      p.jumpTo((p.pixels + 400).clamp(0, p.maxScrollExtent));
      await settle(maxMs: 1500);
    }
  }

  Future<void> scrollBy(double dy) async {
    final st = mainScrollable();
    if (st == null) return;
    final p = st.position;
    p.jumpTo((p.pixels + dy).clamp(0, p.maxScrollExtent));
    await settle();
  }

  Future<void> scrollToTop() async {
    final st = mainScrollable();
    st?.position.jumpTo(0);
    await settle();
  }

  Future<void> enterText(Finder field, String text) async {
    await tester.ensureVisible(field.first);
    await tester.tap(field.first, warnIfMissed: false);
    await settle();
    await tester.enterText(field.first, text);
    await settle();
  }

  /// Tizim «orqaga» tugmasi (Android back / router pop).
  Future<void> back() async {
    await tester.binding.handlePopRoute();
    await settle();
  }

  void expectText(Pattern text, QaStep s, {String? why}) {
    if (!showsText(text)) {
      s.passed = false;
      s.notes.add('KUTILGAN MATN YO‘Q: "$text"${why == null ? '' : ' ($why)'}');
    }
  }

  void expectNoText(Pattern text, QaStep s, {String? why}) {
    if (showsText(text)) {
      s.passed = false;
      s.notes.add('KUTILMAGAN MATN: "$text"${why == null ? '' : ' ($why)'}');
    }
  }

  void writeResults() {
    final f = File('${outDir.path}/results_$role.json');
    f.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'role': role,
        'platform': '${Platform.operatingSystem} (debug, Xvfb)',
        'steps': [for (final s in steps) s.toJson()],
        'pass': steps.where((s) => s.passed).length,
        'fail': steps.where((s) => !s.passed).length,
      }),
    );
  }
}

/// Konsolga qisqa natija.
void printSummary(QaRun run) {
  final pass = run.steps.where((s) => s.passed).length;
  debugPrint('QA SUMMARY ${run.role}: $pass/${run.steps.length} PASS');
  if (kDebugMode) {
    for (final s in run.steps.where((s) => !s.passed)) {
      debugPrint('  FAIL ${s.id} ${s.title}: ${s.notes}');
    }
  }
}
