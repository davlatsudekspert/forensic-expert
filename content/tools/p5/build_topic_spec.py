#!/usr/bin/env python3
"""Metodlar, reagentlar, skrining, sud tibbiyoti, gistologiya va postmortem
biokimyo uchun qidiruv spetsifikatsiyasi (B–G bandlar).

Har bir maqsad: (target, entity, field, PMC so‘rovi, regex shartlar).
Regex’lar ataylab qat’iy — nomzod kam bo‘lsa ham, noto‘g‘ri jumla kirmaydi.
"""
import json

FOR = "(forensic OR postmortem OR autopsy OR medicolegal)"
T = []


def t(target, entity, field, query, patterns, allow_methods=False):
    T.append(dict(target=target, entity=entity, field=field, query=query,
                  patterns=patterns, allow_methods=allow_methods))


# ---- B. Analitik metodlar ---------------------------------------------------
GCMS = r"GC[-–]MS|gas chromatography[-–‐ ]mass spectrometry"
LCMS = r"LC[-–]MS/MS|liquid chromatography[-–‐ ]tandem mass spectrometry"
t("met-gcms|principle", "method-gcms", "principle", f'"gas chromatography-mass spectrometry"[Title/Abstract] AND {FOR}',
  [GCMS, r"separat|volatil|thermally stable|electron (impact|ionization)", r"mass spectr|spectra|library|fragment"])
t("met-gcms|limitation", "method-gcms", "limitation", f'"gas chromatography-mass spectrometry" derivatization {FOR}',
  [GCMS, r"derivati[sz]ation|non-?volatile|thermally (labile|unstable)|polar"])
t("met-gcfid|application", "method-gc-fid", "application", '"GC-FID" (ethanol OR alcohol OR volatile) blood',
  [r"GC[-–]FID|flame ionization detect", r"ethanol|alcohol|volatile"], True)
t("met-hsgc|application", "method-headspace-gc", "application", '"headspace gas chromatography" (ethanol OR alcohol OR volatile)',
  [r"head-?space", r"gas chromatograph|\bGC\b", r"ethanol|alcohol|volatile"])
t("met-lcmsms|principle", "method-lcmsms", "principle", f'"LC-MS/MS"[Title/Abstract] AND {FOR} AND (sensitivity OR selectivity)',
  [LCMS, r"sensitiv|selectiv|specific", r"(is|are|offers|provides|allows|enables|has become)\b"])
t("met-lcmsms|matrix", "method-lcmsms", "limitation", '"matrix effect" "LC-MS/MS" (blood OR postmortem)',
  [r"matrix effects?", r"ion (suppression|enhancement)|suppress|enhance"])
t("met-hplc|application", "method-hplc", "application", f'HPLC ("diode array" OR "UV detection") {FOR}',
  [r"\bHPLC\b|high[- ]performance liquid chromatography", r"diode[- ]array|\bDAD\b|UV|ultraviolet"])
t("met-tlc|application", "method-tlc", "application", '"thin-layer chromatography" (drugs OR toxicology) screening',
  [r"thin[- ]layer chromatography|\bTLC\b", r"screen|identif|simple|inexpensive|low[- ]cost|rapid"])
t("met-uvvis|application", "method-uvvis", "application", f'spectrophotometric (carboxyhemoglobin OR "UV-Vis") {FOR}',
  [r"spectrophotometr|UV[-–/ ]?Vis", r"determin|measur|quantif"])
t("met-immunoassay|principle", "method-immunoassay", "principle", 'immunoassay antibody drugs screening principle',
  [r"immunoassays?", r"antibod", r"bind|antigen|competit"])
t("met-spectroscopy|application", "method-spectroscopy", "application", '(Raman OR FTIR OR "infrared spectroscopy") (seized drugs OR forensic)',
  [r"Raman|FT-?IR|infrared spectroscop", r"seized|street|illicit|drug|forensic", r"identif|non-?destructive|rapid|screen"])
t("met-hrms|screening", "method-hrms", "application", '"high-resolution mass spectrometry" (screening OR untargeted) toxicology',
  [r"high[- ]resolution mass spectrometry|HRMS|QTOF|Orbitrap", r"screen|untargeted|non-?targeted|retrospective"])
t("met-spe|principle", "method-spe", "principle", '"solid-phase extraction" blood drugs forensic',
  [r"solid[- ]phase extraction|\bSPE\b", r"clean|extract|matri|interfer|concentrat"])
