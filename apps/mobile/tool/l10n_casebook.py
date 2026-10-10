# «Ekspert ish daftari» (casebook) — uch tilli matnlar. Idempotent:
# kalitlar har safar qayta yoziladi; privacySummary’ga band bir marta qo‘shiladi.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

k("casebookTitle","Casebook screen title / tools tile.","Expert casebook","Рабочий журнал эксперта","Ekspert ish daftari")
k("casebookTileHint","Tools tile subtitle.","Private notes with source-backed limitations — stored only on this device","Личные заметки с ограничениями из источников — хранятся только на этом устройстве","Manbali cheklovlar bilan shaxsiy yozuvlar — faqat shu qurilmada saqlanadi")
k("casebookPrivacyBanner","Privacy banner.","Stored only on this device. Nothing is sent to a server, to AI or to other users. Deleting the app or clearing the casebook removes it permanently. Do not enter personal data of people involved in a case.","Хранится только на этом устройстве. Ничего не отправляется на сервер, в ИИ или другим пользователям. При удалении приложения или очистке журнала данные удаляются безвозвратно. Не вносите персональные данные участников дела.","Faqat shu qurilmada saqlanadi. Hech narsa serverga, AI’ga yoki boshqa foydalanuvchilarga yuborilmaydi. Ilova o‘chirilsa yoki daftar tozalansa, yozuvlar butunlay yo‘qoladi. Ishda ishtirok etuvchi shaxslarning shaxsiy ma’lumotlarini kiritmang.")
k("casebookEmptyTitle","Empty state title.","Your casebook is empty","Журнал пуст","Daftaringiz bo‘sh")
k("casebookEmptyBody","Empty state body.","Create an entry for your work and add source-backed limitations from guideline cards. Everything stays on this device.","Создайте запись по своей работе и добавляйте ограничения с источниками из карточек руководств. Всё остаётся на этом устройстве.","O‘z ishingiz uchun yozuv yarating va yo‘riqnoma kartalaridagi manbali cheklovlarni qo‘shing. Hammasi shu qurilmada qoladi.")
k("casebookNewEntry","Action.","New entry","Новая запись","Yangi yozuv")
k("casebookUntitled","Fallback title.","Untitled entry","Запись без названия","Nomsiz yozuv")
k("casebookEntryTitleField","Field.","Title","Название","Sarlavha")
k("casebookCaseRefField","Field.","Case reference (optional)","Метка дела (необязательно)","Ish belgisi (ixtiyoriy)")
k("casebookCaseRefHint","Hint.","Your own label, e.g. an internal number","Ваша собственная метка, например внутренний номер","O‘zingizning belgingiz, masalan ichki raqam")
k("casebookDateField","Field.","Date","Дата","Sana")
k("casebookBodyField","Field.","Notes","Заметки","Matn")
k("casebookSave","Action.","Save","Сохранить","Saqlash")
k("casebookSaved","Snackbar.","Saved on this device","Сохранено на этом устройстве","Shu qurilmada saqlandi")
k("casebookLinksTitle","Section.","Linked items","Связанные объекты","Bog‘langan obyektlar")
k("casebookLinksEmpty","Empty.","No linked substances, methods, guideline cards or sources yet.","Пока нет связанных веществ, методов, карточек руководств или источников.","Hozircha modda, usul, yo‘riqnoma kartasi yoki manba bog‘lanmagan.")
k("casebookAddLink","Action.","Link an item","Связать объект","Obyektni bog‘lash")
k("casebookLinkSearchHint","Search hint.","Search substance, method, guideline, source…","Поиск: вещество, метод, руководство, источник…","Qidiring: modda, usul, qo‘llanma, manba…")
k("casebookLinkNoResults","Empty search.","Nothing found. Try another term.","Ничего не найдено. Попробуйте другой запрос.","Hech narsa topilmadi. Boshqa so‘z bilan urinib ko‘ring.")
k("casebookLinkRemove","Tooltip.","Remove link","Убрать связь","Bog‘lanishni olib tashlash")
k("casebookBlocksTitle","Section.","Source-backed statements","Утверждения с источниками","Manbali bayonlar")
k("casebookBlocksEmpty","Empty.","No statements yet. Add a limitation or caution from a guideline card — the source and its section are copied with it.","Утверждений пока нет. Добавьте ограничение или предостережение из карточки руководства — источник и раздел копируются вместе с ним.","Hozircha bayon yo‘q. Yo‘riqnoma kartasidan cheklov yoki ehtiyot choralarini qo‘shing — manba va bo‘lim ham birga ko‘chiriladi.")
k("casebookAddBlock","Action.","Add limitation or caution","Добавить ограничение","Cheklov qo‘shish")
k("casebookPickerTitle","Sheet title.","Choose a statement","Выберите утверждение","Bayonni tanlang")
k("casebookPickerSearchHint","Search hint.","Filter by card or text","Фильтр по карточке или тексту","Karta yoki matn bo‘yicha saralash")
k("casebookPickerEmpty","Empty.","No matching limitations found.","Подходящих ограничений не найдено.","Mos cheklovlar topilmadi.")
k("casebookKindLimitation","Block kind.","Limitation","Ограничение","Cheklov")
k("casebookKindCaution","Block kind.","Caution","Предостережение","Ehtiyot chorasi")
k("casebookKindAi","Block kind.","AI answer","Ответ ИИ","AI javobi")
k("casebookAiUnverified","Mark on AI blocks.","AI-generated — unverified","Создано ИИ — не проверено","AI tomonidan yaratilgan — tekshirilmagan")
k("casebookSourceLabel","Export/label.","Source","Источник","Manba")
k("casebookLocationLabel","Export/label.","Section","Раздел","Bo‘lim")
k("casebookPagesLabel","Export/label.","pp.","стр.","bet")
k("casebookSourcesLabel","Export/label.","Sources","Источники","Manbalar")
k("casebookBlockRemove","Tooltip.","Remove statement","Удалить утверждение","Bayonni olib tashlash")
k("casebookAddToCasebook","Action on guideline sections and AI answers.","Add to casebook","Добавить в журнал","Ish daftariga qo‘shish")
k("casebookChooseEntry","Sheet title.","Add to which entry?","В какую запись добавить?","Qaysi yozuvga qo‘shamiz?")
k("casebookChooseNew","Option.","New entry","Новая запись","Yangi yozuv")
k("casebookAiAddNote","Note shown before adding AI text.","This AI text will be marked “AI-generated — unverified”. Check it against the sources before relying on it.","Этот текст ИИ будет помечен «Создано ИИ — не проверено». Сверьте его с источниками, прежде чем опираться на него.","Bu AI matni «AI tomonidan yaratilgan — tekshirilmagan» deb belgilanadi. Tayanishdan oldin manbalar bilan solishtiring.")
k("casebookAddedTo","Snackbar.","Added to “{title}”","Добавлено в «{title}»","«{title}» yozuviga qo‘shildi",{"title":S})
k("casebookOpen","Snackbar action.","Open","Открыть","Ochish")
k("casebookShare","Action.","Share","Поделиться","Ulashish")
k("casebookCopy","Action.","Copy text","Копировать текст","Matnni nusxalash")
k("casebookCopied","Snackbar.","Copied to clipboard","Скопировано в буфер обмена","Buferga nusxa olindi")
k("casebookExportDisclaimer","First lines of every export.","This is a personal working note, NOT an expert opinion or conclusion. Statements are copied from reference material and do not replace examination of the actual case materials.","Это личная рабочая заметка, а НЕ заключение эксперта. Утверждения скопированы из справочных материалов и не заменяют исследование реальных материалов дела.","Bu shaxsiy ish yozuvi, ekspert xulosasi EMAS. Bayonlar ma’lumotnomadan ko‘chirilgan va ish materiallarini haqiqiy tekshirishni almashtirmaydi.")
k("casebookExportFooter","Export footer.","Exported from the FORENSIC EXPERT casebook (kept on the author’s device). Verify every statement against the original source.","Экспортировано из журнала FORENSIC EXPERT (хранится на устройстве автора). Проверяйте каждое утверждение по первоисточнику.","FORENSIC EXPERT ish daftaridan eksport qilindi (muallif qurilmasida saqlanadi). Har bir bayonni asl manba bilan tekshiring.")
k("casebookExportLinks","Export label.","Linked items","Связанные объекты","Bog‘langan obyektlar")
k("casebookExportBlocks","Export label.","Source-backed statements","Утверждения с источниками","Manbali bayonlar")
k("casebookDeleteEntry","Action.","Delete entry","Удалить запись","Yozuvni o‘chirish")
k("casebookDeleteEntryTitle","Dialog.","Delete this entry?","Удалить эту запись?","Bu yozuv o‘chirilsinmi?")
k("casebookDeleteEntryBody","Dialog body.","The entry will be removed from this device. This cannot be undone.","Запись будет удалена с этого устройства. Отменить нельзя.","Yozuv shu qurilmadan o‘chiriladi. Qaytarib bo‘lmaydi.")
k("casebookDeleteConfirm","Dialog button.","Delete","Удалить","O‘chirish")
k("casebookCancel","Dialog button.","Cancel","Отмена","Bekor qilish")
k("casebookClearAll","Action.","Clear entire casebook","Очистить весь журнал","Butun daftarni tozalash")
k("casebookClearTitle","Dialog.","Clear the whole casebook?","Очистить весь журнал?","Butun daftar tozalansinmi?")
k("casebookClearBody","Dialog body.","All entries will be deleted from this device permanently. They are not stored anywhere else, so they cannot be restored.","Все записи будут безвозвратно удалены с этого устройства. Они нигде больше не хранятся, поэтому восстановить их нельзя.","Barcha yozuvlar shu qurilmadan butunlay o‘chiriladi. Ular boshqa joyda saqlanmaydi, shuning uchun qayta tiklab bo‘lmaydi.")
k("casebookCleared","Snackbar.","Casebook cleared","Журнал очищен","Daftar tozalandi")
k("casebookCount","Entry count.","{n} entries","Записей: {n}","Yozuvlar: {n}",{"n":I})
k("casebookBlockCount","Entry meta.","{n} statements","Утверждений: {n}","Bayonlar: {n}",{"n":I})
k("casebookNotFound","Missing entry.","This entry no longer exists.","Эта запись больше не существует.","Bu yozuv endi mavjud emas.")

