"""Qisqartma + qo‘shimcha qo‘shib yoziladi (O‘zbek imlo qoidasi: BMTga,
KTda): «TLC da» → «TLCda», «JK da» → «JKda». Faqat bosh harfli qisqartmalar
(Yu/Sh/Ch bilan ham); raqamli formulalar (H2SO4) va aralash registr (HCl, Pb)
o‘zgarmaydi. Idempotent."""
import re, sys, pathlib
ABBR = r'(?:[A-Z]|Yu|Ya|Sh|Ch|O‘|G‘){2,}(?:-[A-Z]{1,4})?'
SUF = r'(?:da|dan|ga|ka|ning|ni|lar|larning|larda|lardan|larni|dagi|dek|day)'
R = re.compile(rf'\b({ABBR}) ({SUF})\b')
for p in sys.argv[1:]:
    f = pathlib.Path(p); s = f.read_text(encoding='utf-8')
    n = len(R.findall(s))
    if n: f.write_text(R.sub(r'\1\2', s), encoding='utf-8')
    print(p, n)