t("met-lle|principle", "method-lle", "principle", '"liquid-liquid extraction" blood drugs toxicology',
  [r"liquid[–-]liquid extraction|\bLLE\b", r"extract|solvent|organic"])
t("met-ppt|principle", "method-protein-precipitation", "principle", '"protein precipitation" blood toxicology LC-MS/MS',
  [r"protein precipitation", r"simple|fast|rapid|acetonitrile|methanol|matrix"])
t("met-quechers|application", "method-quechers", "application", 'QuEChERS (blood OR postmortem OR toxicology)',
  [r"QuEChERS", r"blood|post-?mortem|toxicolog|tissue"])
t("met-deriv|principle", "method-derivatization", "principle", 'derivatization GC-MS (drugs OR toxicology) volatility',
  [r"derivati[sz]ation", r"volatil|thermal stabilit|chromatographic|polar"])
t("met-calibration|principle", "method-calibration", "principle", '"calibration curve" "forensic toxicology" linearity',
  [r"calibration (curve|model|range)", r"linear|weight|range|matrix-matched"])
t("met-validation|principle", "method-validation", "principle", '"method validation" "forensic toxicology"',
  [r"validat", r"selectivity|accuracy|precision|limit of detection|LOD|bias|carryover|matrix", r"forensic|toxicolog"])
t("met-uncertainty|principle", "method-uncertainty", "principle", '"measurement uncertainty" (forensic OR toxicology OR blood alcohol)',
  [r"measurement uncertainty|uncertainty of measurement", r"estimat|evaluat|report|budget|interval|confidence"])
t("met-qc|principle", "method-qc", "principle", '"quality control" samples "forensic toxicology"',
  [r"quality control", r"samples?|materials?", r"accura|precis|batch|run|acceptance"])
t("met-idcriteria|principle", "method-identification-criteria", "principle", '"identification criteria" "retention time" "ion ratio"',
  [r"retention time", r"ion ratios?|qualifier", r"criteri|toleran|identif"])
t("met-postmortem-redistribution|limitation", "method-validation", "limitation", '"postmortem redistribution" toxicology',
  [r"post-?mortem redistribution", r"concentration|central|peripheral|femoral|site"])

# ---- C. Reagentlar (rang testlari va TLC reagentlari) ------------------------
COMP = r"compos|consist|prepar|contain|mixture of|solution of|made (up )?of|comprised"
for rid, name, chem in [
    ("rea-marquis", "Marquis", r"formaldehyde|sulfuric|sulphuric"),
    ("rea-mecke", "Mecke", r"selen|sulfuric|sulphuric"),
    ("rea-mandelin", "Mandelin", r"vanad|sulfuric|sulphuric"),
    ("rea-simon", "Simon", r"nitroprusside|acetaldehyde|carbonate"),
    ("rea-scott", "Scott", r"cobalt|thiocyanate"),
    ("rea-cobalt-thiocyanate", "cobalt thiocyanate", r"cobalt|thiocyanate|cocaine"),
    ("rea-duquenois", "Duquenois", r"vanillin|acetaldehyde|hydrochloric|chloroform"),
    ("rea-ehrlich", "Ehrlich", r"dimethylaminobenzaldehyde|DMAB|indole"),
    ("rea-dragendorff", "Dragendorff", r"bismuth|iodide|alkaloid"),
    ("rea-fast-blue-bb", "Fast Blue BB", r"cannabinoid|THC|diazonium"),
    ("rea-ninhydrin", "ninhydrin", r"amine|amino|purple|Ruhemann"),
    ("rea-iodoplatinate", "iodoplatinate", r"platin|iodide|alkaloid|nitrogen"),
    ("rea-trinder", "Trinder", r"ferric|iron|salicyl"),
]:
    t(f"{rid}|composition", rid, "composition_statement", f'"{name}" (reagent OR test) (drugs OR forensic OR toxicology)',
      [rf"{name}(’s|'s)?\s+(reagent|test)", COMP, chem], True)
    t(f"{rid}|use", rid, "use_context", f'"{name}" (reagent OR test) presumptive OR colour OR color',
      [rf"{name}(’s|'s)?\s+(reagent|test)", r"presumptive|colou?r|spot|screen|detect|indicat|purple|violet|blue|orange|red"])

