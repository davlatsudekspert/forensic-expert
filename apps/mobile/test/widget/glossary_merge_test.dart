import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/pump_app.dart';

/// Kutubxona: bitta «Ilmiy lug‘at» kirish nuqtasi (eski «Glossariy» kafeli
/// yo‘q); kutubxonadagi lug‘at maqolalari lug‘at ichida ko‘rinadi.
void main() {
  for (final lang in ['uz', 'ru', 'en']) {
    testWidgets('$lang: kutubxonada bitta lug‘at kafeli', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        initialLocation: Routes.library,
      );
      expect(find.byKey(const Key('library.hub.glossary')), findsNothing);
      await tester.dragUntilVisible(
        find.byKey(const Key('library.hub.terms')),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      expect(find.byKey(const Key('library.hub.terms')), findsOneWidget);
    });
  }

  testWidgets('uz: lug‘at ichida kutubxona maqolalari va filtr', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.glossary,
    );
    final article = find.byKey(const Key('glossary.article.TEST-GLOSS-COC'));
    await tester.dragUntilVisible(
      article,
      find.byKey(const Key('glossary.list')),
      const Offset(0, -300),
    );
    expect(article, findsOneWidget);
    expect(find.text('Kutubxonadagi lug‘at maqolalari'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('glossary.filter')),
      'saqlash zanjiri',
    );
    await tester.pumpAndSettle();
    expect(article, findsOneWidget);
    expect(
      find.byKey(const Key('glossary.article.TEST-GLOSS-MATRIX')),
      findsNothing,
    );
  });
}
