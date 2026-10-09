#!/usr/bin/env python3
"""GMT (giyohvand moddalar tahlili) kartalari → «Ilmiy lug‘at» atamalari.

T-GMT-* atamalari `content/pilot/bundle.json` `term_translations` ga
c3fbc3e kommitida to‘g‘ridan-to‘g‘ri qo‘shilgan (generator skripti yo‘q;
manba: Yuldashev Z.A. va hammualliflar, «Giyohvand moddalar tahlili», TFI
2024, muallif ruxsati bilan; barchasi machine_draft). Bu skript faqat
karta → atama bog‘lanishini ANIQ xaritadan yozadi (matndan taxmin yo‘q);
bundle.json ga tegmaydi.

Ishga tushirish (repo ildizida):
    python3 content/tools/gmt_card_terms.py
    python3 content/guidelines/build.py && python3 content/guidelines/validate.py
"""
import card_terms

# Bog‘lanmagan (faqat lug‘atda): MICROSCOPE-SLIDE, IDENTITY-TEST,
# TOXICOMANIA, NARCOLOGICAL-SIGNIFICANCE.
CARD_TERMS = {
    "guideline.chem.gmt_analysis_scheme": [
        "NARCOTIC-DRUG", "PSYCHOTROPIC-SUBSTANCE", "PRECURSOR",
        "MATERIAL-EVIDENCE", "BIOLOGICAL-MATERIAL", "ISOLATION", "EXTRACTION",
        "ISOLATE-EXTRACT", "DRY-RESIDUE", "ACIDIFIED-WATER", "COLOUR-REACTION",
        "PRECIPITATING-REAGENT", "MICROCRYSTAL-TEST", "THIN-LAYER-CHROMATOGRAPHY",
        "SOLVENT-SYSTEM", "REFERENCE-SOLUTION", "GAS-LIQUID-CHROMATOGRAPHY",
        "HIGH-PERFORMANCE-LIQUID-CHROMATOGRAPHY", "CALIBRATION-GRAPH",
        "OPIUM-POPPY",
    ],
    "guideline.chem.gmt_opioids": [
        "OPIUM-ALKALOIDS", "MECONIC-ACID", "MARQUIS-REAGENT", "FR-HDE-REAGENT",
        "MANDELIN-REAGENT", "DRAGENDORFF-REAGENT", "COBALT-THIOCYANATE",
        "ACETIC-ANHYDRIDE", "ALKALINE-MEDIUM", "THIN-LAYER-CHROMATOGRAPHY",
        "VISUALISING-REAGENT", "ABSORPTION-MAXIMUM",
    ],
    "guideline.chem.gmt_cocaine": [
        "COBALT-THIOCYANATE", "ACID-HYDROLYSIS", "QUANTITATIVE-DETERMINATION",
        "CALIBRATION-GRAPH", "HIGH-PERFORMANCE-LIQUID-CHROMATOGRAPHY",
        "THIN-LAYER-CHROMATOGRAPHY", "ACIDIFIED-WATER", "ABSORPTION-MAXIMUM",
    ],
    "guideline.chem.gmt_cannabis": [
        "CANNABIS", "HASHISH-CANNABIS-RESIN", "TETRAHYDROCANNABINOL",
        "COLOUR-REACTION", "THIN-LAYER-CHROMATOGRAPHY", "VISUALISING-REAGENT",
        "REFERENCE-SOLUTION", "MATERIAL-EVIDENCE",
    ],
    "guideline.chem.gmt_phenylalkylamines": [
        "PHENYLALKYLAMINES", "MARQUIS-REAGENT", "PRECIPITATING-REAGENT",
        "RETENTION-TIME", "ACIDIFIED-WATER", "THIN-LAYER-CHROMATOGRAPHY",
        "VISUALISING-REAGENT", "ABSORPTION-MAXIMUM",
    ],
    "guideline.chem.gmt_barbiturates": [
        "BARBITURATES", "COBALT-THIOCYANATE", "MICROCRYSTAL-TEST",
        "RETENTION-TIME", "RETENTION-INDEX",
        "HIGH-PERFORMANCE-LIQUID-CHROMATOGRAPHY", "THIN-LAYER-CHROMATOGRAPHY",
        "ABSORPTION-MAXIMUM", "PSYCHOTROPIC-SUBSTANCE", "CONTROL-LIST",
    ],
    "guideline.chem.gmt_benzodiazepines": [
        "BENZODIAZEPINE-DERIVATIVES", "ACID-HYDROLYSIS", "AMINOBENZOPHENONE",
        "DRAGENDORFF-REAGENT", "THIN-LAYER-CHROMATOGRAPHY", "ACIDIFIED-WATER",
    ],
    "guideline.chem.gmt_precursors": [
        "PRECURSOR", "ACETIC-ANHYDRIDE", "NARCOTIC-DRUG",
        "PSYCHOTROPIC-SUBSTANCE", "ALKALINE-MEDIUM",
        "HIGH-PERFORMANCE-LIQUID-CHROMATOGRAPHY", "CONTROL-LIST",
    ],
    "guideline.chem.gmt_uz_control_lists": [
        "NARCOTIC-DRUG", "PSYCHOTROPIC-SUBSTANCE", "PRECURSOR", "CONTROL-LIST",
        "DRUG-ADDICTION",
    ],
}


def main() -> None:
    known = {t for t in card_terms.bundle_term_ids() if t.startswith("T-GMT-")}
    n = card_terms.write_card_terms(
        {cid: [f"T-GMT-{s}" for s in ids] for cid, ids in CARD_TERMS.items()},
        known,
    )
    linked = {s for ids in CARD_TERMS.values() for s in ids}
    print(f"gmt cards: term_ids written to {n} cards; "
          f"{len(linked)}/{len(known)} T-GMT terms linked")


if __name__ == "__main__":
    main()
