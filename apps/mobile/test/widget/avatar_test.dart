import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/avatar.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/pump_app.dart';

/// 1×1 PNG.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _Storage implements AvatarStorage {
  Uint8List? data;
  @override
  Future<Uint8List?> load() async => data;
  @override
  Future<void> save(Uint8List bytes) async => data = bytes;
  @override
  Future<void> clear() async => data = null;
}

class _Picker implements AvatarPicker {
  _Picker(this.result, {this.fail = false});
  final Uint8List? result;
  final bool fail;
  @override
  Future<Uint8List?> pick() async {
    if (fail) throw StateError('no access');
    return result;
  }
}

void main() {
  Future<void> open(WidgetTester tester, _Storage s, _Picker p) => pumpApp(
    tester,
    settings: completedSettings(),
    initialLocation: Routes.profile,
    overrides: [
      avatarStorageProvider.overrideWithValue(s),
      avatarPickerProvider.overrideWithValue(p),
    ],
  );

  testWidgets('rasm yo‘q: sheet’da faqat tanlash va qurilmada saqlanishi', (
    tester,
  ) async {
    await open(tester, _Storage(), _Picker(null));
    await tester.tap(find.byKey(const Key('profile.avatar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('avatar.choose')), findsOneWidget);
    expect(find.byKey(const Key('avatar.view')), findsNothing);
    expect(find.byKey(const Key('avatar.remove')), findsNothing);
    expect(find.textContaining('never sent to a server'), findsOneWidget);
  });

  testWidgets('tanlash → moslash → saqlash → ko‘rish → olib tashlash', (
    tester,
  ) async {
    final s = _Storage();
    await open(tester, s, _Picker(Uint8List.fromList(_png)));
    await tester.tap(find.byKey(const Key('profile.avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatar.choose')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('avatar.crop')), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('avatar.save')));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
    expect(s.data, isNotNull);
    expect(s.data!.length, greaterThan(8));
    // profil kartasida rasm.
    expect(
      find.descendant(
        of: find.byKey(const Key('profile.avatar')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    // kattalashtirib ko‘rish.
    await tester.tap(find.byKey(const Key('profile.avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatar.view')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('avatar.viewer')), findsOneWidget);
    await tester.tap(find.byKey(const Key('avatar.viewer')));
    await tester.pumpAndSettle();
    // olib tashlash.
    await tester.tap(find.byKey(const Key('profile.avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatar.remove')));
    await tester.pumpAndSettle();
    expect(s.data, isNull);
    expect(
      find.descendant(
        of: find.byKey(const Key('profile.avatar')),
        matching: find.byType(Image),
      ),
      findsNothing,
    );
  });

  testWidgets('bekor qilish: rasm saqlanmaydi', (tester) async {
    final s = _Storage();
    await open(tester, s, _Picker(Uint8List.fromList(_png)));
    await tester.tap(find.byKey(const Key('profile.avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatar.choose')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatar.cancel')));
    await tester.pumpAndSettle();
    expect(s.data, isNull);
  });

  testWidgets('galereya ochilmasa tushunarli xato', (tester) async {
    await open(tester, _Storage(), _Picker(null, fail: true));
    await tester.tap(find.byKey(const Key('profile.avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatar.choose')));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not open the photo. Choose another one.'),
      findsOneWidget,
    );
  });
}
