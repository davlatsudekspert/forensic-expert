#!/usr/bin/env python3
"""Expert notes ON TOP of the national practice guide — our own reading of the
international literature, not the guide's text.

Why these exist: the guide prescribes procedures that are still in daily use here
but that the international literature has since qualified — a reagent that is a
known human carcinogen, a classic test whose negative result is not proof. A
forensic expert reading the guide in this app should see both. Each note is
attached to the same topic as the guide's own record, cites its own sources
(PubMed metadata verified; abstract level unless stated) and never contradicts a
fact the guide states — it adds what the guide does not say.

Uzbek only (`locale_only`), like the records they annotate: the guide's records
do not exist in the other two languages, so a note about them would be orphaned.
"""
from __future__ import annotations

ACCESSED = "2026-10-11"

SOURCES = [
    {
        "source_id": "SRC-PM16497705",
        "source_type": "journal_article",
        "title": "Hemoglobin adducts in workers exposed to benzidine and azo dyes",
        "authors": ["Beyerbach A", "Rothman N", "Bhatnagar VK", "Kashyap R", "Sabbioni G"],
        "journal": "Carcinogenesis",
        "publication_year": 2006,
        "doi": "10.1093/carcin/bgi362",
        "pmid": "16497705",
        "official_url": "https://doi.org/10.1093/carcin/bgi362",
        "accessed_date": ACCESSED,
        "tier": "tier2",
        "evidence_level": "B",
        "license_mode": "citeOnly",
        "identifier_verified": True,
        "notes": "PubMed metadata (PMID, DOI) verified 2026-10-11. ABSTRACT level only. Used for one fact: benzidine is a known human carcinogen.",
    },
    {
        "source_id": "SRC-PM25757908",
        "source_type": "journal_article",
        "title": "Benzidine induces epithelial-mesenchymal transition in human uroepithelial cells through ERK1/2 pathway",
        "authors": ["Zhao L", "Geng H", "Liang ZF", "Zhang ZQ", "Zhang T", "Yu DX", "Zhong CY"],
        "journal": "Biochemical and Biophysical Research Communications",
        "publication_year": 2015,
        "doi": "10.1016/j.bbrc.2015.02.163",
        "pmid": "25757908",
        "official_url": "https://doi.org/10.1016/j.bbrc.2015.02.163",
        "accessed_date": ACCESSED,
        "tier": "tier2",
        "evidence_level": "C",
        "license_mode": "citeOnly",
        "identifier_verified": True,
        "notes": "PubMed metadata verified 2026-10-11. ABSTRACT level only. Used for one fact: prolonged benzidine exposure is a known cause of urothelial carcinoma.",
    },
    {
        "source_id": "SRC-PM22733108",
        "source_type": "journal_article",
        "title": "Is the lung floating test a valuable tool or obsolete? A prospective autopsy study",
        "authors": ["Große Ostendorf AL", "Rothschild MA", "Müller AM", "Banaschak S"],
        "journal": "International Journal of Legal Medicine",
        "publication_year": 2012,
        "doi": "10.1007/s00414-012-0727-1",
        "pmid": "22733108",
        "official_url": "https://doi.org/10.1007/s00414-012-0727-1",
        "accessed_date": ACCESSED,
        "tier": "tier2",
        "evidence_level": "B",
        "license_mode": "citeOnly",
        "identifier_verified": True,
        "notes": "PubMed metadata verified 2026-10-11. ABSTRACT level only: 208 lungs, 98% agreement, four false negatives, no false positive.",
    },
    {
        "source_id": "SRC-PM31286205",
        "source_type": "journal_article",
        "title": "Lung density measurement in postmortem computed tomography: a new tool to assess immediate neonatal breath in suspected neonaticides",
        "authors": ["Ducloyer M", "Tuchtan L", "Delteil C", "Piercecchi MD", "David A", "Visseaux G", "Bouvet R", "Gorincour G", "Clement R"],
        "journal": "International Journal of Legal Medicine",
        "publication_year": 2019,
        "doi": "10.1007/s00414-019-02103-3",
        "pmid": "31286205",
        "official_url": "https://doi.org/10.1007/s00414-019-02103-3",
        "accessed_date": ACCESSED,
        "tier": "tier2",
        "evidence_level": "C",
        "license_mode": "citeOnly",
        "identifier_verified": True,
        "notes": "PubMed metadata verified 2026-10-11. ABSTRACT level only: 11 cases, lung density on postmortem CT separated live birth from stillbirth.",
    },
]

# (claim_id, entity_type, entity_id, field, evidence_level, [(source_id, locator)], uz text)
CLAIMS = [
    ("C-ABYX-BENZIDINE-01", "topic", "aby-bio-blood-presence", "limitation", "B",
     [("SRC-PM16497705", "abstract"), ("SRC-PM25757908", "abstract")],
     "Xavfsizlik eslatmasi (yo‘riqnomadan emas, xalqaro adabiyotdan). Yo‘riqnomada qon dog‘ini aniqlash "
     "reaksiyalarida benzidin ishlatiladi. Xalqaro adabiyotda benzidin odam uchun kanserogen deb "
     "tan olingan: uzoq ta’sirida siydik pufagi (urotelial) saratoni rivojlanishi kuzatilgan. Shu sababli "
     "ko‘p mamlakatlarda u taqiqlangan yoki boshqa reaktivlar bilan almashtirilgan. Amaliy xulosa: benzidin "
     "bilan ishlashda so‘rib oluvchi shkaf, qo‘lqop va nafas himoyasi shart; imkon bo‘lsa, taxminiy sinama "
     "uchun xavfsizroq alternativalar (leykomalaxit yashili, fenolftalein/Kastl–Meyer, lyuminol, TMB) "
     "qo‘llanadi. Bu eslatma yo‘riqnoma talabini bekor qilmaydi — u faqat xavf haqida ogohlantiradi."),
    ("C-ABYX-FLOAT-01", "topic", "aby-fm-newborn", "limitation", "B",
     [("SRC-PM22733108", "abstract"), ("SRC-PM31286205", "abstract")],
     "Cheklov (yo‘riqnomadan emas, xalqaro adabiyotdan). O‘pka suzish sinamasining ishonchliligi bo‘yicha "
     "208 ta yangi tug‘ilgan chaqaloq o‘pkasi tekshirilgan istiqbolli tadqiqotda natija 98 % holatda "
     "kutilganiga mos kelgan; to‘rt holatda noto‘g‘ri manfiy natija olingan (tibbiy xodimlar hayot "
     "belgilarini qayd etgan bo‘lsa ham o‘pka cho‘kkan), noto‘g‘ri musbat natija esa umuman uchramagan. "
     "Amaliy xulosa: musbat natija nafas olganlikni qo‘llab-quvvatlaydi, ammo MANFIY natija chaqaloq "
     "umuman nafas olmagan degan xulosa uchun yetarli asos emas — gistologiya va boshqa belgilar bilan "
     "birga baholanadi. Zamonaviy qo‘shimcha usul sifatida o‘limdan keyingi kompyuter tomografiyasida "
     "o‘pka zichligini o‘lchash taklif qilingan (kichik tadqiqot, 11 holat)."),
]
