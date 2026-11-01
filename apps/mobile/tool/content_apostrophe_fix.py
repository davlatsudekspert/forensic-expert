"""g’/o’ → g‘/o‘ (Uzbek okina, not tutuq). Visual audit L10/L19/H5. Idempotent."""
import re, sys, pathlib
R = re.compile(r'(?<=[gGoO])’')
for p in sys.argv[1:]:
    f = pathlib.Path(p); s = f.read_text(encoding='utf-8')
    n = len(R.findall(s))
    if n: f.write_text(R.sub('‘', s), encoding='utf-8')
    print(p, n)
