#!/usr/bin/env python3
"""Ғиёсов З.А. «Суд тиббиёти» (2018) — «To‘mtoq jism jarohati» mavzusi.

Qoida (ABY bilan bir xil, egasi qarori 2026-10-11): kitob manba sifatida
ochiq yoziladi va aniq bo‘limi ko‘rsatiladi; **so‘zma-so‘z iqtibos
olinmaydi** — mazmun o‘z so‘zimiz bilan `value.statement` da; kitob
faylining o‘zi repoga, assetlarga yoki Supabase’ga ko‘chirilmaydi.

Skript idempotent.
"""
import json
import sys
from pathlib import Path

BUNDLE = Path(__file__).resolve().parents[2] / "content/pilot/bundle.json"
ACCESSED = "2026-10-11"
SRC = "SRC-GIYASOV-FM-2018"
TOPIC = "fm-blunt-trauma"

SOURCE = {
    "source_id": SRC,
    "source_type": "book",
    "source_class": "bookHandbook",
    "title": "Суд тиббиёти. Тиббиёт олий ўқув юртлари талабалари учун дарслик",
    "authors": ["Ғиёсов З.А."],
    "organization": "Тошкент тиббиёт академияси",
    "publication_year": 2018,
    "accessed_date": ACCESSED,
    "tier": "tier3",
    "evidence_level": "C",
    # Kitob manba sifatida ko‘rsatiladi, matni ko‘chirilmaydi.
    "license_mode": "citeOnly",
    "identifier_verified": True,
    "language": "uz",
    "notes": "Darslik, 356 bet, «Global Books», Тошкент, 2018; "
             "ISBN 978-9943-5345-7-5. Тошкент тиббиёт академияси илмий "
             "кенгаши 2018-02-07, 7-сон баённома. Matn so‘zma-so‘z "
             "ko‘chirilmagan — mazmun o‘z so‘zimiz bilan; joy bo‘lim "
             "raqami bilan ko‘rsatiladi. Ilmiy review kutilmoqda.",
}


def claim(cid, field, statement, *, level="C"):
    assert set(statement) == {"uz", "ru", "en"}, cid
    return {
        "claim_id": cid,
        "entity_type": "topic",
        "entity_id": TOPIC,
        "field": field,
        "domain": "fm",
        "declared_status": "NEEDS_REVIEW",
        "evidence_level": level,
        "layer": "international_scientific",
        "is_structured_value": False,
        "value": {
            "statement": statement,
            # Asl til — o‘zbek (kitob o‘zbekcha); ru/en tekshirilmagan tarjima.
            "source_lang": "uz",
            "translation_status": {
                "uz": "authored",
                "ru": "machine_draft",
                "en": "machine_draft",
            },
            "source_i18n": {
                "uz": "Ғиёсов З.А. «Суд тиббиёти», Тошкент, 2018",
                "ru": "Гиёсов З.А. «Суд тиббиёти» (Судебная медицина), "
                      "Ташкент, 2018",
                "en": "Giyasov Z.A., Forensic Medicine (in Uzbek), "
                      "Tashkent, 2018",
            },
        },
    }


