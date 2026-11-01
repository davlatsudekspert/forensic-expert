# «Asbob-uskunalar» bo‘limi (egasi talabi, 2026-11-01): laboratoriya apparatlari va
# morg asboblari — illyustratsiya, tavsif, manbalar. Idempotent.
# Tartib (CLAUDE.md): … l10n_sourced_badge.py → l10n_equipment.py → … → flutter gen-l10n
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


k("equipTitle", "Section title: laboratory and autopsy equipment.",
  "Instruments and equipment", "Приборы и инструменты", "Asbob-uskunalar")
k("equipCardBody", "Workbench card subtitle for the equipment section.",
  "Laboratory instruments and autopsy tools: what they are and what they are used for",
  "Лабораторные приборы и секционные инструменты: что это и для чего",
  "Laboratoriya apparatlari va morg asboblari: nima ekani va nima uchun ishlatiladi")
k("equipIntro", "Intro text at the top of the equipment section.",
  "Each card shows what the instrument is, what it is used for in forensic practice, and the source.",
  "В каждой карточке — что это за прибор, для чего он нужен в экспертной практике и источник.",
  "Har bir kartada apparat nima ekani, ekspertiza amaliyotida nima uchun ishlatilishi va manbasi berilgan.")
k("equipGroupLab", "Segment: laboratory instruments.",
  "Laboratory", "Лаборатория", "Laboratoriya")
k("equipGroupMorgue", "Segment: autopsy (morgue) instruments.",
  "Autopsy", "Секционная", "Morg")
k("equipIllustrationNote", "Honest caption under AI-drawn instrument illustrations.",
  "Illustration (drawn with AI) — not a photo of a specific device.",
  "Иллюстрация (нарисована с помощью ИИ) — не фотография конкретного прибора.",
  "Illyustratsiya (AI yordamida chizilgan) — muayyan apparatning surati emas.")
k("equipWhat", "Detail section: what the instrument is.",
  "What it is", "Что это", "Bu nima")
k("equipUse", "Detail section: what it is used for.",
  "What it is used for", "Для чего применяется", "Nima uchun ishlatiladi")
k("equipCare", "Detail section: cautions and limitations.",
  "Keep in mind", "Обратите внимание", "E’tibor bering")
k("equipRelated", "Detail section: related topics, methods and lessons in the app.",
  "Related in the app", "Связанное в приложении", "Ilovada bog‘liq mavzular")
k("equipSources", "Detail section: sources.",
  "Sources", "Источники", "Manbalar")
k("equipLesson", "Related link: the instrument lesson (slides).",
  "Instrument lesson (slides)", "Урок по прибору (слайды)", "Apparat bo‘yicha dars (slaydlar)")
k("equipEmpty", "Empty state when the equipment pack is unavailable.",
  "This section is not available yet.", "Раздел пока недоступен.", "Bu bo‘lim hozircha mavjud emas.")
k("equipSteps", "Detail section: how the procedure is performed (ordered steps).",
  "How it is done", "Как проводится", "Qanday o‘tkaziladi")
k("equipFindings", "Detail section: what the method shows well and its limits.",
  "What it shows and what it cannot", "Что показывает и чего не может", "Nimani ko‘rsatadi va nimani ko‘rsata olmaydi")
k("equipOpenDevice", "Lab hub tile prefix: open the instrument card.",
  "Instrument card", "Карточка прибора", "Apparat kartasi")


def main():
    for lang, idx in (("en", 1), ("ru", 2), ("uz", 3)):
        p = f"{D}/app_{lang}.arb"
        with open(p, encoding="utf-8") as f:
            data = json.load(f, object_pairs_hook=collections.OrderedDict)
        for key, v in K.items():
            data[key] = v[idx]
            if lang == "en":
                meta = collections.OrderedDict(description=v[0])
                if v[4]:
                    meta["placeholders"] = v[4]
                data["@" + key] = meta
        with open(p, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print(f"l10n_equipment: {len(K)} keys")


if __name__ == "__main__":
    main()
