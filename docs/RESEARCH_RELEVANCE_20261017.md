# Tadqiqotlar kutubxonasi: mavzuga aloqadorlik tekshiruvi (2026-10-17)

Skript: `content/tools/research_relevance.py` (qoidalar: sarlavhadagi kalit
so‘zlar + jurnal nomi). Qaror qoidasi: sarlavhada sud tibbiyoti / toksikologiya /
sud kimyosi / huquq belgisi bo‘lsa yoki jurnal sohaviy bo‘lsa — **qoldiriladi**;
aks holda aniq aloqasiz mavzu (klinik terapiya sinovi, onkologiya, allergologiya,
oziq-ovqat/veterinariya, atrof-muhit, mamlakat sharhi) — **paketdan chiqariladi**;
qolganlari — **shubhali** (o‘chirilmaydi, ekspert ko‘rib chiqadi).

Natija: jami 882 ta yozuv (oldin chiqarilganlar bilan) —
qoldirildi 692, chiqarildi 43, shubhali 147.
Chiqarilganlar ro‘yxati mashinada o‘qiladigan ko‘rinishda:
`content/pilot/research_excluded.json` (paket qayta yig‘ilganda ham qaytib kirmaydi).

## Chiqarilgan (aniq aloqasiz)

| ID | Sarlavha | Jurnal | Sabab |
|---|---|---|---|
| `RS-2e9b4a506560` | Determination of emerging chlorinated byproducts of diazepam in drinking water | Chemosphere | atrof-muhit / biodegradatsiya |
| `RS-c12efab77548` | Formation of chloroform and chlorinated organics by free-chlorine-mediated oxidation of triclosan | Environmental science & technology | atrof-muhit / biodegradatsiya |
| `RS-ce512277fa21` | The biotransformation of ibuprofen to trihydroxyibuprofen in activated sludge and by Variovorax Ibu-1 | Biodegradation | atrof-muhit / biodegradatsiya |
| `RS-eaba2aaaed1d` | The Determination of Polycyclic Aromatic Hydrocarbons (PAHs) with HPLC-DAD-FLD and GC-MS Techniques in the Dissolved and Particulate Phase of Road-Tunnel Wash Water: A Case Study for Cross-Array Comparisons and Applications | Toxics | atrof-muhit / biodegradatsiya |
| `RS-1734eea85656` | Isolation, purification, and characterization of immunosuppressive compounds from tripterygium: triptolide and tripdiolide | International journal of immunopharmacology | fundamental kimyo/biotexnologiya (sud amaliyotiga aloqasiz) |
| `RS-f428f4ec942c` | Recent Advances in Quenchbody, a Fluorescent Immunosensor | Sensors (Basel, Switzerland) | fundamental kimyo/biotexnologiya (sud amaliyotiga aloqasiz) |
| `RS-0fdbb5b6573f` | HIV: treating Pneumocystis pneumonia (PCP) | BMJ clinical evidence | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-101341659a55` | Semaglutide and Nonarteritic Anterior Ischemic Optic Neuropathy | JAMA ophthalmology | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-17aeac7917f3` | Twice-Yearly Lenacapavir for HIV Prevention in Men and Gender-Diverse Persons | The New England journal of medicine | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-41f046804817` | Ibuprofen use and clinical outcomes in COVID-19 patients | Clinical microbiology and infection : the official publication of the European Society of Clinical Microbiology and Infectious Diseases | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-4e9dd027238b` | Triple Inhaled Therapy at Two Glucocorticoid Doses in Moderate-to-Very-Severe COPD | The New England journal of medicine | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-4ff62aad9d45` | Metformin induces lipogenic differentiation in myofibroblasts to reverse lung fibrosis | Nature communications | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-7a8db085cee8` | Colchicine and gout | Arthritis and rheumatism | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-8c2dc51e79e7` | Allergic Rhinitis and Its Impact on Asthma (ARIA)-EAACI Guidelines-2024-2025 Revision: Part I-Guidelines on Intranasal Treatments | Allergy | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-9215ad4363dc` | Cagrilintide-Semaglutide in Adults with Overweight or Obesity and Type 2 Diabetes | The New England journal of medicine | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-b2dc948cc4ab` | Sepsis in patients who are immunocompromised: diagnostic challenges and future therapies | The Lancet. Respiratory medicine | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-eb411790d89f` | Heterogeneity of multiple sclerosis lesions: implications for the pathogenesis of demyelination | Annals of neurology | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-f0817bcfb48f` | Diphenhydramine photoallergy | Archives of dermatology | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik) |
| `RS-9c5cfb191761` | Management of MDA-5 antibody positive clinically amyopathic dermatomyositis associated interstitial lung disease: A systematic review | Seminars in arthritis and rheumatism | klinik fan (tropik/revmatologik kasallik) |
| `RS-aa2b4fe3959a` | The Mbam drainage system and onchocerciasis transmission post ivermectin mass drug administration (MDA) campaign, Cameroon | PLoS neglected tropical diseases | klinik fan (tropik/revmatologik kasallik) |
| `RS-02c2e18ff695` | Efficacy and safety of pregabalin in eye pain: A systematic review | Medicine | klinik terapiya sinovi (davolash samaradorligi) |
| `RS-8211c3617b0a` | Randomized trial of TAS-102 for refractory metastatic colorectal cancer | The New England journal of medicine | klinik terapiya sinovi (davolash samaradorligi) |
| `RS-a566cafe4342` | B-cell depletion with obinutuzumab for the treatment of proliferative lupus nephritis: a randomised, double-blind, placebo-controlled trial | Annals of the rheumatic diseases | klinik terapiya sinovi (davolash samaradorligi) |
| `RS-b465cc85bf29` | Lenvatinib plus pembrolizumab versus lenvatinib plus placebo for advanced hepatocellular carcinoma (LEAP-002): a randomised, double-blind, phase 3 trial | The Lancet. Oncology | klinik terapiya sinovi (davolash samaradorligi) |
| `RS-c6b081ea4f6f` | Efficacy and safety of once-weekly semaglutide versus once-daily sitagliptin as an add-on to metformin, thiazolidinediones, or both, in patients with type 2 diabetes (SUSTAIN 2): a 56-week, double-blind, phase 3a, randomised trial | The lancet. Diabetes & endocrinology | klinik terapiya sinovi (davolash samaradorligi) |
| `RS-c7cbbf3f8a54` | Measuring Ambulation, Motor, and Behavioral Outcomes with Post-stroke Fluoxetine in Tanzania: The Phase II MAMBO Trial | The American journal of tropical medicine and hygiene | klinik terapiya sinovi (davolash samaradorligi) |
| `RS-eee65ab3d77e` | Switch to fulvestrant and palbociclib versus no switch in advanced breast cancer with rising ESR1 mutation during aromatase inhibitor and palbociclib therapy (PADA-1): a randomised, open-label, multicentre, phase 3 trial | The Lancet. Oncology | klinik terapiya sinovi (davolash samaradorligi) |
| `RS-fee1a99c5a05` | The use of intravenous lidocaine for postoperative pain and recovery: international consensus statement on efficacy and safety | Anaesthesia | klinik terapiya sinovi (davolash samaradorligi) |
| `RS-4ee9496a85a0` | Sudan | Department of State publication. Background notes series | mamlakat sharhi (mavzuga aloqasiz) |
| `RS-51bc7bd6ad31` | Cancer initiatives in Sudan | Annals of oncology : official journal of the European Society for Medical Oncology | mamlakat sharhi (mavzuga aloqasiz) |
| `RS-c471187e6a51` | COVID-19 in Sudan | Journal of infection in developing countries | mamlakat sharhi (mavzuga aloqasiz) |
| `RS-28297e878824` | Ceramide plays a prominent role in MDA-7/IL-24-induced cancer-specific apoptosis | Journal of cellular physiology | onkologiya |
| `RS-dc1842852526` | Methadone for cancer pain | The Cochrane database of systematic reviews | onkologiya |
| `RS-213bb0316af6` | An Integrated QuEChERS LC-MS/MS Method for Screening, Confirmation, and Quantification of Nitroimidazole Residues in Food | Journal of AOAC International | oziq-ovqat / veterinariya / hayvonlar |
| `RS-4423264b1d28` | Relationship between the characteristics of rigor-mortis-related actomyosin and muscle fiber types in the ordinary muscle of various fishes | Journal of the science of food and agriculture | oziq-ovqat / veterinariya / hayvonlar |
| `RS-7aa1d9e96f3c` | Energy Processes During Rigor Mortis in the Adductor Muscle of the Lion's Paw Scallop (Nodipecten subnodosus): Effects of Seasonality and Storage Temperature | Animals : an open access journal from MDPI | oziq-ovqat / veterinariya / hayvonlar |
| `RS-7ef099c4dfae` | Pesticide Residue Analysis in Fruit- and Vegetable-Based Baby Foods Using GC-Orbitrap MS | Journal of AOAC International | oziq-ovqat / veterinariya / hayvonlar |
| `RS-9a74f454f698` | Chlorpyrifos and wildlife | The Veterinary record | oziq-ovqat / veterinariya / hayvonlar |
| `RS-23814029a47c` | Probing toluene catalytic removal mechanism over supported Pt nano- and single-atom-catalyst | Journal of hazardous materials | sanoat kimyosi / kataliz (sud amaliyotiga aloqasiz) |
| `RS-6aa0d9d81828` | Residual Organic Solvent Analysis in Nanoformulations Using Headspace Gas Chromatography: Version 1 |  | sanoat kimyosi / kataliz (sud amaliyotiga aloqasiz) |
| `RS-6ebb229b61ec` | Headspace gas chromatography for the determination of volatile methylsiloxanes in personal care products | Analytical and bioanalytical chemistry | sanoat kimyosi / kataliz (sud amaliyotiga aloqasiz) |
| `RS-80f3fb4786f3` | Dissociative Adsorption of Acetone on Platinum Single-Crystal Electrodes | The journal of physical chemistry. C, Nanomaterials and interfaces | sanoat kimyosi / kataliz (sud amaliyotiga aloqasiz) |
| `RS-ecd12a271e4a` | First-Principles-Based Multiscale Modelling of Nonoxidative Butane Dehydrogenation on Cr(2)O(3)(0001) | ACS catalysis | sanoat kimyosi / kataliz (sud amaliyotiga aloqasiz) |

## Shubhali (o‘chirilmagan — ekspert ko‘rib chiqishi kerak)

| ID | Sarlavha | Jurnal | Sabab |
|---|---|---|---|
| `RS-47115dbc2637` | APPLICATION OF THE INAA METHOD FOR THE DETECTION OF SEIZED ILLEGALLY
                        TRANSPORTED DRUGS: RELEVANT RADIATION PROTECTION ASPECTS | RAD Conference Proceedings | faqat umumiy analitik/klinik so‘z |
| `RS-3db6d417a768` | Application of the INAA methods for the detection of seized illegally transported drugs: Relevant radiation protection aspects | Book of Abstracts | faqat umumiy analitik/klinik so‘z |
| `RS-c3265b16d8f8` | Applications of the ninhydrin reaction for analysis of amino acids, peptides, and proteins to agricultural and biomedical sciences | Journal of agricultural and food chemistry | faqat umumiy analitik/klinik so‘z |
| `RS-0c5a48563820` | Bioautography detection in thin-layer chromatography | Journal of chromatography. A | faqat umumiy analitik/klinik so‘z |
| `RS-2898ffef705e` | Chromatography |  | faqat umumiy analitik/klinik so‘z |
| `RS-c0b60ca5f101` | Clinical pharmacokinetics of sertraline | Clinical pharmacokinetics | faqat umumiy analitik/klinik so‘z |
| `RS-32ab01cd50ea` | Commonly prescribed medications and potential false-positive urine drug screens | American journal of health-system pharmacy : AJHP : official journal of the American Society of Health-System Pharmacists | faqat umumiy analitik/klinik so‘z |
| `RS-bf133bf6c5d9` | Derivatization of steroids in biological samples for GC-MS and LC-MS analyses | Bioanalysis | faqat umumiy analitik/klinik so‘z |
| `RS-05c3d568f7ae` | Development of a rapid RP-HPLC method for the determination of clonazepam in human plasma | Journal of pharmaceutical and biomedical analysis | faqat umumiy analitik/klinik so‘z |
| `RS-d5f3875c9c67` | Disease burden attributable to intimate partner violence against females and sexual violence against children in 204 countries and territories, 1990-2023: a systematic analysis for the Global Burden of Disease Study 2023 | Lancet (London, England) | faqat umumiy analitik/klinik so‘z |
| `RS-19ac2f88b0f9` | Distribution of diazepam and nordiazepam between plasma and whole blood and the influence of hematocrit | Therapeutic drug monitoring | faqat umumiy analitik/klinik so‘z |
| `RS-aa62729096bb` | GC-MS studies on the regioisomeric methoxy-methyl-phenethylamines related to MDEA, MDMMA, and MBDB | Journal of chromatographic science | faqat umumiy analitik/klinik so‘z |
| `RS-16dcb160fb38` | High-Resolution Mass Spectrometry for Untargeted Drug Screening | Methods in molecular biology (Clifton, N.J.) | faqat umumiy analitik/klinik so‘z |
| `RS-5df4376b80f5` | Immunochemical detection of antibiotics and sulfonamides | The Analyst | faqat umumiy analitik/klinik so‘z |
| `RS-e5cfea6610a6` | Iso-glucuronides | Current drug metabolism | faqat umumiy analitik/klinik so‘z |
| `RS-5c94cfab67a1` | Major adverse cardiac events with haloperidol: A meta-analysis | PloS one | faqat umumiy analitik/klinik so‘z |
| `RS-2319d530317e` | Meta-analysis examining the epidemiology of clozapine-associated neutropenia | Acta psychiatrica Scandinavica | faqat umumiy analitik/klinik so‘z |
| `RS-351dcf17e1a3` | Metabolic profiles and screening tactics for MDMB-4en-PINACA in human urine and serum samples | Journal of pharmaceutical and biomedical analysis | faqat umumiy analitik/klinik so‘z |
| `RS-633cd19d13d4` | Metabolomics by Gas Chromatography-Mass Spectrometry: Combined Targeted and Untargeted Profiling | Current protocols in molecular biology | faqat umumiy analitik/klinik so‘z |
| `RS-5c7810464f76` | Multiplex cerebrospinal fluid proteomics identifies biomarkers for diagnosis and prediction of Alzheimer's disease | Nature human behaviour | faqat umumiy analitik/klinik so‘z |
| `RS-b69678966bc9` | New Method To Estimate Total Polyphenol Excretion: Comparison of Fast Blue BB versus Folin-Ciocalteu Performance in Urine | Journal of agricultural and food chemistry | faqat umumiy analitik/klinik so‘z |
| `RS-26cfa6763e27` | On the mammalian acetone metabolism: from chemistry to clinical implications | Biochimica et biophysica acta | faqat umumiy analitik/klinik so‘z |
| `RS-4877318d2282` | Optimal dose of selective serotonin reuptake inhibitors, venlafaxine, and mirtazapine in major depression: a systematic review and dose-response meta-analysis | The lancet. Psychiatry | faqat umumiy analitik/klinik so‘z |
| `RS-ab3f4613a907` | Pharmacokinetics of mitragynine in man | Drug design, development and therapy | faqat umumiy analitik/klinik so‘z |
| `RS-1be7d3ae77e2` | Potential for Underestimation of d-Methylphenidate Bioavailability Using Chiral Derivatization/Gas Chromatography | Drug metabolism and disposition: the biological fate of chemicals | faqat umumiy analitik/klinik so‘z |
| `RS-e7c690fcce06` | The effect of diazinon on blood glucose homeostasis: a systematic and meta-analysis study | Environmental science and pollution research international | faqat umumiy analitik/klinik so‘z |
| `RS-0eacda762e98` | The effect of tramadol on blood glucose concentrations: a systematic review | Expert review of clinical pharmacology | faqat umumiy analitik/klinik so‘z |
| `RS-990659d24033` | The efficacy of lamotrigine in bipolar disorder: A systematic review and meta-analysis | Bipolar disorders | faqat umumiy analitik/klinik so‘z |
| `RS-ca60a441d60e` | The interference of baicalein with uric acid detected by the enzymatic method and its correction method | Scientific reports | faqat umumiy analitik/klinik so‘z |
| `RS-f5b96b9e93e0` | The safety and tolerability of venlafaxine hydrochloride: analysis of the clinical trials database | Journal of clinical psychopharmacology | faqat umumiy analitik/klinik so‘z |
| `RS-e0f8534654e4` | The safety of olanzapine in young children: a systematic review and meta-analysis | Drug safety | faqat umumiy analitik/klinik so‘z |
| `RS-c25c277c7708` | Tissue Sampling and Processing for Histopathology Evaluation | Methods in molecular biology (Clifton, N.J.) | faqat umumiy analitik/klinik so‘z |
| `RS-7eabe17c993e` | Tramadol (with or without acetaminophen) efficacy and harm: Systematic review and meta-analysis | Canadian family physician Medecin de famille canadien | faqat umumiy analitik/klinik so‘z |
| `RS-a0e2d86aaf27` | Unusual glucuronides | Drug metabolism and disposition: the biological fate of chemicals | faqat umumiy analitik/klinik so‘z |
| `RS-7014cda3cacb` | Urine Drug Tests: Ordering and Interpreting Results | American family physician | faqat umumiy analitik/klinik so‘z |
| `RS-91952f13b0ee` | Urine drug screening: practical guide for clinicians | Mayo Clinic proceedings | faqat umumiy analitik/klinik so‘z |
| `RS-ca964e71468b` | [Detection of nordiazepam in the hair of drug addicts] | Annales pharmaceutiques francaises | faqat umumiy analitik/klinik so‘z |
| `RS-d204b018e6db` | [Progress on Determination and Analysis of Zopiclone in Biological Samples] | Fa yi xue za zhi | faqat umumiy analitik/klinik so‘z |
| `RS-21b398fc6216` | [Study on electrical current mark with environmental scanning electron microscopy and energy dispersive X-ray microanalyser] | Fa yi xue za zhi | faqat umumiy analitik/klinik so‘z |
| `RS-08aa23159b30` | Biomarkers for the Diagnosis of Neonatal Sepsis | Clinics in perinatology | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik), lekin sud tibbiyoti mavzusiga bog‘langan |
| `RS-67240ddb66d2` | Diagnostic performances of procalcitonin and C-reactive protein for sepsis: a systematic review and meta-analysis | European journal of emergency medicine : official journal of the European Society for Emergency Medicine | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik), lekin sud tibbiyoti mavzusiga bog‘langan |
| `RS-148ae1faf257` | Mis-spliced transcripts generate de novo proteins in TDP-43-related ALS/FTD | Science translational medicine | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik), lekin sud tibbiyoti mavzusiga bog‘langan |
| `RS-17dbb8a348d3` | Molecular impact of antisense oligonucleotide therapy in C9orf72-associated ALS | Cell | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik), lekin sud tibbiyoti mavzusiga bog‘langan |
| `RS-275bd6274664` | Predictors of Long-Term Outcomes in Hypertrophic Cardiomyopathy: The NHLBI HCM Registry | JAMA | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik), lekin sud tibbiyoti mavzusiga bog‘langan |
| `RS-2e11fd3dd9a2` | The diagnostic accuracy of procalcitonin and C-reactive protein for sepsis: A systematic review and meta-analysis | Journal of cellular biochemistry | klinik fan (sud tibbiyoti/toksikologiyaga aloqasiz kasallik), lekin sud tibbiyoti mavzusiga bog‘langan |
| `RS-5b7393857bda` | Efficacy and Safety of Aficamten in Symptomatic Nonobstructive Hypertrophic Cardiomyopathy: Results From the REDWOOD-HCM Trial, Cohort 4 | Journal of cardiac failure | klinik terapiya sinovi (davolash samaradorligi), lekin sud tibbiyoti mavzusiga bog‘langan |
| `RS-40c61a887357` | The effect of coenzyme Q10 on morbidity and mortality in chronic heart failure: results from Q-SYMBIO: a randomized double-blind trial | JACC. Heart failure | klinik terapiya sinovi (davolash samaradorligi), lekin sud tibbiyoti mavzusiga bog‘langan |
| `RS-20b466305812` | "Experimentation" with chloroform | The American journal of medicine | sohaviy belgi yo‘q |
| `RS-ac1e5e3c49ae` | A Review on Spike and Recovery Method in Analytical Method Development and Validation | Critical reviews in analytical chemistry | sohaviy belgi yo‘q |
| `RS-b41d13fd4c4c` | Abnormal movements following recovery from propofol, alfentanil and nitrous oxide anaesthesia | Anaesthesia | sohaviy belgi yo‘q |
| `RS-33d3c21f9474` | Acute Pharmacological Effects of 2C-B in Humans: An Observational Study | Frontiers in pharmacology | sohaviy belgi yo‘q |
| `RS-827ad032316a` | Amitriptyline, clomipramine, and doxepin adsorption onto sodium polystyrene sulfonate | Daru : journal of Faculty of Pharmacy, Tehran University of Medical Sciences | sohaviy belgi yo‘q |
| `RS-b71ee8071b2f` | Breath Acetone Sensing Based on Single-Walled Carbon Nanotube-Titanium Dioxide Hybrids Enabled by a Custom-Built Dehumidifier | ACS sensors | sohaviy belgi yo‘q |
| `RS-4d1f9a98ec38` | Butalbital in the treatment of headache: history, pharmacology, and efficacy | Headache | sohaviy belgi yo‘q |
| `RS-43526ad4f712` | Butane encephalopathy | Emergency medicine journal : EMJ | sohaviy belgi yo‘q |
| `RS-f4291aa6a87b` | Carbamazepine |  | sohaviy belgi yo‘q |
| `RS-55e495a27309` | Carbamazepine-induced hyperammonemia | American journal of health-system pharmacy : AJHP : official journal of the American Society of Health-System Pharmacists | sohaviy belgi yo‘q |
| `RS-0cadc1f35cb4` | Cardiac arrest following butane inhalation | Anesthesia, essays and researches | sohaviy belgi yo‘q |
| `RS-3045c202abf4` | Carfentanil Outbreak - Florida, 2016-2017 | MMWR. Morbidity and mortality weekly report | sohaviy belgi yo‘q |
| `RS-374ff638b9fb` | Carfentanil: a narrative review of its pharmacology and public health concerns | Canadian journal of anaesthesia = Journal canadien d'anesthesie | sohaviy belgi yo‘q |
| `RS-b2381ab7c81e` | Chlorpromazine versus clotiapine for schizophrenia | The Cochrane database of systematic reviews | sohaviy belgi yo‘q |
| `RS-66dee208c82d` | Chlorpromazine versus penfluridol for schizophrenia | The Cochrane database of systematic reviews | sohaviy belgi yo‘q |
| `RS-67e7c453d055` | Citalopram-Induced Long QT Syndrome and the Mammalian Dive Reflex | Drug safety - case reports | sohaviy belgi yo‘q |
| `RS-cefcca7e9639` | Clonazepam treatment of lysergic acid diethylamide-induced hallucinogen persisting perception disorder with anxiety features | International clinical psychopharmacology | sohaviy belgi yo‘q |
| `RS-95c1deffee83` | Clozapine and Gastrointestinal Hypomotility | CNS drugs | sohaviy belgi yo‘q |
| `RS-b933e87a820a` | Clozapine-Related Thromboembolic Events | Cureus | sohaviy belgi yo‘q |
| `RS-773e9d893156` | Codeine and breastfeeding | Lancet (London, England) | sohaviy belgi yo‘q |
| `RS-ab2648abfc8a` | Colchicine Use in Acute Coronary Syndromes: An Update | Angiology | sohaviy belgi yo‘q |
| `RS-2062084c6710` | Commentary | Clinical chemistry | sohaviy belgi yo‘q |
| `RS-e3dd0dcc7625` | Comparison of hydroxyzine and doxepin in treatment of pruritus due to sulfur mustard | Skinmed | sohaviy belgi yo‘q |
| `RS-14b035bfe683` | Cough, codeine and confusion | BMJ case reports | sohaviy belgi yo‘q |
| `RS-36f7e64c39be` | Differential effects of alprazolam against methylphenidate-induced neurobehavioral alterations | Physiology & behavior | sohaviy belgi yo‘q |
| `RS-b02d485c4997` | Digoxin--issues and controversies | Clinical chemistry | sohaviy belgi yo‘q |
| `RS-94c80926b63e` | Digoxin-specific antibodies: a novel dosing strategy | Netherlands heart journal : monthly journal of the Netherlands Society of Cardiology and the Netherlands Heart Foundation | sohaviy belgi yo‘q |
| `RS-2d8a84b69641` | Dosing the antipsychotic medication olanzapine | The Journal of clinical psychiatry | sohaviy belgi yo‘q |
| `RS-865f96f277a8` | Drug Testing |  | sohaviy belgi yo‘q |
| `RS-a6daaacc0483` | Ephedrine psychosis | British medical journal | sohaviy belgi yo‘q |
| `RS-17fd1ea42ca9` | Flos Albiziae aqueous extract and its active constituent quercetin potentiate the hypnotic effect of pentobarbital via the serotonergic system | Biomedical reports | sohaviy belgi yo‘q |
| `RS-ce269e453ba1` | Flunitrazepam intake in male offenders | Nordic journal of psychiatry | sohaviy belgi yo‘q |
| `RS-53a317cc5e94` | Fluoxetine and stuttering | The Journal of clinical psychiatry | sohaviy belgi yo‘q |
| `RS-001da555d065` | Fucoidan protects against subacute diazinon-induced oxidative damage in cardiac, hepatic, and renal tissues | Environmental science and pollution research international | sohaviy belgi yo‘q |
| `RS-807abfcc5744` | Gabapentin as a drug therapy of intractable hiccup because of vascular lesion: a three-year follow up | The neurologist | sohaviy belgi yo‘q |
| `RS-f6c59dbeb005` | Gabapentin-related dyskinesia | Journal of clinical psychopharmacology | sohaviy belgi yo‘q |
| `RS-f2809fb41dba` | Gamma-hydroxybutyrate withdrawal syndrome | Annals of emergency medicine | sohaviy belgi yo‘q |
| `RS-001515539f91` | Hallucinations and propranolol | British medical journal | sohaviy belgi yo‘q |
| `RS-953d6c4732c8` | Haloperidol versus low-potency first-generation antipsychotic drugs for schizophrenia | The Cochrane database of systematic reviews | sohaviy belgi yo‘q |
| `RS-75cfab9b7211` | Hemodialysis of doxepin and desmethyldoxepin in uremic patients | Artificial organs | sohaviy belgi yo‘q |
| `RS-23c8864bd57c` | How addictive are gabapentin and pregabalin? A systematic review | European neuropsychopharmacology : the journal of the European College of Neuropsychopharmacology | sohaviy belgi yo‘q |
| `RS-8a96219c7ffd` | Hydromorphone neuroexcitation | Journal of palliative medicine | sohaviy belgi yo‘q |
| `RS-203b3a766aea` | Is Valproate Reasonable? | The American journal of psychiatry | sohaviy belgi yo‘q |
| `RS-37b5d8dc2f49` | LSD | Emergency medicine clinics of North America | sohaviy belgi yo‘q |
| `RS-6a54854f1cad` | LSD: 1967 | The British journal of psychiatry : the journal of mental science | sohaviy belgi yo‘q |
| `RS-e355720a66fe` | Loperamide, the "Poor Man's Methadone": Brief Review | Journal of psychoactive drugs | sohaviy belgi yo‘q |
| `RS-1ebcdfef00de` | MDMA (Ecstasy) | Annals of clinical psychiatry : official journal of the American Academy of Clinical Psychiatrists | sohaviy belgi yo‘q |
| `RS-cfc6ab67bbc6` | MDPV and α-PVP use in humans: The twisted sisters | Neuropharmacology | sohaviy belgi yo‘q |
| `RS-ab9fbca9612d` | Mephedrone and MDMA: A comparative review | Brain research | sohaviy belgi yo‘q |
| `RS-28ad3f990e8b` | Mephedrone-induced uvulitis | Anaesthesia | sohaviy belgi yo‘q |
| `RS-dc1788851e00` | Methylphenidate boosts choices of mental labor over leisure depending on striatal dopamine synthesis capacity | Neuropsychopharmacology : official publication of the American College of Neuropsychopharmacology | sohaviy belgi yo‘q |
| `RS-ee09c20717d8` | Methylphenidate in Adults with Attention Deficit Hyperactivity Disorder and Substance Use Disorders | Current pharmaceutical design | sohaviy belgi yo‘q |
| `RS-e18d1e70d8fe` | Mirtazapine-induced steatosis | International journal of clinical pharmacology and therapeutics | sohaviy belgi yo‘q |
| `RS-b8460927cc77` | Modulatory effects of exogenous estradiol during endotoxemia | The international journal of biochemistry & cell biology | sohaviy belgi yo‘q |
| `RS-07ced6a195e2` | Multimodal Imaging Using Raman Spectroscopy and FTIR in a Single Analytical Instrument with a Microscope (Infrared Raman Microscopy AIRsight, Shimadzu): Opportunities and Applications | International journal of molecular sciences | sohaviy belgi yo‘q |
| `RS-0ab0a03c9c06` | Neurobiology of 3,4-methylenedioxypyrovalerone (MDPV) and α-pyrrolidinovalerophenone (α-PVP) | Brain research bulletin | sohaviy belgi yo‘q |
| `RS-ed6e368f228e` | Nitrous oxide availability | Journal of clinical pharmacology | sohaviy belgi yo‘q |
| `RS-55fad65e5604` | Noteworthy Chemistry of Chloroform | Journal of anesthesia history | sohaviy belgi yo‘q |
| `RS-ad03a4b26791` | Olanzapine-induced rhabdomyolysis | Irish journal of psychological medicine | sohaviy belgi yo‘q |
| `RS-b06004962754` | Oral temazepam | British dental journal | sohaviy belgi yo‘q |
| `RS-59a88dcd1087` | Oxazepam: An overview | Diseases of the nervous system | sohaviy belgi yo‘q |
| `RS-f3a98de042f2` | Oxymorphone Induced Thrombotic Microangiopathy Mimicking Atypical Haemolytic Uremic Syndrome | Journal of Ayub Medical College, Abbottabad : JAMC | sohaviy belgi yo‘q |
| `RS-727116a5df8f` | PROPRANOLOL | Lancet (London, England) | sohaviy belgi yo‘q |
| `RS-2baea19c2451` | Parental Grief |  | sohaviy belgi yo‘q |
| `RS-d3fc58229f4d` | Pathophysiology and management of Akathisia 70 years after the introduction of the chlorpromazine, the first antipsychotic | European review for medical and pharmacological sciences | sohaviy belgi yo‘q |
| `RS-4494d96a6821` | Phencyclidine-induced psychosis | The American journal of psychiatry | sohaviy belgi yo‘q |
| `RS-50be337ca031` | Phenobarbital |  | sohaviy belgi yo‘q |
| `RS-342b35879506` | Phenytoin |  | sohaviy belgi yo‘q |
| `RS-f61027719085` | Phenytoin-induced lymphadenopathy | Drug intelligence & clinical pharmacy | sohaviy belgi yo‘q |
| `RS-20d35a23c4b7` | Phenytoin/clonazepam interaction | Therapeutic drug monitoring | sohaviy belgi yo‘q |
| `RS-8ead5f1bf10b` | Potential role of a newly AChE reactivator in the depressive-like behavior induced by malathion | Neuroscience letters | sohaviy belgi yo‘q |
| `RS-c26047e73ec8` | Prediction of methylphenidate treatment outcome in adults with attention-deficit/hyperactivity disorder (ADHD) | European archives of psychiatry and clinical neuroscience | sohaviy belgi yo‘q |
| `RS-c2aa36cd7b3d` | Propranolol (Hemangiol) and severe infantile haemangiomas. The drug of first choice | Prescrire international | sohaviy belgi yo‘q |
| `RS-a922240511a8` | Quetiapine-associated dysphagia | The world journal of biological psychiatry : the official journal of the World Federation of Societies of Biological Psychiatry | sohaviy belgi yo‘q |
| `RS-3f816df40402` | Quetiapine-induced Diabetic Ketoacidosis | Indian journal of psychological medicine | sohaviy belgi yo‘q |
| `RS-2e12319aa771` | Reduction of temazepam to diazepam and lorazepam to delorazepam during enzymatic hydrolysis | Analytical and bioanalytical chemistry | sohaviy belgi yo‘q |
| `RS-431f4145ec60` | Rescue of Methyl-CpG Binding Protein 2 Dysfunction-induced Defects in Newborn Neurons by Pentobarbital | Neurotherapeutics : the journal of the American Society for Experimental NeuroTherapeutics | sohaviy belgi yo‘q |
| `RS-9e71192b7d2d` | Risperidone: rhabdomyolysis | Prescrire international | sohaviy belgi yo‘q |
| `RS-90f40ad16912` | Secobarbital effects on recall and recognition in a levels-of-processing paradigm | Psychopharmacology | sohaviy belgi yo‘q |
| `RS-9b789ab0005e` | Sedative-Hypnotic Agents That Impact Gamma-Aminobutyric Acid Receptors: Focus on Flunitrazepam, Gamma-Hydroxybutyric Acid, Phenibut, and Selank | Journal of clinical pharmacology | sohaviy belgi yo‘q |
| `RS-5e5bfc67d212` | Sertraline-induced Hemichorea | Tremor and other hyperkinetic movements (New York, N.Y.) | sohaviy belgi yo‘q |
| `RS-a319d46082fa` | Sertraline-induced akathisia | Journal of clinical psychopharmacology | sohaviy belgi yo‘q |
| `RS-a8762f5d36aa` | Shared Genetic Risk Factors Across Carbamazepine-Induced Hypersensitivity Reactions | Clinical pharmacology and therapeutics | sohaviy belgi yo‘q |
| `RS-faff1275c865` | Spectrophotometric method for estimation of alkaloids precipitable with Dragendorff's reagent in plant materials | Journal of AOAC International | sohaviy belgi yo‘q |
| `RS-bbd2e50a3334` | Succinate and the shortcut to the cure of metformin-induced lactic acidosis | Intensive care medicine experimental | sohaviy belgi yo‘q |
| `RS-9f6fe7db39d7` | Temazepam dangers | British dental journal | sohaviy belgi yo‘q |
| `RS-a24157d644b5` | The effects of toluene on the central nervous system | Journal of neuropathology and experimental neurology | sohaviy belgi yo‘q |
| `RS-e59a2b65ad54` | The inhibitory effects of mitragynine on P-glycoprotein in vitro | Naunyn-Schmiedeberg's archives of pharmacology | sohaviy belgi yo‘q |
| `RS-ec386dc45f3f` | Traditional and non-traditional uses of Mitragynine (Kratom): A survey of the literature | Brain research bulletin | sohaviy belgi yo‘q |
| `RS-90e87235c99e` | Tramadol-induced apnea | The American journal of emergency medicine | sohaviy belgi yo‘q |
| `RS-b9cb3cbdefa0` | Trazodone (Desyrel, Mead-Johnson Pharmaceutical Division) | Drug intelligence & clinical pharmacy | sohaviy belgi yo‘q |
| `RS-176915f59e11` | Urinalysis | Emergency medicine clinics of North America | sohaviy belgi yo‘q |
| `RS-992c36d4a295` | Use of quetiapine in elderly patients | The Journal of clinical psychiatry | sohaviy belgi yo‘q |
| `RS-ded06e88548b` | Valproate-associated hyperammonemic encephalopathy | Journal of the American Board of Family Medicine : JABFM | sohaviy belgi yo‘q |
| `RS-9772b8bae026` | Venlafaxine: a 2003 update | Clinical therapeutics | sohaviy belgi yo‘q |
| `RS-55982b87238f` | Zolpidem withdrawal delirium | Indian journal of pharmacology | sohaviy belgi yo‘q |
| `RS-0df3353b945d` | Zolpidem, Complex Sleep-Related Behaviour and Volition | Journal of law and medicine | sohaviy belgi yo‘q |
| `RS-4e45f5f77ffc` | Zolpidem-induced psychosis | Annals of clinical psychiatry : official journal of the American Academy of Clinical Psychiatrists | sohaviy belgi yo‘q |
| `RS-4ea2326b737f` | [3,4-methylene-dioxy-pyrovalerone (MDPV) epidemic?] | Orvosi hetilap | sohaviy belgi yo‘q |
| `RS-bf6ea59f25ab` | [Midazolam (Dormicum) in terminal anxiety and agitation. The last choice alternative in palliative care] | Lakartidningen | sohaviy belgi yo‘q |
