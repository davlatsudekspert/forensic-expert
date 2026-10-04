# 03 — Scientific Source Matrix

| | |
|---|---|
| Sana | 2026-10-04 |
| Asos | `docs/01_EVIDENCE_AUDIT.md` (litsenziya va manba tekshiruvi) |
| Tamoyil | Manba **topilganligi** uni ilovaga **ko‘chirish huquqini** bermaydi. Har bir manba uchun «Foydalanish rejimi» alohida ko‘rsatilgan |

## 0. Foydalanish rejimlari

| Rejim | Ma’nosi |
|---|---|
| **OPEN-REUSE** | Litsenziya tijoriy qayta foydalanishga ruxsat beradi (public domain, CC0, CC BY). Atributsiya bilan ma’lumotni bazaga kiritish mumkin |
| **CITE-ONLY** | Faqat bibliografik havola + o‘zimiz mustaqil yozgan qisqa mazmun. Matn, jadval yoki rasm ko‘chirilmaydi |
| **NON-COMMERCIAL** | CC BY-NC va shunga o‘xshash. Tijoriy ilovaga **ruxsatsiz kiritilmaydi**; faqat CITE-ONLY |
| **LICENSE REQUIRED** | Pullik/litsenziyali. Shartnoma bo‘lmaguncha hech qanday himoyalangan kontent kiritilmaydi |
| **LOOKUP-ONLY** | Faqat tashqi qidiruv (onlayn, so‘rov paytida) va havola; natija bazaga avtomatik tushmaydi |

**Fakt va ifoda farqi.** Ilmiy fakt, masalan «X moddaning asosiy metaboliti Y», odatda mualliflik huquqi obyekti emas. Lekin uning **ifodasi, tanlanishi va jadval tuzilishi** himoyalangan bo‘lishi mumkin. Shu sababli:

- har bir faktni imkon qadar **OPEN-REUSE** yoki birlamchi peer-reviewed manbadan olamiz;
- CITE-ONLY manbadan olingan fakt o‘z so‘zlarimiz bilan yoziladi;
- butun jadval yoki tuzilma hech qachon ko‘chirilmaydi.

Bu umumiy tamoyil, yuridik xulosa emas — yakuniy chegarani yurist tasdiqlaydi (legal checklist L-08).

---

## 1. Manbalar reestri (tekshirilgan litsenziya holati bilan)

