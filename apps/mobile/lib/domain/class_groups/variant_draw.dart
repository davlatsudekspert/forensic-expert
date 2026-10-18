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
