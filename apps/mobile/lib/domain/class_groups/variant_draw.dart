import 'dart:convert';

import 'package:crypto/crypto.dart';

/// «Har talabaga boshqa savollar» — variant tanlovi.
///
/// Server (`private.group_variant_draw`, migratsiya
/// `20261018050000_class_groups.sql`) bilan **AYNAN bir xil** algoritm;
/// umumiy test vektorlari: `test/fixtures/class_group_variant_vectors.json`
/// (Python, SQL va Dart testlari shu faylni tekshiradi):
///  1. `seed = hex(SHA-256(utf8("<assignmentId>:<userId>")))`
///  2. har savol uchun `kalit = hex(SHA-256(utf8(seed + ":" + savolId)))`
///  3. hovuz kalit (teng bo‘lsa — id) bo‘yicha o‘sish tartibida;
///  4. birinchi [count] ta — talabaga tushgan savollar (shu tartibda).
///
/// Variantsiz test (hammaga bir xil to‘plam) — [commonUser] bilan.
/// Kalitlar hex (ASCII), shuning uchun Dart `compareTo` va Postgres
/// `collate "C"` bir xil tartib beradi.
List<String> drawVariant({
  required String assignmentId,
  required String userId,
  required List<String> pool,
  required int count,
}) {
  String h(String s) => sha256.convert(utf8.encode(s)).toString();
  final seed = h('$assignmentId:$userId');
  final keyed = [for (final q in pool) (q, h('$seed:$q'))]
    ..sort((a, b) {
      final c = a.$2.compareTo(b.$2);
      return c != 0 ? c : _bytes(a.$1, b.$1);
    });
  final n = count.clamp(0, pool.length);
  return [for (final e in keyed.take(n)) e.$1];
}

/// Har talabaga variantlar (A, B, C, D) joylashuvi alohida (qo‘shnidan yoki
/// boshqa telefondagi rasmdan «B» ni ko‘chirib bo‘lmasin).
///
/// Qaytadi: **ko‘rsatish o‘rni → ASL variant indeksi** (`[2, 0, 3, 1]` —
/// ekrandagi birinchi variant asl ro‘yxatning 2-si). Deterministik: bir xil
/// (test, talaba, savol) uchun tartib har doim bir xil (qayta ochilganda
/// o‘zgarmaydi); `drawVariant` bilan bir xil sha256 uslubi, **faqat mijoz
/// tomonida** — serverga hamisha ASL indeks/id ketadi.
/// [userId] bo‘sh bo‘lsa yoki variant 2 tadan kam bo‘lsa — asl tartib.
List<int> optionDisplayOrder({
  required String assignmentId,
  required String? userId,
  required String questionId,
  required int count,
}) {
  final identity = List<int>.generate(count < 0 ? 0 : count, (i) => i);
  if (userId == null || userId.isEmpty || count < 2) return identity;
  String h(String s) => sha256.convert(utf8.encode(s)).toString();
  final seed = h('$assignmentId:$userId');
  final keyed = [for (final i in identity) (i, h('$seed:$questionId:opt$i'))]
    ..sort((a, b) {
      final c = a.$2.compareTo(b.$2);
      return c != 0 ? c : a.$1 - b.$1;
    });
  return [for (final e in keyed) e.$1];
}

/// Variantsiz testdagi umumiy to‘plam uchun “foydalanuvchi”.
const commonUser = '*';

/// Bayt (UTF-8) tartibida taqqoslash — Postgres `collate "C"` bilan bir xil.
int _bytes(String a, String b) {
  final x = utf8.encode(a);
  final y = utf8.encode(b);
  for (var i = 0; i < x.length && i < y.length; i++) {
    if (x[i] != y[i]) return x[i] - y[i];
  }
  return x.length - y.length;
}

/// Variant rejimi mumkinmi: hovuz kamida 2 × [perStudent] (server ham shuni
/// talab qiladi — `variant_pool_small`).
bool variantAllowed(int poolSize, int perStudent) =>
    perStudent >= 1 && poolSize >= perStudent * 2;

/// «Umumiy test»: mavzu hajmlari [sizes] dan jami [n] ta savol NAVBATMA-
/// NAVBAT (har mavzudan bittadan, so‘ng yana) olinganda har mavzuga nechta
/// tushadi. Server `private.group_round_robin_counts` bilan bir xil
/// (umumiy vektorlar: `round_robin`).
List<int> roundRobinCounts(List<int> sizes, int n) {
  final c = List<int>.filled(sizes.length, 0);
  var left = n < 0 ? 0 : n;
  while (left > 0) {
    var progressed = false;
    for (var i = 0; i < sizes.length && left > 0; i++) {
      if (c[i] < sizes[i]) {
        c[i]++;
        left--;
        progressed = true;
      }
    }
    if (!progressed) break;
  }
  return c;
}

/// Navbatma-navbat tanlov (id takrorlanmaydi): har ro‘yxatdan tartib bilan.
List<String> roundRobinPick(List<List<String>> lists, int n) {
  final out = <String>[];
  final seen = <String>{};
  for (var round = 0; out.length < n; round++) {
    var any = false;
    for (final l in lists) {
      if (round < l.length) {
        any = true;
        if (out.length < n && seen.add(l[round])) out.add(l[round]);
      }
    }
    if (!any) break;
  }
  return out;
}

/// Savol soni ogohlantirishi uchun: har talabaga boshqa savol tushishi uchun
/// savol sonining eng katta qiymati (hovuzning yarmi, pastga yaxlitlangan).
/// 0 — hovuz juda kichik (maslahat berib bo‘lmaydi).
int variantMaxCount(int poolSize) => poolSize < 2 ? 0 : poolSize ~/ 2;
