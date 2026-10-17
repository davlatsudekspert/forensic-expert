import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/features/library/presentation/substance_analysis_section.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// «Tahlil» tabi: egasi belgilagan 3 bo‘lim — 1) test, 2) sifat reaksiyalari,
/// 3) miqdoriy aniqlash. HAQIQIY pilot paket, o‘zbek tilida; 390 va 320 dp.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(
    WidgetTester tester,
    String id, {
    Size size = const Size(390, 844),
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: 'uz'),
    initialLocation: Routes.libraryEntry(id),
    size: size,
    testFixtures: false,
    overrides: [...pilot.overrides],
  );

  /// Lazy ro‘yxatda kartani topguncha pastga suramiz.
  Future<void> scrollTo(WidgetTester tester, Finder f) async {
    for (var i = 0; i < 80 && f.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
  }

  test('maydonlar uch bo‘limga takrorsiz taqsimlangan', () {
    final all = [for (final fs in analysisSectionFields.values) ...fs];
    expect(all.toSet().length, all.length);
    expect(analysisSectionFields[1], contains('immunoassay_screen'));
    expect(analysisSectionFields[2], contains('colour_test'));
    expect(analysisSectionFields[3], contains('confirmatory_method'));
  });

  testWidgets('fenobarbital: 3 bo‘lim tartibda, bo‘sh holat yo‘q', (
    tester,
  ) async {
    await open(tester, 'phenobarbital');
    for (final n in [1, 2, 3]) {
      await scrollTo(tester, find.byKey(Key('analysis.s$n.phenobarbital')));
      expect(
        find.byKey(Key('analysis.s$n.empty.phenobarbital')),
        findsNothing,
        reason: 'bo‘lim $n',
      );
    }
    // Sarlavhalar (o‘zbekcha, egasi tartibida).
    expect(find.text('1. Test (ekspress / skrining)'), findsOneWidget);
    expect(
      find.text('2. Sifat reaksiyalari (rangli reaktivlar)'),
      findsOneWidget,
    );
  });

  testWidgets('loperamid: manba yo‘q — uchala bo‘lim halol bo‘sh', (
    tester,
  ) async {
    await open(tester, 'loperamide');
    for (final n in [1, 2, 3]) {
      await scrollTo(tester, find.byKey(Key('analysis.s$n.loperamide')));
      expect(
        find.byKey(Key('analysis.s$n.empty.loperamide')),
        findsOneWidget,
        reason: 'bo‘lim $n bo‘sh bo‘lishi kerak',
      );
    }
    expect(
      find.text(
        'Bu bo‘lim uchun manbali ma’lumot hali yo‘q — manba kerak. '
        'Hech narsa taxmin qilinmaydi.',
      ),
      findsWidgets,
    );
  });

  testWidgets('320 dp ekranda morfin: bo‘limlar sarlavhasi sig‘adi', (
    tester,
  ) async {
    await open(tester, 'morphine', size: const Size(320, 640));
    await scrollTo(tester, find.byKey(const Key('analysis.s1.morphine')));
    await scrollTo(tester, find.byKey(const Key('analysis.s2.morphine')));
    await scrollTo(tester, find.byKey(const Key('analysis.s3.morphine')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sirka kislota: 3 bo‘lim ham kitob (TOKS) yozuvlari bilan', (
    tester,
  ) async {
    await open(tester, 'acetic-acid');
    for (final n in [1, 2, 3]) {
      await scrollTo(tester, find.byKey(Key('analysis.s$n.acetic-acid')));
      expect(
        find.byKey(Key('analysis.s$n.empty.acetic-acid')),
        findsNothing,
        reason: 'bo‘lim $n',
      );
    }
    final card = find.byKey(const Key('claim.C-AS-ACETIC-ACID-COLOUR_TEST-01'));
    await scrollTo(tester, card);
    expect(
      find.descendant(of: card, matching: find.textContaining('Temir(III)')),
      findsOneWidget,
    );
    // Aniq joyi (bet) ko‘rsatiladi.
    expect(
      find.byKey(const Key('claim.locator.C-AS-ACETIC-ACID-COLOUR_TEST-01')),
      findsOneWidget,
    );
  });

  testWidgets('simob: «Test» bo‘limi halol bo‘sh, qolgan ikkitasi to‘la', (
    tester,
  ) async {
    await open(tester, 'mercury');
    await scrollTo(tester, find.byKey(const Key('analysis.s1.empty.mercury')));
    expect(find.byKey(const Key('analysis.s2.empty.mercury')), findsNothing);
    expect(find.byKey(const Key('analysis.s3.empty.mercury')), findsNothing);
    final card = find.byKey(const Key('claim.C-AS-MERCURY-COLOUR_TEST-01'));
    await scrollTo(tester, card);
    expect(
      find.descendant(of: card, matching: find.textContaining('Ditizon')),
      findsOneWidget,
    );
  });

  testWidgets('aminazin: «Test» bo‘limida peshob sinamasi (kitob, 170-bet)', (
    tester,
  ) async {
    await open(tester, 'chlorpromazine');
    final card = find.byKey(
      const Key('claim.C-AS-CHLORPROMAZINE-EXPRESS_TEST-01'),
    );
    await scrollTo(tester, card);
    expect(
      find.descendant(of: card, matching: find.textContaining('FPN')),
      findsOneWidget,
    );
  });

  testWidgets('rus tilida: faqat o‘zbekcha yozuv «tarjima kutilmoqda» bilan', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.libraryEntry('acetic-acid'),
      testFixtures: false,
      overrides: [...pilot.overrides],
    );
    final note = find.byKey(
      const Key('claim.statement.pending.C-AS-ACETIC-ACID-COLOUR_TEST-01'),
    );
    await scrollTo(tester, note);
    expect(note, findsWidgets);
  });

  testWidgets('furanilfentanil: LOD/LOQ manba jumlasi bilan (PMC, CC BY)', (
    tester,
  ) async {
    await open(tester, 'furanylfentanyl');
    final card = find.byKey(
      const Key('claim.C-AS-FURANYLFENTANYL-ANALYTICAL_METHOD-02'),
    );
    await scrollTo(tester, card);
    // Asl inglizcha jumla + o‘zbekcha tarjima (avtomatik, tekshirilmagan).
    expect(
      find.descendant(
        of: card,
        matching: find.textContaining('0,30 va 1,0 ng/mL'),
      ),
      findsWidgets,
    );
  });

  testWidgets('tramadol: «Test» bo‘limida immunoanaliz yolg‘on musbat', (
    tester,
  ) async {
    await open(tester, 'tramadol');
    final card = find.byKey(
      const Key('claim.C-AS-TRAMADOL-IMMUNOASSAY_SCREEN-02'),
    );
    await scrollTo(tester, card);
    expect(
      find.descendant(of: card, matching: find.textContaining('Feksofenadin')),
      findsWidgets,
    );
    expect(find.byKey(const Key('analysis.s1.empty.tramadol')), findsNothing);
  });
}
