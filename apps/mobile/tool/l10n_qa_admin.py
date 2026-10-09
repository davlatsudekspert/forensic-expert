# Real-ilova QA (2026-10-09, «Taklif va murojaatlar» + admin panel)
# topilmalari bo‘yicha lokalizatsiya tuzatishlari.
# Idempotent — faqat qiymatlarni o‘rnatadi; qayta ishga tushirilsa natija
# o‘zgarmaydi. Ishga tushirish: apps/mobile ichida
# `python3 tool/l10n_qa_admin.py`, so‘ng `flutter gen-l10n`
# (l10n_support_admin.py dan KEYIN).
import json

D = "lib/core/l10n/arb"

# (til, kalit) -> qiymat
SET = {
    # Admin «Yopish» amali murojaatni yakunlaydi: foydalanuvchi va admin
    # uchun holat nomi «Yakunlandi» (spetsifikatsiyadagi atama). «Yopilgan»
    # eshik/kirish yopilganini eslatardi.
    ("uz", "supStatusClosed"): "Yakunlandi",
    ("uz", "supClosedNote"): (
        "Bu murojaat yakunlangan. Yordam kerak bo‘lsa, yangisini yarating."
    ),
}


# Yangi kalitlar: kalit -> (tavsif, en, ru, uz). Admin ro‘yxati va
# jurnalida xom rol kodi («publication_moderator») o‘rniga.
NEW = {
    "admRolePublicationModerator": (
        "Role name of a publication moderator (admin users list, audit log).",
        "Publication moderator",
        "Модератор публикаций",
        "Maqolalar moderatori",
    ),
}


def main():
    langs = ["en", "ru", "uz"]
    for lang in langs:
        path = f"{D}/app_{lang}.arb"
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        changed = False
        for key, (desc, en, ru, uz) in NEW.items():
            value = {"en": en, "ru": ru, "uz": uz}[lang]
            if data.get(key) != value:
                data[key] = value
                changed = True
            if lang == "en" and data.get(f"@{key}") != {"description": desc}:
                data[f"@{key}"] = {"description": desc}
                changed = True
        for (l2, key), value in SET.items():
            if l2 != lang:
                continue
            if key not in data:
                raise SystemExit(f"{path}: kalit yo‘q: {key}")
            if data[key] != value:
                data[key] = value
                changed = True
        if changed:
            with open(path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
                f.write("\n")
        print(f"{path}: {'yangilandi' if changed else 'o‘zgarishsiz'}")


if __name__ == "__main__":
    main()