CLAIMS = [
    claim(
        "C-GIYASOV-BLUNT-SHARE-01",
        "case_observation",
        {
            "uz": "O‘zbekiston amaliyotida to‘mtoq jismlardan yetkazilgan "
                  "jarohatlar yetakchi o‘rinni egallaydi: tirik shaxslar "
                  "ekspertizasining 80 foizdan ziyodi va murdalar "
                  "ekspertizasida zo‘raki o‘limning qariyb yarmi shu "
                  "jarohatlar bilan bog‘liq.",
            "ru": "В практике Узбекистана повреждения тупыми предметами "
                  "занимают ведущее место: более 80 процентов экспертиз живых "
                  "лиц и около половины насильственных смертей при экспертизе "
                  "трупов связаны с ними.",
            "en": "In Uzbek practice blunt-force injuries predominate: more "
                  "than 80 per cent of examinations of living persons and "
                  "about half of the violent deaths examined at autopsy "
                  "involve them.",
        },
    ),
    claim(
        "C-GIYASOV-BLUNT-DEFINITION-01",
        "definition",
        {
            "uz": "Jism ma’lum bir yuza bilan ta’sir qilsa, u to‘mtoq "
                  "hisoblanadi; qattiq (tosh, tayoq), yumshoq (sharf, sochiq) "
                  "va elastik (rezina to‘p) turlari farqlanadi. Ta’sir "
                  "sohasida paydo bo‘lgan jarohat bevosita, boshqa sohada "
                  "paydo bo‘lgani bilvosita deb ataladi. Shikastlovchi yuza "
                  "«chegaralangan» yoki «chegaralanmagan» deb baholanishi "
                  "nisbiy: u shikastlangan soha yuzasidan kichik bo‘lsa "
                  "chegaralangan, katta bo‘lsa chegaralanmagan hisoblanadi — "
                  "ya’ni bitta jism har xil holatda har xil baholanadi.",
            "ru": "Предмет считается тупым, если действует определённой "
                  "поверхностью; различают твёрдые (камень, палка), мягкие "
                  "(шарф, полотенце) и эластичные (резиновый мяч). "
                  "Повреждение в зоне воздействия называют прямым, в другой "
                  "области — непрямым. Деление поверхности на «ограниченную» "
                  "и «неограниченную» относительно: если она меньше площади "
                  "повреждённой области — ограниченная, если больше — "
                  "неограниченная, поэтому один и тот же предмет в разных "
                  "случаях оценивается по-разному.",
            "en": "An object counts as blunt when it acts through a surface; "
                  "hard (stone, stick), soft (scarf, towel) and elastic "
                  "(rubber ball) types are distinguished. An injury at the "
                  "site of impact is direct, one elsewhere is indirect. "
                  "Calling the striking surface limited or unlimited is "
                  "relative: smaller than the injured area it is limited, "
                  "larger it is unlimited, so the same object is judged "
                  "differently from case to case.",
        },
    ),
    claim(
        "C-GIYASOV-BLUNT-MECHANISM-01",
        "principle",
        {
            "uz": "To‘mtoq jism jarohatlari asosan to‘rt mexanizm bilan "
                  "yuzaga keladi. Zarb — bir tomonlama, qisqa (0,1–0,01 "
                  "sekund va undan kam) ta’sir; shilinma, qontalash, lat "
                  "yara, suyak sinishi, bosh miya va ichki a’zo jarohatlari "
                  "beradi. Siqilish — markazga yo‘nalgan ikki kuchning uzoq "
                  "ta’siri; tashqi jarohatga nisbatan ichki a’zo va suyak "
                  "shikasti og‘irroq bo‘ladi. Cho‘zilish — markazdan qochuvchi "
                  "kuchlar; yirtma yara, yorilish, tana qismining ajralishi. "
                  "Ishqalanish — burchak ostida siljish; asosan shilinma. "
                  "Qo‘shimcha ikki mexanizm: buralish (suyakning spiralsimon "
                  "sinishi) va chayqalish (kuchsizida bosh miya chayqalishi, "
                  "kuchlisida ichki a’zo va bog‘lam yorilishi; «silkitilgan "
                  "chaqaloq sindromi» asosida ham shu yotadi). Ko‘p holatda "
                  "ikki va undan ortiq mexanizm birga ishlaydi.",
            "ru": "Повреждения тупыми предметами возникают в основном по "
                  "четырём механизмам. Удар — одностороннее кратковременное "
                  "(0,1–0,01 секунды и менее) воздействие; даёт ссадины, "
                  "кровоподтёки, ушибленные раны, переломы, повреждения "
                  "головного мозга и внутренних органов. Сдавление — "
                  "длительное действие двух центростремительных сил; "
                  "повреждения внутренних органов и костей тяжелее наружных. "
                  "Растяжение — центробежные силы; рваные раны, разрывы, "
                  "отрывы частей тела. Трение — смещение под углом; в "
                  "основном ссадины. Дополнительно: кручение (винтообразные "
                  "переломы) и сотрясение (при слабом воздействии — "
                  "сотрясение головного мозга, при сильном — разрывы органов "
                  "и связок; на нём же основан «синдром сотрясённого "
                  "ребёнка»). Чаще действуют два и более механизма сразу.",
            "en": "Blunt injuries arise mainly through four mechanisms. "
                  "Impact is one-sided and brief (0.1–0.01 second or less), "
                  "producing abrasions, bruises, lacerations, fractures and "
                  "injury to the brain and internal organs. Compression is "
                  "the prolonged action of two forces directed towards each "
                  "other; organ and bone damage exceeds what is visible "
                  "outside. Traction pulls in opposite directions, tearing "
                  "tissue, rupturing organs and avulsing body parts. Friction "
                  "acts at an angle and mainly abrades. Two further "
                  "mechanisms: torsion, which produces spiral fractures, and "
                  "shaking, which at low force concusses the brain and at "
                  "high force ruptures organs and ligaments — the basis of "
                  "shaken baby syndrome. Two or more mechanisms usually act "
                  "together.",
        },
    ),
    claim(
        "C-GIYASOV-ABRASION-STAGES-01",
        "application",
        {
            "uz": "Shilinma — terining yuza qatlamlari butunligining "
                  "buzilishi; faqat epidermis shikastlansa yuzaki, "
                  "so‘rg‘ichsimon qatlamga o‘tsa chuqur shilinma, chiziqsimon "
                  "shakli tirnalma deyiladi. Taykov (1951) bo‘yicha to‘rt "
                  "bosqich: yangi shilinma — yuzasi avval nam, keyin quriydi "
                  "va sog‘lom teri sathidan past turadi, 12 soatgacha; "
                  "qoplama hosil bo‘lishi — 2–3 sutkagacha; epitelizatsiya — "
                  "7–9 sutkagacha, qoplama qalinlashib teri sathidan "
                  "ko‘tariladi va chetidan ko‘chadi; iz bosqichi — pushti "
                  "dog‘ 10–15 sutkaga kelib yo‘qoladi, va shilinma shaklidan "
                  "qat’i nazar iz dumaloq yoki oval bo‘ladi.",
            "ru": "Ссадина — нарушение целости поверхностных слоёв кожи: при "
                  "повреждении только эпидермиса поверхностная, при переходе "
                  "на сосочковый слой глубокая, линейная форма называется "
                  "царапиной. По Тайкову (1951) четыре стадии: свежая ссадина "
                  "— поверхность сначала влажная, затем подсыхает и лежит ниже "
                  "уровня кожи, до 12 часов; образование корочки — до 2–3 "
                  "суток; эпителизация — до 7–9 суток, корочка утолщается, "
                  "поднимается над кожей и отслаивается с краёв; стадия следа "
                  "— розоватое пятно исчезает к 10–15 суткам, и независимо от "
                  "формы ссадины след округлый или овальный.",
            "en": "An abrasion is a breach of the superficial skin layers: "
                  "superficial when only the epidermis is involved, deep when "
                  "it reaches the papillary layer, and a linear one is called "
                  "a scratch. Taykov (1951) describes four stages: the fresh "
                  "abrasion, moist at first and then drying, lying below the "
                  "level of intact skin, up to 12 hours; crust formation, up "
                  "to 2–3 days; epithelialisation, up to 7–9 days, as the "
                  "crust thickens, rises above the skin and separates from "
                  "the edges; and the trace stage, a pinkish mark that fades "
                  "by 10–15 days and is round or oval whatever the shape of "
                  "the abrasion was.",
        },
    ),
    claim(
        "C-GIYASOV-ABRASION-VALUE-01",
        "application",
        {
            "uz": "Shilinmaning sud-tibbiy ahamiyati: mexanik ta’sir "
                  "bo‘lganini tasdiqlaydi; shikastlanish mexanizmi va "
                  "muddatini aniqlash imkonini beradi; joylashuvi, shakli va "
                  "soniga qarab hodisa tafsiloti haqida taxmin qilish mumkin "
                  "(masalan, bo‘yindagi yoysimon shilinmalar qo‘l bilan "
                  "bo‘g‘ishga ishora qiladi); ayrim holatda tan jarohati "
                  "og‘irlik darajasini belgilashda ishlatiladi. Tibbiy "
                  "hujjatda shilinma to‘liq tavsiflanadi: joyi, shakli, "
                  "o‘lchami, rangi, qoplama bor-yo‘qligi, atrofdagi teriga "
                  "nisbatan sathi va ifloslanganligi.",
            "ru": "Судебно-медицинское значение ссадины: подтверждает "
                  "механическое воздействие; позволяет установить механизм и "
                  "давность повреждения; по расположению, форме и числу можно "
                  "предполагать обстоятельства происшествия (например, "
                  "дугообразные ссадины на шее указывают на удавление руками); "
                  "иногда используется при определении степени тяжести "
                  "телесных повреждений. В медицинском документе ссадина "
                  "описывается полностью: локализация, форма, размеры, цвет, "
                  "наличие корочки, уровень относительно окружающей кожи и "
                  "загрязнение.",
            "en": "The forensic value of an abrasion: it establishes that "
                  "mechanical force was applied; it allows the mechanism and "
                  "the age of the injury to be determined; its site, shape "
                  "and number may suggest what happened — arc-shaped "
                  "abrasions on the neck point to manual strangulation; and "
                  "it is sometimes used in grading the severity of bodily "
                  "harm. The medical record must describe it in full: site, "
                  "shape, size, colour, whether a crust has formed, its level "
                  "relative to the surrounding skin, and any contamination.",
        },
    ),
    claim(
        "C-GIYASOV-ABRASION-LIMITS-01",
        "limitation",
        {
            "uz": "Shilinma bosqichlarining muddatlari shartli: ular "
                  "shaxsning yoshi, sog‘lig‘i, shikastlangan sohadagi teri "
                  "xususiyati va jarohat chuqurligiga bog‘liq. Qoplama 4–6 "
                  "soatdayoq hosil bo‘lishi, qolgan iz esa 30 va undan ortiq "
                  "kun saqlanishi mumkin (Akopov, 1978). Shuning uchun "
                  "muddatni faqat bosqich ko‘rinishiga qarab qat’iy "
                  "belgilash mumkin emas. Murda ekspertizasida shilinmani "
                  "o‘limdan keyingi qurish alomati — pergament dog‘laridan "
                  "farqlash kerak: ular sariq yoki jigarrang, atrofdagi teri "
                  "sathida yoki undan pastroq, qoplama hosil qilmaydi va "
                  "hayotiy jarohatga xos o‘zgarishlar bermaydi.",
            "ru": "Сроки стадий ссадины условны: они зависят от возраста и "
                  "состояния здоровья человека, особенностей кожи в области "
                  "повреждения и глубины ссадины. Корочка может образоваться "
                  "уже через 4–6 часов, а остаточный след сохраняться 30 и "
                  "более суток (Акопов, 1978). Поэтому давность нельзя "
                  "устанавливать строго по виду стадии. При экспертизе трупа "
                  "ссадину следует отличать от пергаментных пятен — признака "
                  "посмертного высыхания: они жёлтые или бурые, находятся на "
                  "уровне окружающей кожи или ниже, не образуют корочки и не "
                  "дают изменений, характерных для прижизненных повреждений.",
            "en": "The stage timings are conditional: they depend on the "
                  "person's age and health, the skin at the injured site and "
                  "the depth of the abrasion. A crust may form within 4–6 "
                  "hours and the residual mark persist for 30 days or more "
                  "(Akopov, 1978), so the age of an injury cannot be fixed "
                  "from the appearance of the stage alone. At autopsy an "
                  "abrasion must be distinguished from parchment spots, a "
                  "sign of post-mortem drying: these are yellow or brown, lie "
                  "at or below the level of the surrounding skin, form no "
                  "crust and show none of the changes of a vital injury.",
        },
    ),
]

