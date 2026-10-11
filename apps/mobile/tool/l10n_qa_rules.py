#!/usr/bin/env python3
"""«Savol-javob (Hamjamiyat)» qoidalari uchun ARB kalitlari — idempotent.

Uch til teng chuqurlikda. Qoidalar ikki narsani aniq ajratadi: maxfiylik
(ish materiali yozilmaydi) va qonuniylik (xulosani buzishga, dalilni
yashirishga yoki zarar yetkazishga qaratilgan iltimoslar taqiqlanadi).
"""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"

# key: (en, ru, uz, description)
ROWS = [
    ("qaRulesOpen", "Community rules", "Правила сообщества",
     "Hamjamiyat qoidalari",
     "Link that opens the Q&A community rules screen."),
    ("qaRulesTitle", "Community rules", "Правила сообщества",
     "Hamjamiyat qoidalari", "Title of the Q&A rules screen."),
    ("qaRulesIntro",
     "This section is a professional conversation between forensic "
     "practitioners. Two rules decide everything else: no case material, "
     "and nothing that works against the law.",
     "Этот раздел — профессиональный разговор между судебными "
     "специалистами. Всё остальное определяют два правила: никаких "
     "материалов дела и ничего, что работает против закона.",
     "Bu bo‘lim — sud ekspertlari o‘rtasidagi kasbiy suhbat. Qolgan "
     "hammasini ikki qoida belgilaydi: ish materiali yozilmaydi va "
     "qonunga qarshi ishlaydigan narsa yozilmaydi.",
     "Opening paragraph of the Q&A rules."),

    ("qaRulesPurposeTitle", "What this section is for",
     "Для чего этот раздел", "Bu bo‘lim nima uchun",
     "Section header in the Q&A rules."),
    ("qaRulesPurposeBody",
     "Questions about method, reagent, specimen, instrument, "
     "interpretation of a result, a standard or a regulation — asked in "
     "general terms, the way they would be asked at a conference, not "
     "about a particular case.",
     "Вопросы о методе, реактиве, объекте, приборе, интерпретации "
     "результата, стандарте или нормативном документе — в общем виде, так, "
     "как их задают на конференции, а не о конкретном деле.",
     "Usul, reaktiv, namuna, asbob, natijani talqin qilish, standart yoki "
     "normativ hujjat haqidagi savollar — umumiy holda, xuddi "
     "konferensiyada so‘ralganidek, aniq ish haqida emas.",
     "Body of the purpose section in the Q&A rules."),

    ("qaRulesGoodTitle", "How to ask well", "Как задать вопрос хорошо",
     "Savolni qanday yozish kerak", "Section header in the Q&A rules."),
    ("qaRulesGood1",
     "Name the substance, the method and the specimen type. Without them "
     "an answer is guesswork.",
     "Назовите вещество, метод и вид объекта. Без этого ответ будет "
     "догадкой.",
     "Modda, usul va namuna turini ayting. Ularsiz javob taxmin bo‘ladi.",
     "First item in the how-to-ask list."),
    ("qaRulesGood2",
     "Say what you already tried and where exactly you got stuck.",
     "Напишите, что вы уже пробовали и на чём именно остановились.",
     "Nima qilib ko‘rganingizni va aynan qayerda to‘xtab qolganingizni "
     "yozing.",
     "Second item in the how-to-ask list."),
    ("qaRulesGood3",
     "Write numbers with their units, and say which guideline or edition "
     "you are working from.",
     "Пишите числа с единицами и указывайте, по какому руководству или "
     "изданию вы работаете.",
     "Raqamlarni birligi bilan yozing va qaysi qo‘llanma yoki nashrga "
     "tayanayotganingizni ayting.",
     "Third item in the how-to-ask list."),
    ("qaRulesGood4",
     "Choose the topics, so the right specialists see the question.",
     "Выберите темы, чтобы вопрос увидели нужные специалисты.",
     "Mavzularni tanlang — savolni kerakli mutaxassislar ko‘rsin.",
     "Fourth item in the how-to-ask list."),

    ("qaRulesForbiddenTitle", "Never write this", "Этого писать нельзя",
     "Bularni yozish mumkin emas", "Section header in the Q&A rules."),
    ("qaRulesForbidden1",
     "Case material: a case or examination number, a person's name, an "
     "address, a date together with a place, a photograph, or anything "
     "else by which someone could be identified.",
     "Материалы дела: номер дела или экспертизы, имя человека, адрес, дата "
     "вместе с местом, фотография и любые другие данные, по которым можно "
     "установить личность.",
     "Ish materiali: ish yoki ekspertiza raqami, shaxsning ismi, manzil, "
     "sana bilan birga joy, fotosurat va shaxsni aniqlashga imkon beradigan "
     "boshqa har qanday ma’lumot.",
     "First item in the forbidden list of the Q&A rules."),
    ("qaRulesForbidden2",
     "Material from an examination in progress, or a draft opinion.",
     "Материалы незавершённой экспертизы или проект заключения.",
     "Tugallanmagan ekspertiza materiali yoki xulosa loyihasi.",
     "Second item in the forbidden list."),
    ("qaRulesForbidden3",
     "Anything aimed at bending a result: how to make a conclusion come "
     "out a particular way, how to alter or hide a finding, how to "
     "backdate or forge a document, how to make evidence disappear.",
     "Всё, что направлено на искажение результата: как подогнать вывод под "
     "нужный ответ, как изменить или скрыть результат, как задним числом "
     "оформить или подделать документ, как избавиться от доказательства.",
     "Natijani buzishga qaratilgan har qanday narsa: xulosani kerakli "
     "tomonga moslashtirish, natijani o‘zgartirish yoki yashirish, hujjatni "
     "orqa sana bilan rasmiylashtirish yoki soxtalashtirish, dalilni yo‘q "
     "qilish.",
     "Third item in the forbidden list — tampering with results."),
    ("qaRulesForbidden4",
     "How to obtain, make, conceal or use a substance in order to harm "
     "someone or to avoid detection.",
     "Как получить, изготовить, скрыть или применить вещество, чтобы "
     "причинить вред или избежать обнаружения.",
     "Biror moddani zarar yetkazish yoki aniqlanishdan qochish maqsadida "
     "olish, tayyorlash, yashirish yoki qo‘llash yo‘llari.",
     "Fourth item in the forbidden list — harm and evasion."),
    ("qaRulesForbidden5",
     "Legal advice, a diagnosis, a treatment or a dose for a particular "
     "person. This section is not a consultation.",
     "Юридическая консультация, диагноз, лечение или доза для конкретного "
     "человека. Этот раздел — не консультация.",
     "Huquqiy maslahat, tashxis, davolash yoki aniq odam uchun doza. Bu "
     "bo‘lim maslahatxona emas.",
     "Fifth item in the forbidden list — advice."),
    ("qaRulesForbidden6",
     "Advertising, spam, and anything insulting to a colleague.",
     "Реклама, спам и всё, что унижает коллегу.",
     "Reklama, spam va hamkasbni kamsitadigan har qanday narsa.",
     "Sixth item in the forbidden list."),

    ("qaRulesAnswerTitle", "Answering", "Ответы", "Javob yozish",
     "Section header in the Q&A rules."),
    ("qaRulesAnswer1",
     "Only verified specialists may answer, and only within what they "
     "actually practise.",
     "Отвечать могут только подтверждённые специалисты и только в пределах "
     "того, чем они занимаются на практике.",
     "Javob yozishni faqat tasdiqlangan mutaxassislar oladi va faqat o‘zi "
     "amalda shug‘ullanadigan doirada.",
     "First item in the answering section."),
    ("qaRulesAnswer2",
     "Lean on a source and name it. Where you are guessing, say that you "
     "are guessing.",
     "Опирайтесь на источник и называйте его. Где вы предполагаете — так и "
     "напишите.",
     "Manbaga tayaning va uni ayting. Taxmin qilayotgan joyingizni taxmin "
     "deb yozing.",
     "Second item in the answering section."),
    ("qaRulesAnswer3",
     "An answer here is a colleague's opinion. It is not an expert "
     "opinion for a case file and cannot be cited as one.",
     "Ответ здесь — мнение коллеги. Это не экспертное заключение для дела "
     "и не может на него ссылаться.",
     "Bu yerdagi javob — hamkasbning fikri. U ish uchun ekspert xulosasi "
     "emas va unga havola qilib bo‘lmaydi.",
     "Third item in the answering section."),

    ("qaRulesEnforceTitle", "What happens if a rule is broken",
     "Что будет при нарушении", "Qoida buzilsa nima bo‘ladi",
     "Section header in the Q&A rules."),
    ("qaRulesEnforceBody",
     "Text that looks like case material is held for review automatically. "
     "Reports from three different users hide a post, or suspend a "
     "specialist badge, until an administrator decides. A post that works "
     "against the law is removed and the badge goes with it.",
     "Текст, похожий на материалы дела, автоматически отправляется на "
     "проверку. Жалобы трёх разных пользователей скрывают публикацию или "
     "приостанавливают подтверждение специалиста до решения администратора. "
     "Публикация, направленная против закона, удаляется вместе с "
     "подтверждением.",
     "Ish materialiga o‘xshagan matn avtomatik tekshiruvga tushadi. Uch xil "
     "foydalanuvchining shikoyati postni yashiradi yoki mutaxassis belgisini "
     "administrator qaroriga qadar to‘xtatadi. Qonunga qarshi qaratilgan "
     "post o‘chiriladi, belgi ham u bilan birga ketadi.",
     "Body of the enforcement section in the Q&A rules."),
]


def main() -> None:
    values = {"en": 0, "ru": 1, "uz": 2}
    for lang, index in values.items():
        path = ARB / f"app_{lang}.arb"
        data = json.loads(path.read_text(encoding="utf-8"))
        changed = False
        for row in ROWS:
            key, text, description = row[0], row[1 + index], row[4]
            if data.get(key) != text:
                data[key] = text
                changed = True
            if lang == "en":
                meta = {"description": description}
                if data.get(f"@{key}") != meta:
                    data[f"@{key}"] = meta
                    changed = True
        if changed:
            path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        print(f"l10n_qa_rules: {lang} {'updated' if changed else 'unchanged'}")


if __name__ == "__main__":
    main()
