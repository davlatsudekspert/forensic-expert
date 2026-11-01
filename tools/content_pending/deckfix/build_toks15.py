from lib import *
D='toks-15-toks-sud-biokimyo'
LI={"author":"Li Z va boshq.","title":"Development and Clinical Validation of a Sensitive Lateral Flow Assay for Rapid Urine Fentanyl Screening in the Emergency Department, Clinical Chemistry, 2020"}
CH={"author":"Chang YZ va boshq.","title":"Numerical analysis of an immunochromatographic test strip reader in abused drugs screening, Journal of Immunoassay & Immunochemistry, 2012"}
ON={"author":"Medical Advisory Secretariat (Ontario)","title":"Optimum methadone compliance testing: an evidence-based analysis, Ontario Health Technology Assessment Series, 2006"}
L="PMID 32040576; DOI 10.1093/clinchem/hvz023 (abstrakt)"
C="PMID 22471608; DOI 10.1080/15321819.2011.618862 (abstrakt)"
OP="PMID 23074492; PMC3379523 (abstrakt)"
i1=slide("Immunoxromatografik testlar: tamoyil va qo‘llanilishi",[
("Immunoxromatografik (lateral flow) test – antigen-antitelo reaksiyasiga asoslangan tezkor, nuqtada (point-of-care) o‘tkaziladigan immunotahlil turi.",LI,L),
("Raqobatli lateral flow tahlilida oltin nanozarrachalar nishon sifatida ishlatilib, natija taxminan 5 daqiqada olinadi.",LI,L),
("Siydik bo‘yicha point-of-care immunotahlil mavjud; musbat skrining natijasi tasdiqlovchi laboratoriya usuliga yuboriladi.",ON,OP),
("Strip-testlar natijalari laboratoriya immunotahlili (EMIT) va GC-MS bilan taqqoslanib baholanadi.",CH,C)],
"Vaqt: 6 daq. Muhokama: tezkor test natijasi nega yakuniy dalil emas? Doskada: namuna → tez test → cutoff bilan taqqoslash → tasdiqlash. Tipik xato: musbat tez testni identifikatsiya deb hisoblash. Eslatma: bu slayd nashr etilgan tadqiqot abstraktlariga tayanadi, darslik betlariga emas.")
i2=slide("Fentanil bo‘yicha lateral flow tahlili: ko‘rsatkichlar",[
("Test fentanilni (≥1 ng/ml) va asosiy metabolit norfentanilni (≥10 ng/ml) aniqladi.",LI,L),
("Siydik shoshilinch yordam bo‘limidagi 218 bemor va fentanil bilan zaharlanish gumon qilingan 7 bemorda tekshirildi; natijalar LC-MS/MS bilan solishtirildi.",LI,L),
("218 bemorda klinik sezuvchanlik 100 foiz, o‘ziga xoslik 99,5 foiz; musbat va manfiy bashoratli qiymatlar 92,3 va 100 foiz.",LI,L),
("Amfetamin, kokain, morfin, THC, metadon, buprenorfin va naloksonning 1000 ng/ml konsentratsiyasida o‘zaro reaksiya kuzatilmadi.",LI,L)],
"Vaqt: 6 daq. Muhokama: nega tezkor test uchun cutoff pastligi (bir xonali ng/ml) muhim? Tipik xato: natijalarni boshqa moddalar va boshqa test uchun umumlashtirish.")
i3=slide("Test-polosa o‘qigich: ko‘z bilan baholash va raqamli o‘qish",[
("Point-of-care strip o‘qigich (Uniscan) siydikda metamfetamin, opiat va marixuanani taxminiy konsentratsiya shaklida raqamli ko‘rsatadi.",CH,C),
("Cutoff qo‘shilgan nazorat namunalar bilan tekshirildi; klinik namunalar EMIT bilan taqqoslandi.",CH,C),
("Nomuvofiq 19 natija GC-MS bilan tekshirildi: 11 tasida Uniscan, 8 tasida EMIT to‘g‘ri chiqdi.",CH,C),
("Raqamli o‘qish subyektiv vizual baholashdan afzal sanaladi.",CH,C)],
"Vaqt: 5 daq. Muhokama: nomuvofiq natijalarda nega GC-MS hakamlik qiladi? Tipik xato: bir tadqiqot natijasini barcha test turlari uchun amal qiladi deb o‘ylash.")
i4=slide("Skrining natijasini baholash: tasdiqlash va namunani soxtalashtirish xavfi",[
("Siydik namunasi skriningda birinchi tahlil immunotahlil bilan o‘tkaziladi, musbatlari tasdiqlovchi tekshiruvga yuboriladi.",ON,OP),
("Siydik namunasini soxtalashtirishning uch yo‘li: suyultirish, kimyoviy moddalar qo‘shish va boshqa odam siydigini almashtirish.",ON,OP),
("Shu sababli kuzatuv ostida namuna olish tavsiya etiladi; siydik kreatinin va pH bo‘yicha ishonchlilikka tekshiriladi.",ON,OP),
("Siydikda aniqlash oynasi qondagidan kengroq (taxminan 1–3 kun).",ON,OP)],
"Vaqt: 5 daq. Muhokama: tez test manfiy chiqsa, zaharlanishni inkor etish mumkinmi? (cutoff va aniqlash oynasi). Tipik xato: suyultirilgan siydik natijasini ishonchli deb hisoblash.")
n36=slide("Kitoblar, malaka ma’lumotlari va maqolalar: manbalar chegarasi",[
("Dvssm kitobida immunokimyoviy usul nazariy asoslari (antigen, antitelo, IFT, RIA nomi, to‘g‘ri va to‘g‘ri bo‘lmagan usul) berilgan.",{"author":"Yuldashev Z.A., Nurmatova M.I.","title":"Toksikologik kimyo modulidan o‘quv-uslubiy majmua (DVSSM). Toshkent farmatsevtika instituti, 2025"},"83-85"),
("Gmt kitobida geroin va metabolitlari uchun immunobiologik hamda IFT usullari qisqa eslatilgan.",{"author":"Yuldashev Z.A., Zulfikariyeva D.A., Usmanaliyeva Z.U., Nurmatova M.I.","title":"Giyohvand moddalar tahlili. O‘quv qo‘llanma. Toshkent, 2024"},"37-38"),
("Cutoff va siydikda aniqlanish muddatlari faqat malaka ma’lumotnomalarida mavjud.",{"author":"Malaka materiali №042 (TFI Toksikologik kimyo kafedrasi)","title":"Siydikda giyohvand moddalarni aniqlash muddatlari (CDRH, 1997; ruscha ma’lumotnoma)"},"jadval"),
("Immunoxromatografik testlar bo‘yicha slaydlar kitoblarga emas, PubMed’dagi nashr abstraktlariga (Li 2020, Chang 2012, Ontario 2006) tayanadi.",LI,L)],
"Vaqt: 3 daqiqa. Muhokama: nima uchun kitobda cutoff tushunchasi yo‘q? Doskada: manba — mavzu jadvali. Tipik xato: malaka jadvallarini O‘zbekistondagi rasmiy me’yor deb hisoblash.")
concl=slide("Xulosa va nazorat savollari",[
("Sud biokimyosi postmortal tahlil: qon, peshob, perikardial suyuqlik; avvalo glyukoza.",{"author":"Yuldashev Z.A., Nurmatova M.I.","title":"Toksikologik kimyo modulidan o‘quv-uslubiy majmua (DVSSM). Toshkent farmatsevtika instituti, 2025"},83),
("Immunotahlil antigen-antitelo reaksiyasiga asoslangan; nishon turiga qarab IFT, RIA, immunofluoressent.",{"author":"Yuldashev Z.A., Nurmatova M.I.","title":"Toksikologik kimyo modulidan o‘quv-uslubiy majmua (DVSSM). Toshkent farmatsevtika instituti, 2025"},84),
("Immunoxromatografik tezkor testlar skriningda tez natija beradi (taxminan 5 daqiqa), lekin natija cutoff bilan taqqoslanadi va tasdiqlanadi.",LI,L),
("Skrining natijasi cutoff bilan taqqoslanadi, so‘ng LC-MS/MS yoki GC-MS kabi tasdiqlovchi usul bilan tasdiqlanadi.",CH,C)],
"Vaqt: 5 daqiqa. Muhokama: skrining va tasdiqlashning mantiqiy ketma-ketligini ayting. Doskada: skrining -> tasdiqlash -> xulosa. Tipik xato: immunotahlilni yakuniy usul deb hisoblash.")
plan=[('k',0)]+[('k',i) for i in range(1,19)]+[('n',i1),('n',i2),('n',i3),('n',i4)]+[('k',i) for i in range(27,36)]+[('n',n36,"manbalar chegarasi yangilandi"),('n',concl,"xulosa immunoxromatografik testlarni qamrab oldi")]
src_add=[{"year":2020,"pages":L,"title":LI['title'],"author":LI['author']},{"year":2012,"pages":C,"title":CH['title'],"author":CH['author']},{"year":2006,"pages":OP,"title":ON['title'],"author":ON['author']}]
o,deck,ch=build(D,plan,src_add)
qr=[
Q(D,14,"Raqobatli lateral flow tahlilida nishon sifatida nima ishlatilgan va natija qancha vaqtda olingan?","Oltin nanozarrachalar; taxminan 5 daqiqa",["Radioaktiv izotop; 5 soat","Ferment; 24 soat","Floresent bo‘yoq; 3 kun"],"Li va boshq. (2020): raqobatli lateral flow tahlili oltin nanozarrachalar bilan ishlab chiqilgan, fentanilni 5 daqiqada skrining qilish uchun optimallashtirilgan.",LI,L),
Q(D,15,"Li va boshq. (2020) tahlilida fentanil va norfentanil uchun qaysi cutoff keltirilgan?","Fentanil ≥1 ng/ml, norfentanil ≥10 ng/ml",["Fentanil ≥100 ng/ml, norfentanil ≥1000 ng/ml","Fentanil ≥1000 ng/ml, norfentanil ≥1 ng/ml","Ikkalasi ham ≥5 mg/ml"],"Abstrakt: tahlil fentanilni (≥1 ng/ml) va norfentanilni (≥10 ng/ml) yuqori aniqlik bilan aniqladi.",LI,L),
Q(D,16,"218 ketma-ket bemorda lateral flow tahlilining klinik sezuvchanligi va o‘ziga xosligi qancha bo‘lgan?","Sezuvchanlik 100 foiz, o‘ziga xoslik 99,5 foiz",["Ikkalasi ham 50 foiz","Sezuvchanlik 60 foiz, o‘ziga xoslik 70 foiz","Sezuvchanlik 99,5, o‘ziga xoslik 10 foiz"],"Abstrakt: klinik sezuvchanlik 100 foiz, o‘ziga xoslik 99,5 foiz, PPV 92,3 va NPV 100 foiz.",LI,L),
Q(D,17,"Uniscan va EMIT natijalari nomuvofiq bo‘lganda (19 ta) qaysi usul hakamlik qilgan va natija qanday?","GC-MS; Uniscan 11 tada, EMIT 8 tada to‘g‘ri chiqqan",["Oddiy ko‘z baholash; EMIT hammasida to‘g‘ri","IFT; ikkalasi ham noto‘g‘ri","RIA; Uniscan 19 tada to‘g‘ri"],"Chang va boshq. (2012): nomuvofiq 19 natijani GC-MS tasdiqladi: Uniscan 11, EMIT 8 namunada to‘g‘ri bo‘lgan.",CH,C),
Q(D,18,"Chang va boshq. (2012) bo‘yicha raqamli strip o‘qigichning vizual baholashdan afzalligi nimada?","Subyektiv ko‘z bilan baholash o‘rniga raqamli o‘qish beradi",["Hech qanday kalibrovka talab etmaydi","Siydikni konsentratsiyalab beradi","Faqat qon bilan ishlaydi"],"Abstrakt: Uniscan natijani raqamli o‘qish asosida talqin qilishi subyektiv vizual baholashdan afzalligi qayd etilgan.",CH,C),
Q(D,19,"Siydik namunasini soxtalashtirishning uch usuli qaysi qatorda to‘g‘ri berilgan?","Suyultirish, kimyoviy qo‘shimcha va boshqa odam siydigini almashtirish",["Muzlatish, qizdirish, yorug‘lik","Filtrlash, bo‘yash, hidlash","Faqat bitta usul bor"],"Ontario hisobotida siydik namunasini soxtalashtirish uch usulda: suyultirish, adulteratsiya (kimyoviy qo‘shish) va almashtirish keltirilgan.",ON,OP),
]
write(D,o,deck,ch,qr,["Immunoxromatografik testlar bo‘yicha lokal darslik/qo‘llanma matni topilmadi; slaydlar PubMed abstraktlariga (PMID 32040576, 22471608, 23074492) tayanadi — to‘liq matn o‘qilmadi.","Immunoxromatografik testlarning har bir modda bo‘yicha rasmiy cutoff qiymatlari (SAMHSA/ETX) manbada topilmadi; faqat abstraktdagi fentanil qiymatlari keltirildi."])
