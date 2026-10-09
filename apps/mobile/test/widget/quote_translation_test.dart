import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/evidence/machine_translations.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Haqiqiy pilot paket: asl iqtibos birinchi, ostida belgilangan avtomatik
/// tarjima; bo‘lim kodi lokal nom bilan.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  const claimId = 'C-METHANOL-ANALYTICAL_METHOD-P5';
  const original =
      'Thereafter, ethanol, methanol, and formate concentrations were '
      'measured by headspace GC/FID.';

  Future<void> open(
    WidgetTester tester,
    String lang, {
    MachineTranslations? translations,
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    initialLocation: Routes.libraryEntry('methanol'),
    testFixtures: false,
    overrides: pilot.overridesWith(machine: translations),
  );

  Future<void> scrollTo(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f,
      find.byType(ListView).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('uz: asl iqtibos + «Avtomatik tarjima · tekshirilmagan»', (
    tester,
  ) async {
    expect(pilot.translations.isEmpty, isFalse);
    await open(tester, 'uz');
    final card = find.byKey(const Key('claim.excerpt.$claimId'));
    await scrollTo(tester, card);
    expect(card, findsOneWidget);
    // Asl matn (dalil) o‘zgarmagan.
    expect(
      find.descendant(of: card, matching: find.textContaining(original)),
      findsOneWidget,
    );
    final tr = find.byKey(
      const Key('quote.translation.claim_excerpt.$claimId'),
    );
    expect(tr, findsOneWidget);
    expect(
      find.descendant(
        of: tr,
        matching: find.text('Avtomatik tarjima · tekshirilmagan'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: tr,
        matching: find.textContaining(
          'Shundan so‘ng etanol, metanol va formiat',
        ),
      ),
      findsOneWidget,
    );
    // Tarjima asl iqtibos OSTIDA.
    expect(
      tester.getTopLeft(tr).dy,
      greaterThan(tester.getTopLeft(find.textContaining(original)).dy),
    );
    // «§ ABSTRACT» emas — lokal bo‘lim nomi.
    expect(find.textContaining('§ Annotatsiya'), findsWidgets);
    expect(find.textContaining('§ ABSTRACT'), findsNothing);
    expect(find.textContaining('tekshirilgan tarjima'), findsNothing);
  });

  testWidgets('en: tarjima ko‘rsatilmaydi, faqat asl matn', (tester) async {
    await open(tester, 'en');
    final card = find.byKey(const Key('claim.excerpt.$claimId'));
    await scrollTo(tester, card);
    expect(find.textContaining(original), findsOneWidget);
    expect(
      find.byKey(const Key('quote.translation.claim_excerpt.$claimId')),
      findsNothing,
    );
    expect(find.textContaining('§ Abstract'), findsWidgets);
  });

  testWidgets('uz: eskirgan tarjima (xesh mos emas) — ko‘rsatilmaydi', (
    tester,
  ) async {
    await open(
      tester,
      'uz',
      translations: MachineTranslations.of([
        TextTranslation(
          target: TextTranslationTarget.claimExcerpt,
          targetId: claimId,
          lang: 'uz',
          sourceSha256: TextTranslation.hashOf('an older excerpt'),
          text: 'Eskirgan tarjima',
        ),
      ]),
    );
    final card = find.byKey(const Key('claim.excerpt.$claimId'));
    await scrollTo(tester, card);
    expect(find.textContaining(original), findsOneWidget);
    expect(find.text('Avtomatik tarjima · tekshirilmagan'), findsNothing);
    expect(find.text('Eskirgan tarjima'), findsNothing);
  });
}
