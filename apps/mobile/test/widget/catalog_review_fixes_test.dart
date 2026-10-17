import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/widgets/fe_components.dart';
import 'package:forensic_expert/features/knowledge/presentation/knowledge_detail_screen.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Ekranlar katalogi ko‘rigi (2026-10-17) tuzatishlari: aralash til, uzun
/// AppBar sarlavhasi, skrining ogohlantirishi, GHS P-kodlar, manbasiz mavzu
/// kartasi, «Rasmiy til» bosh harfi.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<ProviderContainer> open(
    WidgetTester tester,
    String location, {
    String lang = 'uz',
    Size size = const Size(390, 844),
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    initialLocation: location,
    testFixtures: false,
    size: size,
    overrides: [...pilot.overrides],
  );

  final uz = lookupAppLocalizations(const Locale('uz'));

  testWidgets('skrining ro‘yxati: uz rejimda prinsip o‘zbekcha (inglizcha '
      'emas)', (tester) async {
    await open(tester, Routes.knowledge('screeningTest'));
    expect(find.text('colour (spot) reaction'), findsNothing);
    expect(find.text('immunoassay'), findsNothing);
    expect(find.text('rangli (tomchi) reaksiya'), findsOneWidget);
    expect(find.text('immunoanaliz'), findsWidgets);
  });

  testWidgets('skrining ogohlantirishi: KATTA HARF emas, mayin uslub', (
    tester,
  ) async {
    await open(tester, Routes.knowledge('screeningTest'));
    final banner = tester.widget<FeBanner>(
      find.byKey(const Key('screening.banner')),
    );
    expect(banner.tone, FeBannerTone.critical);
    expect(banner.text, uz.screeningBanner);
    expect(banner.text.startsWith('SKRINING NATIJASI'), isFalse);
    expect(banner.text, contains('tasdiqlangan identifikatsiya emas'));
  });

  testWidgets('qidiruv «etanol»: sarlavha joriy tilda — «methyl alcohol» '
      'emas', (tester) async {
    await open(tester, Routes.searchWith('etanol'));
    await tester.pumpAndSettle();
    expect(find.text('methyl alcohol'), findsNothing);
    // Avval «methyl alcohol» sarlavha, «Metanol» izohda edi.
    expect(find.text('Metanol'), findsOneWidget);
  });

  testWidgets('uzun AppBar sarlavhasi 2 qatorga o‘tadi (kesilmaydi)', (
    tester,
  ) async {
    await open(tester, Routes.tool('tool.lab.molarity'));
    final title = find.descendant(
      of: find.byType(AppBar),
      matching: find.text(uz.toolMolarityName),
    );
    expect(title, findsOneWidget);
    final text = tester.widget<Text>(title);
    expect(text.maxLines, 2);
    expect(text.style?.fontSize, FeAppBarTitle.twoLineFontSize);
    expect(tester.takeException(), isNull);
  });

  testWidgets('qisqa AppBar sarlavhasi — bir qator, odatiy shrift', (
    tester,
  ) async {
    await open(tester, Routes.tools);
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(uz.toolsTitle),
      ),
    );
    expect(text.maxLines, 1);
  });

  test('GHS: P-kodlar ajratiladi, H-bayonotlar xulosada qoladi', () {
    const t =
        'Natriy gidroksid (PubChem CID 14798) — Xavfli. H314: Terini jiddiy '
        'kuydiradi. GHS piktogrammalari: Yemiruvchi (korroziv). Ehtiyot '
        'choralari (P-kodlar): P260, P264, P280, P301+P330+P331, P501.';
    final r = splitGhsPCodes(t)!;
    expect(r.$1, endsWith('Yemiruvchi (korroziv).'));
    expect(r.$1, contains('H314'));
    expect(r.$2, ['P260', 'P264', 'P280', 'P301+P330+P331', 'P501']);
    expect(
      splitGhsPCodes(
        'Formaldehyde — Danger. Precautionary statements (P-codes): P203, '
        'P260.',
      )!.$2,
      ['P203', 'P260'],
    );
    expect(splitGhsPCodes('P-kodlarsiz oddiy izoh.'), isNull);
  });

  testWidgets('sud tibbiyoti: manbasiz mavzu boshqa kartalar bilan bir xil '
      'karta', (tester) async {
    await open(tester, Routes.forensicMedicine);
    final row = find.byKey(const Key('fm.topic.causeMechanismManner'));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(of: row, matching: find.byType(FeCard)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: row,
        matching: find.text(uz.knowledgeNoSourcedContent),
      ),
      findsOneWidget,
    );
  });
}
