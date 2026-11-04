// PROMO Talaba REVISION 4: cards (Testlar va kartochkalar) va exam
// (Imtihon rejimi) — qisqa qo‘shimcha sahnalar (student rejimi).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

String? _deck;

/// Majmua (Yuldashev) bo‘lmagan birinchi to‘plam id si.
String? findDeck() {
  final re = RegExp(r"^\[<'study\.deck\.(.+)'>\]$");
  for (final e
      in find
          .byWidgetPredicate((w) => w.key is Key && re.hasMatch('${w.key}'))
          .evaluate()) {
    final m = re.firstMatch('${e.widget.key}');
    final id = m!.group(1)!;
    if (!id.startsWith('teaching.')) return id;
  }
  return null;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo extra2', (tester) async {
    final p = Promo(tester, 'talaba_extra2');
    await p.launch(mode: 'student');

    await p.scene('cards', () async {
      await p.go(Routes.home, after: 700);
      await p.reveal(
        p.byKeyStr('workbench.deskTests'),
        alignment: 0.3,
        after: 500,
      );
      await p.tapKey('workbench.deskTests', after: 1500);
      p.screen('study hub');
      await p.scroll(900, ms: 2000);
      _deck = findDeck();
      debugPrint('PROMO deck=$_deck');
      await p.reveal(
        p.byKeyStr('study.deck.$_deck'),
        alignment: 0.15,
        after: 700,
      );
      await p.tapKey('study.cards.$_deck', after: 1800);
      p.screen('card front');
      await p.tapKey('study.reveal', after: 2000);
      p.screen('card back');
      if (p.has('study.knew')) await p.tapKey('study.knew', after: 1200);
    });

    await p.scene('exam', () async {
      await p.go(Routes.study, after: 900);
      await p.reveal(
        p.byKeyStr('study.deck.teaching.gmt'),
        alignment: 0.15,
        after: 700,
      );
      p.screen('exam deck');
      await p.tapKey('study.exam.teaching.gmt', after: 1800);
      p.screen('exam start');
      await p.tapKey('study.quiz.option.1', after: 1500);
      p.screen('exam answered');
    });

    await p.wait(2500);
    p.finish();
  });
}
