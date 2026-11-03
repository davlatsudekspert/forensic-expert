#!/usr/bin/env bash
# Promo yozuvi: haqiqiy ilova (Linux desktop, Xvfb) -> xom MKV + events.json.
#   rec.sh <test.dart> <name> [plan.json]
# Natija: $PROMO_OUT/<name>.raw.mkv, <name>.events.json, <name>.log
# Oyna 390x844 mantiqiy (GDK_SCALE=2 -> 780x1688 piksel), dekorasiyasiz.
# XAVFSIZLIK: FE_SUPABASE_* o'rnatilmaydi (mock akkaunt, tarmoq yo'q).
set -uo pipefail
pkill -f 'ffmpeg.*x11grab' 2>/dev/null; pkill -f flutter_tester 2>/dev/null
TEST="$1"; NAME="$2"; PLAN="${3:-}"
export PATH=/opt/flutter/bin:$PATH TMPDIR=/dev/shm/tmp
for v in FE_SUPABASE_URL FE_SUPABASE_ANON_KEY FE_AUTH_BASE_URL; do
  [[ -n "${!v:-}" ]] && { echo "$v o'rnatilgan - to'xtatildi" >&2; exit 3; }
done
APP=/home/user/fe-pro/apps/mobile
SP=/tmp/claude-0/-home-user-forensic-expert/175c64be-a763-5e6d-b5d4-87e9aa8fedc6/scratchpad
export PROMO_OUT="${PROMO_OUT:-$SP/promo_work/rec}"
export PROMO_DECKS="${PROMO_DECKS:-$SP/promo_work/data/promo_decks.json}"
[[ -n "$PLAN" ]] && export PROMO_PLAN="$PLAN"
mkdir -p "$PROMO_OUT" /dev/shm/tmp
export PROMO_READY="/dev/shm/promo/ready_$NAME"; rm -f "$PROMO_READY" "$PROMO_OUT/$NAME.events.json"
D=:77
pkill -f "Xvfb $D" 2>/dev/null; sleep 0.5
Xvfb $D -screen 0 1000x1800x24 -nolisten tcp >/dev/null 2>&1 &
XPID=$!; sleep 1
export DISPLAY=$D GDK_SCALE=2 GDK_BACKEND=x11 LIBGL_ALWAYS_SOFTWARE=1
cd "$APP"
flutter test "$TEST" -d linux ${FLUTTER_EXTRA:-} \
  --dart-define=FE_AUTH_MODE=mock --dart-define=FE_PUBLICATIONS=true \
  >"$PROMO_OUT/$NAME.log" 2>&1 &
FPID=$!
# Oynani kutish
WID=""
for i in $(seq 1 600); do
  WID=$(xdotool search --onlyvisible --name forensic_expert 2>/dev/null | head -1)
  [[ -n "$WID" ]] && break
  kill -0 $FPID 2>/dev/null || { echo "flutter test erta tugadi"; tail -30 "$PROMO_OUT/$NAME.log"; kill $XPID; exit 1; }
  sleep 1
done
echo "oyna: $WID"
xdotool windowsize "$WID" 780 1688; xdotool windowmove "$WID" 0 0; sleep 2
xwininfo -id "$WID" | grep -E "Absolute|Width|Height"
sleep 2
[[ -z "${NOREC:-}" ]] && ffmpeg -y -loglevel error -f x11grab -framerate 30 -video_size 780x1688 -draw_mouse 0 -i $D.0+0,0 \
  -c:v libx264 -preset ultrafast -crf 10 -pix_fmt yuv444p "$PROMO_OUT/$NAME.raw.mkv" </dev/null &
FF=$!
sleep 1.5
touch "$PROMO_READY"
wait $FPID; RC=$?
sleep 1
sleep 3; kill -TERM $FF 2>/dev/null; wait $FF 2>/dev/null
kill $XPID 2>/dev/null
echo "flutter rc=$RC"
tail -5 "$PROMO_OUT/$NAME.log"
ls -la "$PROMO_OUT/$NAME".*
