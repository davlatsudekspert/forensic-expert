import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/features/pro/presentation/pro_first_offer.dart';

import '../helpers/pump_app.dart';

/// Haqiqiy yig‘ma (FE_PRO berilmagan): ilovada to‘lovga oid HECH NARSA yo‘q —
/// Pro taklifi, «Pro rejasi» qatori/ekrani, qulf belgilari (egasi qarori,
/// 2026-11-01; Apple 2.3/3.1). Hamma funksiya bepul ochiq.
void main() {
  for (final mode in UserMode.values) {
    testWidgets('${mode.name}: Asosiyda Pro taklifi va qulf yo‘q', (t) async {
      await pumpApp(
        t,
        settings: completedSettings(lang: 'uz', mode: mode),
        size: const Size(390, 4000),
        proEnabled: false,
      );
      expect(find.byType(ProFirstOfferCard), findsOneWidget);
      expect(find.textContaining(RegExp(r'\bPro\b')), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });
  }

  testWidgets('Profil: «Pro rejasi» qatori yo‘q', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz'),
      size: const Size(390, 4000),
      initialLocation: Routes.profile,
      proEnabled: false,
    );
    expect(find.byKey(const Key('profile.plan')), findsNothing);
    expect(find.textContaining(RegExp(r'\bPro\b')), findsNothing);
  });

  testWidgets('/profile/pro havolasi Asosiyga qaytadi', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.pro,
      proEnabled: false,
    );
    expect(find.byKey(const Key('home.areas')), findsOneWidget);
  });

  testWidgets('Ustoz: guruh yaratish qulfsiz', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
      initialLocation: Routes.groups,
      proEnabled: false,
    );
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.textContaining(RegExp(r'\bPro\b')), findsNothing);
  });

  testWidgets('Talaba: o‘quv rejimi to‘plamlari qulfsiz', (t) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz', mode: UserMode.student),
      initialLocation: Routes.study,
      proEnabled: false,
    );
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.textContaining(RegExp(r'\bPro\b')), findsNothing);
  });
}
