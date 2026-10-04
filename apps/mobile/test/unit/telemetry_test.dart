import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/telemetry/telemetry.dart';

enum _Screen implements TelemetryEnumValue {
  search;

  @override
  String get telemetryName => name;
}

void main() {
  test('telemetriya faqat tiplangan qiymatlarni qabul qiladi', () {
    final sink = RecordingTelemetrySink()
      ..record(TelemetryEvent.searchPerformed, {
        'result_count': const IntValue(3),
        'offline': const BoolValue(true),
        'screen': const EnumValue(_Screen.search),
      });
    final (event, params) = sink.records.single;
    expect(event, TelemetryEvent.searchPerformed);
    // Sealed ierarxiya: matn (String) parametr turi mavjud emas.
    for (final v in params.values) {
      expect(v is IntValue || v is BoolValue || v is EnumValue, isTrue);
    }
  });

  test('PHASE 2 default sink hech narsa yubormaydi', () {
    const NoopTelemetrySink().record(TelemetryEvent.appStarted);
  });

  test('SensitiveText.redact matnni chiqarmaydi', () {
    expect(SensitiveText.redact('patient Ivanov case 123'), '[redacted:23]');
    expect(SensitiveText.redact(''), '');
  });

  test('ilova kodida tashqi analytics/crash SDK yo‘q', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final sdk in [
      'firebase_analytics',
      'firebase_crashlytics',
      'sentry',
      'amplitude',
      'mixpanel',
      'appmetrica',
    ]) {
      expect(pubspec.contains(sdk), isFalse, reason: sdk);
    }
  });

  test('TelemetryValue’da String turi yo‘q (manba tekshiruvi)', () {
    final src = File('lib/core/telemetry/telemetry.dart').readAsStringSync();
    expect(
      RegExp(r'class \w+ extends TelemetryValue[^}]*String').hasMatch(src),
      isFalse,
    );
  });
}