# ---- D. Skrining / ekspress testlar ------------------------------------------
t("scr-fts|performance", "scr-fentanyl-test-strips", "performance", '"fentanyl test strips"',
  [r"fentanyl test strips?|\bFTS\b", r"sensitiv|specific|false|detect|cross-?reactiv"])
t("scr-fts|limitation", "scr-fentanyl-test-strips", "limitation", '"fentanyl test strips" analogs OR "false positive"',
  [r"fentanyl test strips?|\bFTS\b", r"false[- ]positive|false[- ]negative|analog|methamphetamine|MDMA|diphenhydramine|cannot|not detect|quantif"])
t("scr-benzo-ia|limitation", "scr-immunoassay-benzodiazepines", "limitation", 'benzodiazepine immunoassay (lorazepam OR clonazepam) "false negative" OR glucuronide',
  [r"benzodiazepine", r"immunoassay", r"false[- ]negative|glucuronid|not (be )?detect|poor(ly)? cross|low cross|lorazepam|clonazepam"])
t("scr-amph-ia|limitation", "scr-immunoassay-amphetamines", "limitation", 'amphetamine immunoassay "false positive"',
  [r"amphetamine", r"immunoassay|screen", r"false[- ]positive"])
t("scr-opiate-ia|limitation", "scr-immunoassay-opiates", "limitation", 'opiate immunoassay oxycodone OR fentanyl cross-reactivity',
  [r"opiate", r"immunoassay|screen", r"oxycodone|fentanyl|synthetic|cross-?reactiv|not detect"])
t("scr-cannabis-ia|limitation", "scr-immunoassay-cannabinoids", "limitation", 'cannabinoid immunoassay synthetic cannabinoids OR "false positive" urine',
  [r"cannabinoid|THC", r"immunoassay|screen", r"false[- ]positive|synthetic cannabinoids?|not detect|cross-?reactiv|efavirenz|pantoprazole|ibuprofen"])
t("scr-fentanyl-ia|application", "scr-immunoassay-fentanyl", "limitation", 'fentanyl immunoassay analogs cross-reactivity urine',
  [r"fentanyl", r"immunoassay", r"analog|cross-?reactiv|norfentanyl|false"])
t("scr-oral-fluid|limitation", "scr-oral-fluid-poc", "limitation", '"oral fluid" (point-of-care OR roadside OR on-site) drug test sensitivity',
  [r"oral fluid", r"point[- ]of[- ]care|roadside|on-?site|rapid", r"sensitiv|specific|false|confirm"])
t("scr-colour|limitation", "scr-colour-tests", "limitation", '"color test" OR "colour test" presumptive "false positive" drugs',
  [r"colou?r (tests?|reagents?)|spot tests?", r"false[- ]positive|subjective|interfer|not specific|non-?specific|presumptive"])
t("scr-ia-confirm|principle", "scr-immunoassay-drugs", "confirmation_requirement", 'immunoassay positive confirmed "mass spectrometry" urine drug testing',
  [r"immunoassay|screen(ing)? (test|result)", r"confirm", r"mass spectrometr|GC[-–]MS|LC[-–]MS"])

