#!/usr/bin/env python3
"""Admin panel kengaytmasi (2026-10-17) uchun ARB kalitlari — idempotent.

Shikoyat formasi, hamjamiyat qoidalari qabuli, mualliflarni bloklash, admin
shikoyatlar ro‘yxati, foydalanuvchi amallari (rol, to‘xtatish), statistika
kengaytmasi va jurnal amallari nomlari. Tartibda `l10n_avatar.py` dan keyin,
`l10n_ux_audit.py` dan oldin ishga tushiriladi (CLAUDE.md), so‘ng
`flutter gen-l10n`.
"""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"

# key: (en, ru, uz, description)
ROWS = [
    # ------------------------------------------------------------ contact
    ("contactLine", "Contact: {email}", "Связь: {email}",
     "Aloqa: {email}",
     "Visible support contact line; tapping opens the mail app."),
    # ------------------------------------------------------------ report
    ("repTitle", "Send a report", "Отправить жалобу", "Shikoyat yuborish",
     "Title of the report screen and the profile row."),
    ("repProfileHint", "Inappropriate content, a bug, advertising or anything else",
     "Недопустимый контент, ошибка, реклама или другое",
     "Nomaqbul kontent, xato, reklama yoki boshqa muammo",
     "Subtitle of the profile row that opens the report form."),
    ("repIntro",
     "Tell us about inappropriate content, a bug or another problem. You can "
     "send a report without signing in.",
     "Сообщите о недопустимом контенте, ошибке или другой проблеме. "
     "Отправить жалобу можно и без входа в аккаунт.",
     "Nomaqbul kontent, xato yoki boshqa muammo haqida xabar bering. "
     "Hisobga kirmasdan ham yuborish mumkin.",
     "Intro text on the report form."),
    ("repKindField", "Type", "Тип", "Turi",
     "Label of the report type dropdown."),
    ("repKindComplaint", "Complaint", "Жалоба", "Shikoyat",
     "Report type: complaint."),
    ("repKindInappropriate", "Inappropriate content",
     "Недопустимый контент", "Nomaqbul kontent",
     "Report type: inappropriate content."),
    ("repKindBug", "Bug", "Ошибка", "Xato", "Report type: bug."),
    ("repKindAdvertising", "Advertising", "Реклама", "Reklama",
     "Report type: advertising or spam."),
    ("repKindOther", "Other", "Другое", "Boshqa", "Report type: other."),
    ("repBody", "What happened?", "Что произошло?", "Nima bo‘ldi?",
     "Label of the report text field."),
    ("repBodyHint",
     "Do not write personal data, case numbers or patient information.",
     "Не указывайте персональные данные, номера дел и сведения о пациентах.",
     "Shaxsiy ma’lumot, ish raqami yoki bemor ma’lumotini yozmang.",
     "Helper text under the report text field."),
    ("repBodyShort", "Write at least {min} characters.",
     "Напишите не менее {min} символов.", "Kamida {min} belgi yozing.",
     "Validation message for a too short report."),
    ("repContact", "E-mail for a reply (optional)",
     "E-mail для ответа (необязательно)", "Javob uchun email (ixtiyoriy)",
     "Label of the optional contact field."),
    ("repContactHint",
     "If you are not signed in, leave an address if you want a reply.",
     "Если вы не вошли в аккаунт, оставьте адрес, чтобы получить ответ.",
     "Hisobga kirmagan bo‘lsangiz, javob olish uchun manzil qoldiring.",
     "Helper text under the optional contact field."),
    ("repPrivacy",
     "The text is stored only to review your report. To fight spam, an "
     "irreversible hash of the device or network address is kept; the "
     "address itself is not.",
     "Текст хранится только для рассмотрения жалобы. Для защиты от спама "
     "хранится необратимый хеш устройства или сетевого адреса, сам адрес "
     "не сохраняется.",
     "Matn faqat shikoyatni ko‘rib chiqish uchun saqlanadi. Spamdan himoya "
     "uchun qurilma yoki tarmoq manzilining qaytarib bo‘lmas xeshi "
     "saqlanadi, manzilning o‘zi saqlanmaydi.",
     "Privacy note under the report form."),
    ("repSend", "Send", "Отправить", "Yuborish", "Send button."),
    ("repSent", "Your report was sent. Thank you.",
     "Жалоба отправлена. Спасибо.", "Shikoyatingiz yuborildi. Rahmat.",
     "Confirmation after sending a report."),
    ("repInvalid", "Check the text and try again.",
     "Проверьте текст и попробуйте снова.",
     "Matnni tekshirib, qayta urinib ko‘ring.",
     "Server rejected the report as invalid."),
    ("repRateLimited",
     "You can send up to {n} reports per hour. Try again later.",
     "Можно отправить не более {n} жалоб в час. Попробуйте позже.",
     "Soatiga {n} tagacha shikoyat yuborish mumkin. Keyinroq urinib ko‘ring.",
     "Rate limit message."),
    ("repFailed", "Not sent. Check your connection and try again.",
     "Не отправлено. Проверьте соединение и попробуйте снова.",
     "Yuborilmadi. Internetni tekshirib, qayta urinib ko‘ring.",
     "Network or server error while sending a report."),
    ("repSuspended",
     "This account is suspended. Write to us by e-mail for help.",
     "Аккаунт приостановлен. Напишите нам по e-mail.",
     "Hisob to‘xtatilgan. Yordam uchun email orqali yozing.",
     "Message for a suspended account."),
    ("repUnavailable",
     "The report service is not connected in this build. Write to us by "
     "e-mail.",
     "Сервис жалоб в этой сборке не подключён. Напишите нам по e-mail.",
     "Bu yig‘mada shikoyat xizmati ulanmagan. Email orqali yozing.",
     "Honest empty state when no backend is connected."),
    ("repMine", "My reports", "Мои жалобы", "Mening shikoyatlarim",
     "Section with the signed-in user's own reports."),
    ("repStatusOpen", "Under review", "На рассмотрении",
     "Ko‘rib chiqilmoqda", "Report status: open."),
    ("repStatusResolved", "Resolved", "Решено", "Hal qilindi",
     "Report status: resolved."),
    # -------------------------------------------------- community rules
    ("ctTitle", "Community rules", "Правила сообщества",
     "Foydalanish qoidalari",
     "Title of the rules acceptance screen."),
    ("ctDraft",
     "This text is a draft and must be checked by a lawyer before the "
     "public release.",
     "Этот текст — черновик, его должен проверить юрист до публичного "
     "релиза.",
     "Bu matn qoralama — ommaviy chiqarishdan oldin yurist tekshirishi "
     "kerak.",
     "Draft label on the rules acceptance screen."),
    ("ctZeroTolerance",
     "Abusive, hateful, violent, illegal or spam content is not allowed. "
     "Every post has «Report» and «Block author» buttons. Content that "
     "breaks the rules can be removed and the account suspended.",
     "Оскорбительный, враждебный, насильственный, незаконный контент и спам "
     "запрещены. У каждой записи есть кнопки «Пожаловаться» и "
     "«Заблокировать автора». Нарушающий правила контент может быть удалён, "
     "а аккаунт приостановлен.",
     "Haqoratli, nafrat uyg‘otuvchi, zo‘ravonlikka undovchi, noqonuniy "
     "kontent va spamga yo‘l qo‘yilmaydi. Har bir postda «Shikoyat» va "
     "«Muallifni bloklash» tugmalari bor. Qoidani buzgan kontent olib "
     "tashlanishi va hisob to‘xtatilishi mumkin.",
     "Zero-tolerance statement shown before accepting the rules."),
    ("ctOpenTerms", "Terms of Use (draft)", "Условия использования (черновик)",
     "Foydalanish shartlari (qoralama)",
     "Button that opens the Terms of Use draft."),
    ("ctAgree", "I have read the rules and accept them",
     "Я прочитал(а) правила и принимаю их",
     "Qoidalarni o‘qidim va qabul qilaman",
     "Checkbox label."),
    ("ctAccept", "Accept", "Принять", "Qabul qilish", "Accept button."),
    ("ctDecline", "Not now", "Не сейчас", "Hozir emas", "Decline button."),
    ("ctSaveFailed", "Not saved. Try again.",
     "Не сохранено. Попробуйте снова.", "Saqlanmadi. Qayta urinib ko‘ring.",
     "Error when accepting the rules failed."),
    # ------------------------------------------------------------- blocks
    ("blkTitle", "Blocked authors", "Заблокированные авторы",
     "Bloklangan mualliflar", "Title of the blocked authors screen."),
    ("blkIntro",
     "Posts of blocked authors are hidden from you. You are not shown who "
     "they are.",
     "Записи заблокированных авторов вам не показываются. Кто они, вы "
     "также не видите.",
     "Bloklangan mualliflarning postlari sizga ko‘rinmaydi. Ular kimligi "
     "sizga ham ko‘rsatilmaydi.",
     "Explains blocking."),
    ("blkEmpty", "You have not blocked anyone.",
     "Вы никого не блокировали.", "Hech kim bloklanmagan.",
     "Empty state of the blocked list."),
    ("blkItem", "Blocked author", "Заблокированный автор",
     "Bloklangan muallif", "Row title in the blocked list."),
    ("blkSince", "since {date}", "с {date}", "{date} dan beri",
     "Row subtitle: block date."),
    ("blkUnblock", "Unblock", "Разблокировать", "Blokdan chiqarish",
     "Unblock button."),
    ("blkUnblocked", "Unblocked.", "Разблокировано.", "Blokdan chiqarildi.",
     "Confirmation after unblocking."),
    ("blkAction", "Block author", "Заблокировать автора", "Muallifni bloklash",
     "Block button on a post."),
    ("blkConfirmTitle", "Block this author?", "Заблокировать автора?",
     "Muallifni bloklaysizmi?", "Block confirmation title."),
    ("blkConfirmBody",
     "You will no longer see this author's questions and answers. You are "
     "not told who it is. You can undo this in the blocked list.",
     "Вы больше не увидите вопросы и ответы этого автора. Кто это, вам не "
     "сообщается. Отменить можно в списке заблокированных.",
     "Siz bu muallifning savol va javoblarini endi ko‘rmaysiz. Muallif "
     "kimligi sizga ko‘rsatilmaydi. Keyinroq bloklanganlar ro‘yxatida "
     "qaytarishingiz mumkin.",
     "Block confirmation body."),
    ("blkDone", "Author blocked.", "Автор заблокирован.", "Muallif bloklandi.",
     "Confirmation after blocking."),
    ("blkAlready", "This author is already blocked.",
     "Этот автор уже заблокирован.", "Bu muallif allaqachon bloklangan.",
     "Already blocked."),
    ("blkSelf", "You cannot block yourself.",
     "Нельзя заблокировать самого себя.", "O‘zingizni bloklab bo‘lmaydi.",
     "Self block attempt."),
    ("blkFailed", "Could not complete. Try again.",
     "Не удалось выполнить. Попробуйте снова.",
     "Bajarilmadi. Qayta urinib ko‘ring.", "Block or load failure."),
    # ------------------------------------------------------- admin reports
    ("admxNavReports", "Reports", "Жалобы", "Shikoyatlar",
     "Admin section tile title."),
    ("admxNavReportsHint", "{n} open", "Открытых: {n}", "{n} ta ochiq",
     "Admin section tile subtitle with the open count."),
    ("admxReportsTitle", "Reports", "Жалобы", "Shikoyatlar",
     "Admin reports screen title."),
    ("admxReportsSearch", "Search by text or e-mail",
     "Поиск по тексту или e-mail", "Matn yoki email bo‘yicha qidirish",
     "Search hint in the admin reports list."),
    ("admxOpen", "Open", "Открытые", "Ochiq", "Filter: open."),
    ("admxResolvedFilter", "Resolved", "Решённые", "Hal qilingan",
     "Filter: resolved."),
    ("admxAll", "All", "Все", "Hammasi", "Filter: all."),
    ("admxKindAny", "All types", "Все типы", "Barcha turlar",
     "Filter: any report type."),
    ("admxQaLink", "Open Q&A moderation (posts reported by three people)",
     "Открыть модерацию «Вопросов и ответов» (записи, на которые "
     "пожаловались трое)",
     "Savol-javob moderatsiyasini ochish (uch kishi shikoyat qilgan postlar)",
     "Link from the reports list to the existing Q&A moderation queue."),
    ("admxReportsEmpty", "No reports.", "Жалоб нет.", "Shikoyat yo‘q.",
     "Empty admin reports list."),
    ("admxLoadMore", "Load more", "Загрузить ещё", "Yana yuklash",
     "Pagination."),
    ("admxAnonymous", "Not signed in", "Не вошёл в аккаунт",
     "Kirmagan foydalanuvchi", "Reporter was not signed in."),
    ("admxContact", "Contact: {value}", "Связь: {value}", "Aloqa: {value}",
     "Contact given by the reporter."),
    ("admxTarget", "About: {type}", "Касается: {type}", "Qaysi post: {type}",
     "Target type of the report (technical code)."),
    ("admxNoteLabel", "Note (admins only)", "Заметка (только для админов)",
     "Izoh (faqat adminlar uchun)", "Admin note field."),
    ("admxNoteSave", "Save note", "Сохранить заметку", "Izohni saqlash",
     "Save note button."),
    ("admxNoteSaved", "Note saved.", "Заметка сохранена.", "Izoh saqlandi.",
     "Confirmation."),
    ("admxResolve", "Mark as resolved", "Отметить решённой",
     "Hal qilindi deb belgilash", "Resolve button."),
    ("admxReopen", "Reopen", "Открыть снова", "Qayta ochish",
     "Reopen button."),
    ("admxResolvedDone", "Report marked as resolved.",
     "Жалоба отмечена как решённая.", "Shikoyat hal qilindi.",
     "Confirmation."),
    ("admxReopened", "Report reopened.", "Жалоба открыта снова.",
     "Shikoyat qayta ochildi.", "Confirmation."),
    ("admxActionFailed", "Action failed. Try again.",
     "Действие не выполнено. Попробуйте снова.",
     "Amal bajarilmadi. Qayta urinib ko‘ring.", "Generic admin action error."),
    # ------------------------------------------------------ user actions
    ("admxActions", "Actions", "Действия", "Amallar",
     "Tooltip of the user actions button."),
    ("admxActionsHint",
     "Every action is checked by the server and written to the audit log.",
     "Каждое действие проверяется сервером и записывается в журнал.",
     "Har bir amalni server tekshiradi va jurnalga yozadi.",
     "Hint at the top of the user actions sheet."),
    ("admxReason", "Reason", "Причина", "Sabab",
     "Reason field of the user actions sheet."),
    ("admxReasonHint",
     "At least 5 characters. Saved in the audit log.",
     "Не менее 5 символов. Записывается в журнал.",
     "Kamida 5 belgi. Jurnalga yoziladi.", "Helper text for the reason."),
    ("admxReasonShort", "The reason must be at least 5 characters.",
     "Причина — не менее 5 символов.", "Sabab kamida 5 belgi bo‘lsin.",
     "Validation."),
    ("admxCancel", "Cancel", "Отмена", "Bekor qilish", "Cancel button."),
    ("admxConfirm", "Confirm", "Подтвердить", "Tasdiqlash", "Confirm button."),
    ("admxSelfNote",
     "You cannot change your own role or suspend your own account.",
     "Нельзя менять собственную роль или приостанавливать собственный "
     "аккаунт.",
     "O‘zingizning rolingizni o‘zgartirib yoki hisobingizni to‘xtatib "
     "bo‘lmaydi.",
     "Shown instead of actions when the admin opens their own row."),
    ("admxModeratorGrant", "Make publication moderator",
     "Назначить модератором статей", "Maqolalar moderatori qilish",
     "Grant the publication_moderator role."),
    ("admxModeratorRemove", "Remove moderator role",
     "Снять роль модератора", "Moderatorlikni olib tashlash",
     "Revoke the publication_moderator role."),
    ("admxRemoveAdmin", "Remove admin role", "Снять роль администратора",
     "Adminlikni olib tashlash", "Revoke identity_admin."),
    ("admxRemoveAdminTitle", "Remove admin role?",
     "Снять роль администратора?", "Adminlik olib tashlansinmi?",
     "Dialog title."),
    ("admxRemoveAdminBody",
     "This person loses access to the admin panel at once. The last admin "
     "cannot be removed. A scientific reviewer role is separate and is not "
     "changed here.",
     "Человек сразу потеряет доступ к админ-панели. Последнего "
     "администратора снять нельзя. Роль научного рецензента отдельная и "
     "здесь не меняется.",
     "Odam admin panelga kirish huquqini darhol yo‘qotadi. Oxirgi adminni "
     "olib tashlab bo‘lmaydi. Ilmiy reviewer roli alohida va bu yerda "
     "o‘zgarmaydi.",
     "Dialog body."),
    ("admxAdminNotSuspendable", "An admin account cannot be suspended.",
     "Аккаунт администратора нельзя приостановить.",
     "Admin hisobini to‘xtatib bo‘lmaydi.",
     "Shown instead of the suspend button for admins."),
    ("admxSuspend", "Suspend account", "Приостановить аккаунт",
     "Hisobni to‘xtatish", "Suspend button."),
    ("admxRestore", "Restore account", "Восстановить аккаунт",
     "Hisobni qayta yoqish", "Restore button."),
    ("admxSuspendTitle", "Suspend this account?",
     "Приостановить этот аккаунт?", "Hisob to‘xtatilsinmi?",
     "Dialog title."),
    ("admxSuspendConfirmBody",
     "The person is signed out everywhere and cannot sign in again until "
     "you restore the account. The action is written to the audit log.",
     "Человек будет выведен из аккаунта на всех устройствах и не сможет "
     "войти, пока вы не восстановите аккаунт. Действие записывается в "
     "журнал.",
     "Foydalanuvchi barcha qurilmalardan chiqariladi va hisob qayta "
     "yoqilmaguncha kira olmaydi. Amal jurnalga yoziladi.",
     "Dialog body."),
    ("admxRoleGranted", "Role granted.", "Роль назначена.", "Rol berildi.",
     "Result."),
    ("admxRoleRevoked", "Role removed.", "Роль снята.",
     "Rol olib tashlandi.", "Result."),
    ("admxNoChange", "Nothing changed.", "Изменений нет.", "O‘zgarish yo‘q.",
     "Result: already in that state."),
    ("admxUserNotFound", "User not found.", "Пользователь не найден.",
     "Foydalanuvchi topilmadi.", "Result."),
    ("admxRoleForbidden",
     "This role cannot be granted from the app. The owner does it on the "
     "server.",
     "Эту роль нельзя назначить из приложения. Владелец делает это на "
     "сервере.",
     "Bu rolni ilovadan berib bo‘lmaydi. Egasi buni server orqali qiladi.",
     "Result: role not grantable in-app."),
    ("admxEmailUnconfirmed", "The e-mail address is not confirmed.",
     "Адрес e-mail не подтверждён.", "Email manzili tasdiqlanmagan.",
     "Result."),
    ("admxSelfAdmin", "You cannot change your own admin role.",
     "Нельзя менять собственную роль администратора.",
     "O‘zingizning admin rolingizni o‘zgartirib bo‘lmaydi.", "Result."),
    ("admxLastAdmin", "The last admin cannot be removed.",
     "Последнего администратора снять нельзя.",
     "Oxirgi adminni olib tashlab bo‘lmaydi.", "Result."),
    ("admxCannotSuspendAdmin", "An admin cannot be suspended.",
     "Администратора нельзя приостановить.",
     "Adminni to‘xtatib bo‘lmaydi.", "Result."),
    ("admxCannotSuspendSelf", "You cannot suspend yourself.",
     "Нельзя приостановить самого себя.",
     "O‘zingizni to‘xtatib bo‘lmaydi.", "Result."),
    ("admxSuspended", "Account suspended. Its sessions were closed.",
     "Аккаунт приостановлен. Его сеансы закрыты.",
     "Hisob to‘xtatildi. Sessiyalari o‘chirildi.", "Result."),
    ("admxRestored", "Account restored.", "Аккаунт восстановлен.",
     "Hisob qayta yoqildi.", "Result."),
    # ----------------------------------------------------- stats extension
    ("admxExtTitle", "Roles, reports and objects",
     "Роли, жалобы и объекты", "Rollar, shikoyatlar va obyektlar",
     "Section title of the extended statistics."),
    ("admxStatAdmins", "Admins", "Администраторы", "Adminlar", "Stat label."),
    ("admxStatModerators", "Moderators", "Модераторы", "Moderatorlar",
     "Stat label."),
    ("admxStatSuspended", "Suspended", "Приостановлено", "To‘xtatilgan",
     "Stat label."),
    ("admxStatReportsOpen", "Open reports", "Открытые жалобы",
     "Ochiq shikoyatlar", "Stat label."),
    ("admxStatReportsResolved", "Resolved reports", "Решённые жалобы",
     "Hal qilingan shikoyatlar", "Stat label."),
    ("admxStatQaQuestions", "Q&A questions", "Вопросы (В&О)",
     "Savol-javob: savollar", "Stat label."),
    ("admxStatQaAnswers", "Q&A answers", "Ответы (В&О)",
     "Savol-javob: javoblar", "Stat label."),
    ("admxStatQaModeration", "In moderation", "На модерации",
     "Moderatsiyada", "Stat label."),
    ("admxStatBlocks", "Blocks", "Блокировки", "Bloklashlar", "Stat label."),
    ("admxCasebookNote",
     "Casebooks: stored on the device, not counted.",
     "Рабочие дневники: хранятся на устройстве, не учитываются.",
     "Casebook: qurilmada saqlanadi, hisoblanmaydi.",
     "Honest note: casebooks are not on the server."),
    ("admxOnlineNote",
     "Online now: not available (there is no activity tracking).",
     "Сейчас в системе: недоступно (нет отслеживания активности).",
     "Hozir tizimda: mavjud emas (faol kuzatuv yo‘q).",
     "Honest note: no real-time presence."),
    ("admxStoresTitle", "Downloads and sales", "Загрузки и продажи",
     "Yuklab olishlar va sotuvlar", "Section title."),
    ("admxDownloadsNote",
     "Downloads: the server cannot see them. Open the store consoles.",
     "Загрузки: сервер их не видит. Откройте консоли магазинов.",
     "Yuklab olishlar: serverga ko‘rinmaydi. Do‘kon konsollarini oching.",
     "Honest note about downloads."),
    ("admxSalesNote", "Sales: 0 — there is no payment system.",
     "Продажи: 0 — платёжной системы нет.",
     "Sotuvlar: 0 — to‘lov tizimi yo‘q.", "Honest note about sales."),
    ("admxOpenAsc", "App Store Connect", "App Store Connect",
     "App Store Connect", "Button that opens App Store Connect."),
    ("admxOpenPlay", "Google Play Console", "Google Play Console",
     "Google Play Console", "Button that opens Google Play Console."),
    ("admxOpenFailed", "Could not open the link.",
     "Не удалось открыть ссылку.", "Havola ochilmadi.",
     "External link failure."),
    # ------------------------------------------------------------- audit
    ("admActAdminRoleSet", "Role changed from the panel",
     "Роль изменена из панели", "Rol paneldan o‘zgartirildi",
     "Audit action label."),
    ("admActUserSuspended", "Account suspended",
     "Аккаунт приостановлен", "Hisob to‘xtatildi", "Audit action label."),
    ("admActUserRestored", "Account restored", "Аккаунт восстановлен",
     "Hisob qayta yoqildi", "Audit action label."),
    ("admActReportsView", "Report list viewed", "Просмотр списка жалоб",
     "Shikoyatlar ro‘yxati ko‘rildi", "Audit action label."),
    ("admActReportNote", "Note on a report", "Заметка к жалобе",
     "Shikoyatga izoh", "Audit action label."),
    ("admActReportResolved", "Report resolved", "Жалоба решена",
     "Shikoyat hal qilindi", "Audit action label."),
    ("admActReportReopened", "Report reopened", "Жалоба открыта снова",
     "Shikoyat qayta ochildi", "Audit action label."),
    ("admActAdminBootstrap", "First admin assigned (owner bootstrap)",
     "Назначен первый администратор (начальная настройка)",
     "Birinchi admin tayinlandi (egasi bootstrap)", "Audit action label."),
]

PLACEHOLDERS = {
    "contactLine": {"email": {"type": "String"}},
    "repBodyShort": {"min": {"type": "int"}},
    "repRateLimited": {"n": {"type": "int"}},
    "blkSince": {"date": {"type": "String"}},
    "admxNavReportsHint": {"n": {"type": "int"}},
    "admxContact": {"value": {"type": "String"}},
    "admxTarget": {"type": {"type": "String"}},
}


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
        print(f"l10n_admin_ext: {lang} {'updated' if changed else 'unchanged'}")


if __name__ == "__main__":
    main()
