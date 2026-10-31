# Taklif mukofoti (egasi qarori 2026-10-31): «3 do‘st Pro sotib olsa = 1 oy Pro».
# Matn faqat server `my_referral_reward_progress().rewards_enabled == true` bo‘lganda ko‘rinadi
# (Apple: xarid yoqilmaguncha pullik funksiya haqida matn yo‘q).
# Idempotent: faqat shu fayldagi kalitlarni yozadi.
# CLAUDE.md tartibida: l10n_pro_split.py dan keyin, (yangi skriptlar) dan oldin:
#   cd apps/mobile && python3 tool/l10n_referral_reward.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('referralRewardProgress', 'Referral screen: progress toward the Pro reward (shown only when rewards are enabled).',
  '{n} of {needed} friends got Pro. At {needed}, you get 1 month of Pro.',
  '{n} из {needed} друзей получили Pro. Когда их станет {needed}, вы получите 1 месяц Pro.',
  'Do‘stlaringizdan {n}/{needed} tasi Pro oldi — {needed} ta bo‘lsa, sizga 1 oy Pro',
  {'n': 'int', 'needed': 'int'})
k('referralRewardGranted', 'Referral screen: how many 1-month Pro rewards were already granted.',
  'Rewards earned: {count} × 1 month of Pro',
  'Получено наград: {count} × 1 месяц Pro',
  'Olingan mukofotlar: {count} × 1 oy Pro',
  {'count': 'int'})

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    data = json.loads(text)
    for key, (desc, en, ru, uz, ph) in K.items():
        val = (en, ru, uz)[idx]
        entries = [(key, val)]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = {n: {"type": t} for n, t in ph.items()}
            entries.append(("@" + key, meta))
        for kk, vv in entries:
            line = f"  {json.dumps(kk, ensure_ascii=False)}: {json.dumps(vv, ensure_ascii=False)}"
            if kk in data:
                text = re.sub(r"(?ms)^  " + re.escape(json.dumps(kk, ensure_ascii=False)) + r": .*?(,?)\n(?=  \"|\}$)",
                              lambda m: line + m.group(1) + "\n", text, count=1)
            else:
                body = text.rstrip()
                assert body.endswith("}")
                text = body[:-1].rstrip() + ",\n" + line + "\n}\n"
        data = json.loads(text)
    json.loads(text)
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
