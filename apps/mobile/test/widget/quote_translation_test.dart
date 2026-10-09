import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/evidence/content_translations.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Haqiqiy pilot paket (Phase C): UI tilidagi tarjima **birinchi**, holat
/// belgisi, asl iqtibos «Asl matn» ostida (yig‘ilgan); tarjima yo‘q yoki
/// eskirgan bo‘lsa — halol xabar + asl matn.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  const claimId = 'C-METHANOL-ANALYTICAL_METHOD-P5';
  const original =
      'Thereafter, ethanol, methanol, and formate concentrations were '
      'measured by headspace GC/FID.';
  const kind = ContentTextKind.claimExcerpt;

  Future<void> open(
    WidgetTester tester,
    String lang, {
    ContentTranslations? translations,
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

  testWidgets('uz: tarjima birinchi, holat, asl matn yig‘ilgan', (
    tester,
  ) async {
    expect(pilot.translations.isEmpty, isFalse);
    await open(tester, 'uz');
    final card = find.byKey(const Key('claim.excerpt.$claimId'));
    await scrollTo(tester, card);
    expect(card, findsOneWidget);
    final tr = find.byKey(const Key('quote.translation.$kind.$claimId'));
    expect(tr, findsOneWidget);
    expect(
      find.descendant(
        of: tr,
        matching: find.text('Avtomatik tarjima — tekshirilmagan'),
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
    // Asl iqtibos (dalil) yig‘ilgan — bosilganda ochiladi, o‘zgarmagan.
    expect(find.textContaining(original), findsNothing);
    final toggle = find.byKey(const Key('l10n.originalToggle.$kind.$claimId'));
    expect(
      find.descendant(of: toggle, matching: find.text('Asl matn')),
      findsOneWidget,
    );
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    final orig = find.byKey(const Key('l10n.original.$kind.$claimId'));
    expect(
      find.descendant(of: orig, matching: find.textContaining(original)),
      findsOneWidget,
    );
    // Asl matn tarjima OSTIDA.
    expect(
      tester.getTopLeft(orig).dy,
      greaterThan(tester.getTopLeft(tr).dy),
    );
    expect(
      find.descendant(of: toggle, matching: find.text('Asl matnni yashirish')),
      findsOneWidget,
    );
    // «§ ABSTRACT» emas — lokal bo‘lim nomi.
    expect(find.textContaining('§ Annotatsiya'), findsWidgets);
    expect(find.textContaining('§ ABSTRACT'), findsNothing);
    expect(find.textContaining('tekshirilgan tarjima'), findsNothing);
  });

  testWidgets('ru: «Оригинал» va ruscha holat belgisi', (tester) async {
    await open(tester, 'ru');
    final card = find.byKey(const Key('claim.excerpt.$claimId'));
    await scrollTo(tester, card);
    final tr = find.byKey(const Key('quote.translation.$kind.$claimId'));
    expect(
      find.descendant(
        of: tr,
        matching: find.text('Автоматический перевод — не проверен'),
      ),
      findsOneWidget,
    );
    expect(find.text('Оригинал'), findsWidgets);
  });

  testWidgets('en: tarjima ko‘rsatilmaydi, faqat asl matn (belgisiz)', (
    tester,
  ) async {
    await open(tester, 'en');
    final card = find.byKey(const Key('claim.excerpt.$claimId'));
    await scrollTo(tester, card);
    expect(find.textContaining(original), findsOneWidget);
    expect(
      find.byKey(const Key('quote.translation.$kind.$claimId')),
      findsNothing,
    );
    expect(find.byKey(const Key('l10n.missing.$kind.$claimId')), findsNothing);
    expect(find.textContaining('§ Abstract'), findsWidgets);
  });

  testWidgets('uz: eskirgan tarjima — halol xabar + asl matn', (
    tester,
  ) async {
    await open(
      tester,
      'uz',
      translations: ContentTranslations.of([
        ContentTranslationRow.tryParse(
          kind: kind,
          id: claimId,
          lang: 'uz',
          sourceSha256: TextTranslation.hashOf('an older excerpt'),
          text: 'Eskirgan tarjima',
          status: 'machine_draft',
        )!,
      ]),
    );
    final card = find.byKey(const Key('claim.excerpt.$claimId'));
    await scrollTo(tester, card);
    expect(find.textContaining(original), findsOneWidget);
    expect(find.text('Eskirgan tarjima'), findsNothing);
    expect(find.text('Avtomatik tarjima — tekshirilmagan'), findsNothing);
    expect(
      find.text(
        'Bu matnning o‘zbekcha tarjimasi hali tayyorlanmagan — asl tili: ingliz',
      ),
      findsWidgets,
    );
  });
}
