#!/usr/bin/env bash
# iOS imzolangan IPA va TestFlight’ga yuklash — FAQAT CI’da, sirlar muhit
# o‘zgaruvchilaridan (GitHub Secrets). Kalit faylga faqat vaqtinchalik
# katalogda yoziladi va jurnalga chiqarilmaydi. App Review’ga yuborilmaydi.
#
# Kerakli muhit o‘zgaruvchilari: ASC_KEY_ID, ASC_ISSUER_ID, ASC_PRIVATE_KEY
# (.p8 matni), APPLE_TEAM_ID. Shuningdek App Store Connect’da bundle ID
# `uz.forensicexpert.forensicExpert` uchun ilova yozuvi mavjud bo‘lishi shart.
set -euo pipefail
: "${ASC_KEY_ID:?missing}" "${ASC_ISSUER_ID:?missing}" "${ASC_PRIVATE_KEY:?missing}" "${APPLE_TEAM_ID:?missing}"

KEY_DIR="$(mktemp -d)"
trap 'rm -rf "$KEY_DIR"' EXIT
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
shasum -a 256 "$IPA"

mkdir -p "$HOME/.appstoreconnect/private_keys"
cp "$KEY_PATH" "$HOME/.appstoreconnect/private_keys/"
xcrun altool --upload-app -f "$IPA" -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
rm -f "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
echo "Uploaded to App Store Connect (TestFlight processing). NOT submitted for review."
