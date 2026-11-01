"""Visual audit (2026-11-01) — UZ meta/editorial texts → plain Uzbek.

Runs after l10n_ux_audit.py, right before `flutter gen-l10n`. Idempotent.
"""
import json, pathlib
ARB = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb/app_uz.arb'
UZ = {
  'rdGlanceNote': 'Asosiy ma’lumotlar. Har bir bo‘limda manba ko‘rsatilgan.',
  'provSheetTitle': 'Bu ma’lumot qayerdan olingan',
  'provLifecycle': 'Holati',
  'provReviewsRecorded': 'Ekspert ko‘rib chiqqan: {n} marta',
  'provStatement': 'Ma’lumot',
  'groupEditorialNote': 'Guruhlar faqat qulay ko‘rish uchun; rasmiy ilmiy tasnif emas.',
  'analysisSectionEmpty': 'Bu bo‘lim bo‘yicha ma’lumot tayyorlanmoqda.',
  'jurisdictionNoContent': 'Bu davlat uchun huquqiy ma’lumot hali qo‘shilmagan. Har bir huquqiy yozuvda rasmiy manba, kuchga kirgan sana va tahrir ko‘rsatiladi.',
  'legalNoNational': '{name} uchun milliy huquqiy ma’lumot hali qo‘shilmagan.',
  'planIntro': 'Faqat manbalarda keltirilgan ma’lumotlar asosida tuzilgan. Bu ma’lumotnoma — tasdiqlangan protsedura ham, ekspert xulosasi ham emas.',
  'planNoSamplingNotes': 'Bu namunalarni olish va saqlash bo‘yicha manbalarda ko‘rsatma topilmadi.',
  'planNoSpecimens': 'Bu modda uchun manbalarda namuna turi ko‘rsatilmagan.',
  'planReminderFootnote': 'Faqat manbalardagi belgilar va cheklovlarga asoslangan; ekspert xulosasi emas.',
  'guidelinesIntro': 'Har bir yo‘riqnoma ko‘rsatilgan adabiyot asosida yozilgan ilmiy sharh. U rasmiy metodika emas, akkreditatsiyadan o‘tgan laboratoriya tartiblari va qonunchilik o‘rnini bosmaydi.',
  'specimensIntro': 'Har bir namuna turi uchun manbalarda keltirilgan qiymatlar. Bu qiymatlar me’yor yoki chegara emas.',
  'glossaryIntro': 'Atamalar o‘zbek, rus va ingliz tillarida. Tarjima tekshirilmoqda.',
  'conflictKindOverlap': 'Turli holatlardagi qiymatlar bir-biriga to‘g‘ri keladi',
  'disciplinesIntro': 'FORENSIC EXPERT shu fanlarni qamrab oladi. Fanlar bosqichma-bosqich to‘ldirilmoqda; har bir ma’lumot manbasi bilan qo‘shiladi.',
  'proSearchIntro': 'Qidiruvni namuna, usul, reagent yoki dalil darajasi bo‘yicha toraytiring. Teskari qidiruv: namuna, usul yoki reagentni tanlab, unga tegishli moddalarni toping.',
  'toolsReviewNote': 'Formulalar manbasi bilan berilgan va dasturiy sinovdan o‘tgan; natijani laboratoriya protokoli bilan solishtiring.',
  'studyIntro': 'Har bir savol va kartochka ilovadagi manbalar asosida tuzilgan. Ekspert hali tekshirmagan materiallar alohida belgilangan.',
  'studyExamUnavailableHub': '«Faqat mashq» to‘plamlari o‘z-o‘zini tekshirish uchun; ular baholanmaydi.',
  'studyExamUnavailable': 'Bu to‘plam o‘z-o‘zini tekshirish uchun; baholanmaydi. Mashq rejimidan foydalaning.',
  'learnCourseSourceNote': 'Darslar ustozlar kitoblari va qo‘llanmalaridan olingan; har bir parcha manbasi bilan berilgan.',
  'grpScoreReadyNote': 'Ballingiz tayyor.',
  'grpScoreCaption': 'to‘g‘ri javob',
  'grpIntro': 'Ustoz guruhga mavzu testi beradi. Siz uni muddatgacha o‘zingizga qulay vaqtda yechasiz; ball avtomatik hisoblanadi.',
  'classPrivacyNote': 'Ustoz faqat laqabingizni ko‘radi. Tugagan testlar 30 kundan keyin avtomatik o‘chiriladi. Nomaqbul laqabga shikoyat qilish mumkin, u olib tashlanadi.',
  'classDemoBanner': 'Sinov rejimi: natijalar shu qurilmada saqlanadi.',
  'grpDemoBanner': 'Sinov rejimi: guruh ma’lumotlari shu qurilmada saqlanadi.',
  'proFreeAlways': 'Xavfsizlik ma’lumotlari va manbalar doim bepul.',
  'guidelineAreaForensicMedicine': 'Sud tibbiyoti',
  'deathHubCardBody': 'Qiyin holatlar: o‘lim vaqti, jarohatlar, to‘satdan o‘lim, zaharlanish gumoni',
  'homeInstrumentsBody': 'Apparatlar bilan ishlash: GCda etanol, UV-1900da COHb, GC-MS asoslari — ish tartibi, rasmlar, test',
  'reuseLicenseRequired': 'Matni nashriyotda (pullik)',
  'relationAnalysedBy': 'Tahlil usullari',
  'relationMetabolism': 'Bog‘liq moddalar (metabolizm)',
  'detailTranslationDraft': 'Nomlar tarjimasi tekshirilmoqda',
  'studyFrontTopic': 'Bu mavzu bo‘yicha manbada nima deyilgan?',
  'studyDeckMixedTopics': 'Turli mavzular',
  'studyDeckMixedSubstances': 'Turli guruhlar',
  'studyDeckMixedGuidelines': 'Turli yo‘riqnomalar',
  'knowledgeEmpty': 'Hozircha yozuv yo‘q.',
  'knowledgeNoSourcedContent': 'Tayyorlanmoqda',
  'calcReferenceLabel': 'Formula holati',
  'bindingLegal': 'Amaldagi tahriri o‘z davlati hududida majburiy',
  'instrVersion': 'Tahrir holati',
  'layerGlobalCore': 'Umumiy ilmiy qism — barcha davlatlar uchun bir xil',
  'jurisdictionNoContentShort': 'Ma’lumot hali tekshirilmagan',
  'accountTestBackend': 'Sinov rejimi: haqiqiy xat yuborilmaydi, ma’lumot faqat shu qurilmada saqlanadi.',
  'homePrototypeNotice': 'Namoyish versiyasi: NAMUNA belgili yozuvlar faqat tasviriy, ilmiy ma’lumot emas.',
  'supUnavailable': 'Murojaat yuborish uchun internet orqali xizmat kerak; u bu versiyada hali ulanmagan.',
  'admVfUnavailable': 'Tasdiqlash uchun internet orqali xizmat kerak; u bu versiyada hali ulanmagan.',
  'repUnavailable': 'Bu versiyada shikoyat xizmati hali ulanmagan. Email orqali yozing.',
  'jurisdictionGlobalWorks': 'Ilmiy ma’lumotlar davlat tanlamasdan ishlaydi. Davlat faqat qonunlar, nazoratdagi moddalar ro‘yxatlari va milliy tartiblar uchun kerak.',
  'aiDisclaimerBody': 'Forensic AI javoblari ilovadagi manbali ma’lumotlar asosida tuziladi va ekspert xulosasi emas. Ular to‘liq bo‘lmasligi yoki xato bo‘lishi mumkin; sud-ekspert xulosasi, huquqiy qaror yoki davolash uchun yagona asos bo‘la olmaydi. Keltirilgan manbalarni tekshiring va malakali ekspert bilan maslahatlashing.',
  'blkIntro': 'Bloklangan mualliflarning xabarlari sizga ko‘rinmaydi. Ular ham kimligingizni ko‘rmaydi.',
}
a = json.loads(ARB.read_text(encoding='utf-8'))
missing = [k for k in UZ if k not in a]
assert not missing, missing
a.update(UZ)
import re
for k, v in list(a.items()):
    if not k.startswith('@') and isinstance(v, str):
        a[k] = re.sub(r'(?<=[gGoO])’', '‘', v)
ARB.write_text(json.dumps(a, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(f'l10n_visual_audit: {len(UZ)} keys')

# Yangi kalitlar (uch tilda; ru/en — UI matni, kontent emas).
NEW = {
  'fmTopicsPreparing': {'uz': 'Tayyorlanayotgan mavzular', 'ru': 'Темы в подготовке', 'en': 'Topics in preparation'},
}
for lang in ('uz', 'ru', 'en'):
    f = ARB.parent / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in NEW.items():
        b[k] = v[lang]
        if lang == 'en':
            b['@' + k] = {'description': 'Forensic medicine hub: header above topics that have no sourced entries yet.'}
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('new keys:', list(NEW))
