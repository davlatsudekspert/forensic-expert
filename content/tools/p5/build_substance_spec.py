#!/usr/bin/env python3
"""Moddalar uchun qidiruv spetsifikatsiyasi (metabolizm, analitik metod,
xabar qilingan konsentratsiya)."""
import json, re

ident = json.load(open("phase5/identity.json"))
# Qidiruvda ishlatiladigan nom(lar): EN nomning asosiy qismi + so‘rov nomi.
ALIASES = {
    "heroin": ["heroin", "diacetylmorphine", "diamorphine"],
    "6-mam": ["6-MAM", "6-monoacetylmorphine", "6-acetylmorphine"],
    "thc": ["THC", "tetrahydrocannabinol"],
    "11-oh-thc": ["11-OH-THC", "11-hydroxy-THC"],
    "thc-cooh": ["THC-COOH", "carboxy-THC", "THCCOOH"],
    "cbd": ["cannabidiol", "CBD"],
    "mdma": ["MDMA"], "mda": ["MDA"], "mdea": ["MDEA"],
    "mdpv": ["MDPV"], "alpha-pvp": ["α-PVP", "alpha-PVP", "a-PVP"],
    "mephedrone": ["mephedrone", "4-MMC"],
    "ghb": ["GHB", "gamma-hydroxybutyrate", "γ-hydroxybutyrate"],
    "pcp": ["phencyclidine", "PCP"], "lsd": ["LSD", "lysergic acid diethylamide"],
    "paracetamol": ["paracetamol", "acetaminophen"],
    "salicylic-acid": ["salicylate", "salicylic acid", "aspirin"],
    "carbon-monoxide": ["carbon monoxide", "carboxyhemoglobin", "COHb"],
    "hydrogen-cyanide": ["cyanide"], "hydrogen-sulfide": ["hydrogen sulfide", "hydrogen sulphide"],
    "aluminium-phosphide": ["aluminium phosphide", "aluminum phosphide"],
    "arsenic-trioxide": ["arsenic"], "thallium-sulfate": ["thallium"],
    "isopropanol": ["isopropanol", "isopropyl alcohol"],
    "valproic-acid": ["valproic acid", "valproate"],
    "difluoroethane": ["difluoroethane", "HFC-152a"],
    "nordiazepam": ["nordiazepam", "nordazepam"],
    "7-aminoclonazepam": ["7-aminoclonazepam"],
    "etonitazepyne": ["etonitazepyne", "N-pyrrolidino etonitazene"],
    "mitragynine": ["mitragynine"],
    "mdmb-4en-pinaca": ["MDMB-4en-PINACA"], "adb-butinaca": ["ADB-BUTINACA"],
    "jwh-018": ["JWH-018"], "2c-b": ["2C-B"],
}
UNIT = (r"\d+(?:[.,]\d+)?\s?(?:–|-|to)?\s?\d*(?:[.,]\d+)?\s?"
        r"(?:ng/m[lL]|µg/m[lL]|μg/m[lL]|ug/m[lL]|mg/[lL]|µg/[lL]|μg/[lL]|ng/g|µg/g|μg/g|"
        r"mg/kg|mg/d[lL]|g/[lL]|g/dL|mmol/[lL]|µmol/[lL]|%\s?(?:COHb|saturation))")
SPECIMEN = (r"\b(blood|femoral|cardiac|heart|peripheral|urine|vitreous|plasma|serum|"
            r"liver|gastric|bile|hair|brain|kidney|lung)\b")
CONTEXT = r"post-?mortem|deceased|autops|fatal|death|died|decedent|cases?|intoxicat|poison|drivers?"
METHOD = (r"LC[-–]?MS/MS|LC[-–]MS|UHPLC|UPLC|GC[-–]MS|GC[-–]FID|head-?space|HPLC|"
          r"immunoassay|ELISA|LC[-–]HRMS|LC[-–]QTOF|QTOF|TLC|thin[- ]layer|"
          r"spectrophotometr|CO-?oximetr")

spec = []
for s in ident:
    names = ALIASES.get(s["id"]) or list({s["en"].split(" (")[0], s["query"]})
    name_re = "(" + "|".join(re.escape(n) for n in names) + ")"
    qn = " OR ".join(f'"{n}"[Title/Abstract]' for n in names[:3])
    spec += [
        dict(target=f"{s['id']}|metabolism", entity=s["id"], field="metabolism",
             query=f"({qn}) AND (metabolism OR metabolite OR metabolites)",
             patterns=[name_re, r"metaboli[sz]ed (to|into|by|via)|(major|main|primary|active|principal) metabolites?|"
                       r"metabolites? (of|include|are|is)|is metaboli[sz]ed|hydroly[sz]ed to|biotransform|metabolic pathway"]),
        dict(target=f"{s['id']}|analytical", entity=s["id"], field="analytical_method",
             query=f"({qn}) AND (forensic OR postmortem OR toxicology) AND (\"mass spectrometry\" OR chromatography OR immunoassay)",
             patterns=[name_re, METHOD, r"determin|quantif|detect|identif|confirm|screen|measur|analy[sz]"],
             allow_methods=True),
        dict(target=f"{s['id']}|concentration", entity=s["id"], field="reported_concentration",
             query=f"({qn}) AND (postmortem OR fatal OR autopsy OR intoxication OR poisoning) AND concentration",
             patterns=[name_re, UNIT, SPECIMEN, CONTEXT]),
    ]
json.dump(spec, open("phase5/spec_substances.json", "w"), indent=1)
print(len(spec))
