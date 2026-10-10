"""Renders docs/SUBSTANCE_METHODS_COVERAGE.md from the bundle (generated; do not edit by hand)."""
from collections import Counter, defaultdict

COLS = [("colour_test", "rang"), ("odour_test", "hid"), ("chemical", "kimyo"), ("tlc", "TLC"), ("microcrystal", "kristall"),
        ("uv_spectrum", "UB"), ("photometric", "foto"), ("spectroscopy", "spektr."), ("physical", "t.suyuq."),
        ("immunoassay", "immuno"), ("instrumental", "instr.")]
SRC_SHORT = {"SRC-YULDASHEV-GMT-2024": "GMT-2024", "SRC-YULDASHEV-TOKS-2025": "TOKS-2025",
             "SRC-UNODC-STNAR-13": "UNODC-13", "SRC-SWGDRUG-8-2": "SWGDRUG"}


def render(b, subs, by_sub, existing_instr, local_families, seized_groups):
    cit = defaultdict(set)
    for c in b["citations"]:
        if c["claim_id"].startswith("C-SM-"):
            cit[c["claim_id"]].add(SRC_SHORT.get(c["source_id"], c["source_id"]))
    src_of = defaultdict(set)
    for c in b["claims"]:
        if c["claim_id"].startswith("C-SM-") and c["field"] != "identification_methods_overview":
            src_of[c["entity_id"]] |= cit[c["claim_id"]]
    n_all = len(subs)
    local = {s: [e for e in rows if e["family"] in local_families] for s, rows in by_sub.items()}
    local = {s: r for s, r in local.items() if r}
    fam_total = Counter(e["family"] for rows in by_sub.values() for e in rows)
    n_claims = sum(1 for c in b["claims"] if c["claim_id"].startswith("C-SM-"))
    multi = sorted(s for s, r in local.items() if len({e["family"] for e in r}) >= 3)
    L = []
    w = L.append
    w("# Modda darajasidagi «Tekshirish usullari» — qamrov hisoboti\n")
    w("> Avtomatik yaratiladi: `python3 content/tools/build_substance_methods.py` (qo‘lda tahrirlamang). "
      "Holat: barcha matnlar `machine_draft`, yozuvlar `NEEDS_REVIEW` (ilmiy reviewer tasdig‘i yo‘q).\n")
    w("## 1. Umumiy natija\n")
    w(f"- Paketdagi moddalar: **{n_all}**.")
    w(f"- Kamida 1 ta **mahalliy (GC-MS/LC-MS/MS talab qilmaydigan)** usuli manba va aniq joyi bilan hujjatlashtirilgan moddalar: **{len(local)}**.")
    w(f"- Kamida 3 xil usul oilasi hujjatlashtirilgan: **{len(multi)}** ta modda ({', '.join(multi)}).")
    w(f"- Yangi yozuvlar (claim): **{n_claims}** (shundan {len(by_sub)} tasi — modda bo‘yicha umumiy «identifikatsiya usullari» xulosasi).")
    w("- Usul oilalari bo‘yicha yozuvlar: " + ", ".join(f"{n} {k}" for k, n in sorted(fam_total.items())) + ".")
    w(f"- Hujjatlashtirilmagan moddalar: **{n_all - len(local)}** (4-bo‘lim).\n")
    w("## 2. Manbalar (faqat ruxsat etilganlari)\n")
    w("| Kalit | Manba | Qanday keltiriladi |\n|---|---|---|")
    w("| GMT-2024 | Yuldashev Z.A. va boshq., «Giyohvand moddalar tahlili», 2024 (muallif yozma ruxsati, `docs/DECISIONS.md`) | PDF sahifasi (bosma = PDF − 1), jadval raqami |")
    w("| TOKS-2025 | Yuldashev Z.A., Umarova G.Q., «Toksikologik kimyo» o‘quv-uslubiy majmua, 2025 (shu ruxsat) | PDF sahifasi (= bosma) |")
    w("| UNODC-13 | UNODC ST/NAR/13/Rev.1 «Rapid Testing Methods of Drugs of Abuse» (rasmiy PDF, bosma 37–52-betlar o‘qilgan) | bosma bet (PDF = bosma + 10) |")
    w("| SWGDRUG | SWGDRUG Recommendations v8.2, Part IIIB (Table 1 bosma 17-b.; IIIB.2–IIIB.5) | bo‘lim raqami + bosma bet |")
    w("\nEgasining reaktivlar to‘plami (`SRC-OWNER-REAGENTS`) — retseptlar bilan bog‘lash uchun: yozuvlardagi `recipe_ids` mavjud 76 retseptga ishora qiladi (Marki, Mecke, Mandelin, Fröhde, Erdmann, Dragendorff, Wagner, kobalt rodanid, Duquenois, Nessler, Trinder va b.); retsepti yo‘q reaktivlar (Simon, Zimmermann, Vitali–Morin, Fast Blue B, Pauli, Dille–Koppanyi, Ehrlich, van Urk …) nomi bilan keltirilgan, retsept to‘qilmagan.\n")
    w("Har bir yozuvda: matn (uz/ru/en), manba, aniq joyi (`value.locator_i18n` — uch tilda, manba nomi bilan), `evidence_class` (presumptive / supporting / screening / instrumental / physical), `swgdrug_category` (SWGDRUG ning o‘z toifasi, hujjatda bor bo‘lsa), `recipe_ids`. Aniq joyi keltirib bo‘lmagan usul **qo‘shilmagan**.\n")
    w("## 3. Modda bo‘yicha qamrov (usul oilalari soni)\n")
    w("| Modda | Guruh | " + " | ".join(h for _, h in COLS) + " | Manbalar | Adabiyotdagi instr. havolalar |")
    w("|---|---|" + "---|" * len(COLS) + "---|---|")
    for s in sorted(by_sub):
        c = Counter(e["family"] for e in by_sub[s])
        w(f"| {s} | {subs[s].get('group')} | " + " | ".join(str(c.get(k, '')) or "" for k, _ in COLS) + " | " +
          ", ".join(sorted(src_of[s])) + f" | {existing_instr.get(s, '')} |")
    w("\n`instr.` — shu qatlamdagi (manbali) instrumental yozuvlar; oxirgi ustun — paketda oldindan mavjud `analysed_by` (adabiyot) havolalari soni.\n")
    w("## 4. Mahalliy usul hujjatlashtirilmagan moddalar (halol ro‘yxat)\n")
    rest = defaultdict(list)
    for s, rec in subs.items():
        if s not in local:
            rest[rec.get("group")].append(s)
    w("Bu moddalar uchun ruxsat etilgan manbalarda (yuqoridagi 4 ta) aniq joyi bilan mahalliy usul topilmadi yoki o‘qilgan qismda yo‘q. Bu «usul mavjud emas» degani emas — faqat «hujjatlashtirilmagan».\n")
    for g in sorted(rest, key=str):
        w(f"- **{g}** ({len(rest[g])}): " + ", ".join(sorted(rest[g])))
    w("\nEslatma: GMT-2024 to‘liq o‘qilgan, TOKS-2025 esa kerakli bo‘limlar (alkaloidlar, uchuvchi zaharlar, metallar, FOB, antidepressantlar, NSAID). "
      "Qolgan moddalar (masalan, etilenglikol, izopropanol, paraquat, glifosat, karbamazepin, fenitoin, digoksin, metformin, propranolol, tramadol, paratsetamol) bu kitoblarda mahalliy usul bilan uchramadi.\n")
    w("## 5. Ilmiy halollik — qanday cheklovlar kiritilgan\n")
    w("- Har bir presumptive usul matnida uch tilda «taxminiy natija, o‘zi bilan aynanlikni isbotlamaydi» jumlasi bor; TLC uchun «xuddi shu plastinkadagi standart + ortogonal usul», kristall uchun «solishtirma nazorat», UB uchun «faqat yordamchi».")
    w("- Rf faqat manba aniq tizim bilan keltirganda kiritilgan. Tizimi aytilmagan Rf (strixnin 0,33; LSD 0,57) kiritilmadi; fentanilning jadvalida kesilgan ikki ustun qiymati kiritilmadi.")
    w("- Manbalarning ichki qarama-qarshiliklari yashirilmagan: morfinning Rf bir tizimda ikki jadvalda har xil (0,32–0,39 va 0,20); geroin UB (ishqorda 299 va 294 nm); morfin UB (296 va 298 nm); Duquenois ranglari kitobda (pushti → ko‘k → to‘q pushti) va UNODC da (binafsha) farq qiladi; talliy ditizonati ranglari ma’ruza va laboratoriya matnida farq qiladi.")
    w("- Kitob «reaksiya manfiy bo‘lsa tekshirishni to‘xtatish / nasha emas» kabi xulosalarni (ko‘rsatilgan joylarda) **takrorlanmadi**: SWGDRUG IIIB.3.3.4 ga ko‘ra manfiy natija aynanlikka hissa qo‘shmaydi; «manfiy ahamiyatli» reaksiyalar manba so‘zi bilan shunday belgilangan.")
    w("- SWGDRUG toifalari (A/B/C) hujjatning o‘z ta’rifi bo‘yicha; minimal talab IIIB.3.1–3.2 iborasi bilan; «sud xulosasi uchun yetarli» deb **aytilmaydi** — bu yurisdiksiya va laboratoriya protokoliga bog‘liq (IIIB.2.2). SWGDRUG faqat musodara qilingan giyohvand moddalar guruhlariga qo‘llanilgan.")
    w("- «ABY 2025» materiali ishlatilmagan va bu qatlamda unga havola yo‘q.\n")
    w("## 6. Hali qilinmagan / keyingi qadamlar\n")
    w("- Boshqa UNODC ST/NAR qo‘llanmalari (kannabis, amfetaminlar, kokain, opiatlar uchun TLC/rang sinamalari) hali o‘qilmagan; rasmiy PDF manzillari tekshirilib qo‘shilishi mumkin.")
    w("- Peer-reviewed adabiyot (PubMed/Crossref) bu o‘tishda yangi usul yozuvlari uchun ishlatilmadi; immunoanaliz kross-reaktivligi mavjud `scr-immunoassay-*` yozuvlarida (adabiyotdan) turibdi.")
    w("- UI (Dart) integratsiyasi: yangi `claims.field` qiymatlari — `colour_test`, `odour_test`, `chemical_test`, `tlc_system`, `microcrystal_test`, `uv_spectrum`, `photometric_assay`, `immunoassay_screen`, `confirmatory_method`, `melting_point`, `spectroscopy`, `identification_methods_overview`. Joyi uch tilda `value.locator_i18n`, manba nomi `value.source_i18n`; `value.evidence_class` bo‘yicha «TAXMINIY» belgisi ko‘rsatilishi kerak. Mavjud UI bu maydonlarni hozircha bo‘lim sifatida ko‘rsatmaydi.")
    w("- Ilmiy reviewer tasdig‘i va uz/ru tarjimalarining inson tekshiruvi.")
    return "\n".join(L) + "\n"
