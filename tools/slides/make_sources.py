"""G'iyosov 2018 boblarini mavzularga bog'laydi: sources_private/sources.json ni to'ldiradi (maxfiy)."""
import json, re, sys
from pathlib import Path
from topics import parse_topics

GIY = Path(sys.argv[1])  # 4 ta qism .txt joylashgan papka
OUT = Path("sources_private"); (OUT / "giyosov").mkdir(parents=True, exist_ok=True)
P = {n: (GIY / f"Giyosov_2018_{n}-qism_.txt").read_text(encoding="utf-8").splitlines() for n in "1234"}
# (bob, [(qism, boshlanish_qator, tugash_qator)]) -- 1-indeksli, tugash kiritilmaydi
CH = {
 1: [("1", 120, 882)], 2: [("1", 882, 2078)], 3: [("1", 2078, None)],
 4: [("2", 1, 903)], 5: [("2", 903, 1940)], 6: [("2", 1940, None), ("3", 1, 797)],
 7: [("3", 797, 2123)], 9: [("4", 1, 301)], 10: [("4", 301, 766)], 11: [("4", 766, 1074)],
 12: [("4", 1074, 2169)], 13: [("4", 2169, 3020)],
}
TITLE = {1: "Fan, tarix", 2: "Sud-tibbiy travmatologiya", 3: "Transport travmasi", 4: "O'q otar qurollardan jarohatlar",
         5: "Kislorod tanqisligi (asfiksiya)", 6: "Sud-tibbiy toksikologiya", 7: "Fizik omillar ta'siri",
         9: "Nozo'raki o'lim hollarida murda ekspertizasi", 10: "Homila va yangi tug'ilgan go'daklar murdasi",
         11: "Hodisa joyi va murda topilgan joyni ko'zdan kechirish", 12: "Tirik shaxslar sud-tibbiy ekspertizasi",
         13: "Ashyoviy dalillarni sud-tibbiy tekshirish"}
for b, parts in CH.items():
    txt = []
    for q, a, z in parts:
        txt += P[q][a - 1:(z - 1 if z else None)]
    (OUT / "giyosov" / f"bob{b}.txt").write_text("\n".join(txt), encoding="utf-8")
RULES = [(r"tanatolog", None), (r"transport|avtotravma", 3), (r"o.?q ?otar|portlash", 4), (r"asfiksiya|kislorod", 5),
         (r"toksikolog", 6), (r"fizik omil", 7), (r"nozo.?raki", 9), (r"yangi tug|chaqaloq|go.?dak|homila", 10),
         (r"ko.?zdan kechirish|hodisa joyi|topilgan joy", 11), (r"jinsiy|tirik shaxs", 12), (r"ashyoviy|dalil", 13),
         (r"travmatolog|mexanik jarohat|jarohat", 2), (r"fani, vazifa|sud tibbiyoti fani|ekspertiza xizmat", 1)]
src_path = OUT / "sources.json"
S = json.loads(src_path.read_text(encoding="utf-8")) if src_path.exists() else {}
for t in parse_topics():
    if t["id"] in S:
        continue
    title = t["title"].lower()
    for pat, b in RULES:
        if re.search(pat, title):
            if b is None:
                break  # tanatologiya: alohida (qo'lda tanlangan) bob
            S[t["id"]] = [{"author": "G‘iyosov Z.A.", "title": "Sud tibbiyoti: darslik, Toshkent: Global Books nashriyoti",
                           "year": 2018, "pages": f"Bob {b}. {TITLE[b]}", "local_text_path": f"sources_private/giyosov/bob{b}.txt"}]
            break
src_path.write_text(json.dumps(S, ensure_ascii=False, indent=1), encoding="utf-8")
print(len(S), "mavzu manbaga bog'landi,", len(parse_topics()), "jami")