| ID | Manba | Litsenziya / shart (2026-10-04 da tekshirilgan) | Rejim |
|---|---|---|---|
| SRC-PUBCHEM | PubChem (NCBI) | NCBI kontenti public domain, lekin PubChem’dagi har bir **deposit manbasi o‘z litsenziyasiga ega**. PUG-REST: ≤ 5 so‘rov/s, API kalit yo‘q | OPEN-REUSE (NCBI tomonidan hisoblangan maydonlar: formula, MW, InChIKey, IUPAC); deposit ma’lumotlari — har biri alohida |
| SRC-CHEBI | ChEBI (EMBL-EBI) | CC BY 4.0 | OPEN-REUSE |
| SRC-DRUGBANK-OPEN | DrugBank Open Data (vocabulary, ochiq strukturalar) | CC0 | OPEN-REUSE |
| SRC-DRUGBANK-FULL | DrugBank to‘liq ma’lumotlari | CC BY-NC 4.0; tijoriy — pullik litsenziya; akademik yuklab olish hozir to‘xtatilgan | LICENSE REQUIRED |
| SRC-CAS | CAS Registry Numbers (ACS) | Ommaga ko‘rsatish yoki «CAS RN bo‘yicha qidiruv» uchun **CAS litsenziyasi talab qilinadi**; CAS Common Chemistry — CC BY-NC 4.0 | LICENSE REQUIRED |
| SRC-PUBMED | PubMed / E-utilities | Metadata; 3 so‘rov/s (kalit bilan 10/s); NCBI disclaimer ko‘rsatilishi so‘raladi | LOOKUP-ONLY + CITE-ONLY |
| SRC-PMC-OA | PubMed Central OA subset | Har bir maqola o‘z litsenziyasi bilan: commercial (CC0/BY/BY-SA/BY-ND) va non-commercial | Maqolaga qarab |
| SRC-CROSSREF | Crossref REST API | Metadata — CC0 (fakt); abstraktlar himoyalangan bo‘lishi mumkin; polite pool 10 so‘rov/s | OPEN-REUSE (metadata) |
| SRC-NIST-WB | NIST Chemistry WebBook | © U.S. Secretary of Commerce, Standard Reference Data Act; rasmiy API yo‘q | CITE-ONLY + tashqi havola |
| SRC-NIST-MS | NIST/EPA/NIH Mass Spectral Library (NIST26) | Pullik, faqat distribyutorlar orqali | LICENSE REQUIRED (V1 da kerak emas) |
| SRC-SWGDRUG | SWGDRUG monografiyalari, MS kutubxonasi (v3.14), Recommendations (v8.2) | Bepul yuklab olish, lekin «All rights reserved», qayta tarqatish litsenziyasi yo‘q | CITE-ONLY (qayta tarqatish uchun ruxsat so‘raladi) |
| SRC-ASB | ANSI/ASB 036, 119, 120, 121 | Bepul yuklab olish; **tijoriy maqsadda ko‘chirish va o‘zgartirish taqiqlangan** | CITE-ONLY (havola + o‘z so‘zimiz bilan qisqa mazmun) |
| SRC-UNODC | UNODC ST/NAR «Recommended methods…», EWA | Bepul ommaviy hujjatlar; EWA batafsil ma’lumoti — ro‘yxatdan o‘tgan mutaxassislarga | CITE-ONLY (aniq reuse shartlari — ochiq savol) |
| SRC-EUDA | EUDA (sobiq EMCDDA) | CC BY 4.0 bilan mos siyosat; atributsiya bilan ruxsatsiz qayta foydalanish (uchinchi tomon fotosuratlaridan tashqari) | OPEN-REUSE (atributsiya bilan) |
| SRC-WHO-ATC | WHO ATC/DDD indeksi | Tijoriy nusxalash, tarqatish va o‘zgartirish taqiqlangan | LICENSE REQUIRED (yoki faqat ATC **kodini** havola sifatida ko‘rsatish — yurist bilan) |
| SRC-NIOSH | NIOSH Pocket Guide | AQSh davlat ishi | OPEN-REUSE (atributsiya bilan) |
| SRC-DAILYMED | DailyMed (FDA yorliqlari) | Bepul API; FDA yorliqlari — AQSh davlat hujjatlari | OPEN-REUSE (yorliq matnlari) |
| SRC-INTERPOL-DVI | INTERPOL DVI Guide 2023 | Bepul PDF | CITE-ONLY |
| SRC-SCHULZ-2012 | Schulz M va hamk., Crit Care 2012;16(4):R136, doi:10.1186/cc11441 | **CC BY 2.0** | OPEN-REUSE (atributsiya bilan) — yangiroq 2020 versiyasi afzal |
| SRC-SCHULZ-2020 | Schulz M va hamk., Crit Care 2020;24(1):195, doi:10.1186/s13054-020-02915-5 | **CC BY 4.0** | OPEN-REUSE (atributsiya bilan) — V1 reference konsentratsiyalarining asosiy ochiq manbasi |
| SRC-DORAZIO-2021 | D’Orazio va hamk., J Anal Toxicol 2021;45(6):529-536, doi:10.1093/jat/bkab064 | **CC BY-NC 4.0** | NON-COMMERCIAL → CITE-ONLY |
| SRC-JONES-2010 | Jones AW, Forensic Sci Int 2010;200:1-20, doi:10.1016/j.forsciint.2010.02.021 | Elsevier, obuna | CITE-ONLY (faktlar mustaqil ifoda bilan) |
| SRC-WATSON-1980 | Watson PE va hamk., Am J Clin Nutr 1980;33(1):27-39, doi:10.1093/ajcn/33.1.27 | Jurnal | CITE-ONLY (formula — ilmiy usul) |
| SRC-SEIDL-2000 | Seidl S va hamk., Int J Legal Med 2000;114:71-77, doi:10.1007/s004140000154 | Springer | CITE-ONLY |
| SRC-FORREST-1986 | Forrest A, J Forensic Sci Soc 1986;26(4):249-252, doi:10.1016/s0015-7368(86)72491-2 | Elsevier | CITE-ONLY |
| SRC-WIDMARK-1932 | Widmark EMP, 1932 (Urban & Schwarzenberg); ingl. tarjima 1981 (Biomedical Publications) | Kitob | CITE-ONLY |
| SRC-HENSSGE-1988 | Henssge C, Forensic Sci Int 1988;38:209-236, doi:10.1016/0379-0738(88)90168-5 | Elsevier; nomogramma **tasviri** himoyalangan | CITE-ONLY (V1.1) |
| SRC-MADEA-2023 | Madea B (ed.), Estimation of the Time Since Death, 4th ed., CRC Press 2023 | Kitob | CITE-ONLY |
| SRC-TROTTER | Trotter & Gleser 1952 (PMID 13007782), 1958 (PMID 13571400) | Wiley | CITE-ONLY (FUTURE) |
| SRC-BASELT | Baselt, Disposition of Toxic Drugs and Chemicals in Man, 12th ed., 2020; MedicinesComplete’da onlayn | Pullik | LICENSE REQUIRED |
| SRC-CLARKE | Clarke’s Analysis of Drugs and Poisons, 4th ed., 2011; MedicinesComplete’da onlayn (yangilanadi) | Pullik | LICENSE REQUIRED |
| SRC-PIGOLKIN | Судебная медицина, под ред. Пиголкина Ю.И., 4-е изд., ГЭОТАР-Медиа, 2022 | Darslik | CITE-ONLY (RU terminologiyasi) |
| SRC-LEX-UZ | lex.uz — O‘zbekiston qonunchilik bazasi | Rasmiy davlat manbasi | OPEN-REUSE (rasmiy matnlar) — yurist tasdig‘i bilan |