CITATIONS = [
    ("C-GIYASOV-BLUNT-SHARE-01", "2.7-бўлим «Ўтмас жисмлардан жароҳатланиш»"),
    ("C-GIYASOV-BLUNT-DEFINITION-01",
     "2.7-бўлим «Ўтмас жисмлардан жароҳатланиш. Ўтмас жисмларнинг турлари»"),
    ("C-GIYASOV-BLUNT-MECHANISM-01",
     "2.8-бўлим «Ўтмас жисмларнинг таъсир механизми»"),
    ("C-GIYASOV-ABRASION-STAGES-01",
     "2.9-бўлим «Ўтмас жисмлардан етказилган жароҳатлар», шилинмалар"),
    ("C-GIYASOV-ABRASION-VALUE-01",
     "2.9-бўлим «Ўтмас жисмлардан етказилган жароҳатлар», шилинмалар"),
    ("C-GIYASOV-ABRASION-LIMITS-01",
     "2.9-бўлим «Ўтмас жисмлардан етказилган жароҳатлар», шилинмалар"),
]


def main() -> int:
    b = json.loads(BUNDLE.read_text())
    if SRC not in {s["source_id"] for s in b["sources"]}:
        b["sources"].append(SOURCE)
    have = {c["claim_id"] for c in b["claims"]}
    for c in CLAIMS:
        if c["claim_id"] not in have:
            b["claims"].append(c)
    have_cit = {(c["claim_id"], c["source_id"]) for c in b["citations"]}
    for cid, loc in CITATIONS:
        if (cid, SRC) not in have_cit:
            b["citations"].append(
                {"claim_id": cid, "source_id": SRC, "locator": loc}
            )
    BUNDLE.write_text(json.dumps(b, ensure_ascii=False, indent=1) + "\n")
    print("giyasov blunt trauma: claims", len(CLAIMS),
          "citations", len(CITATIONS))
    return 0


if __name__ == "__main__":
    sys.exit(main())
