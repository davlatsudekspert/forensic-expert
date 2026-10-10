# Admin «Tasdiqlash arizalari» (identity verification inbox) matnlari.
# Idempotent: kalitlarni o‘rnatadi, qayta ishga tushirilsa natija o‘zgarmaydi.
# Ishga tushirish (apps/mobile ichida):
#   python3 tool/l10n_admin_verify.py && flutter gen-l10n
# l10n_support_admin.py / l10n_qa_admin.py dan KEYIN ishga tushiriladi.
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import json, collections

D = "lib/core/l10n/arb"
K = collections.OrderedDict()
S = {"type": "String"}
I = {"type": "int"}


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


k("admNavVerify", "Admin section title: pending identity verification applications.",
  "Verification applications", "Заявки на верификацию", "Tasdiqlash arizalari")
k("admNavVerifyHint", "Admin section hint.",
  "Review professional applications and decide",
  "Проверьте заявки специалистов и примите решение",
  "Mutaxassis arizalarini ko‘rib chiqing va qaror qabul qiling")
k("admVfEmpty", "Empty list.", "No applications are waiting.",
  "Ожидающих заявок нет.", "Kutayotgan ariza yo‘q.")
k("admVfUnavailable", "Backend not connected.",
  "Verification needs the online service, which is not connected in this build.",
  "Для верификации нужен онлайн-сервис, он не подключён в этой сборке.",
  "Tasdiqlash uchun onlayn xizmat kerak, u bu yig‘mada ulanmagan.")
k("admVfLoadFailed", "Load error.",
  "Could not load applications. Check the connection and try again.",
  "Не удалось загрузить заявки. Проверьте соединение и повторите.",
  "Arizalarni yuklab bo‘lmadi. Aloqani tekshirib, qayta urinib ko‘ring.")
k("admVfSubmitted", "Application meta.", "Submitted {date}",
  "Подана: {date}", "Yuborilgan: {date}", {"date": S})
k("admVfDocsCount", "Document count on a list card.",
  "{count, plural, =0{No documents} =1{1 document} other{{count} documents}}",
  "{count, plural, =0{Нет документов} one{{count} документ} few{{count} документа} other{{count} документов}}",
  "{count, plural, =0{Hujjat yo‘q} other{{count} ta hujjat}}", {"count": I})
k("admVfSelfBadge", "Badge on the admin's own application.",
  "Your own application", "Ваша собственная заявка", "Sizning o‘z arizangiz")
k("admVfSelfNote", "Shown instead of the decision form for the admin's own application.",
  "You cannot approve your own application — another authorised admin will decide it.",
  "Вы не можете подтвердить собственную заявку — это сделает другой уполномоченный администратор.",
  "O‘z arizangizni tasdiqlay olmaysiz — buni boshqa vakolatli admin bajaradi.")
k("admVfApplicant", "Section header.", "Applicant", "Заявитель", "Ariza beruvchi")
k("admVfFieldSpecialty", "Field label.", "Specialty", "Специальность", "Mutaxassislik")
k("admVfFieldExperience", "Field label.", "Experience", "Стаж", "Tajriba")
k("admVfYears", "Years of experience.",
  "{count, plural, =1{1 year} other{{count} years}}",
  "{count, plural, one{{count} год} few{{count} года} other{{count} лет}}",
  "{count, plural, other{{count} yil}}", {"count": I})
k("admVfFieldEducation", "Field label.", "Education", "Образование", "Ma’lumoti")
k("admVfFieldCountry", "Field label.", "Country", "Страна", "Mamlakat")
k("admVfDocs", "Section header.", "Credential documents",
  "Документы о квалификации", "Malaka hujjatlari")
k("admVfDocsHint", "Explains the checkboxes.",
  "Tick every document you have checked. Approval needs at least one checked document.",
  "Отметьте каждый проверенный документ. Для подтверждения нужен хотя бы один проверенный документ.",
  "Tekshirgan har bir hujjatni belgilang. Tasdiqlash uchun kamida bitta tekshirilgan hujjat kerak.")
k("admVfDocsNone", "No documents uploaded.",
  "The applicant has not uploaded any documents, so the application cannot be approved yet.",
  "Заявитель не загрузил документов, поэтому заявку пока нельзя подтвердить.",
  "Ariza beruvchi hujjat yuklamagan, shuning uchun arizani hozircha tasdiqlab bo‘lmaydi.")
k("admVfDocsNote", "Honest note: the app lists metadata only.",
  "The app shows document details only (type, size, SHA-256). Check the file itself in the secure server storage.",
  "Приложение показывает только сведения о документе (тип, размер, SHA-256). Сам файл проверяйте в защищённом хранилище на сервере.",
  "Ilova hujjat haqidagi ma’lumotni (tur, hajm, SHA-256) ko‘rsatadi. Faylning o‘zini serverdagi xavfsiz omborda tekshiring.")