# ---- E. Sud tibbiyoti ---------------------------------------------------------
FMQ = [
 ("fm-death-investigation", "definition", '"death investigation"[Title/Abstract] scene', [r"death (scene )?investigation", r"scene|circumstanc|history|multidisciplin|autopsy"]),
 ("fm-cause-manner", "definition", '"manner of death" "cause of death" definition', [r"manner of death", r"natural|accident|suicide|homicide|undetermined", r"cause of death"]),
 ("fm-mechanism-of-death", "definition", '"mechanism of death" "cause of death"', [r"mechanism of death", r"cause of death|physiolog|derangement"]),
 ("fm-postmortem-changes", "definition", '"postmortem changes"[Title/Abstract] early late', [r"post-?mortem changes", r"early|late|livor|rigor|algor|decompos|putref"]),
 ("fm-rigor-mortis", "definition", '"rigor mortis"[Title/Abstract] muscle ATP', [r"rigor mortis", r"ATP|muscle|stiff|rigid|actin|myosin"]),
 ("fm-decomposition", "definition", 'decomposition stages human remains forensic', [r"decomposition", r"stages?|fresh|bloat|active decay|advanced decay|skeleton"]),
 ("fm-pmi-methods", "limitation", '"postmortem interval" estimation methods accuracy', [r"post-?mortem interval|PMI", r"accura|precis|error|uncertain|limit|variab"]),
 ("fm-blunt-trauma", "definition", '"blunt force" injuries abrasion contusion laceration', [r"blunt", r"abrasion|contusion|bruis|laceration"]),
 ("fm-sharp-trauma", "definition", '"sharp force" injuries "stab wound" "incised wound"', [r"incised wound|stab wound|sharp force", r"length|depth|deeper|longer|edge"]),
 ("fm-firearm", "definition", 'gunshot wound entrance exit range forensic', [r"gunshot|firearm", r"entr(ance|y)|exit|range|soot|stippling|tattoo"]),
 ("fm-asphyxia", "definition", 'asphyxia forensic classification hanging strangulation', [r"asphyxi", r"hanging|strangulation|smothering|suffocation|choking|compression"]),
 ("fm-drowning", "limitation", 'drowning diagnosis diatom test forensic', [r"drowning", r"diatom|diagnos|exclusion|difficult|challeng"]),
 ("fm-burns", "marker", 'fire death carboxyhemoglobin soot airway vital', [r"soot|carboxyh(a)?emoglobin|COHb", r"airway|trachea|alive|vital|inhal"]),
 ("fm-electrical", "definition", '"electrical injury" OR electrocution forensic "current mark"', [r"electr", r"current mark|electric mark|entry|exit|burn"]),
 ("fm-hypothermia", "marker", 'hypothermia death "Wischnewski" gastric', [r"hypotherm", r"Wischnewski|gastric (erosions|mucosa|lesions)|frost"]),
 ("fm-hyperthermia", "definition", 'hyperthermia OR "heat stroke" death forensic autopsy', [r"hypertherm|heat ?stroke", r"death|autopsy|diagnos|body temperature|non-?specific"]),
 ("fm-anthropology", "definition", '"forensic anthropology"[Title/Abstract] skeletal remains', [r"forensic anthropolog", r"skelet|remains|biological profile|identif"]),
 ("fm-age-estimation", "limitation", 'age estimation skeletal OR dental forensic accuracy', [r"age estimat", r"accura|error|reliab|method|interval"]),
 ("fm-sex-estimation", "marker", 'sex estimation pelvis skull forensic accuracy', [r"sex (estimat|determin)", r"pelvis|pelvic|os coxae|skull|cranial|accura"]),
 ("fm-stature-estimation", "marker", 'stature estimation long bones regression forensic', [r"stature", r"long bones?|femur|tibia|regression|formula"]),
 ("fm-odontology", "definition", '"forensic odontology" identification dental records', [r"odontolog|dental", r"identif|records|comparison|ante-?mortem"]),
 ("fm-dvi", "definition", '"disaster victim identification" Interpol primary identifiers', [r"disaster victim identification|\bDVI\b", r"DNA|fingerprint|dental|primary identif|Interpol"]),
 ("fm-pm-imaging", "definition", '"postmortem computed tomography" autopsy complement', [r"post-?mortem (computed tomography|CT|imaging)|PMCT|virtopsy", r"autopsy|complement|non-?invasive|detect"]),
]
for ent, field, q, pats in FMQ:
    t(f"{ent}|{field}", ent, field, q, pats)

# ---- F. Sud gistologiyasi ----------------------------------------------------
HIS = [
 ("his-sampling", "principle", 'forensic histology sampling autopsy tissue samples', [r"histolog", r"sampl", r"autops|tissue|organ"]),
 ("his-fixation", "principle", 'formalin fixation tissue histology autolysis', [r"formalin|fixation|fixed", r"autoly|tissue|preserv|morpholog"]),
 ("his-he-stain", "principle", 'hematoxylin eosin staining forensic histology', [r"h(a)?ematoxylin|H&E", r"eosin|stain"]),
 ("his-ihc", "application", 'immunohistochemistry forensic pathology markers wound OR myocardial', [r"immunohistochem|IHC", r"forensic|post-?mortem|autops", r"marker|express|detect"]),
 ("his-wound-vitality", "limitation", 'wound vitality age estimation histology forensic', [r"vital|wound age", r"histolog|immunohistochem|inflammat|neutrophil|leukocyt", r"estimat|determin|limit|difficult|challeng"]),
 ("his-mi-early", "marker", 'early myocardial infarction postmortem histology markers', [r"myocardial (infarction|ischemi|ischaemi)", r"early|histolog|immunohistochem|marker|C5b|fibronectin|troponin"]),
 ("his-putrefaction-artifact", "limitation", 'putrefaction autolysis artifacts histology postmortem', [r"autoly|putrefact|decompos", r"artifact|artefact|interpret|histolog"]),
 ("his-fat-embolism", "marker", 'fat embolism postmortem histology "Oil Red O" OR Sudan', [r"fat embolism", r"Oil Red O|Sudan|lung|pulmonary|stain"]),
 ("his-drowning", "limitation", 'drowning lung histology forensic emphysema aquosum', [r"drowning", r"histolog|lung|alveol|emphysema"]),
 ("his-sids", "limitation", 'histology sudden death heart conduction system autopsy', [r"histolog", r"sudden (cardiac )?death", r"heart|cardiac|myocard"]),
]
for ent, field, q, pats in HIS:
    t(f"{ent}|{field}", ent, field, q, pats)

