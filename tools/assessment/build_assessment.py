#!/usr/bin/env python3
"""Malaka toifalari bo‘yicha og‘zaki imtihon savollari -> ilova assetiga.

Manba: O‘zbekiston Respublikasi Sog‘liqni saqlash vazirligi, Tibbiyot va
farmatsevtika xodimlari malakasini baholash markazi (tmbm.ssv.uz) saytidagi
ochiq «Og‘zaki imtihon savollari» DOCX hujjatlari. Faqat savollar ro‘yxati;
javoblar hujjatda yo‘q va to‘qilmaydi.

Ishlatish: python3 -I build_assessment.py <docx_papka> <chiqish.json>
(papkada 135-…, 134-…, 1351-… DOCX fayllari bo‘lishi kerak).
"""
import json
import re
import sys
import zipfile
from pathlib import Path

SPECIALTIES = [
    ("sud_tib", "Sud-tibbiy ekspertiza", "135-sud-tib-eksp-ogz-sav-sajt-uzb.docx", "https://tmbm.ssv.uz/post/category/questions"),
    ("pat_anat", "Patologik anatomiya", "134-patanatom-ogz-sav-sajt-uzb.docx", "https://tmbm.ssv.uz/post/category/questions"),
    ("sud_kimyo", "Sud-kimyogar ekspertiza", "1351-sud-kime-eks-ogz-sav-sajt-uzb.docx", "https://tmbm.ssv.uz/post/category/questions"),
]
CATEGORIES = [
    ("c23", re.compile(r"uchinchi va ikkinchi malaka", re.I)),
    ("c1", re.compile(r"^birinchi malaka", re.I)),
    ("c0", re.compile(r"^oliy malaka", re.I)),
]
ENT = [("&amp;", "&"), ("&quot;", '"'), ("&lt;", "<"), ("&gt;", ">"), ("&apos;", "'")]


def paragraphs(path: Path):
    xml = zipfile.ZipFile(path).read("word/document.xml").decode("utf8")
    for p in re.findall(r"<w:p(?:\s[^>]*)?>.*?</w:p>", xml, flags=re.S):
        t = "".join(re.findall(r"<w:t(?:\s[^>]*)?>(.*?)</w:t>", p, flags=re.S))
        for a, b in ENT:
            t = t.replace(a, b)
        t = re.sub(r"\s+", " ", t).strip()
        if t:
            yield t


def main(src: Path, out: Path):
    result = {
        "version": 1,
        "lang": "uz",
        "source": {
            "publisher": "O‘zbekiston Respublikasi Sog‘liqni saqlash vazirligi, Tibbiyot va farmatsevtika xodimlari malakasini baholash markazi",
            "title": "Og‘zaki imtihon savollari (malaka toifalari uchun)",
            "url": "https://tmbm.ssv.uz/post/category/questions",
            "page": "https://gov.uz/oz/ssv/pages/og-zaki-imtixon-savollari",
            "retrieved": "2026-10-25",
        },
        "specialties": [],
    }
    for sid, title, fname, _url in SPECIALTIES:
        cats = {cid: [] for cid, _ in CATEGORIES}
        cur = None
        for t in paragraphs(src / fname):
            hit = next((cid for cid, rx in CATEGORIES if len(t) < 90 and rx.search(t)), None)
            if hit:
                cur = hit
                continue
            if cur is None:
                continue  # sarlavha qatorlari (mutaxassislik nomi)
            cats[cur].append(t)
        entry = {"id": sid, "title": title, "categories": []}
        for cid, _ in CATEGORIES:
            qs = [{"id": f"{sid}.{cid}.{i:03d}", "n": i, "text": q} for i, q in enumerate(cats[cid], 1)]
            entry["categories"].append({"id": cid, "questions": qs})
        result["specialties"].append(entry)
    out.write_text(json.dumps(result, ensure_ascii=False, indent=1) + "\n", encoding="utf8")
    for s in result["specialties"]:
        print(s["id"], [len(c["questions"]) for c in s["categories"]])


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