---

## 2. MODULE → DATA TYPE → PRIMARY → SECONDARY → UPDATE METHOD → REVIEW REQUIRED

### 2.1. Substance Library

| Data type | Primary source | Secondary source | Update method | Review required |
|---|---|---|---|---|
| Canonical nom, IUPAC, formula, MW, InChIKey, SMILES | SRC-PUBCHEM (NCBI hisoblagan maydonlar) | SRC-CHEBI | Pipeline: PubChem PUG-REST orqali avtomatik olish (≤ 5 so‘rov/s) → ChEBI bilan solishtirish → farq bo‘lsa conflict | `tox` (1 reviewer, avtomatik tekshiruv o‘tgan bo‘lsa) |
| Identifikatorlar | PubChem CID, ChEBI ID, InChIKey | DrugBank Open Data ID (CC0) | Avtomatik | Avtomatik + `tox` tasodifiy tekshiruv |
| **CAS RN** | — | — | **V1 da ko‘rsatilmaydi va qidiruvga qo‘shilmaydi** (CAS litsenziyasi talab qilinadi) | LICENSE REQUIRED ro‘yxatida |
| Sinonimlar (EN) | SRC-DRUGBANK-OPEN (CC0), SRC-CHEBI | PubChem (filtrlangan) | Avtomatik olish + qo‘lda tozalash | `tox` |
| RU/UZ nomlari | Rasmiy ro‘yxatlar (lex.uz; RF hukumati qarorlari), SRC-PIGOLKIN | Ilmiy terminologiya lug‘ati | Qo‘lda | `i18n:ru`, `i18n:uz` + `tox` |
| Dori/kimyoviy sinf | SRC-CHEBI (ontologiya) | O‘z «forensic class» taksonomiyamiz | Qo‘lda | `tox` |
| ATC kodi | — | — | V1 da ko‘rsatilmaydi (WHO ATC tijoriy cheklov); FUTURE — litsenziya bilan | LICENSE REQUIRED |
| Ta’sir mexanizmi | SRC-DAILYMED (FDA yorlig‘i), PMC OA review maqolalar | CITE-ONLY review’lar | Qo‘lda, o‘z so‘zimiz bilan | `tox` |
| Metabolitlar | PMC OA / peer-reviewed birlamchi maqolalar | SRC-DAILYMED | Qo‘lda | `tox` (VERIFIED uchun 2 reviewer) |
| Terapevtik / toksik reference konsentratsiyalar | **SRC-SCHULZ-2020 (CC BY 4.0)** | Birlamchi peer-reviewed maqolalar | Qo‘lda strukturalash; har bir qator — alohida claim | `tox` × 2 (VERIFIED) |
| Postmortemda qayd etilgan konsentratsiyalar | Birlamchi case series (PMC OA yoki CITE-ONLY) | SRC-SCHULZ-2020 | Qo‘lda; matrix/population/n majburiy | `tox` × 2 |
| Talqin izohlari | Peer-reviewed review maqolalar (CITE-ONLY, o‘z so‘zimiz bilan) | — | Qo‘lda | `tox` × 2 |
| Barqarorlik / saqlash | Peer-reviewed maqolalar | SRC-UNODC qo‘llanmalari | Qo‘lda | `tox` / `lab` |
| Interferensiyalar | Immunoassay ishlab chiqaruvchi yo‘riqnomalari, peer-reviewed | — | Qo‘lda | `lab` |
| Huquqiy status — UZ | SRC-LEX-UZ | — | Qo‘lda; `effective_date`; chorakda bir marta tekshiruv | `legal` |
| Huquqiy status — xalqaro | INCB «Yellow/Green/Red List» (BMT konvensiyalari) | — | Qo‘lda, yiliga | `legal` |
| Huquqiy status — AQSh | eCFR 21 CFR 1308 | — | Qo‘lda | `legal` |
| Huquqiy status — RF | RF hukumati qarori №681 (1998) va o‘zgarishlari (rasmiy portal) | — | Qo‘lda | `legal` |

