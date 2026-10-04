"""Umumiy HTTP yordamchi: disk kesh + retry/backoff (429/5xx).

Ma’lumot hech qachon taxmin qilinmaydi: so‘rov muvaffaqiyatsiz bo‘lsa
xato qaytadi va yozuv `unresolved` bo‘lib qoladi.
"""
import hashlib, json, os, time, urllib.error, urllib.request

CACHE = os.path.join(os.path.dirname(__file__), "..", "..", "phase5", "cache")
UA = "ForensicExpertContentPipeline/0.5 (research; non-commercial verification)"


def get(url, *, as_json=True, binary=False, ttl_days=30, tries=6):
    os.makedirs(CACHE, exist_ok=True)
    key = hashlib.sha256(url.encode()).hexdigest()
    path = os.path.join(CACHE, key + (".bin" if binary else ".txt"))
    if os.path.exists(path) and time.time() - os.path.getmtime(path) < ttl_days * 86400:
        data = open(path, "rb").read()
    else:
        delay = 2.0
        for attempt in range(tries):
            try:
                req = urllib.request.Request(url, headers={"User-Agent": UA})
                with urllib.request.urlopen(req, timeout=60) as r:
                    data = r.read()
                break
            except urllib.error.HTTPError as e:
                if e.code == 404:
                    raise
                if e.code in (429, 500, 502, 503, 504) and attempt < tries - 1:
                    time.sleep(delay)
                    delay *= 2
                    continue
                raise
            except (urllib.error.URLError, TimeoutError):
                if attempt < tries - 1:
                    time.sleep(delay)
                    delay *= 2
                    continue
                raise
        open(path, "wb").write(data)
        time.sleep(0.25)  # muloyim tezlik (PubChem/NCBI qoidalari)
    if binary:
        return data
    text = data.decode("utf-8")
    return json.loads(text) if as_json else text
