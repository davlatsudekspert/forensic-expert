# Fanlar ontologiyasi kengaytmasi: serologiya va kriminalistika guruhi.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz):
    K[key] = (desc, en, ru, uz)
k("disc_forensicSerology","Discipline.","Forensic serology","Судебная серология","Sud serologiyasi")
k("disc_medicalCriminalistics","Discipline.","Medical criminalistics","Медицинская криминалистика","Tibbiy-kriminalistika")
k("disc_traceEvidence","Discipline.","Trace evidence and traceology","Трасология и микроследы","Trasologiya va mikroizlar")
k("disc_firearmsBallistics","Discipline.","Firearms and ballistics","Баллистика и огнестрельное оружие","Ballistika va o‘qotar qurollar")
k("disc_questionedDocuments","Discipline.","Questioned documents","Техническая экспертиза документов","Hujjatlar ekspertizasi")
k("disc_digitalForensics","Discipline.","Digital forensics","Цифровая криминалистика","Raqamli kriminalistika")
k("discGroupCriminalistics","Discipline group.","Criminalistics","Криминалистика","Kriminalistika")
for idx, code in enumerate(["en","ru","uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key,(desc,en,ru,uz) in K.items():
        data[key] = (en,ru,uz)[idx]
        if code == "en": data["@"+key] = {"description": desc}
    json.dump(data, open(p,"w",encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p,"a").write("\n")
print(len(K), "keys")