### 2.2. Forensic Toxicology — Ethanol

| Data type | Primary source | Secondary source | Update method | Review required |
|---|---|---|---|---|
| Widmark formulasi | SRC-WIDMARK-1932 | Zamonaviy review (SRC-JONES-2010) | Kodda (calc_engine) + koeffitsientlar kontentda | `tox` + `lab` |
| TBW asosidagi r-faktor | SRC-WATSON-1980, SRC-FORREST-1986, SRC-SEIDL-2000 | — | Kodda; har bir variant alohida metod sifatida | `tox` |
| Eliminatsiya tezligi diapazonlari | SRC-JONES-2010 | Boshqa peer-reviewed | Kontentda (claim) | `tox` × 2 |
| Birlik konvertatsiyasi | Fizik/kimyoviy ta’riflar (zichlik — rasmiy manba bilan) | — | Kodda | `lab` |
| Namuna konteksti (qon/siydik/vitreous) | Peer-reviewed | — | Kontentda | `tox` |

### 2.3. Analytical Methods

| Data type | Primary source | Secondary source | Update method | Review required |
|---|---|---|---|---|
| Metod prinsipi, qo‘llanishi | SRC-UNODC (ST/NAR) | Darsliklar (CITE-ONLY) | Qo‘lda, o‘z so‘zimiz bilan | `lab` |
| Validatsiya talablari | SRC-ASB (036) — **faqat havola va mustaqil qisqa mazmun** | Peer-reviewed | Qo‘lda | `lab` |
| Tasdiqlash (confirmation) talablari | SRC-SWGDRUG Recommendations (CITE-ONLY) | SRC-UNODC | Qo‘lda | `lab` |
| Analitik qamrov (scope) | SRC-ASB 119/120/121 (CITE-ONLY) | SRC-DORAZIO-2021 (CITE-ONLY) | Qo‘lda | `lab` + `tox` |
| Mass spektrlar | — | — | V1 da yo‘q (SWGDRUG — qayta tarqatish ruxsati kerak; NIST — pullik) | LICENSE REQUIRED / FUTURE |

### 2.4. Laboratory Tools

