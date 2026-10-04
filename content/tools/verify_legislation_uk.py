#!/usr/bin/env python3
"""Yurisdiksiya namoyishi: Buyuk Britaniya — haydashda alkogol chegarasi.

Faqat rasmiy birlamchi manba (legislation.gov.uk, Open Government Licence):
* Road Traffic Act 1988, s.11(2) «the prescribed limit» — joriy versiya;
* The Road Traffic Act 1988 (Prescribed Limit) (Scotland) Regulations 2014
  (SSI 2014/328), reg.2.

Qiymatlar rasmiy matndan regex bilan olinadi; extent va versiya sanasi
XML metama’lumotidan. Topilmasa — skript xato bilan to‘xtaydi (taxmin yo‘q).
Chiqish: pilot/jurisdiction_gb.generated.json
"""
import datetime, hashlib, json, re, sys, urllib.request

RTA = "https://www.legislation.gov.uk/ukpga/1988/52/section/11/data.xml"
SSI = "https://www.legislation.gov.uk/ssi/2014/328/data.xml"


def fetch(url):
    with urllib.request.urlopen(url, timeout=60) as r:
        raw = r.read()
    xml = raw.decode("utf-8")
    text = re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", xml))
    return xml, text, hashlib.sha256(raw).hexdigest()


def limits(text):
    out = {}
    for amount, unit, matrix in re.findall(
            r"(\d+) (microgrammes|milligrammes) of alcohol in 100 millilitres of "
            r"(breath|blood|urine)", text):
        out.setdefault(matrix, {"value": int(amount),
                                "unit": f"{'µg' if unit.startswith('micro') else 'mg'}/100 mL"})
    return out


def main():
    accessed = datetime.date.today().isoformat()
    rta_xml, rta_text, rta_sha = fetch(RTA)
    i = rta_text.find("the prescribed limit")
    if i < 0:
        sys.exit("RTA: 'the prescribed limit' not found")
    rta_def = rta_text[i:i + 400]
    rta_limits = limits(rta_def)
    valid = re.search(r"<dct:valid>([^<]+)", rta_xml).group(1)
    # Bo‘lim darajasidagi qamrov: section-11 dan oldingi P1group atributi.
    sec = rta_xml.find('id="section-11"')
    group = rta_xml.rfind("<P1group", 0, sec)
    m = re.search(r'RestrictExtent="([^"]+)"', rta_xml[group:sec])
    if not m:
        sys.exit("RTA: section extent not found")
    extents = m.group(1)
    ssi_xml, ssi_text, ssi_sha = fetch(SSI)
    j = ssi_text.find("Prescription of proportion of alcohol")
    if j < 0:
        sys.exit("SSI: regulation 2 not found")
    ssi_reg = ssi_text[j:j + 500]
    ssi_limits = limits(ssi_reg)
    force = re.search(r"come into force on (\d+)(?:st|nd|rd|th) (\w+) (\d{4})", ssi_text)
    made = re.search(r'<ukm:Made Date="([^"]+)"', ssi_xml)
    ssi_valid = re.search(r"<dct:valid>([^<]+)", ssi_xml)
    if len(rta_limits) != 3 or len(ssi_limits) != 3 or not force:
        sys.exit(f"Unexpected text: {rta_limits} {ssi_limits} {force}")
    force_date = datetime.datetime.strptime(
        " ".join(force.groups()), "%d %B %Y").date().isoformat()
    out = dict(
        accessed=accessed,
        rta=dict(url=RTA, sha256=rta_sha, version_valid=valid, extents=extents,
                 section="s.11(2)", excerpt=rta_def.strip(), limits=rta_limits),
        ssi=dict(url=SSI, sha256=ssi_sha, made=made.group(1) if made else None,
                 version_valid=ssi_valid.group(1) if ssi_valid else None,
                 in_force=force_date, section="reg. 2", excerpt=ssi_reg.strip(),
                 limits=ssi_limits),
    )
    json.dump(out, open("pilot/jurisdiction_gb.generated.json", "w"),
              ensure_ascii=False, indent=2)
    print("RTA", valid, extents, rta_limits)
    print("SSI", force_date, ssi_limits)


if __name__ == "__main__":
    main()
