#!/usr/bin/env bash
# CI bilan bir xil tekshiruvlarni lokal ishga tushirish.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== pub get";            flutter pub get --enforce-lockfile >/dev/null
echo "== generated code";     (cd packages/fe_database && dart run build_runner build >/dev/null) && (cd apps/mobile && flutter gen-l10n >/dev/null) && git diff --exit-code
echo "== format";             dart format --output=none --set-exit-if-changed $(git ls-files '*.dart' | grep -v -E '\.g\.dart$|/generated/')
echo "== analyze packages";   dart analyze --fatal-infos packages
echo "== analyze app";        (cd apps/mobile && flutter analyze --fatal-infos)
for p in packages/*; do echo "== test $p"; (cd "$p" && dart test); done
echo "== test app";           (cd apps/mobile && flutter test)
echo "OK"
