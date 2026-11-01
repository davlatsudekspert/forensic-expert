# Egasi savoli (2026-11-01): «Manba bo‘lsa, “Tekshirilmagan” shart emas».
# Halol va ijobiy so‘z: manbali da’vo — «Manba keltirilgan» (statusSourced bilan bir xil);
# kalkulyator ogohlantirishi — salbiy emas, amaliy. «Tasdiqlangan» faqat haqiqiy taqrizga.
# Idempotent. Tartib (CLAUDE.md): … l10n_results_wording.py → l10n_sourced_badge.py → … → flutter gen-l10n
import json
import re

D = "lib/core/l10n/arb"
V = {
    "lcNeedsReview": {
        "uz": "Manba keltirilgan",
        "ru": "Источник указан",
        "en": "Source cited",
    },
    "calcNeedsReviewNotice": {
        "uz": "Hisob standart formula bo‘yicha bajariladi. Natijani laboratoriyangiz protokoli bilan solishtiring.",
        "ru": "Расчёт выполняется по стандартной формуле. Сверьте результат с протоколом вашей лаборатории.",
        "en": "The calculation uses the standard formula. Check the result against your laboratory protocol.",
    },
    "moduleHubSourcedNote": {
        "uz": "Har bir yozuv manbasi bilan ko‘rsatiladi: «Manba keltirilgan» — adabiyotdan olingan (muallif, kitob, sahifa); «Tasdiqlangan» — ekspert taqrizidan ham o‘tgan.",
        "ru": "Каждая запись показана с источником: «Источник указан» — взято из литературы (автор, книга, страница); «Подтверждено» — дополнительно прошло экспертную рецензию.",
        "en": "Every entry is shown with its source: “Source cited” means taken from the literature (author, book, page); “Verified” means it has also passed expert review.",
    },
}


def main():
    for lang in ("uz", "ru", "en"):
        p = f"{D}/app_{lang}.arb"
        s = open(p, encoding="utf-8").read()
        for key, vals in V.items():
            new = json.dumps(vals[lang], ensure_ascii=False)
            s, n = re.subn(
                r'^(  "' + re.escape(key) + r'": )"(?:[^"\\]|\\.)*"',
                lambda m: m.group(1) + new,
                s,
                count=1,
                flags=re.M,
            )
            if n != 1:
                raise SystemExit(f"{lang}: {key} topilmadi")
        json.loads(s)
        open(p, "w", encoding="utf-8").write(s)
    print(f"l10n_sourced_badge: {len(V)} keys")


if __name__ == "__main__":
    main()
