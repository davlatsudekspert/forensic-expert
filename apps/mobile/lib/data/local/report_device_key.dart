import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Qurilmaga bog‘langan tasodifiy kalit: kirmagan foydalanuvchining shikoyat
/// limiti (soatiga 5 ta) uchun. Shaxsiy ma’lumot emas; serverda faqat tuzlangan
/// xeshi saqlanadi. Xotira (SharedPreferences) ishlamasa — jarayon davomida
/// bir xil kalit ishlatiladi.
const reportDeviceKeyPref = 'fe.report_device_key';

String? _memory;

Future<String> reportDeviceKey(
  SharedPreferences prefs, {
  Random? random,
}) async {
  final stored = prefs.getString(reportDeviceKeyPref);
  if (stored != null && RegExp(r'^[A-Za-z0-9_-]{8,64}$').hasMatch(stored)) {
    return stored;
  }
  if (_memory != null) return _memory!;
  final r = random ?? Random.secure();
  const alphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final key = List.generate(
    32,
    (_) => alphabet[r.nextInt(alphabet.length)],
  ).join();
  _memory = key;
  try {
    await prefs.setString(reportDeviceKeyPref, key);
  } on Object {
    // Saqlanmasa ham kalit shu jarayon uchun yaroqli.
  }
  return key;
}
