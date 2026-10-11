#!/usr/bin/env python3
"""Admin panelidan Pro sovg‘a qilish uchun ARB kalitlari — idempotent."""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"

# key: (en, ru, uz, description)
ROWS = [
    ("adminGrantStudent", "Grant Student Pro", "Выдать «Студент Pro»",
     "Talaba Pro berish",
     "Admin panel button that gives the Student Pro tier to an e-mail."),
    ("adminGrantHint",
     "Enter the e-mail the person signed in with. The account must already "
     "exist; an invitation is not sent from here.",
     "Укажите адрес, с которым человек вошёл в приложение. Учётная запись "
     "должна уже существовать; приглашение отсюда не отправляется.",
     "Odam ilovaga qaysi pochta bilan kirgan bo‘lsa, shuni yozing. Hisob "
     "allaqachon mavjud bo‘lishi kerak; bu yerdan taklif yuborilmaydi.",
     "Helper text under the e-mail field in the admin grant section."),
    ("adminEmailInvalid", "This is not an e-mail address.",
     "Это не адрес электронной почты.",
     "Bu elektron pochta manzili emas.",
     "Validation message for the admin grant e-mail field."),
    ("adminGrantedTier", "Granted: {tier}", "Выдано: {tier}",
     "Berildi: {tier}",
     "Confirmation after granting, naming the tier that was given."),
    ("adminRevokeConfirmTitle", "Remove access?", "Убрать доступ?",
     "Kirishni olib tashlansinmi?",
     "Title of the confirmation dialog before revoking a grant."),
    ("adminRevokeConfirmBody",
     "The person loses the paid sections at once. A purchase made in the "
     "store is not affected — only a grant given from here.",
     "Человек сразу потеряет платные разделы. Покупки в магазине это не "
     "затрагивает — только выдачу из этой панели.",
     "Odam pullik bo‘limlarni darhol yo‘qotadi. Do‘kondan qilingan xaridga "
     "bu ta’sir qilmaydi — faqat shu paneldan berilgan huquqqa.",
     "Body of the confirmation dialog before revoking a grant."),
    ("adminTierStudent", "Student Pro", "«Студент Pro»", "Talaba Pro",
     "Name of the Student Pro tier in the admin panel."),
    ("adminTierProfessional", "Professional Pro", "«Специалист Pro»",
     "Mutaxassis Pro",
     "Name of the Professional Pro tier in the admin panel."),
]

PLACEHOLDERS = {"adminGrantedTier": {"tier": {"type": "String"}}}


def main() -> None:
    for lang, index in {"en": 0, "ru": 1, "uz": 2}.items():
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
                if key in PLACEHOLDERS:
                    meta["placeholders"] = PLACEHOLDERS[key]
                if data.get(f"@{key}") != meta:
                    data[f"@{key}"] = meta
                    changed = True
        if changed:
            path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        print(f"l10n_admin_gift: {lang} {'updated' if changed else 'unchanged'}")


if __name__ == "__main__":
    main()
