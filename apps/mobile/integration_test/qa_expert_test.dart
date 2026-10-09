// REAL-ILOVA QA — MUTAXASSIS (EXPERT) yo‘li.
//
// Haqiqiy ilova (`bootstrap()`), haqiqiy pilot kontent paketi, Linux desktop
// dvigateli. Akkaunt — MOCK, «Ekspert maqolalari» serveri — xotiradagi soxta
// servis (QaPublicationService), tarmoq — o‘chirilgan.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/publications.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/professional/professional_strings.dart';
import 'package:integration_test/integration_test.dart';

import 'qa/harness.dart';
import 'qa/qa_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA real app — EXPERT', (tester) async {
    final net = NoNetworkOverrides();
    HttpOverrides.global = net;
    final l = lookupAppLocalizations(const Locale('uz'));
    final pubs = QaPublicationService();
    final qa = await launchRealApp(
      tester,
      role: 'expert',
      overrides: [publicationServiceProvider.overrideWithValue(pubs)],
    );

    // ------------------------------------------------------------ onboarding
    await qa.step('Onboarding: O‘zbekcha + ogohlantirish', (s) async {
      await qa.tapText('O‘zbekcha');
      await qa.tapText(l.actionContinue);
      await qa.tapText(l.disclaimerAccept);
      qa.expectText(l.modeProfessional, s);
    });

    final role = l.professionalRoleLabel(ProfessionalRole.forensicToxicologist);
    await qa.step('Rejim: Mutaxassis + rol ($role)', (s) async {
      await qa.tapText(l.modeProfessional);
      await qa.tapText(l.modeRoleExpand);
      await qa.tapText(role);
      qa.expectText(l.modeProfessionalNotVerified, s);
    });

    await qa.step('Davom etish → Hisob yaratish / Kirish', (s) async {
      await qa.tapText(l.actionContinue);
      await qa.tapText('Hisob yaratish / Kirish');
      qa.expectText(l.emailCodeSend, s);
    }, shot: false);

    await qa.step('MOCK OTP bilan kirish', (s) async {
      await qa.enterText(find.byType(TextField), 'qa.expert@example.test');
      await qa.tapText(l.emailCodeSend);
      await qa.enterText(find.byType(TextField), lastMockCode(tester)!);
      await qa.tapText(l.verifySubmit);
      await qa.settle(maxMs: 4000);
      goTo(tester, Routes.profile);
      await qa.settle();
      qa.expectText('qa.expert@example.test', s);
      qa.expectNoText(
        'qa.student@example.test',
        s,
        why: 'boshqa foydalanuvchi',
      );
    });

    // ------------------------------------------- profil: ixtisoslik (3 qadam)
    await qa.step('Profil: 1-qadam (ism, davlat)', (s) async {
      goTo(tester, Routes.profileEdit);
      await qa.settle();
      await qa.enterText(
        find.byKey(const Key('profileEdit.fullName')),
        'QA Mutaxassis',
      );
      await pickCountry(qa, 'O‘zbek', 'UZ');
      await qa.tapFinder(find.byKey(const Key('profileEdit.next')));
      qa.expectNoText(l.formHasErrors, s);
    });

    final specialty = l.specialtyLabel(Specialty.forensicToxicology);
    await qa.step('Profil: 2-qadam — ixtisoslik «$specialty»', (s) async {
      await qa.enterText(
        find.byKey(const Key('profileEdit.organization')),
        'QA laboratoriyasi',
      );
      await qa.enterText(
        find.byKey(const Key('profileEdit.position')),
        'Ekspert-kimyogar',
      );
      await qa.tapFinder(find.byKey(const Key('profileEdit.primarySpecialty')));
      await tester.tap(find.text(specialty).last, warnIfMissed: false);
      await qa.settle();
      await qa.enterText(
        find.byKey(const Key('profileEdit.education')),
        'Toshkent farmatsevtika instituti',
      );
      await qa.tapFinder(find.byKey(const Key('profileEdit.next')));
      qa.expectNoText(l.formHasErrors, s);
    });

    await qa.step('Profil: 3-qadam → Saqlash', (s) async {
      await qa.tapFinder(find.byKey(const Key('profileEdit.save')));
      qa.expectNoText(l.formHasErrors, s);
      goTo(tester, Routes.profile);
      await qa.settle();
      await qa.scrollToTop();
      qa.expectText('QA Mutaxassis', s);
    });

    await qa.step('Professional maqomni tasdiqlash (server yo‘q)', (s) async {
      goTo(tester, Routes.verification);
      await qa.settle();
      final t = qa.visibleTexts().join(' ');
      if (t.contains('Tasdiqlangan mutaxassis') && !t.contains('emas')) {
        s.passed = false;
        s.notes.add('Server yo‘q, lekin tasdiqlangan deb ko‘rsatildi');
      }
    });

    // --------------------------------------------------- fan ma’lumotlari
    await qa.step('Fanlar → Sud kimyosi', (s) async {
      goTo(tester, Routes.disciplines);
      await qa.settle();
      await qa.tapText('Sud kimyosi');
      qa.expectText('Sud kimyosi', s);
    });

    await qa.step('Kutubxona → Usullar va SOP', (s) async {
      goTo(tester, Routes.library);
      await qa.settle();
      await qa.tapText('Usullar va SOP');
      qa.expectText('Usullar va SOP', s);
    }, shot: false);

    await qa.step('Usul yozuvini ochish (GX)', (s) async {
      await qa.tapText('gaz xromatografiya');
      qa.expectText('Tekshirilmagan', s);
    });

    await qa.step('Yo‘riqnoma: preanalitika kartasi', (s) async {
      goTo(tester, Routes.guidelines);
      await qa.settle();
      await qa.tapText('preanalitika');
      qa.expectText('preanalitika', s);
    });

    await qa.step('Etanol → «Bu ma’lumot qayerdan?»', (s) async {
      goTo(tester, Routes.libraryEntry('ethanol'));
      await qa.settle();
      await qa.tapText('Bu ma’lumot qayerdan?');
      qa.expectText('kelib chiqishi', s);
      qa.expectText('Murojaat sanasi', s);
    });

    // ------------------------------------------------- Ekspert maqolalari
    await qa.step('Ekspert maqolalari ro‘yxati', (s) async {
      await qa.back();
      goTo(tester, Routes.publications);
      await qa.settle();
      qa.expectText('QA namunasi', s);
    });

    await qa.step('Maqolani ochish', (s) async {
      await qa.tapText('QA namunasi');
      qa.expectText('soxta maqola', s);
    });

    await qa.step('Maqola yuborish: bo‘sh forma → xato', (s) async {
      goTo(tester, Routes.publicationSubmit);
      await qa.settle();
      await qa.tapFinder(find.byKey(const Key('submit.send')));
      final t = qa.visibleTexts().join(' ');
      if (pubs.submittedCount > 0) {
        s.passed = false;
        s.notes.add('Bo‘sh forma yuborildi');
      }
      if (t.contains(l.pubSubmitRejected)) {
        s.notes.add('Xabar: ${l.pubSubmitRejected}');
      }
    });

    await qa.step('Maqola: to‘ldirish → qoralama saqlash', (s) async {
      await qa.enterText(
        find.byKey(const Key('submit.title')),
        'QA: postmortem namunalarda etanol barqarorligi',
      );
      await qa.enterText(
        find.byKey(const Key('submit.abstract')),
        'QA sinovi uchun qisqa annotatsiya. Haqiqiy maqola emas.',
      );
      await qa.tapFinder(find.byKey(const Key('submit.discipline')));
      // Menyu ochiq: ro‘yxatning boshidagi fan (ko‘rinib turgan element).
      final item = find.text('Analitik fan');
      await tester.tap(item.last, warnIfMissed: false);
      await qa.settle();
      qa.expectText('Analitik fan', s, why: 'fan tanlandi');
      await qa.tapFinder(find.byKey(const Key('submit.saveDraft')));
      qa.expectText(l.pubDraftSaved, s);
    });

    await qa.step('Maqola: tasdiqlarsiz yuborish → rad', (s) async {
      await qa.tapFinder(find.byKey(const Key('submit.send')));
      if (pubs.submittedCount > 0) {
        s.passed = false;
        s.notes.add('Tasdiqlarsiz yuborildi');
      }
    }, shot: false);

    await qa.step('Maqola: 3 tasdiq → yuborish → «Mening maqolalarim»', (
      s,
    ) async {
      await qa.tapFinder(find.byKey(const Key('submit.confirm.rights')));
      await qa.tapFinder(find.byKey(const Key('submit.confirm.consent')));
      await qa.tapFinder(find.byKey(const Key('submit.confirm.noPii')));
      await qa.tapFinder(find.byKey(const Key('submit.send')));
      await qa.settle(maxMs: 4000);
      if (pubs.submittedCount != 1) {
        s.passed = false;
        s.notes.add('Yuborilmadi (submitted=${pubs.submittedCount})');
      }
      qa.expectText('postmortem namunalarda etanol', s);
      qa.expectText('Analitik fan', s, why: 'tanlangan fan');
    });

    // ------------------------------------------------------------- qidiruv
    await qa.step('Qidiruv: «etanol qon»', (s) async {
      goTo(tester, Routes.searchWith('etanol qon'));
      await qa.settle(maxMs: 6000);
      qa.expectText('Etanol', s);
      qa.expectNoText('Место забора', s, why: 'uz rejimida ruscha sarlavha');
    });

    await qa.step('Qidiruv: «HS-GC»', (s) async {
      await qa.enterText(find.byType(TextField), 'HS-GC');
      await qa.settle(maxMs: 6000);
      qa.expectText('xromatografiya', s);
    }, shot: false);

    // ------------------------------------------------------------------ AI
    await qa.step('AI: oflayn manbalar «metanol»', (s) async {
      goTo(tester, Routes.ai);
      await qa.settle();
      await qa.enterText(find.byType(TextField), 'metanol');
      await qa.tapText('Manbalarni oflayn topish');
      await qa.scrollUntil(find.textContaining('Oflayn bazadan topilgan'));
      qa.expectText('Oflayn bazadan topilgan manbalar', s);
    });

    // ---------------------------------------------------- kalkulyatorlar
    await qa.step('Vositalar ro‘yxati', (s) async {
      goTo(tester, Routes.tools);
      await qa.settle();
      qa.expectText('Suyultirish', s);
    }, shot: false);

    await qa.step('Suyultirish: C₁=10, C₂=1, V₂=100 → V₁=10', (s) async {
      await qa.tapText('Suyultirish (C₁V₁ = C₂V₂)');
      await qa.enterText(
        find.descendant(
          of: find.byKey(const Key('calc.field.c1')),
          matching: find.byType(TextField),
        ),
        '10',
      );
      await qa.enterText(
        find.descendant(
          of: find.byKey(const Key('calc.field.c2')),
          matching: find.byType(TextField),
        ),
        '1',
      );
      await qa.enterText(
        find.descendant(
          of: find.byKey(const Key('calc.field.v2')),
          matching: find.byType(TextField),
        ),
        '100',
      );
      await qa.tapFinder(find.byKey(const Key('calc.calculate')));
      await qa.scrollUntil(find.byKey(const Key('calc.result')));
      qa.expectText(RegExp(r'^10([.,]0+)?\b'), s);
    });

    await qa.step('Suyultirish: mantiqsiz kiritish (C₂ > C₁) → ogohlantirish', (
      s,
    ) async {
      await qa.scrollToTop();
      await qa.enterText(
        find.descendant(
          of: find.byKey(const Key('calc.field.c2')),
          matching: find.byType(TextField),
        ),
        '50',
      );
      await qa.tapFinder(find.byKey(const Key('calc.calculate')));
      await qa.scrollUntil(find.byKey(const Key('calc.result')));
      qa.expectText('ma’lumotlarni tekshiring', s, why: 'ogohlantirish');
    });

    await qa.step('Pro kalkulyator (Widmark) → tariflar', (s) async {
      goTo(tester, Routes.tools);
      await qa.settle();
      await qa.tapText('Qondagi alkogol (Widmark)');
      qa.expectText('Mutaxassis Pro', s);
    });

    // --------------------------------------------- profil, til, kichik ekran
    await qa.step('Profil va sozlamalar (Mutaxassis)', (s) async {
      goTo(tester, Routes.profile);
      await qa.settle();
      await qa.scrollToTop();
      qa.expectText('Mutaxassis', s);
      qa.expectText('Sozlamalar', s);
    });

    await qa.step('Til: Русский — Профиль', (s) async {
      goTo(tester, Routes.profileLanguage);
      await qa.settle();
      await qa.tapText('Русский');
      goTo(tester, Routes.tools);
      await qa.settle();
      qa.expectText(RegExp('[А-Яа-я]{4,}'), s);
    }, langCheck: false);

    await qa.step('Til: O‘zbekcha (qaytish)', (s) async {
      goTo(tester, Routes.profileLanguage);
      await qa.settle();
      await qa.tapText('O‘zbekcha');
      goTo(tester, Routes.tools);
      await qa.settle();
      qa.expectText('Vositalar', s);
    }, shot: false);

    await qa.setSize(const Size(320, 640));
    for (final (title, route) in [
      ('320×640: Vositalar', Routes.tools),
      ('320×640: maqola yuborish formasi', Routes.publicationSubmit),
      ('320×640: yo‘riqnomalar', Routes.guidelines),
      ('320×640: profil tahrirlash', Routes.profileEdit),
    ]) {
      await qa.step(title, (s) async {
        goTo(tester, route);
        await qa.settle(maxMs: 6000);
        await qa.scrollToTop();
      });
    }

    await qa.step('Tarmoq o‘chiq: oflayn ishladi', (s) async {
      s.notes.add('Bloklangan HTTP urinishlari: ${net.attempts}');
    }, shot: false);

    qa.restoreErrorHandler();
    qa.writeResults();
    printSummary(qa);
    HttpOverrides.global = null;
  });
}
