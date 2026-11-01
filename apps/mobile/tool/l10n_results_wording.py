# Egasi so‘rovi (2026-11-01): «CSV»/«Excel» o‘rniga oddiy so‘z — «natijalar».
# Fayl hamon .csv (Excel, Google Sheets ochadi; UTF-8 BOM bilan). Idempotent:
# faqat qiymat qatori almashtiriladi (fayl formati saqlanadi).
# Tartib (CLAUDE.md): … l10n_referral_reward.py → l10n_results_wording.py → … → flutter gen-l10n
import json
import re

D = "lib/core/l10n/arb"
V = {
    "classExportCsv": {
        "uz": "Natijalarni saqlash / ulashish",
        "ru": "Сохранить / отправить результаты",
        "en": "Save / share results",
    },
    "teacherPanelHomeBody": {
        "uz": "Guruh testi o‘tkazing, natijalarni saqlab oling",
        "ru": "Проведите тест для группы и сохраните результаты",
        "en": "Run a group test and save the results",
    },
    "teacherResultsTitle": {
        "uz": "Natijalar",
        "ru": "Результаты",
        "en": "Results",
    },
    "teacherResultsBody": {
        "uz": "O‘tkazilgan testlar, reyting va baholar",
        "ru": "Проведённые тесты, рейтинг и оценки",
        "en": "Past quizzes, leaderboard and grades",
    },
    "proBenefitResultsCsv": {
        "uz": "Natijalarni yuklab olish",
        "ru": "Скачивание результатов",
        "en": "Download results",
    },
    "proIncludesTeacher3": {
        "uz": "Natijalarni yuklab olish",
        "ru": "Скачивание результатов",
        "en": "Download results",
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
    print(f"l10n_results_wording: {len(V)} keys")


if __name__ == "__main__":
    main()
