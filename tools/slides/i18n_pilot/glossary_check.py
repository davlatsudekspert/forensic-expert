import json,re,sys
sys.path.insert(0,'/tmp/pilot'); import dx
from ks_ru_a import RU_A; from ks_ru_b import RU_B; from ks_en_a import EN_A; from ks_en_b import EN_B
import u38_ru, u38_en
G=[  # (uz regex, ru regex, en regex, nom)
 (r'\bshok', r'шок', r'shock', 'shok'),
 (r'DVS', r'ДВС', r'DIC', 'DVS-sindrom'),
 (r'sladj', r'сладж|монетн', r'sludge|rouleaux', 'sladj'),
 (r'shokli buyrak', r'шоков\w+ почк', r'shock kidney', 'shokli buyrak'),
 (r'shokli o‘pka', r'шоков\w+ лёгк', r'shock lung', 'shokli o‘pka'),
 (r'murda dog', r'трупн\w+ пят', r'lividity', 'murda dog‘lari'),
 (r'qon yo‘qotish', r'кровопотер', r'blood loss', 'qon yo‘qotish'),
 (r'\bkofein', r'кофеин', r'caffeine', 'kofein'),
 (r'\bteobromin', r'теобромин', r'theobromine', 'teobromin'),
 (r'\bteofillin', r'теофиллин', r'theophylline', 'teofillin'),
 (r'ureksid', r'мурексид', r'murexide', 'mureksid'),
 (r'YuQX', r'ТСХ', r'TLC', 'YuQX'),
 (r'YuSSX', r'ВЭЖХ', r'HPLC', 'YuSSX'),
 (r'\bGX\b', r'ГХ', r'GC', 'GX'),
 (r'ksantin', r'ксантин', r'xanthine', 'ksantin'),
 (r'Nessler', r'Несслер', r'Nessler', 'Nessler'),
 (r'optik (zichlik|ko‘rsatkich)', r'оптическ\w+ плотност', r'absorbance', 'optik zichlik'),
 (r'ishqor', r'щёлоч|щелоч', r'alkali|alkaline', 'ishqor'),
 (r'Tipik xato', r'Типичная ошибка', r'Typical mistake', 'Tipik xato'),
 (r'Muhokama', r'Обсуждение', r'Discussion', 'Muhokama'),
]
res={}
for name,decks in (('u38',(u38_ru.RU,u38_en.EN)),('ks',(RU_A+RU_B,EN_A+EN_B))):
    d=json.load(open(f'/tmp/pilot/{name}.deck.json')); S=[t for _,t in dx.extract(d)]
    ru,en=decks; fails=[]; cnt={}
    for i,uz in enumerate(S):
        for uzr,rur,enr,nom in G:
            if re.search(uzr,uz):
                cnt[nom]=cnt.get(nom,0)+1
                if not re.search(rur,ru[i],re.I): fails.append((i,nom,'ru',uz[:50]))
                if not re.search(enr,en[i],re.I): fails.append((i,nom,'en',uz[:50]))
    print(name,'checked',sum(cnt.values()),'fails',len(fails)); [print(' ',f) for f in fails[:25]]