PRIVACY = {
  "uz": "Ekspert ish daftari: daftardagi yozuvlaringiz (sarlavha, ish belgisi, matn, bog‘langan obyektlar va ko‘chirilgan bayonlar) faqat shu qurilmada saqlanadi. Ular serverga, telemetriyaga, AI’ga yoki boshqa foydalanuvchilarga yuborilmaydi va zaxira nusxaga kiritilmaydi. Yozuvni ulashish yoki nusxalash faqat siz tugmani bossangiz amalga oshadi. Daftarni istalgan vaqtda «Ish daftari → Butun daftarni tozalash» orqali o‘chirishingiz mumkin; ilova o‘chirilsa, yozuvlar ham yo‘qoladi.",
  "ru": "Рабочий журнал эксперта: ваши записи (название, метка дела, текст, связанные объекты и скопированные утверждения) хранятся только на этом устройстве. Они не отправляются на сервер, в телеметрию, в ИИ или другим пользователям и не попадают в резервные копии. Поделиться записью или скопировать её можно только по вашему нажатию. Журнал можно в любой момент удалить через «Рабочий журнал → Очистить весь журнал»; при удалении приложения записи тоже исчезают.",
  "en": "Expert casebook: your entries (title, case reference, text, linked items and copied statements) are stored only on this device. They are not sent to a server, to telemetry, to AI or to other users, and are not included in backups. An entry is shared or copied only when you press the button. You can delete the casebook at any time via “Casebook → Clear entire casebook”; if you delete the app, the entries are gone too.",
}
MARK = {"uz": "Ekspert ish daftari:", "ru": "Рабочий журнал эксперта:", "en": "Expert casebook:"}

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz, ph) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = {n: dict(t) for n, t in ph.items()}
            data["@" + key] = meta
    cur = data["privacySummary"]
    if MARK[code] not in cur:
        data["privacySummary"] = cur.rstrip() + "\n\n" + PRIVACY[code]
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print("casebook:", len(K), "keys")
