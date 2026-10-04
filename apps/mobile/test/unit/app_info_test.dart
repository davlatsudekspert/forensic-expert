import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/app_info.dart';

void main() {
  test('AppInfo.version pubspec.yaml bilan mos', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)',
      multiLine: true,
    ).firstMatch(pubspec)!;
    expect(AppInfo.version, m[1]);
    expect(AppInfo.build, int.parse(m[2]!));
  });
}
