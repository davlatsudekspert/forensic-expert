#!/usr/bin/env python3
"""Ochiq maxfiylik siyosati havolasi uchun ARB kalitlari (idempotent)."""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"

KEYS = {
    "legalOpenOnline": {
        "en": "Open the full policy online",
        "ru": "Открыть полную политику в интернете",
        "uz": "To‘liq siyosatni internetda ochish",
    },
    "legalPublishedNotice": {
        "en": "This is the published policy. The same text is available online.",
        "ru": "Это опубликованная политика. Тот же текст доступен в интернете.",
        "uz": "Bu — e’lon qilingan siyosat. Xuddi shu matn internetda ham bor.",
    },
}

DESCRIPTIONS = {
    "legalOpenOnline": "Button that opens the published privacy policy in a browser.",
    "legalPublishedNotice": "Banner shown on the privacy screen: the policy is published.",
}


def main() -> None:
    for lang in ("en", "ru", "uz"):
        path = ARB / f"app_{lang}.arb"
        data = json.loads(path.read_text(encoding="utf-8"))
        changed = False
        for key, values in KEYS.items():
            if data.get(key) != values[lang]:
                data[key] = values[lang]
                changed = True
            # Shablon fayl (en) har bir kalit uchun @meta talab qiladi.
            if lang == "en" and f"@{key}" not in data:
                data[f"@{key}"] = {"description": DESCRIPTIONS[key]}
                changed = True
        if changed:
            path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
            )
            print(f"l10n_legal_url: {lang} updated")
        else:
            print(f"l10n_legal_url: {lang} unchanged")


if __name__ == "__main__":
    main()