| Data type | Primary source | Secondary source | Update method | Review required |
|---|---|---|---|---|
| Formulalar (C1V1, molarity, statistika, regressiya) | Standart matematik/kimyoviy ta’riflar; statistika darsliklari | — | Kodda | `lab` + unit test |
| LOD/LOQ usullari | SRC-ASB 036 (havola), ICH Q2 kabi rasmiy qo‘llanmalar (litsenziyasi tekshiriladi) | Peer-reviewed | Kodda + izoh kontentda | `lab` |
| Atom massalari | IUPAC CIAAW standart atom massalari (litsenziya — ochiq savol) | PubChem | Kontentda | `lab` |

### 2.5. Forensic Medicine

| Data type | Primary source | Secondary source | Update method | Review required |
|---|---|---|---|---|
| Postmortem o‘zgarishlar (reference matn) | Peer-reviewed review’lar, SRC-MADEA-2023 (CITE-ONLY) | SRC-PIGOLKIN | Qo‘lda, o‘z so‘zimiz bilan | `fm` × 2 |
| Henssge (V1.1) | SRC-HENSSGE-1988 va birlamchi seriya | SRC-MADEA-2023 | Kodda, nashr qilingan misollar bilan test | `fm` × 2 + `lab` |
| Travma, kuyishlar | Peer-reviewed, darsliklar (CITE-ONLY) | — | Qo‘lda | `fm` |
| Antropologiya formulalari (FUTURE) | Birlamchi maqolalar (SRC-TROTTER va h.k.), populyatsiya ko‘rsatilgan | — | Kodda | `fm` × 2 |
| DVI (FUTURE) | SRC-INTERPOL-DVI | — | Qo‘lda | `fm` |

### 2.6. Learn

| Data type | Primary source | Secondary source | Update method | Review required |
|---|---|---|---|---|
| Lesson matnlari | Ichki `REVIEWED`+ claim’lar | — | CMS | `edu` + tegishli domen |
| Quiz / flashcards | Ichki claim’lar (`claim_id` majburiy) | — | CMS | `edu` + domen |
| Glossary | Darsliklar (CITE-ONLY), ICD-11 (litsenziya — ochiq savol) | — | CMS | `edu` + `i18n:*` |

### 2.7. Forensic AI va External Search

| Data type | Primary source | Secondary source | Update method | Review required |
|---|---|---|---|---|
| RAG korpusi | Faqat ichki PUBLISHED + REVIEWED/VERIFIED claim’lar | — | Content pack publish bo‘lganda qayta indekslanadi | Meros (content review) |
| Tashqi natijalar | SRC-PUBMED, SRC-PUBCHEM, SRC-CROSSREF | — | Real vaqtda (proxy, rate limit, kesh) | «EXTERNAL — NOT VERIFIED»; bazaga faqat CMS review orqali |

---

## 3. LICENSE REQUIRED ro‘yxati

