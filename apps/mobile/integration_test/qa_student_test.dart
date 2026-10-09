// REAL-ILOVA QA — TALABA (STUDENT) yo‘li.
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy imzolangan pilot kontent paketi,
// haqiqiy router va Linux desktop dvigateli. Akkaunt — MOCK (xotirada),
// tarmoq — o‘chirilgan. Ishga tushirish: `tool/qa_real_app.sh`.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

final _cyrillic = RegExp('[А-Яа-яЁё]');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — STUDENT', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final qa = await launchRealApp(tester, role: 'student');

    // ------------------------------------------------------------ onboarding
    await qa.step('Onboarding: til tanlash ekrani', (s) async {
      qa.expectText('O‘zbekcha', s);
      qa.expectText('Tilni tanlang', s);
    }, langCheck: false);

    await qa.step('O‘zbekcha → Davom etish → ilmiy ogohlantirish', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      qa.expectText(l.disclaimerTitle, s);
    });

    await qa.step('Tushundim → rejim tanlash', (s) async {
      await qa.tapText(l.disclaimerAccept);
      qa.expectText(l.modeStudent, s);
      qa.expectText(l.modeProfessional, s);
    }, shot: false);

    await qa.step('Rejim: Talaba → hisob taklifi', (s) async {
      await qa.tapText(l.modeStudent);
      await qa.tapText(l.actionContinue);
      qa.expectText('Hisobsiz davom etish', s);
    });

    await qa.step('Hisobsiz davom etish → Asosiy', (s) async {
      await qa.tapText('Hisobsiz davom etish');
      qa.expectText('Rejim: Talaba', s);
    });

    // ------------------------------------------------- AI (hisobsiz holat)
    await qa.step('AI ekrani — hisobsiz', (s) async {
      await qa.tapTooltip('AI');
      qa.expectText('Forensic AI', s);
      qa.expectText('Manba: oflayn baza', s);
    });

    // ------------------------------------------- kirish (MOCK OTP) va xatolar
    await qa.step('Profil → Kirish (email kod)', (s) async {
      await qa.tapTooltip('Profil');
      await qa.tapText('Kirish (email kod)');
      qa.expectText(l.emailCodeSend, s);
      qa.expectText('SINOV', s, why: 'MOCK backend belgisi ko‘rinishi kerak');
    });

    await qa.step('Noto‘g‘ri email → tushunarli xato', (s) async {
      await qa.enterText(find.byType(TextField), 'talaba-email');
      await qa.tapText(l.emailCodeSend);
      qa.expectText(l.authErrInvalidEmail, s);
    });

    await qa.step('To‘g‘ri email → kod kiritish ekrani', (s) async {
      await qa.enterText(find.byType(TextField), 'qa.student@example.test');
      await qa.tapText(l.emailCodeSend);
      qa.expectText('qa.student@example.test', s);
      if (lastMockCode(tester) == null) {
        s.passed = false;
        s.notes.add('MOCK kod yaratilmadi');
      }
    }, shot: false);

    await qa.step('Noto‘g‘ri kod → tushunarli xato', (s) async {
      final wrong = lastMockCode(tester) == '000000' ? '111111' : '000000';
      await qa.enterText(find.byType(TextField), wrong);
      await qa.tapText(l.verifySubmit);
      qa.expectText(l.authErrCodeInvalid, s);
    });

    await qa.step('To‘g‘ri kod → tizimga kirildi', (s) async {
      await qa.enterText(find.byType(TextField), lastMockCode(tester)!);
      await qa.tapText(l.verifySubmit);
      await qa.settle(maxMs: 4000);
      goTo(tester, Routes.profile);
      await qa.settle();
      qa.expectText('qa.student@example.test', s);
    });

    await qa.step('AI ekrani — kirgan holat, oflayn manbalar', (s) async {
      await qa.tapTooltip('AI');
      await qa.enterText(find.byType(TextField), 'etanol');
      await qa.tapText('Manbalarni oflayn topish');
      await qa.scrollUntil(find.textContaining('Oflayn bazadan topilgan'));
      qa.expectText('Oflayn bazadan topilgan manbalar', s);
      qa.expectText('Etanol', s);
    });

    // ------------------------------------------------------ fan va kutubxona
    await qa.step('Fanni tanlash: Barcha fanlar → Sud toksikologiyasi', (
      s,
    ) async {
      await qa.tapTooltip('Asosiy');
      await qa.scrollToTop();
      await qa.tapText('Barcha sud-ekspert fanlari');
      await qa.tapText('Sud toksikologiyasi');
      qa.expectText('Sud toksikologiyasi', s);
    });

    await qa.step('Kutubxona markazi', (s) async {
      await qa.tapTooltip('Kutubxona');
      qa.expectText('Moddalar', s);
      qa.expectText('Yo‘riqnomalar', s);
    }, shot: false);

    await qa.step('Yo‘riqnomalar ro‘yxati', (s) async {
      await qa.tapText('Yo‘riqnomalar');
      qa.expectText('Yo‘riqnomalardan qidirish', s);
    });

    await qa.step('Yo‘riqnoma kartasini ochish (etanol, HS-GC-FID)', (s) async {
      await qa.tapText('Qon va biologik suyuqliklarda etanolni');
      qa.expectText('etanol', s);
    });

    await qa.step('Moddalar → Etanol (Tahlil bo‘limi)', (s) async {
      goTo(tester, Routes.library);
      await qa.settle();
      await qa.tapText('Moddalar');
      await qa.tapText('Etanol');
      qa.expectText('Tahlil', s);
      qa.expectText('Tahlil usullari', s);
    });

    await qa.step('Manba iqtibosi + o‘zbekcha tarjima', (s) async {
      await qa.tapText('Metabolitlar');
      await qa.scrollUntil(find.text('Avtomatik tarjima · tekshirilmagan'));
      qa.expectText('Manbadan iqtibos', s);
      qa.expectText('Avtomatik tarjima', s);
      qa.expectText('atsetaldegid', s);
      qa.expectNoText('untitled opening section', s, why: 'xom bo‘lim izohi');
    });

    await qa.step('Saralanganlarga qo‘shish (yulduzcha)', (s) async {
      await qa.tapTooltip('Saralanganlarga qo‘shish');
      if (find.byTooltip('Saralanganlardan olib tashlash').evaluate().isEmpty) {
        s.notes.add('Tooltip o‘zgarmadi (tekshirib ko‘ring)');
      }
    });

    await qa.step('«Bu ma’lumot qayerdan?» — kelib chiqish oynasi', (s) async {
      await qa.tapText('Bu ma’lumot qayerdan?');
      qa.expectText('kelib chiqishi', s);
      qa.expectText('Manba', s);
    });

    // ------------------------------------------------------------- qidiruv
    await qa.step('Qidiruv: «alkogol»', (s) async {
      await qa.back();
      goTo(tester, Routes.searchWith('alkogol'));
      await qa.settle(maxMs: 6000);
      qa.expectText('Etanol', s);
      qa.expectText('Qurilmada · oflayn', s);
      final cyr = qa.visibleTexts().where(_cyrillic.hasMatch).toList();
      if (cyr.isNotEmpty) {
        s.passed = false;
        s.notes.add('uz rejimida kirill sarlavha: $cyr');
      }
      qa.expectNoText('Ethanol back-calculation', s, why: 'inglizcha sarlavha');
    });

    await qa.step('Qidiruv: «etanol qon» (yo‘riqnoma ham chiqadi)', (s) async {
      await qa.enterText(find.byType(TextField), 'etanol qon');
      await qa.settle(maxMs: 6000);
      qa.expectText('Etanol', s);
      qa.expectText('Qon va biologik suyuqliklarda etanolni', s);
    });

    await qa.step('Qidiruv: fan filtri (Sud toksikologiyasi)', (s) async {
      await qa.tapFinder(
        find.widgetWithText(ChoiceChip, 'Sud toksikologiyasi'),
      );
      qa.expectText('Etanol', s);
    }, shot: false);

    await qa.step('Qidiruv: natija yo‘q — tushunarli xabar', (s) async {
      await qa.enterText(find.byType(TextField), 'zzqxw');
      await qa.settle(maxMs: 4000);
      final t = qa.visibleTexts().join(' ').toLowerCase();
      if (!t.contains('topilmadi') && !t.contains('natija yo')) {
        s.passed = false;
        s.notes.add('«topilmadi» xabari yo‘q');
      }
    });

    // ----------------------------------------------------- saqlanganlar
    await qa.step('Saqlanganlar Asosiy ekranda ko‘rinadi', (s) async {
      goTo(tester, Routes.home);
      await qa.settle();
      await qa.scrollUntil(find.text('Davom ettirish va saqlanganlar'));
      await qa.scrollBy(250);
      qa.expectText('Etanol', s);
    });

    // ------------------------------------------------------ Bepul vs Pro
    await qa.step('Pro modda (Alprazolam) — qulf kartasi', (s) async {
      goTo(tester, Routes.librarySection('substances'));
      await qa.settle();
      await qa.tapText('Alprazolam');
      await qa.scrollUntil(find.text('Tariflarni ko‘rish'));
      qa.expectText('Tariflarni ko‘rish', s);
    });

    await qa.step('Tariflarni ko‘rish → paywall', (s) async {
      await qa.tapText('Tariflarni ko‘rish');
      qa.expectText('Talaba Pro', s);
      qa.expectText('Xaridlarni tiklash', s);
    });

    await qa.step('Paywall: do‘kon yo‘q — narx/xarid o‘chiq, xabar bor', (
      s,
    ) async {
      await qa.tapText('Obuna bo‘lish');
      final t = qa.visibleTexts().join(' ');
      if (!t.contains('mavjud emas') && !t.contains('do‘kon')) {
        s.passed = false;
        s.notes.add('Do‘kon yo‘qligi haqida xabar ko‘rinmadi');
      }
    });

    // --------------------------------------------- profil va sozlamalar
    await qa.step('Profil va sozlamalar', (s) async {
      goTo(tester, Routes.profile);
      await qa.settle();
      qa.expectText('Sozlamalar', s);
      qa.expectText('qa.student@example.test', s);
      final emails = qa
          .visibleTexts()
          .where((t) => t.contains('@'))
          .where((t) => !t.contains('qa.student@example.test'))
          .toList();
      if (emails.isNotEmpty) {
        s.passed = false;
        s.notes.add('Boshqa email ko‘rindi: $emails');
      }
    });

    await qa.step('Profilni to‘ldirish (talaba)', (s) async {
      await qa.tapText('Profilni to‘ldirish');
      await qa.enterText(
        find.byKey(const Key('profileEdit.fullName')),
        'QA Talaba',
      );
      await pickCountry(qa, 'O‘zbek', 'UZ');
      await qa.tapFinder(find.byKey(const Key('profileEdit.save')));
      await qa.settle();
      qa.expectNoText(
        l.formHasErrors,
        s,
        why: 'saqlash xatosiz bo‘lishi kerak',
      );
      goTo(tester, Routes.profile);
      await qa.settle();
      await qa.scrollToTop();
      qa.expectText('QA Talaba', s);
    });

    await qa.step('Til: English', (s) async {
      goTo(tester, Routes.profileLanguage);
      await qa.settle();
      await qa.tapText('English');
      goTo(tester, Routes.profile);
      await qa.settle();
      qa.expectText('Settings', s);
    }, langCheck: false);

    await qa.step('Til: Русский', (s) async {
      goTo(tester, Routes.profileLanguage);
      await qa.settle();
      await qa.tapText('Русский');
      goTo(tester, Routes.home);
      await qa.settle();
      qa.expectText(RegExp('[А-Яа-я]{4,}'), s);
    }, langCheck: false);

    await qa.step('Til: O‘zbekcha (qaytish)', (s) async {
      goTo(tester, Routes.profileLanguage);
      await qa.settle();
      await qa.tapText('O‘zbekcha');
      goTo(tester, Routes.profile);
      await qa.settle();
      qa.expectText('Sozlamalar', s);
    }, shot: false);

    // ------------------------------------------------- kichik ekran 320×640
    await qa.setSize(const Size(320, 640));
    for (final (title, route) in [
      ('320×640: Asosiy', Routes.home),
      ('320×640: Etanol yozuvi', Routes.libraryEntry('ethanol')),
      ('320×640: qidiruv «alkogol»', Routes.searchWith('alkogol')),
      ('320×640: tariflar', Routes.purchase),
      ('320×640: Profil', Routes.profile),
    ]) {
      await qa.step(title, (s) async {
        goTo(tester, route);
        await qa.settle(maxMs: 6000);
        await qa.scrollToTop();
      });
    }

    await qa.step('Tarmoq o‘chiq: hech bir HTTP so‘rov muvaffaqiyatli emas', (
      s,
    ) async {
      s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
    }, shot: false);

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
