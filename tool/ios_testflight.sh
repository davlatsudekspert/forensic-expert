#!/usr/bin/env bash
# iOS imzolangan IPA va TestFlight’ga yuklash — FAQAT CI’da, sirlar muhit
# o‘zgaruvchilaridan (GitHub Secrets). Kalit faylga faqat vaqtinchalik
# katalogda yoziladi va jurnalga chiqarilmaydi. App Review’ga yuborilmaydi.
#
# Kerakli muhit o‘zgaruvchilari: ASC_KEY_ID, ASC_ISSUER_ID, ASC_PRIVATE_KEY
# (.p8 matni), APPLE_TEAM_ID. Shuningdek App Store Connect’da bundle ID
# `uz.forensicexpert.app` uchun ilova yozuvi mavjud bo‘lishi shart.
set -euo pipefail
: "${ASC_KEY_ID:?missing}" "${ASC_ISSUER_ID:?missing}" "${ASC_PRIVATE_KEY:?missing}" "${APPLE_TEAM_ID:?missing}"

KEY_DIR="$(mktemp -d)"
trap 'rm -rf "$KEY_DIR"; rm -f "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"' EXIT
KEY_PATH="$KEY_DIR/AuthKey_${ASC_KEY_ID}.p8"
printf '%s' "$ASC_PRIVATE_KEY" > "$KEY_PATH"
chmod 600 "$KEY_PATH"

cat > "$KEY_DIR/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>method</key><string>app-store-connect</string>
  <key>teamID</key><string>${APPLE_TEAM_ID}</string>
  <key>signingStyle</key><string>automatic</string>
  <key>uploadSymbols</key><true/>
  <key>destination</key><string>export</string>
</dict></plist>
PLIST

# Avtomatik imzo: Xcode App Store Connect API kaliti bilan sertifikat va
# provisioning profilini oladi.
flutter build ipa --release \
  --export-options-plist="$KEY_DIR/ExportOptions.plist" \
  --build-number="${GITHUB_RUN_NUMBER:-1}" \
  -- -allowProvisioningUpdates \
  -authenticationKeyPath "$KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID" || {
    echo "::error::Signed IPA build failed (check team, bundle id, app record)"; exit 1; }

IPA="$(ls build/ios/ipa/*.ipa | head -1)"
FINAL_IPA="build/ios/ipa/forensic-expert-testflight.ipa"
[ "$IPA" = "$FINAL_IPA" ] || mv "$IPA" "$FINAL_IPA"
IPA="$FINAL_IPA"
shasum -a 256 "$IPA"

# altool kalitni shu katalogdan o‘qiydi (validate va upload uchun).
mkdir -p "$HOME/.appstoreconnect/private_keys"
cp "$KEY_PATH" "$HOME/.appstoreconnect/private_keys/"

# Imzo va identifikatorlarni tekshirish (TestFlight’ga faqat to‘g‘ri build).
CHECK_DIR="$(mktemp -d)"
unzip -q "$IPA" -d "$CHECK_DIR"
APP="$(ls -d "$CHECK_DIR"/Payload/*.app | head -1)"
BID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")"
VER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Info.plist")"
BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP/Info.plist")"
echo "bundle=$BID version=$VER build=$BUILD"
[ "$BID" = "uz.forensicexpert.app" ] || { echo "::error::unexpected bundle id $BID"; exit 1; }
codesign --verify --deep --strict "$APP"
codesign -dv --verbose=2 "$APP" 2>&1 | grep -E "Authority=Apple Distribution|TeamIdentifier" \
  || { echo "::error::IPA is not signed with an Apple Distribution certificate"; exit 1; }
[ -f "$APP/embedded.mobileprovision" ] || { echo "::error::no provisioning profile"; exit 1; }
security cms -D -i "$APP/embedded.mobileprovision" > "$CHECK_DIR/profile.plist"
/usr/libexec/PlistBuddy -c 'Print :Entitlements:get-task-allow' "$CHECK_DIR/profile.plist" 2>/dev/null | grep -q false \
  || { echo "::error::profile is not an App Store distribution profile"; exit 1; }
rm -rf "$CHECK_DIR"
xcrun altool --validate-app -f "$IPA" -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID" \
  || { echo "::error::App Store validation failed"; exit 1; }

xcrun altool --upload-app -f "$IPA" -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
rm -f "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
echo "Uploaded to App Store Connect (TestFlight processing). NOT submitted for review."
