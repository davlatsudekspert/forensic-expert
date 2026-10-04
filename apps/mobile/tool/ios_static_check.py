#!/usr/bin/env python3
"""iOS statik tekshiruvi (macOS/Xcode’siz). Bu REAL iOS BUILD EMAS.

Tekshiradi: Info.plist, bundle ID, deployment target, ikonlar (alpha yo‘q),
launch screen, lokalizatsiyalar, StoreKit plagini, privacy manifest va
export compliance kaliti. Natija: PASS / FAIL / OPEN (inson qarori kerak).
Ishga tushirish: apps/mobile ichida `python3 tool/ios_static_check.py`.
"""
import glob, json, plistlib, re, sys

from PIL import Image

res = []


def check(name, ok, detail="", open_item=False):
    res.append(("OPEN" if open_item else ("PASS" if ok else "FAIL"), name, detail))


info = plistlib.load(open("ios/Runner/Info.plist", "rb"))
pbx = open("ios/Runner.xcodeproj/project.pbxproj").read()
pub = open("pubspec.yaml").read()

check("Info.plist o‘qiladi (plist sintaksisi)", True)
check("CFBundleDisplayName", info.get("CFBundleDisplayName") == "FORENSIC EXPERT", info.get("CFBundleDisplayName", ""))
ids = set(re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = ([\w.]+);", pbx))
app_ids = {i for i in ids if not i.endswith("RunnerTests")}
check("Bundle ID barcha konfiguratsiyada bir xil", len(app_ids) == 1, ", ".join(sorted(app_ids)))
targets = set(re.findall(r"IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+);", pbx))
check("Deployment target ≥ 13.0 (bitta qiymat)", len(targets) == 1 and float(next(iter(targets))) >= 13.0, ", ".join(targets))
check("Launch screen", info.get("UILaunchStoryboardName") == "LaunchScreen"
      and bool(glob.glob("ios/Runner/Base.lproj/LaunchScreen.storyboard")))
check("Lokalizatsiyalar (en, ru, uz)", set(info.get("CFBundleLocalizations", [])) == {"en", "ru", "uz"},
      ", ".join(info.get("CFBundleLocalizations", [])))
contents = json.load(open("ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json"))
missing, alpha = [], []
for img in contents["images"]:
    f = img.get("filename")
    if not f:
        continue
    path = f"ios/Runner/Assets.xcassets/AppIcon.appiconset/{f}"
    try:
        im = Image.open(path)
    except FileNotFoundError:
        missing.append(f)
        continue
    w = round(float(img["size"].split("x")[0]) * int(img["scale"][0]))
    if im.size != (w, w):
        missing.append(f"{f} (o‘lcham {im.size} ≠ {w})")
    if im.mode in ("RGBA", "LA", "P"):
        alpha.append(f)
check("AppIcon: barcha fayl mavjud, o‘lcham to‘g‘ri", not missing, "; ".join(missing))
check("AppIcon: alpha kanal yo‘q (App Store talabi)", not alpha, "; ".join(alpha))
check("1024×1024 marketing ikon", any(i.get("size") == "1024x1024" for i in contents["images"]))
check("StoreKit plagini (in_app_purchase_storekit)", "in_app_purchase_storekit" in pub)
check("Qurilma oilasi", True, "TARGETED_DEVICE_FAMILY = " + ",".join(set(re.findall(r'TARGETED_DEVICE_FAMILY = "([\d,]+)"', pbx)))
      + " (iPad layout real qurilmada tekshirilmagan)")
check("Privacy manifest (PrivacyInfo.xcprivacy)", False,
      "yo‘q — ma’lumot yig‘ish va required-reason API deklaratsiyasi egasi/yurist tasdig‘ini talab qiladi", open_item=True)
check("Export compliance (ITSAppUsesNonExemptEncryption)", False,
      "deklaratsiya qilinmagan — huquqiy qaror (faqat HTTPS bo‘lsa odatda exempt)", open_item=True)
check("Real Xcode build / TestFlight / real iPhone", False,
      "bu muhitda macOS/Xcode yo‘q — iOS build BAJARILMAGAN", open_item=True)

w = max(len(n) for _, n, _ in res)
for st, n, d in res:
    print(f"[{st:4}] {n.ljust(w)}  {d}")
fails = [r for r in res if r[0] == "FAIL"]
print(f"\nPASS={sum(r[0]=='PASS' for r in res)} FAIL={len(fails)} OPEN={sum(r[0]=='OPEN' for r in res)}")
sys.exit(1 if fails else 0)