k("admVfDocMeta", "Document line: type, size, hash prefix.",
  "{type} · {size} · SHA-256 {hash}", "{type} · {size} · хеш SHA-256: {hash}",
  "{type} · {size} · SHA-256 xeshi: {hash}", {"type": S, "size": S, "hash": S})
k("admVfDecision", "Section header.", "Decision", "Решение", "Qaror")
k("admVfScope", "Dropdown label.", "Area of the decision",
  "Область решения", "Qaror sohasi")
k("admVfScopeRequired", "Hint when no area is chosen.",
  "Choose the specialty area this decision refers to.",
  "Выберите область специальности, к которой относится решение.",
  "Qaror qaysi mutaxassislik sohasiga tegishli ekanini tanlang.")
k("admVfReason", "Field label.", "Reason (at least 5 characters)",
  "Причина (не менее 5 символов)", "Sabab (kamida 5 belgi)")
k("admVfReasonShort", "Validation.", "Enter a reason of at least 5 characters.",
  "Укажите причину не короче 5 символов.", "Kamida 5 belgidan iborat sabab kiriting.")
k("admVfMessage", "Field label.", "Message to the applicant (optional)",
  "Сообщение заявителю (необязательно)", "Ariza beruvchiga xabar (ixtiyoriy)")
k("admVfApprove", "Action.", "Approve", "Подтвердить", "Tasdiqlash")
k("admVfRequestInfo", "Action.", "Request more information",
  "Запросить дополнительные сведения", "Qo‘shimcha ma’lumot so‘rash")
k("admVfReject", "Action.", "Reject", "Отклонить", "Rad etish")
k("admVfNoScientific", "Reminder under the decision form.",
  "Identity verification does not grant scientific review rights.",
  "Подтверждение личности не даёт прав научного рецензирования.",
  "Shaxsni tasdiqlash ilmiy taqriz huquqini bermaydi.")
k("admVfDoneVerified", "Result.", "Application approved.",
  "Заявка подтверждена.", "Ariza tasdiqlandi.")
k("admVfDoneInfo", "Result.", "More information requested.",
  "Дополнительные сведения запрошены.", "Qo‘shimcha ma’lumot so‘raldi.")
k("admVfDoneRejected", "Result.", "Application rejected.",
  "Заявка отклонена.", "Ariza rad etildi.")
k("admVfErrSelf", "Server refused: self approval.",
  "You cannot approve your own application — another authorised admin will decide it.",
  "Вы не можете подтвердить собственную заявку — это сделает другой уполномоченный администратор.",
  "O‘z arizangizni tasdiqlay olmaysiz — buni boshqa vakolatli admin bajaradi.")
k("admVfErrForbidden", "Server refused: no authority.",
  "You have no authority to verify in this area.",
  "У вас нет полномочий подтверждать в этой области.",
  "Sizda bu soha bo‘yicha tasdiqlash vakolati yo‘q.")
k("admVfErrNoCredential", "Server refused: no checked document.",
  "Mark at least one document as checked.",
  "Отметьте проверенным хотя бы один документ.",
  "Kamida bitta hujjatni tekshirilgan deb belgilang.")
k("admVfErrUnknownCredential", "Server refused: foreign document.",
  "A selected document does not belong to this applicant. Refresh the list.",
  "Выбранный документ не принадлежит заявителю. Обновите список.",
  "Tanlangan hujjat bu ariza beruvchiga tegishli emas. Ro‘yxatni yangilang.")
k("admVfErrTransition", "Server refused: already decided.",
  "This application has already been decided. Refresh the list.",
  "По этой заявке решение уже принято. Обновите список.",
  "Bu ariza bo‘yicha qaror allaqachon qabul qilingan. Ro‘yxatni yangilang.")
k("admVfErrNoApplication", "Server refused: no application.",
  "Application not found.", "Заявка не найдена.", "Ariza topilmadi.")
k("admVfErrMfa", "Server refused: MFA needed.",
  "Sign in with two-step verification to continue.",
  "Для продолжения войдите с двухэтапной проверкой.",
  "Davom etish uchun ikki bosqichli tekshiruv bilan kiring.")
k("admVfErrSignIn", "Session expired.", "Please sign in again.",
  "Войдите в аккаунт снова.", "Hisobingizga qayta kiring.")
k("admVfErrOffline", "No network.",
  "No connection. Check the internet and try again.",
  "Нет соединения. Проверьте интернет и повторите.",
  "Aloqa yo‘q. Internetni tekshirib, qayta urinib ko‘ring.")
k("admVfErrServer", "Generic failure.",
  "The decision was not saved. Try again later.",
  "Решение не сохранено. Повторите позже.",
  "Qaror saqlanmadi. Keyinroq urinib ko‘ring.")
k("admActVerificationsView", "Audit action.", "Viewed verification applications",
  "Просмотрены заявки на верификацию", "Tasdiqlash arizalari ko‘rildi")

for code, idx in (("en", 0), ("ru", 1), ("uz", 2)):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz, ph) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = ph
            data["@" + key] = meta
    with open(p, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
print(len(K), "keys")
