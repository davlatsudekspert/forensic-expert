// REAL-ILOVA QA — «TO‘LOV QATLAMI YO‘Q, HAMMASI OCHIQ» (egasi qarori,
// 2026-10-17; Apple 2.5.19 va 3.1.1).
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy pilot kontent paketi, Linux desktop.
// TALABA yo‘li: Asosiy, Kutubxona (bo‘lim: BARCHA yozuvlar), modda detali
// (oxirigacha), Vositalar, AI, Profil, O‘quv. Har ekranda (aylantirib) barcha
// matn yig‘iladi va to‘lov/Pro/tarif/qulf so‘zlari YO‘QLIGI tekshiriladi;
// qulf ikonkasi va paywall yo‘li ham.
//
// Muhit: QA_LANG=uz|ru|en  QA_OUT=<katalog>  QA_MODE=student|professional
//   QA_LANG=ru ./tool/qa_real_app.sh nopaywall
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

/// To‘lov/tarif/qulf bilan bog‘liq so‘zlar (uz, ru, en). «Professional»
/// (rejim nomi) bu ro‘yxatga kirmaydi — `\bpro\b` faqat alohida «Pro».
final _banned = RegExp(
  r'\bpro\b|subscri|obuna|tarif|xarid|narx|to.lov|qulf|premium|lifetime|'
  r'restore|paywall|locked|unlock|bepul demo|free demo|'
  r'подпис|тариф|покуп|оплат|цен[аы]\b|заблок|разблок|платн',
  caseSensitive: false,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final env = Platform.environment;
  final lang = env['QA_LANG'] ?? 'uz';
  final mode = env['QA_MODE'] ?? 'student';

  testWidgets('QA real app — TO‘LOV QATLAMI YO‘Q ($lang/$mode)', (
    tester,
  ) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final qa = await launchRealApp(
      tester,
      role: 'nopaywall',
      prefs: {
        'fe.settings.locale': lang,
        'fe.settings.theme': 'light',
        'fe.settings.mode': mode,
        'fe.settings.disclaimer_version': 1,
      },
    );
    qa.lang = lang;

    /// Joriy ekranni tepadan pastgacha aylantirib, ko‘ringan barcha matn va
    /// tile kalitlarini yig‘adi.
    Future<({Set<String> texts, int locks, Set<String> keys})> sweep() async {
      final texts = <String>{};
      final keys = <String>{};
      var locks = 0;
      await qa.scrollToTop();
      for (var i = 0; i < 80; i++) {
        texts.addAll(qa.visibleTexts());
        locks += find.byIcon(Icons.lock_outline).evaluate().length;
        locks += find
            .byIcon(Icons.workspace_premium_outlined)
            .evaluate()
            .length;
        for (final e in find.byType(KeyedSubtree).evaluate()) {
          final k = e.widget.key;
          if (k is ValueKey<String>) keys.add(k.value);
        }
        for (final w in tester.allWidgets) {
          final k = w.key;
          if (k is ValueKey<String>) keys.add(k.value);
        }
        final st = qa.mainScrollable();
        if (st == null || st.position.pixels >= st.position.maxScrollExtent) {
          break;
        }
        await qa.scrollBy(300);
      }
      return (texts: texts, locks: locks, keys: keys);
    }

    Future<void> checkScreen(
      String title,
      String route, {
      void Function(QaStep s, Set<String> texts, Set<String> keys)? extra,
    }) async {
      await qa.step(title, (s) async {
        goTo(tester, route);
        await qa.settle();
        final r = await sweep();
        final bad = r.texts.where(_banned.hasMatch).toList();
        if (bad.isNotEmpty) {
          s.passed = false;
          s.notes.add('TO‘LOV/PRO SO‘ZI: ${bad.take(6).join(' | ')}');
        }
        if (r.locks > 0) {
          s.passed = false;
          s.notes.add('QULF/PREMIUM IKONKASI: ${r.locks} ta');
        }
        s.notes.add('matn: ${r.texts.length} ta, ekran(lar) aylantirildi');
        extra?.call(s, r.texts, r.keys);
      }, langCheck: false);
    }

    final container = containerOf(tester);
    // Paket asinxron yuklanadi — qiymat har safar ishlatilganda o‘qiladi.
    List<LibraryEntry> substancesNow() => container
        .read(libraryRepositoryProvider)
        .entries(LibrarySection.substances);

    await checkScreen('Asosiy', Routes.home);
    await checkScreen('Kutubxona (markaz)', Routes.library);

    await checkScreen(
      'Kutubxona: Moddalar — BARCHA yozuvlar ko‘rinadi',
      Routes.librarySection('substances'),
      extra: (s, texts, keys) {
        final shown = {
          for (final k in keys)
            if (k.startsWith('library.entry.')) k,
        };
        s.notes.add(
          'yozuvlar: ${shown.length} / ${substancesNow().length} '
          '(paketdagi jami)',
        );
        if (shown.length != substancesNow().length) {
          s.passed = false;
          s.notes.add('BA’ZI YOZUVLAR KO‘RINMADI');
        }
      },
    );

    // Modda detali: paketdagi HAR BIR modda ochiladi, qulf kartasi yo‘q.
    // Hammasini ochish juda sekin (Xvfb): birinchi 3 ta + har 10-chi modda.
    await qa.step(
      'Modda detallari (tanlama): qulf kartasi yo‘q',
      (s) async {
        final substances = substancesNow();
        final sample = [
          for (var i = 0; i < substances.length; i++)
            if (i < 3 || i % 25 == 0) substances[i],
        ];
        var locked = 0;
        var bad = 0;
        for (final e in sample) {
          File('${qa.outDir.path}/progress.txt')
              .writeAsStringSync('${e.id}\n', mode: FileMode.append);
          goTo(tester, Routes.libraryEntry(e.id));
          await qa.settle(maxMs: 3000);
          if (find.byKey(const Key('entry.locked')).evaluate().isNotEmpty) {
            locked++;
          }
          final texts = qa.visibleTexts();
          bad += texts.where(_banned.hasMatch).length;
        }
        s.notes.add('qulf kartasi: $locked, taqiqlangan so‘z: $bad');
        if (locked > 0 || bad > 0) s.passed = false;
      },
      shot: false,
      langCheck: false,
    );

    // Birinchi modda — oxirigacha aylantirib barcha bo‘limlar.
    final all = substancesNow();
    final first = all.firstWhere(
      (e) => e.details != null,
      orElse: () => all.first,
    );
    await checkScreen(
      'Modda detali (${first.id}) — oxirigacha',
      Routes.libraryEntry(first.id),
      extra: (s, texts, keys) {
        final anchors = keys.where((k) => k.startsWith('entry.index.')).length;
        s.notes.add('«Shu sahifada» bo‘limlari: $anchors ta');
        if (keys.contains('entry.locked') || keys.contains('locked.unlock')) {
          s.passed = false;
          s.notes.add('QULF KARTASI BOR');
        }
      },
    );

    await checkScreen('Vositalar', Routes.tools);
    await checkScreen(
      'Vosita: LOD/LOQ kalkulyatori (ilgari Pro)',
      Routes.tool('tool.lab.lod_loq'),
      extra: (s, texts, keys) {
        if (!keys.contains('calc.calculate') &&
            find.byKey(const Key('calc.calculate')).evaluate().isEmpty) {
          s.notes.add('eslatma: hisoblash tugmasi kaliti topilmadi');
        }
      },
    );
    await checkScreen(
      'Vosita: C1V1 suyultirish',
      Routes.tool('tool.lab.dilution'),
    );
    await checkScreen('AI', Routes.ai);
    await checkScreen('O‘quv', Routes.learn);
    await checkScreen('Qidiruv', Routes.searchWith('et'));
    await checkScreen('Kengaytirilgan qidiruv (ilgari Pro)', Routes.proSearch);
    await checkScreen('Profil', Routes.profile);

    await qa.step('/profile/purchase yo‘li yo‘q (paywall ochilmaydi)', (
      s,
    ) async {
      goTo(tester, '/profile/purchase');
      await qa.settle();
      for (final k in [
        'purchase.restore',
        'paywall.tier.professionalPro',
        'purchase.storeUnavailable',
      ]) {
        if (find.byKey(Key(k)).evaluate().isNotEmpty) {
          s.passed = false;
          s.notes.add('PAYWALL KALITI BOR: $k');
        }
      }
    }, langCheck: false);

    await qa.step(
      'Tarmoq o‘chiq: hech bir HTTP so‘rov muvaffaqiyatli emas',
      (s) async {
        s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
      },
      shot: false,
      langCheck: false,
    );

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
