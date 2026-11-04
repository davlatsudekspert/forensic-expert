# «yaratish» so‘zi ilovada bo‘lmasin (egasi talabi, 2026-11-04): tayyorlash / tuzish / qo‘shish /
# ro‘yxatdan o‘tish. Faqat o‘zbekcha ARB; idempotent.
#   cd apps/mobile && python3 tool/l10n_no_yaratish.py && flutter gen-l10n
import re, json
P = "lib/core/l10n/arb/app_uz.arb"
R = {
 "learnExamEmpty": [("avtomatik yaratilmaydi", "avtomatik tuzilmaydi")],
 "aiLimMock": [("javobi yaratilmadi", "javobi tayyorlanmadi")],
 "accountCreate": [("Hisob yaratish", "Ro‘yxatdan o‘tish")],
 "accountNoAccount": [("Hisob yo‘qmi? Yarating", "Hisob yo‘qmi? Ro‘yxatdan o‘ting")],
 "aiPreviewPoint1": [("javobi yaratilmaydi", "javobi tayyorlanmaydi")],
 "accountContinueWithoutNote": [("Profil bo‘limida yaratish mumkin", "Profil bo‘limida ro‘yxatdan o‘tish mumkin")],
 "accountCreateOrSignIn": [("Hisob yaratish / Kirish", "Ro‘yxatdan o‘tish / Kirish")],
 "referralSignInBody": [("serverda yaratiladi", "serverda tayyorlanadi")],
 "supClosedNote": [("yangisini yarating", "yangisini yuboring")],
 "casebookEmptyBody": [("yozuv yarating", "yozuv qo‘shing")],
 "casebookAiUnverified": [("tomonidan yaratilgan", "tomonidan tuzilgan")],
 "casebookAiAddNote": [("tomonidan yaratilgan", "tomonidan tuzilgan")],
 "grpTeacherTileBody": [("Guruh yarating", "Guruh tuzing")],
 "grpTeachingEmpty": [("Guruh yarating", "Guruh tuzing")],
 "grpCreateAction": [("Guruh yaratish", "Guruh tuzish")],
 "grpLessonNoGroups": [("yaratiladi", "tuziladi")],
 "grpLessonCreateGroup": [("Guruh yaratish", "Guruh tuzish")],
 "proCtxGroupLimit": [("bilan yaratiladi", "bilan tuziladi")],
 "scoringMidtermIntro": [("Yaratishdan oldin", "Tuzishdan oldin")],
 "oralErrTryAgain": [("Kod yaratib bo‘lmadi", "Kod tayyorlab bo‘lmadi")],
}
s = open(P, encoding="utf-8").read()
for key, subs in R.items():
    m = re.search(r'("' + key + r'":\s*)"((?:[^"\\]|\\.)*)"', s)
    assert m, key
    v = m.group(2)
    for a, b in subs:
        v = v.replace(a, b)
    s = s[:m.start(2)] + v + s[m.end(2):]
open(P, "w", encoding="utf-8").write(s)
left = re.findall(r'"[A-Za-z0-9_]+":\s*"[^"]*[Yy]arat[^"]*"', s)
print("qolgan:", len(left))
