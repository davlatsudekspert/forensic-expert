#!/usr/bin/env bash
# Real-ilova QA: ilovani Linux desktop’da (haqiqiy Flutter dvigateli, Xvfb)
# ishga tushirib, TALABA va MUTAXASSIS yo‘llarini foydalanuvchi kabi bosib
# chiqadi va har qadam skrinshotini saqlaydi.
#
#   ./tool/qa_real_app.sh                 # ikkala rol
#   ./tool/qa_real_app.sh student         # faqat talaba
#   ./tool/qa_real_app.sh home            # birinchi ishga tushirish, Asosiy, Profil
#                                         # (qorong‘i, 320 dp ×2, ru/en)
#   QA_OUT=/tmp/qa ./tool/qa_real_app.sh  # boshqa natija katalogi
#
# Natija: docs/qa/real_app_YYYYMMDD/ (PNG + results_<rol>.json).
# Talablar (Ubuntu): flutter, xvfb, clang, cmake, ninja-build, pkg-config,
#   libgtk-3-dev, libsecret-1-dev.
#
# XAVFSIZLIK: yig‘ma FE_SUPABASE_* / FE_AUTH_BASE_URL / FE_AI_REMOTE’siz
# quriladi — production backend’ga hech narsa yuborilmaydi. Akkaunt MOCK
# (FE_AUTH_MODE=mock, xotirada), testlar barcha HTTP ulanishlarni bloklaydi.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/mobile"
OUT="${QA_OUT:-$ROOT/docs/qa/real_app_$(date +%Y%m%d)}"
ROLES=("${@:-student expert}")
read -r -a ROLES <<<"${ROLES[*]}"

for bin in flutter xvfb-run pkg-config; do
  command -v "$bin" >/dev/null || { echo "QA: '$bin' topilmadi" >&2; exit 2; }
done
for lib in gtk+-3.0 libsecret-1; do
  pkg-config --exists "$lib" || { echo "QA: $lib (dev) o‘rnatilmagan" >&2; exit 2; }
done
for v in FE_SUPABASE_URL FE_SUPABASE_ANON_KEY FE_AUTH_BASE_URL; do
  if [[ -n "${!v:-}" ]]; then
    echo "QA: $v muhitda o‘rnatilgan — xavfsizlik uchun to‘xtatildi." >&2
    exit 3
  fi
done

mkdir -p "$OUT"
cd "$APP"
flutter config --enable-linux-desktop >/dev/null

status=0
for role in "${ROLES[@]}"; do
  echo "== QA real app: $role"
  # Eski build konfiguratsiyalari diskni to‘ldirmasin.
  { ls -td .dart_tool/flutter_build/*/ 2>/dev/null || true; } | tail -n +3 | xargs -r rm -rf
  QA_OUT="$OUT" xvfb-run -a -s "-screen 0 1280x1024x24" \
    flutter test "integration_test/qa_${role}_test.dart" -d linux \
    --dart-define=FE_AUTH_MODE=mock \
    --dart-define=FE_PUBLICATIONS=true 2>&1 |
    grep -E '^QA |All tests passed|Some tests failed|\[E\]' || true
  if [[ ! -f "$OUT/results_${role}.json" ]]; then
    echo "QA: $role natijasi yozilmadi" >&2
    status=1
    continue
  fi
  python3 - "$OUT/results_${role}.json" <<'PY' || status=1
import json, sys
d = json.load(open(sys.argv[1]))
print(f"   {d['role']}: {d['pass']} PASS / {d['fail']} FAIL")
sys.exit(1 if d["fail"] else 0)
PY
done

echo "Skrinshotlar: $OUT ($(ls "$OUT"/*.png 2>/dev/null | wc -l) ta PNG)"
exit $status
