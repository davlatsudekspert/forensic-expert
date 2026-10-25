#!/usr/bin/env python3
"""Lokal, bepul release konfiguratsiya tekshiruvi (build qilmaydi, tarmoqqa faqat --net bilan chiqadi).
Ishlatish: cd apps/mobile && python3 tool/release_check.py [--net]"""
import glob, os, plistlib, re, sys, urllib.request

R = []
def ok(c, name, detail=''):
    R.append(('PASS' if c else 'FAIL', name, detail))
def warn(name, detail=''):
    R.append(('WARN', name, detail))

pub = open('pubspec.yaml', encoding='utf8').read()
m = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)', pub, re.M)
ok(bool(m), 'pubspec version', m and f'{m.group(1)}+{m.group(2)}')
gr = open('android/app/build.gradle.kts', encoding='utf8').read()
app_id = re.search(r'applicationId\s*=\s*"([^"]+)"', gr).group(1)
ok(app_id == 'uz.forensicexpert.forensic_expert', 'Android applicationId', app_id)
ok('flutter.versionCode' in gr and 'flutter.versionName' in gr, 'Android version pubspec’dan olinadi')
ok('flutter.minSdkVersion' in gr and 'flutter.targetSdkVersion' in gr, 'Android min/targetSdk Flutter SDK’dan')
ok('requireReleaseSigning' in gr, 'Android: store build kalitsiz to‘xtatiladi (-PrequireReleaseSigning=true)')
man = open('android/app/src/main/AndroidManifest.xml', encoding='utf8').read()
perms = sorted(set(re.findall(r'uses-permission android:name="([^"]+)"', man)))
ok(perms == ['android.permission.CAMERA', 'android.permission.INTERNET'], 'Android ruxsatlar (faqat INTERNET, CAMERA)', ', '.join(p.split('.')[-1] for p in perms))
ok('usesCleartextTraffic="false"' in man and 'allowBackup="false"' in man, 'Android: cleartext o‘chiq, backup o‘chiq')
ok('required="false"' in man, 'Android: kamera majburiy emas')
pb = open('ios/Runner.xcodeproj/project.pbxproj', encoding='utf8').read()
bid = set(re.findall(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);', pb))
ok('uz.forensicexpert.app' in bid, 'iOS Bundle ID', 'uz.forensicexpert.app')
ok(set(re.findall(r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+);', pb)) == {'15.0'}, 'iOS deployment target 15.0')
pl = plistlib.load(open('ios/Runner/Info.plist', 'rb'))
ok(pl.get('CFBundleShortVersionString') == '$(FLUTTER_BUILD_NAME)' and pl.get('CFBundleVersion') == '$(FLUTTER_BUILD_NUMBER)', 'iOS versiya pubspec’dan')
ok(bool(pl.get('NSCameraUsageDescription')) and bool(pl.get('NSPhotoLibraryUsageDescription')), 'iOS: Camera/Photo usage description')
ok(pl.get('ITSAppUsesNonExemptEncryption') is False, 'iOS: ITSAppUsesNonExemptEncryption=false')
ok('NSAppTransportSecurity' not in pl or not pl['NSAppTransportSecurity'].get('NSAllowsArbitraryLoads'), 'iOS: ATS ochiq emas')
px = plistlib.load(open('ios/Runner/PrivacyInfo.xcprivacy', 'rb'))
ok(px.get('NSPrivacyTracking') is False, 'iOS PrivacyInfo: tracking yo‘q', 'yig‘ilgan: ' + ', '.join(c['NSPrivacyCollectedDataType'].split('DataType')[-1] for c in px.get('NSPrivacyCollectedDataTypes', [])))
ent = plistlib.load(open('ios/Runner/Runner.entitlements', 'rb'))
ok('com.apple.developer.applesignin' in ent, 'iOS: Sign in with Apple entitlement')
try:
    from PIL import Image
    ic = glob.glob('ios/Runner/Assets.xcassets/AppIcon.appiconset/*1024*.png')[0]
    im = Image.open(ic)
    ok(im.size == (1024, 1024) and im.mode == 'RGB', 'iOS 1024 ikonka alfa kanalsiz', f'{im.size} {im.mode}')
except Exception as e:
    warn('PIL yo‘q — ikonka tekshirilmadi', str(e))
ok(len(glob.glob('android/app/src/main/res/mipmap-*/ic_launcher*.png')) >= 5, 'Android ikonkalar mavjud')
ok(os.path.exists('../../docs/legal/privacy.html'), 'Maxfiylik siyosati manbasi (docs/legal/privacy.html)')
priv = open('../../docs/legal/privacy.html', encoding='utf8').read()
ok('id="terms-of-use"' in priv and 'Obunalar' in priv, 'Maxfiylik sahifasida obuna va Foydalanish shartlari bo‘limi')
ks = [f for f in ('android/key.properties',) if os.path.exists(f)]
warn('Android release kaliti lokal yo‘q', 'GitHub secrets (ANDROID_KEYSTORE_*) orqali CI’da; lokalda tekshirib bo‘lmaydi') if not ks else ok(True, 'key.properties bor')
if '--net' in sys.argv:
    for u in ('https://davlatsudekspert.github.io/forensic-expert-legal/',):
        try:
            c = urllib.request.urlopen(urllib.request.Request(u, headers={'User-Agent': 'Mozilla/5.0'}), timeout=25).status
        except Exception as e:
            c = str(e)
        ok(c == 200, 'Ochiq maxfiylik URL', f'{c} {u}')
w = max(len(n) for _, n, _ in R)
for s, n, d in R:
    print(f'{s:4} {n:{w}}  {d}')
bad = sum(1 for s, _, _ in R if s == 'FAIL')
print(f'\n{len(R)} tekshiruv, FAIL={bad}, WARN={sum(1 for s,_,_ in R if s=="WARN")}')
sys.exit(1 if bad else 0)
