# Home «Toksikologiya» kartasi → «Sud-kimyoviy ekspertiza» (egasi qarori, 2026-11-04):
# Toksikologik kimyo va apparatlar kursi shu bo‘lim ichida. Server kurs nomlari o‘zgarmaydi.
# Idempotent:  cd apps/mobile && python3 tool/l10n_sud_kimyo_label.py && flutter gen-l10n
import re
D = "lib/core/l10n/arb"
VAL = {
    "uz": {"moduleToxicology": "Sud-kimyoviy ekspertiza",
           "homeCoreToxBody": "Toksikologik kimyo: zaharlar, dorilar va giyohvand moddalar"},
    "ru": {"moduleToxicology": "Судебно-химическая экспертиза",
           "homeCoreToxBody": "Токсикологическая химия: яды, лекарства и наркотические вещества"},
    "en": {"moduleToxicology": "Forensic chemical examination",
           "homeCoreToxBody": "Toxicological chemistry: poisons, medicines and narcotics"},
}
for lang, kv in VAL.items():
    p = f"{D}/app_{lang}.arb"
    s = open(p, encoding="utf-8").read()
    for key, v in kv.items():
        s, n = re.subn(r'("' + key + r'":\s*)"[^"]*"', lambda m: m.group(1) + '"' + v + '"', s, count=1)
        assert n == 1, (p, key)
    open(p, "w", encoding="utf-8").write(s)
print(VAL)