| # | Nima kerak | Nima uchun kerak | Kimdan ruxsat olinadi | Ochiq alternativa | V1 ga ta’siri |
|---|---|---|---|---|---|
| LR-01 | **CAS Registry Numbers** ko‘rsatish va CAS RN bo‘yicha qidiruv | Sud-kimyogarlar CAS raqami bilan ishlashga o‘rgangan; laboratoriya hujjatlarida ishlatiladi | CAS (American Chemical Society bo‘limi) — CAS RN Verified Partner Program / litsenziya | PubChem CID, InChIKey, ChEBI ID, DrugBank Open Data ID — identifikatsiya uchun yetarli, lekin foydalanuvchiga tanish emas | **Muhim.** V1 CAS’siz chiqishi mumkin; litsenziya narxi so‘raladi |
| LR-02 | **Baselt** — Disposition of Toxic Drugs and Chemicals in Man (12th ed. / MedicinesComplete onlayn) | Soha standarti: har bir modda bo‘yicha farmakokinetika va qayd etilgan konsentratsiyalarning eng to‘liq to‘plami | Pharmaceutical Press (MedicinesComplete) / Biomedical Publications | SRC-SCHULZ-2020 (CC BY 4.0) + birlamchi PMC OA maqolalar — qamrovi kichikroq | Sifatni sezilarli oshiradi; V1 ochiq manbalar bilan mumkin, lekin chuqurligi kamroq |
| LR-03 | **Clarke’s Analysis of Drugs and Poisons** (onlayn) | Analitik ma’lumotlar (UV, IR, MS, TLC, GC xususiyatlari) | Pharmaceutical Press (MedicinesComplete) | UNODC ST/NAR + SWGDRUG monografiyalari (ruxsat bilan) | Analytical modulni boyitadi; V1 uchun shart emas |
| LR-04 | **WHO ATC/DDD** indeksi | Dorilarni standart tasniflash | WHO Collaborating Centre for Drug Statistics Methodology (Oslo) | ChEBI ontologiyasi + o‘z forensic taksonomiyamiz | V1 o‘z taksonomiyasi bilan |
| LR-05 | **DrugBank** to‘liq ma’lumotlari | Farmakologiya, metabolizm, o‘zaro ta’sir | OMx Personal Health Analytics (DrugBank) — tijoriy litsenziya | DrugBank Open Data (CC0), DailyMed, PMC OA | V1 uchun shart emas |
| LR-06 | **SWGDRUG** MS kutubxonasi va monografiyalarni ilovada qayta tarqatish | Spektral ma’lumot, monografiyalar | SWGDRUG (ruxsat so‘rovi) | Faqat havola | V1 da havola yetarli |
| LR-07 | **NIST26** Mass Spectral Library | Spektral moslik | NIST distribyutorlari | — | FUTURE; mobil ilovaga kerak emas |
| LR-08 | **D’Orazio 2021** (CC BY-NC) jadvallarini kiritish | DUID scope ro‘yxatlari | Oxford University Press / mualliflar | ASB 120 (CITE-ONLY) | V1 da faqat havola |
| LR-09 | **ASB standartlari** matnini kiritish | Validatsiya talablari | AAFS Standards Board | Faqat havola + mustaqil qisqa mazmun | V1 da faqat havola |

**Qoida:** litsenziya imzolanmaguncha ushbu manbalardagi himoyalangan kontent (matn, jadval, rasm, ma’lumotlar to‘plami) content bazasiga kiritilmaydi. Content pipeline validatori `license IN ('licensed','citation-only','non-commercial')` bo‘lgan manbadan **strukturaviy qiymat** (`value_json`) olgan claim’ni, agar shartnoma ID’si bo‘lmasa, rad etadi.

---

## 4. V1 ni ochiq manbalardan qurish mumkinmi? — Xulosa

| Modul | Ochiq manbalar bilan V1 | Izoh |
|---|---|---|
| Laboratory Tools | ✅ To‘liq | Matematika — litsenziyasiz |
| Ethanol | ✅ To‘liq | Formulalar — ilmiy usullar; birlamchi maqolalarga havola |
| Substance identifikatsiyasi | ✅ (CAS’siz) | PubChem + ChEBI + DrugBank Open Data |
| Reference konsentratsiyalar | ✅ Asosiy qism | Schulz 2020 (CC BY 4.0) — asosiy ochiq manba; postmortem ma’lumotlar uchun birlamchi maqolalar — ko‘p qo‘l mehnati |
| Analytical Methods | ✅ Reference darajasida | UNODC, ASB/SWGDRUG havolalari bilan, mustaqil matn |
| Forensic Medicine reference | ✅ | Mustaqil matn + havolalar; ko‘p mehnat va `fm` reviewer talab qiladi |
| Huquqiy status | ✅ | Rasmiy davlat manbalari |
| Spektral ma’lumotlar | ❌ | Litsenziya kerak — V1 da yo‘q |

**Umumiy xulosa:** V1 ni qonuniy ravishda ochiq va rasmiy manbalardan qurish **mumkin**. Eng katta yo‘qotish — CAS raqamlari va Baselt darajasidagi chuqurlik. LR-01 (CAS) bo‘yicha narx so‘rovini PHASE 1 bilan parallel boshlash tavsiya etiladi.
