#!/usr/bin/env python3
"""«Savol-javob (Hamjamiyat)» uchun ARB kalitlari — idempotent.

Uch til teng chuqurlikda (egasining talabi). Hech bir matn boshqa tilga
tashlab ketilmaydi; raqam va atama nomlari o‘zgarmaydi.
"""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"

# key: (en, ru, uz, description)
ROWS = [
    # ---------------------------------------------------------------- bo‘lim
    ("qaTitle", "Questions & answers", "Вопросы и ответы",
     "Savol-javob (Hamjamiyat)", "Title of the community Q&A section."),
    ("qaIntro",
     "Forensic physicians and forensic chemists ask each other practical "
     "questions here. Only verified specialists may answer.",
     "Здесь судебные медики и судебные химики задают друг другу практические "
     "вопросы. Отвечать могут только подтверждённые специалисты.",
     "Bu yerda sud tabiblari va sud kimyogarlari bir-biriga amaliy savollar "
     "beradi. Javob yozishni faqat tasdiqlangan mutaxassislar oladi.",
     "One-paragraph intro at the top of the Q&A feed."),
    ("qaNotice",
     "An answer here is a colleague's opinion, not a scientific conclusion "
     "and not an expert opinion for a case file.",
     "Ответ здесь — мнение коллеги, а не научный вывод и не экспертное "
     "заключение для дела.",
     "Bu yerdagi javob — hamkasbning fikri; ilmiy xulosa ham, ish uchun "
     "ekspert xulosasi ham emas.",
     "Standing warning banner in the Q&A section."),
    ("qaUnavailable", "This section is not available yet.",
     "Этот раздел пока недоступен.", "Bu bo‘lim hozircha mavjud emas.",
     "Empty state when the Q&A section is switched off or the server is "
     "unreachable."),
    ("qaSignInRequired", "Sign in to read and ask questions.",
     "Войдите, чтобы читать и задавать вопросы.",
     "Savollarni o‘qish va berish uchun hisobingizga kiring.",
     "Empty state for a signed-out user in the Q&A section."),
    ("qaSignIn", "Sign in", "Войти", "Kirish", "Sign-in button in Q&A."),
    # ---------------------------------------------------------------- ro‘yxat
    ("qaSearchHint", "Search questions", "Поиск по вопросам",
     "Savollar ichidan qidirish", "Search field hint in the Q&A feed."),
    ("qaAllTopics", "All topics", "Все темы", "Barcha mavzular",
     "Chip that clears the tag filter."),
    ("qaEmpty", "No questions yet. Be the first to ask.",
     "Вопросов пока нет. Задайте первый.",
     "Hozircha savol yo‘q. Birinchi savolni siz bering.",
     "Empty state for the Q&A feed."),
    ("qaLoadFailed", "Could not load the questions. Check the connection.",
     "Не удалось загрузить вопросы. Проверьте соединение.",
     "Savollarni yuklab bo‘lmadi. Internet aloqasini tekshiring.",
     "Error state for the Q&A feed."),
    ("qaAnswersCount", "{count, plural, =0{No answers} =1{1 answer} "
     "other{{count} answers}}",
     "{count, plural, =0{Нет ответов} =1{1 ответ} few{{count} ответа} "
     "other{{count} ответов}}",
     "{count, plural, =0{Javob yo‘q} other{{count} javob}}",
     "Number of answers on a question card."),
    ("qaAcceptedAnswer", "Best answer", "Лучший ответ", "Eng yaxshi javob",
     "Badge on the answer the asker accepted."),
    ("qaPinned", "Pinned", "Закреплено", "Qadalgan",
     "Badge on a question an admin pinned."),
    ("qaOpenMine", "My questions", "Мои вопросы", "Mening savollarim",
     "Toolbar action that opens the user's own questions and answers."),
    ("qaAsk", "Ask a question", "Задать вопрос", "Savol berish",
     "Primary action that opens the ask form."),
    ("qaOpenModeration", "Moderation", "Модерация", "Moderatsiya",
     "Toolbar action that opens the admin moderation queue."),
    # ---------------------------------------------------------------- teglar
    ("qaTagToxicology", "Toxicology", "Токсикология", "Toksikologiya",
     "Q&A topic tag."),
    ("qaTagAlcohol", "Alcohol", "Алкоголь", "Alkogol", "Q&A topic tag."),
    ("qaTagDrugs", "Narcotic drugs", "Наркотические средства",
     "Narkotik moddalar", "Q&A topic tag."),
    ("qaTagDna", "DNA", "ДНК", "DNK", "Q&A topic tag."),
    ("qaTagHistology", "Histology", "Гистология", "Gistologiya",
     "Q&A topic tag."),
    ("qaTagThanatology", "Thanatology", "Танатология", "Tanatologiya",
     "Q&A topic tag."),
    ("qaTagMethods", "Methods", "Методы", "Usullar", "Q&A topic tag."),
    ("qaTagRegulations", "Regulations", "Нормативные документы",
     "Normativ hujjatlar", "Q&A topic tag."),
    ("qaTagBiology", "Biology", "Биология", "Biologiya", "Q&A topic tag."),
    ("qaTagCriminalistics", "Criminalistics", "Криминалистика",
     "Kriminalistika", "Q&A topic tag."),
    ("qaTagDocumentation", "Documentation", "Документация", "Hujjatlar",
     "Q&A topic tag."),
    # ---------------------------------------------------------------- rollar
    ("qaRolePhysician", "Forensic physician", "Судебный медик",
     "Sud tabibi", "Q&A role of a verified specialist."),
    ("qaRoleChemist", "Forensic chemist", "Судебный химик",
     "Sud kimyogari", "Q&A role of a verified specialist."),
    ("qaRoleTechnician", "Laboratory technician", "Лаборант",
     "Laborant", "Q&A role of a verified specialist."),
    ("qaRoleStudent", "Student", "Студент", "Talaba", "Q&A role."),
    ("qaRoleOther", "Other", "Другое", "Boshqa", "Q&A role."),
    ("qaVerifiedBadge", "Verified specialist", "Подтверждённый специалист",
     "Tasdiqlangan mutaxassis",
     "Badge next to the author of a post when the server reports a verified "
     "profile."),
    ("qaManualBadge", "Checked by hand", "Проверено вручную",
     "Qo‘lda tekshirilgan",
     "Extra note on a profile a human verified instead of the automatic "
     "document check."),
    # ---------------------------------------------------------------- savol berish
    ("qaAskTitle", "Ask a question", "Задать вопрос", "Savol berish",
     "Title of the ask form."),
    ("qaFieldTitle", "Question", "Вопрос", "Savol",
     "Label of the question title field."),
    ("qaFieldBody", "Details", "Подробности", "Batafsil",
     "Label of the question body field."),
    ("qaFieldTopics", "Topics (up to 5)", "Темы (до 5)",
     "Mavzular (5 tagacha)", "Label of the tag picker in the ask form."),
    ("qaPrivacyWarning",
     "Never write case material: case or examination numbers, a person's "
     "name, an address, a date together with a place, or anything else that "
     "identifies someone. Describe the question in general terms. Photographs "
     "cannot be attached.",
     "Никогда не пишите материалы дела: номер дела или экспертизы, имя "
     "человека, адрес, дату вместе с местом и любые другие данные, по которым "
     "можно установить личность. Опишите вопрос в общем виде. Фотографии "
     "прикрепить нельзя.",
     "Ish materialini hech qachon yozmang: ish yoki ekspertiza raqami, "
     "shaxsning ismi, manzil, sana bilan birga joy va shaxsni aniqlashga imkon "
     "beradigan boshqa ma’lumot. Savolni umumiy holda yozing. Fotosurat "
     "ilova qilinmaydi.",
     "Privacy warning shown above the ask form and the answer field."),
    ("qaNoImages", "Images cannot be attached to posts.",
     "К публикациям нельзя прикреплять изображения.",
     "Postlarga rasm ilova qilinmaydi.",
     "Note explaining that image upload is not available in Q&A posts."),
    ("qaTitleTooShort", "Write the question in at least 10 characters.",
     "Сформулируйте вопрос минимум в 10 символах.",
     "Savolni kamida 10 belgida yozing.",
     "Validation message for the question title."),
    ("qaBodyTooShort", "Add at least 30 characters of detail.",
     "Добавьте не менее 30 символов подробностей.",
     "Kamida 30 belgilik tushuntirish qo‘shing.",
     "Validation message for the question body."),
    ("qaSend", "Send", "Отправить", "Yuborish",
     "Submit button in the ask and answer forms."),
    ("qaPosted", "Published.", "Опубликовано.", "Joylandi.",
     "Confirmation after a post went straight to the feed."),
    ("qaHeldForReview",
     "Held for review: the text looks like it contains case material. An "
     "administrator will look at it.",
     "Отправлено на проверку: текст похож на материалы дела. Его посмотрит "
     "администратор.",
     "Tekshiruvga qoldirildi: matnda ish materiali bordek ko‘rinadi. "
     "Administrator ko‘rib chiqadi.",
     "Shown when the server's privacy filter moved a post to moderation."),
    ("qaFlagCaseNumber", "a case or examination number",
     "номер дела или экспертизы", "ish yoki ekspertiza raqami",
     "Name of a privacy filter rule, listed after qaHeldForReview."),
    ("qaFlagPersonName", "a person's name", "имя человека",
     "shaxsning ismi", "Name of a privacy filter rule."),
    ("qaFlagDateAndPlace", "a date together with a place",
     "дата вместе с местом", "sana bilan birga joy",
     "Name of a privacy filter rule."),
    ("qaFlagContact", "a phone number or an address",
     "номер телефона или адрес", "telefon raqami yoki manzil",
     "Name of a privacy filter rule."),
    ("qaFlagIdentifier", "an identity document number",
     "номер документа, удостоверяющего личность",
     "shaxsni tasdiqlovchi hujjat raqami",
     "Name of a privacy filter rule."),
    ("qaFlagsFound", "Found: {flags}", "Найдено: {flags}",
     "Topildi: {flags}",
     "Prefix for the list of privacy rules that matched a post."),
    ("qaDailyLimit", "You have reached today's limit. Try again tomorrow.",
     "Вы достигли дневного лимита. Попробуйте завтра.",
     "Bugungi chegaraga yetdingiz. Ertaga qayta urinib ko‘ring.",
     "Message for a server-side daily rate limit."),
    ("qaSendFailed", "Could not send. Check the connection.",
     "Не удалось отправить. Проверьте соединение.",
     "Yuborib bo‘lmadi. Internet aloqasini tekshiring.",
     "Generic failure message for a Q&A write."),
    # ---------------------------------------------------------------- savol sahifasi
    ("qaAnswerHint", "Write your answer", "Напишите ответ",
     "Javobingizni yozing", "Hint of the answer field."),
    ("qaOnlyVerifiedMayAnswer",
     "Only verified specialists may answer. Get verified to join in.",
     "Отвечать могут только подтверждённые специалисты. Пройдите "
     "подтверждение, чтобы участвовать.",
     "Javob yozishni faqat tasdiqlangan mutaxassislar oladi. Qatnashish uchun "
     "tasdiqdan o‘ting.",
     "Shown in place of the answer field for a user without a verified "
     "badge."),
    ("qaNoAnswers", "No answers yet.", "Ответов пока нет.",
     "Hozircha javob yo‘q.", "Empty state on a question page."),
    ("qaMarkBest", "Mark as best answer", "Отметить лучшим ответом",
     "Eng yaxshi javob deb belgilash",
     "Action available to the asker on each answer."),
    ("qaUnmarkBest", "Remove the best-answer mark", "Снять отметку лучшего",
     "Eng yaxshi javob belgisini olish",
     "Action that clears the accepted answer."),
    ("qaUpvote", "Useful answer", "Полезный ответ", "Foydali javob",
     "Tooltip of the up-vote button."),
    ("qaDownvote", "Not a useful answer", "Бесполезный ответ",
     "Foydasiz javob", "Tooltip of the down-vote button."),
    ("qaOnlyVerifiedMayVote", "Only verified specialists may vote.",
     "Голосовать могут только подтверждённые специалисты.",
     "Ovoz berishni faqat tasdiqlangan mutaxassislar oladi.",
     "Message when a user without a badge tries to vote."),
    ("qaReport", "Report", "Пожаловаться", "Shikoyat qilish",
     "Action that reports a post or a profile."),
    ("qaReportReasonHint", "What is wrong with this post?",
     "Что не так с этой публикацией?", "Bu postda nima noto‘g‘ri?",
     "Hint of the report reason field."),
    ("qaReportSent", "Thank you. An administrator will look at it.",
     "Спасибо. Администратор посмотрит.",
     "Rahmat. Administrator ko‘rib chiqadi.",
     "Confirmation after a report."),
    ("qaReportHidden",
     "Hidden until an administrator decides: three different users reported "
     "it.",
     "Скрыто до решения администратора: пожаловались три разных "
     "пользователя.",
     "Administrator qaroriga qadar yashirildi: uch xil foydalanuvchi shikoyat "
     "qildi.",
     "Shown when a report crossed the three-reporter threshold."),
    # ---------------------------------------------------------------- tarjima
    ("qaMachineTranslation", "Machine translation", "Машинный перевод",
     "Mashina tarjimasi",
     "Badge above a post that the server translated automatically."),
    ("qaShowTranslation", "Translate", "Перевести", "Tarjima qilish",
     "Action that asks the server for a machine translation."),
    ("qaShowOriginal", "Original text", "Исходный текст", "Asl matn",
     "Action that switches back to the text the author wrote."),
    ("qaTranslationFailed", "Could not translate right now.",
     "Сейчас не удалось перевести.", "Hozir tarjima qilib bo‘lmadi.",
     "Failure message for the machine translation."),
    # ---------------------------------------------------------------- tasdiqlash
    ("qaVerifyTitle", "Verify as a specialist",
     "Подтверждение специалиста", "Mutaxassis sifatida tasdiqlanish",
     "Title of the expert verification screen."),
    ("qaVerifyIntro",
     "Send a photograph or a PDF of your professional credential — a diploma, "
     "certificate, licence or qualification certificate. It is checked "
     "automatically.",
     "Отправьте фотографию или PDF вашего профессионального документа — "
     "диплома, сертификата, лицензии или удостоверения о квалификации. "
     "Проверка автоматическая.",
     "Kasbiy hujjatingizning surati yoki PDF faylini yuboring — diplom, "
     "sertifikat, litsenziya yoki malaka guvohnomasi. Tekshiruv avtomatik "
     "bo‘ladi.",
     "Intro on the verification screen."),
    ("qaVerifyFileNotStored",
     "The file is NOT stored. It is held only in memory during the check and "
     "goes to no database, no storage and no log. Only this is kept: your "
     "account id, role, country, the outcome and the date. The document "
     "number and your full name are not written down.",
     "Файл НЕ сохраняется. Он находится только в памяти во время проверки и "
     "не попадает ни в базу, ни в хранилище, ни в журнал. Сохраняется лишь: "
     "идентификатор вашей учётной записи, роль, страна, результат и дата. "
     "Номер документа и полное имя не записываются.",
     "Fayl SAQLANMAYDI. U faqat tekshiruv vaqtida xotirada bo‘ladi va "
     "bazaga, saqlagichga yoki jurnalga tushmaydi. Saqlanadigani: hisobingiz "
     "identifikatori, rol, mamlakat, natija va sana. Hujjat raqami va to‘liq "
     "ism yozilmaydi.",
     "Privacy promise on the verification screen; must stay accurate."),
    ("qaVerifyRole", "Your role", "Ваша роль", "Sizning rolingiz",
     "Role picker on the verification screen."),
    ("qaVerifyCountry", "Country (two letters)", "Страна (две буквы)",
     "Mamlakat (ikki harf)",
     "Country code field on the verification screen."),
    ("qaVerifyPickFile", "Choose the document", "Выбрать документ",
     "Hujjatni tanlash",
     "Button that opens the file picker on the verification screen."),
    ("qaVerifyFileChosen", "Document chosen ({size})",
     "Документ выбран ({size})", "Hujjat tanlandi ({size})",
     "Shown after a document is picked; size is a human-readable file size."),
    ("qaVerifySend", "Send for checking", "Отправить на проверку",
     "Tekshirishga yuborish",
     "Submit button on the verification screen."),
    ("qaVerifyAttemptsLeft", "{count, plural, =0{No attempts left today} "
     "=1{1 attempt left today} other{{count} attempts left today}}",
     "{count, plural, =0{Сегодня попыток не осталось} "
     "=1{Осталась 1 попытка на сегодня} few{Осталось {count} попытки на "
     "сегодня} other{Осталось {count} попыток на сегодня}}",
     "{count, plural, =0{Bugun urinish qolmadi} "
     "other{Bugun {count} urinish qoldi}}",
     "Daily attempt counter on the verification screen (three per day)."),
    ("qaVerifyChecking", "Checking the document…", "Проверяем документ…",
     "Hujjat tekshirilmoqda…",
     "Progress message while the vision check runs."),
    ("qaVerifyAccepted",
     "Verified. You may now answer questions and vote.",
     "Подтверждено. Теперь вы можете отвечать на вопросы и голосовать.",
     "Tasdiqlandi. Endi savollarga javob yozishingiz va ovoz berishingiz "
     "mumkin.",
     "Success message after verification."),
    ("qaVerifyRejected", "Not verified: {reason}", "Не подтверждено: {reason}",
     "Tasdiqlanmadi: {reason}",
     "Failure message after verification; reason is one of the qaReason* "
     "strings."),
    ("qaReasonNotACredential",
     "the file does not look like a professional credential",
     "файл не похож на профессиональный документ",
     "fayl kasbiy hujjatga o‘xshamaydi",
     "Machine reason for a rejected verification."),
    ("qaReasonUnreadable", "the document could not be read",
     "документ не удалось прочитать", "hujjatni o‘qib bo‘lmadi",
     "Machine reason for a rejected verification."),
    ("qaReasonRoleMismatch",
     "the document shows a different profession from the one you chose",
     "в документе указана другая специальность, чем выбранная вами",
     "hujjatda siz tanlagan kasbdan boshqasi ko‘rsatilgan",
     "Machine reason for a rejected verification."),
    ("qaReasonLowConfidence", "the check was not confident enough",
     "проверка оказалась недостаточно уверенной",
     "tekshiruv yetarlicha ishonchli bo‘lmadi",
     "Machine reason for a rejected verification."),
    ("qaReasonExpired", "the document looks expired",
     "срок действия документа, похоже, истёк",
     "hujjat muddati o‘tganga o‘xshaydi",
     "Machine reason for a rejected verification."),
    ("qaReasonReported", "other users reported the profile",
     "на профиль пожаловались другие пользователи",
     "profilga boshqa foydalanuvchilar shikoyat qildi",
     "Machine reason for a suspended badge."),
    ("qaVerifyBadDocument",
     "Choose a JPEG, PNG, WebP or PDF file no larger than 6 MB.",
     "Выберите файл JPEG, PNG, WebP или PDF размером не более 6 МБ.",
     "JPEG, PNG, WebP yoki PDF faylni tanlang — 6 MB dan oshmasin.",
     "Validation message for the picked document."),
    ("qaVerifyUnavailable",
     "The check is unavailable right now. Your attempt was not used.",
     "Проверка сейчас недоступна. Попытка не израсходована.",
     "Tekshiruv hozir ishlamayapti. Urinishingiz sarflanmadi.",
     "Shown when the vision model could not be reached."),
    ("qaStatusUnverified", "Not verified", "Не подтверждён",
     "Tasdiqlanmagan", "Q&A profile status."),
    ("qaStatusVerified", "Verified", "Подтверждён", "Tasdiqlangan",
     "Q&A profile status."),
    ("qaStatusRejected", "Rejected", "Отклонён", "Rad etilgan",
     "Q&A profile status."),
    ("qaStatusSuspended", "Suspended", "Приостановлен", "To‘xtatilgan",
     "Q&A profile status."),
    # ---------------------------------------------------------------- menikilar
    ("qaMineTitle", "My questions and answers", "Мои вопросы и ответы",
     "Mening savollarim va javoblarim",
     "Title of the user's own Q&A posts screen."),
    ("qaMineQuestions", "Questions", "Вопросы", "Savollar",
     "Section header on the user's own Q&A posts screen."),
    ("qaMineAnswers", "Answers", "Ответы", "Javoblar",
     "Section header on the user's own Q&A posts screen."),
    ("qaMineEmpty", "You have not posted anything yet.",
     "Вы пока ничего не публиковали.", "Siz hali hech narsa joylamagansiz.",
     "Empty state on the user's own Q&A posts screen."),
    ("qaPostPublished", "Published", "Опубликовано", "Joylangan",
     "Status of a Q&A post."),
    ("qaPostModeration", "Under review", "На проверке", "Tekshiruvda",
     "Status of a Q&A post."),
    ("qaPostRemoved", "Removed", "Удалено", "Olib tashlangan",
     "Status of a Q&A post."),
    ("qaScore", "Rating: {score}", "Оценка: {score}", "Baho: {score}",
     "Vote score of an answer."),
    # ---------------------------------------------------------------- moderatsiya
    ("qaModerationTitle", "Q&A moderation", "Модерация вопросов и ответов",
     "Savol-javob moderatsiyasi",
     "Title of the admin moderation queue for Q&A."),
    ("qaModerationEmpty", "Nothing is waiting.", "Ничего не ожидает.",
     "Kutayotgan narsa yo‘q.", "Empty state of the Q&A moderation queue."),
    ("qaModerationQuestions", "Questions under review", "Вопросы на проверке",
     "Tekshiruvdagi savollar", "Section header in the moderation queue."),
    ("qaModerationAnswers", "Answers under review", "Ответы на проверке",
     "Tekshiruvdagi javoblar", "Section header in the moderation queue."),
    ("qaModerationSuspended", "Suspended badges",
     "Приостановленные подтверждения", "To‘xtatilgan belgilar",
     "Section header in the moderation queue."),
    ("qaReportsCount", "{count, plural, =1{1 report} other{{count} reports}}",
     "{count, plural, =1{1 жалоба} few{{count} жалобы} "
     "other{{count} жалоб}}",
     "{count, plural, other{{count} shikoyat}}",
     "Number of distinct reporters on a post."),
    ("qaActionPublish", "Publish", "Опубликовать", "Joylash",
     "Admin action in the Q&A moderation queue."),
    ("qaActionRemove", "Remove", "Удалить", "Olib tashlash",
     "Admin action in the Q&A moderation queue."),
    ("qaActionPin", "Pin", "Закрепить", "Qadash",
     "Admin action in the Q&A moderation queue."),
    ("qaActionUnpin", "Unpin", "Открепить", "Qadashni olish",
     "Admin action in the Q&A moderation queue."),
    ("qaActionReinstate", "Reinstate the badge", "Вернуть подтверждение",
     "Belgini qaytarish", "Admin action in the Q&A moderation queue."),
    ("qaActionSuspend", "Suspend the badge", "Приостановить подтверждение",
     "Belgini to‘xtatish", "Admin action in the Q&A moderation queue."),
    ("qaActionDone", "Done.", "Готово.", "Bajarildi.",
     "Confirmation after an admin action in Q&A."),
    ("qaActionFailed", "Could not do that.", "Не удалось выполнить.",
     "Bajarib bo‘lmadi.", "Failure after an admin action in Q&A."),
    ("qaAdminOnly", "Only an administrator can open this.",
     "Это может открыть только администратор.",
     "Buni faqat administrator ochadi.",
     "Shown when a non-admin reaches the Q&A moderation queue."),
]

PLACEHOLDERS = {
    "qaAnswersCount": {"count": {"type": "int"}},
    "qaVerifyAttemptsLeft": {"count": {"type": "int"}},
    "qaReportsCount": {"count": {"type": "int"}},
    "qaScore": {"score": {"type": "int"}},
    "qaFlagsFound": {"flags": {"type": "String"}},
    "qaVerifyRejected": {"reason": {"type": "String"}},
    "qaVerifyFileChosen": {"size": {"type": "String"}},
}


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
        print(f"l10n_qa_community: {lang} {'updated' if changed else 'unchanged'}")


if __name__ == "__main__":
    main()
