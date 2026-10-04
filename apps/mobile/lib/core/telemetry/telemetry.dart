/// Telemetriya (crash/analytics) uchun maxfiylik arxitekturasi.
///
/// PHASE 2 da hech qanday analytics yoki crash SDK ulanmagan
/// ([NoopTelemetrySink]). Kelajakda ulanganda ham quyidagi qoidalar
/// **tur darajasida** majburlanadi:
///
/// * Hodisalar faqat [TelemetryEvent] enum’idan — erkin nomlar yo‘q.
/// * Parametrlar faqat `int`, `bool` yoki [TelemetryEnumValue] — erkin
///   matn (qidiruv so‘rovi, AI savoli, ish raqami, ism) uzatib bo‘lmaydi.
/// * Ilmiy qidiruv tarixi qurilmada qoladi va telemetriyaga tushmaydi.
library;

import 'package:flutter/foundation.dart';

enum TelemetryEvent {
  appStarted,
  screenViewed,
  searchPerformed,
  toolOpened,
  calculationPerformed,
  languageChanged,
  themeChanged,
}

/// Erkin matn emas, oldindan ma’lum qiymat (masalan, ekran nomi).
abstract interface class TelemetryEnumValue {
  String get telemetryName;
}

/// Ruxsat etilgan parametr qiymati.
@immutable
sealed class TelemetryValue {
  const TelemetryValue();
}

final class IntValue extends TelemetryValue {
  const IntValue(this.value);
  final int value;
}

final class BoolValue extends TelemetryValue {
  const BoolValue(this.value);
  final bool value;
}

final class EnumValue extends TelemetryValue {
  const EnumValue(this.value);
  final TelemetryEnumValue value;
}

abstract interface class TelemetrySink {
  void record(TelemetryEvent event, [Map<String, TelemetryValue> params]);
}

/// PHASE 2 default: hech narsa yubormaydi.
class NoopTelemetrySink implements TelemetrySink {
  const NoopTelemetrySink();

  @override
  void record(TelemetryEvent event, [Map<String, TelemetryValue>? params]) {}
}

/// Testlar uchun yozib oluvchi.
class RecordingTelemetrySink implements TelemetrySink {
  final records = <(TelemetryEvent, Map<String, TelemetryValue>)>[];

  @override
  void record(TelemetryEvent event, [Map<String, TelemetryValue>? params]) =>
      records.add((event, params ?? const {}));
}

/// Debug log uchun matnni tozalaydi (release’da log umuman yozilmaydi).
abstract final class SensitiveText {
  static String redact(String input) =>
      input.isEmpty ? '' : '[redacted:${input.length}]';
}
