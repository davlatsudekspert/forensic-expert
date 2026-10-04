import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/tokens.dart';

/// WCAG 2.2 nisbiy yorug‘lik va kontrast nisbati.
double _channel(double c) =>
    c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double contrast(Color a, Color b) {
  final la = luminance(a), lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('kontrast formulasi: oq/qora = 21:1', () {
    expect(contrast(Colors.white, Colors.black), closeTo(21, 0.01));
  });

  for (final (name, tokens) in [
    ('light', FePalette.light),
    ('dark', FePalette.dark),
  ]) {
    group('$name palitra — WCAG AA (≥ 4.5:1)', () {
      for (final (fg, bg, label) in tokens.textPairs) {
        test(label, () {
          final r = contrast(fg, bg);
          expect(
            r,
            greaterThanOrEqualTo(4.5),
            reason: '$label = ${r.toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }

  for (final (name, tokens) in [
    ('light high contrast', FePalette.lightHighContrast),
    ('dark high contrast', FePalette.darkHighContrast),
  ]) {
    group('$name — WCAG AAA (≥ 7:1)', () {
      for (final (fg, bg, label) in tokens.textPairs) {
        test(label, () {
          final r = contrast(fg, bg);
          expect(
            r,
            greaterThanOrEqualTo(7),
            reason: '$label = ${r.toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }
}
