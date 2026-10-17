import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';
import '../helpers/screens.dart';

/// Suzuvchi menyu ekran oxiridagi kontentni berkitmasligi kerak: har bir
/// ekranda asosiy vertikal skroll oxirigacha surilganda hech bir matn
/// menyu ostida qolmaydi (pastki padding = menyu + safe area).
void main() {
  setUp(() => floatingNavEnabled = true);
  tearDown(() => floatingNavEnabled = kFloatingNav);

  final routes = <String>{
    ...everyScreen,
    Routes.classQuiz,
    Routes.discipline('forensic_chemistry'),
    Routes.librarySection('substances'),
    '/library/entry/TEST-SUB-ETOH',
  };

  for (final mode in UserMode.values) {
    testWidgets('kontent menyu ostida qolmaydi (${mode.name})', (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: mode),
      );
      final failures = <String>[];
      for (final route in routes) {
        c.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        final nav = find.byKey(const Key('nav.floating'));
        if (nav.evaluate().isEmpty) {
          debugPrint('NONAV $route');
          continue;
        }
        final navTop = tester.getRect(nav).top;
        final scrollables = find
            .byType(Scrollable)
            .hitTestable()
            .evaluate()
            .where((e) {
              final s = e.widget as Scrollable;
              return axisDirectionToAxis(s.axisDirection) == Axis.vertical;
            })
            .toList();
        if (scrollables.isEmpty) {
          debugPrint('NOSCROLL $route');
          continue;
        }
        // Eng katta (asosiy) skroll.
        scrollables.sort(
          (a, b) => (b.renderObject! as RenderBox).size.height.compareTo(
            (a.renderObject! as RenderBox).size.height,
          ),
        );
        final main = scrollables.first;
        final state = (main as StatefulElement).state as ScrollableState;
        final pos = state.position;
        pos.jumpTo(pos.maxScrollExtent);
        await tester.pumpAndSettle();
        final box = main.renderObject! as RenderBox;
        final viewBottom = box.localToGlobal(Offset(0, box.size.height)).dy;
        debugPrint('R $route vb=$viewBottom nt=$navTop');
        if (viewBottom <= navTop) continue;
        var worst = 0.0;
        String? worstText;
        void visit(Element e) {
          final ro = e.renderObject;
          if (e.widget is RichText && ro is RenderParagraph && ro.hasSize) {
            final r = ro.localToGlobal(Offset.zero) & ro.size;
            if (r.bottom > navTop + 1 && r.top < viewBottom - 1) {
              if (r.bottom - navTop > worst) {
                worst = r.bottom - navTop;
                worstText = ro.text.toPlainText();
              }
            }
          }
          e.visitChildren(visit);
        }

        main.visitChildren(visit);
        if (worstText != null) {
          failures.add('$route: «$worstText» ${worst.toStringAsFixed(0)} dp');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  }
}
