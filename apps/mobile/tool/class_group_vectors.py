# «Ustoz–talaba testi»: variant tanlovi uchun umumiy test vektorlari.
#
# Mustaqil (uchinchi) amalga oshirish: SQL `private.group_variant_draw` va
# Dart `drawVariant` shu fayl yozgan natijani berishi shart.
#   seed  = hex(SHA-256(utf8("<assignmentId>:<userId>")))
#   kalit = hex(SHA-256(utf8(seed + ":" + savolId)))
#   kalit (teng bo'lsa — id, bayt tartibida) bo'yicha o'sish, birinchi N ta.
# Ishga tushirish (apps/mobile ichida):
#   python3 tool/class_group_vectors.py          # faylni yozadi
#   python3 tool/class_group_vectors.py --check  # o'zgarmaganini tekshiradi
import hashlib
import json
import sys

OUT = "test/fixtures/class_group_variant_vectors.json"


def h(s):
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def draw(aid, uid, pool, n):
    seed = h(f"{aid}:{uid}")
    keyed = sorted(pool, key=lambda q: (h(f"{seed}:{q}"), q.encode("utf-8")))
    return keyed[: max(0, min(n, len(pool)))]


uuid_pool = [f"3f2a1c00-0000-4000-8000-{i:012d}" for i in range(1, 31)]
small_pool = [f"q{i:02d}" for i in range(1, 13)]
A1 = "8d6f0a4e-1b2c-4d3e-9f80-112233445566"
A2 = "00000000-0000-4000-8000-0000000000aa"
users = [
    "11111111-1111-4111-8111-111111111111",
    "22222222-2222-4222-8222-222222222222",
    "33333333-3333-4333-8333-333333333333",
]
cases = []
for u in users:
    cases.append(dict(assignment_id=A1, user_id=u, pool=uuid_pool, n=10))
cases.append(dict(assignment_id=A1, user_id="*", pool=uuid_pool, n=10))
for u in users:
    cases.append(dict(assignment_id=A2, user_id=u, pool=small_pool, n=4))
cases.append(dict(assignment_id=A2, user_id=users[0], pool=small_pool, n=0))
cases.append(dict(assignment_id=A2, user_id=users[0], pool=small_pool[:3], n=5))
cases.append(dict(assignment_id="a", user_id="b",
                  pool=["Zeta", "alpha", "Beta", "ж-савол", "x:1"], n=5))
cases.append(dict(assignment_id=A2, user_id=users[1], pool=[], n=3))
for c in cases:
    c["seed"] = h(f'{c["assignment_id"]}:{c["user_id"]}')
    c["expected"] = draw(c["assignment_id"], c["user_id"], c["pool"], c["n"])

text = json.dumps({
    "algorithm": "seed=hex(sha256(utf8(assignmentId+':'+userId))); "
                 "key(q)=hex(sha256(utf8(seed+':'+q))); "
                 "sort by (key, q) ascending (byte order); take first n",
    "cases": cases,
}, ensure_ascii=False, indent=1) + "\n"

if "--check" in sys.argv:
    with open(OUT, encoding="utf-8") as f:
        if f.read() != text:
            sys.exit("class_group_variant_vectors.json is stale")
    print("ok")
else:
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(text)
    print(len(cases), "cases")
