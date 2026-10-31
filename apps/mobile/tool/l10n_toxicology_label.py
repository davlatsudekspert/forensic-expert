# Home/kutubxona bo‘limi nomi: «Sud toksikologiyasi» → «Toksikologiya» (egasi, 2026-10-31).
# Sabab: sud toksikologiyasi — «Sud tibbiyoti» ichidagi alohida bo‘lim; bu modul esa
# umumiy toksikologiya. Mutaxassislik nomlari (role*, spec*) o‘zgarmaydi.
# Idempotent; faylning boshqa joylari formati o‘zgarmaydi (faqat shu qator almashtiriladi).
#   cd apps/mobile && python3 tool/l10n_toxicology_label.py && flutter gen-l10n
import re
D = "lib/core/l10n/arb"
VAL = {"en": "Toxicology", "ru": "Токсикология", "uz": "Toksikologiya"}
# Fanlar ro‘yxati (disc_forensicToxicology) ham — egasi so‘rovi, 2026-10-31.
KEYS = ("moduleToxicology", "disc_forensicToxicology")
for lang, v in VAL.items():
    p = f"{D}/app_{lang}.arb"
    s = open(p, encoding="utf-8").read()
    for key in KEYS:
        s, n = re.subn(r'("' + key + r'":\s*)"[^"]*"', lambda m: m.group(1) + '"' + v + '"', s, count=1)
        assert n == 1, (p, key)
    open(p, "w", encoding="utf-8").write(s)
print(KEYS, VAL)
