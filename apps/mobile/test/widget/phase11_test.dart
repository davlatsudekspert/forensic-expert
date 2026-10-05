import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/user_data.dart';

import '../helpers/pump_app.dart';

/// PHASE 11: maxfiylik, ma’lumotni o‘chirish, release konfiguratsiyasi.
void main() {
  testWidgets('qurilmadagi ma’lumotlarni o‘chirish (tasdiq bilan)', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.profile,
    );
    await c.read(userDataProvider.notifier).toggleFavorite('morphine');
    await c.read(userDataProvider.notifier).recordSearch('fentanyl');
    expect(c.read(userDataProvider).favorites, isNotEmpty);
    final row = find.byKey(const Key('profile.deleteLocalData'));
    await tester.dragUntilVisible(
      row,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile.deleteLocalData.confirm')));
    await tester.pumpAndSettle();
    expect(c.read(userDataProvider).favorites, isEmpty);
    expect(c.read(userDataProvider).recentSearches, isEmpty);
  });

  group('release konfiguratsiyasi (statik)', () {
    test('Android: zaxira o‘chiq, faqat HTTPS, ortiqcha ruxsat yo‘q', () {
      final m = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(m, contains('android:allowBackup="false"'));
      expect(m, contains('android:usesCleartextTraffic="false"'));
      for (final p in [
        'ACCESS_FINE_LOCATION',
        'CAMERA',
        'READ_CONTACTS',
        'RECORD_AUDIO',
      ]) {
        expect(m, isNot(contains(p)));
      }
    });

    test('Android: kalit/parol repozitoriyda yo‘q; imzo himoyasi bor', () {
      final g = File('android/app/build.gradle.kts').readAsStringSync();
      expect(g, contains('requireReleaseSigning'));
      expect(File('android/key.properties').existsSync(), isFalse);
      final ex = File('android/key.properties.example').readAsStringSync();
      expect(ex, contains('CHANGE_ME'));
    });

    test('iOS: privacy manifest — kuzatuv yo‘q; eksport kaliti bor', () {
      final p = File('ios/Runner/PrivacyInfo.xcprivacy').readAsStringSync();
      expect(p, contains('<key>NSPrivacyTracking</key>\n\t<false/>'));
      expect(
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync(),
        contains('PrivacyInfo.xcprivacy in Resources'),
      );
      expect(
        File('ios/Runner/Info.plist').readAsStringSync(),
        contains('ITSAppUsesNonExemptEncryption'),
      );
    });

    test('release: INTERNET (faqat HTTPS), email va xarid tarixi e’lon '
        'qilingan, kuzatuv yo‘q', () {
      final m = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(m, contains('android.permission.INTERNET'));
      expect(m, contains('android:usesCleartextTraffic="false"'));
      final p = File('ios/Runner/PrivacyInfo.xcprivacy').readAsStringSync();
      expect(p, contains('NSPrivacyCollectedDataTypeEmailAddress'));
      expect(p, contains('NSPrivacyCollectedDataTypePurchaseHistory'));
      expect(
        p,
        isNot(
          contains('NSPrivacyCollectedDataTypePurposeThirdPartyAdvertising'),
        ),
      );
      expect(
        RegExp(r'<key>NSPrivacyCollectedDataTypeTracking</key>\s*<true/>')
            .hasMatch(p),
        isFalse,
      );
    });
  });
}