# ---- G. Postmortem biokimyo --------------------------------------------------
BIO = [
 ("bio-vitreous-sodium-chloride", "marker", 'vitreous sodium chloride dehydration postmortem', [r"vitreous", r"sodium|chloride", r"dehydrat|hypernatr|stable"]),
 ("bio-vitreous-urea-creatinine", "marker", 'vitreous urea creatinine postmortem renal', [r"vitreous", r"urea|creatinine", r"renal|kidney|uremi|stable|antemortem|ante-mortem"]),
 ("bio-vitreous-glucose", "limitation", 'vitreous glucose postmortem hyperglycemia decrease', [r"vitreous", r"glucose", r"decreas|glycoly|hyperglyc|diabet|unreliable|cannot"]),
 ("bio-bhb-ketoacidosis", "marker", 'beta-hydroxybutyrate postmortem ketoacidosis', [r"hydroxybutyr|BHB", r"ketoacidosis|ketosis|diabet|alcohol"]),
 ("bio-hba1c", "marker", 'HbA1c postmortem blood diabetes', [r"HbA1c|glycated h(a)?emoglobin", r"post-?mortem|stable|antemortem|diabet"]),
 ("bio-tryptase", "marker", 'postmortem tryptase anaphylaxis', [r"tryptase", r"anaphyla", r"post-?mortem|elevat|limit|interpret"]),
 ("bio-crp-procalcitonin", "marker", 'postmortem procalcitonin OR "C-reactive protein" sepsis', [r"procalcitonin|C-reactive protein|\bCRP\b", r"sepsis|infection|inflamm", r"post-?mortem"]),
 ("bio-cardiac-markers", "limitation", 'postmortem troponin OR NT-proBNP cardiac death', [r"troponin|NT-?proBNP|BNP", r"post-?mortem", r"cardiac|heart|myocard"]),
 ("bio-insulin-cpeptide", "marker", 'insulin C-peptide ratio postmortem insulin poisoning vitreous', [r"insulin", r"C-?peptide", r"ratio|exogenous|poison|overdose"]),
 ("bio-csf", "application", 'cerebrospinal fluid postmortem biochemistry', [r"cerebrospinal fluid|\bCSF\b", r"post-?mortem", r"biochem|marker|analy|concentration"]),
 ("bio-preanalytical-hemolysis", "limitation", 'postmortem blood hemolysis biochemistry interference', [r"h(a)?emoly", r"post-?mortem", r"interfer|unreliab|limit|affect"]),
 ("bio-sampling-site", "limitation", 'postmortem blood sampling site femoral cardiac toxicology', [r"femoral|peripheral", r"cardiac|heart|central", r"sampl|site|preferred|recommend|differ"]),
 ("bio-ethanol-neoformation", "limitation", 'postmortem ethanol production putrefaction neoformation', [r"ethanol|alcohol", r"post-?mortem (production|formation|synthesis)|neo-?formation|putrefact|microbial|endogenous"]),
 ("bio-cocaine-stability", "limitation", 'cocaine stability blood fluoride benzoylecgonine storage', [r"cocaine", r"stabil|degrad|hydroly", r"fluoride|storage|temperature|benzoylecgonine"]),
 ("bio-temperature-effect", "limitation", 'temperature effect postmortem biochemical markers', [r"temperature", r"post-?mortem", r"marker|potassium|biochem|concentration|degrad"]),
]
for ent, field, q, pats in BIO:
    t(f"{ent}|{field}", ent, field, q, pats)

json.dump(T, open("phase5/spec_topics.json", "w"), indent=1)
print(len(T))
