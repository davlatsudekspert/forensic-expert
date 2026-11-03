#!/usr/bin/env bash
# 30 TA BIR VAQTDAGI TALABA: «Guruh testi» va «Guruh og‘zaki imtihoni» (haqiqiy
# RPC'lar, lokal PostgreSQL 16; production'ga tegmaydi).
# Ishlatish: supabase/tests/load_30_students.sh [talabalar_soni=30]
set -uo pipefail
N="${1:-30}"
PGBIN="${PGBIN:-/usr/lib/postgresql/16/bin}"
HERE="$(cd "$(dirname "$0")" && pwd)"
D="$(mktemp -d)"
trap '"$PGBIN/pg_ctl" -D "$D/data" stop -m immediate >/dev/null 2>&1 || true; rm -rf "$D"' EXIT
if [ "$(id -u)" = 0 ]; then RUN="runuser -u postgres --"; chown postgres "$D"; else RUN=""; fi
EXT="$("$PGBIN/pg_config" --sharedir)/extension"
for e in pg_cron pg_net; do
  [ -f "$EXT/$e.control" ] || cp "$HERE/fake_extensions/$e.control" "$HERE/fake_extensions/$e--1.0.sql" "$EXT/"
done
$RUN "$PGBIN/initdb" -D "$D/data" -A trust -U postgres -E UTF8 --locale=C.UTF-8 >/dev/null
$RUN "$PGBIN/pg_ctl" -D "$D/data" -o "-p 54330 -k $D -c listen_addresses='' -c max_connections=200" -l "$D/log" start >/dev/null
for i in $(seq 1 30); do "$PGBIN/pg_isready" -h "$D" -p 54330 >/dev/null 2>&1 && break; sleep 0.5; done
export PSQLBIN="$PGBIN/psql" PGHOST="$D" PGPORT=54330 PGUSER=postgres
P="$PGBIN/psql -h $D -p 54330 -U postgres -v ON_ERROR_STOP=1 -q -tA"
$P -c "create database fe" >/dev/null
$P -d fe -f "$HERE/stubs.sql" >/dev/null
for m in "$HERE"/../migrations/*.sql; do $P -d fe -f "$m" >/dev/null || { echo "MIGRATSIYA XATO: $m"; exit 1; }; done
export PGDATABASE=fe

FAIL=0
ok()   { echo "  PASS  $1"; }
bad()  { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }
check(){ if [ "$1" = "$2" ]; then ok "$3 ($1)"; else bad "$3: kutilgan=$2, chiqqan=$1"; fi; }

TEACHER='aa000000-0000-0000-0000-000000000001'
sid() { printf '77000000-0000-0000-0000-%012x' "$1"; }

# ---- seed: ustoz, N+1 talaba, savollar
SEED="insert into auth.users (id, email, created_at, email_confirmed_at) values ('$TEACHER','ustoz@test.uz',now(),now());
insert into public.account_roles (user_id, role) values ('$TEACHER','teacher');"
for i in $(seq 1 $((N+1))); do
  SEED="$SEED insert into auth.users (id, email, created_at, email_confirmed_at) values ('$(sid $i)','talaba$i@test.uz',now(),now());"
done
SEED="$SEED insert into public.class_quiz_questions (topic_id, topic_title, position, question, options, correct_index, explanation, source, is_demo)
 select 'load-topic','Yuklama mavzu', g, 'Savol '||g, jsonb_build_array('A'||g,'B'||g,'C'||g,'D'||g), (g%4)::smallint, 'izoh',
        '{\"author\":\"Test\",\"title\":\"Kitob\",\"page\":\"1\"}'::jsonb, false from generate_series(1,12) g;"
$P -c "$SEED" >/dev/null || { echo "SEED XATO"; exit 1; }

# uid sifatida bitta RPC chaqirish (har chaqiruv — alohida ulanish, ya’ni haqiqiy parallellik)
as() { local uid="$1"; shift
  $P -c "select set_config('request.jwt.claim.sub','$uid',false); select set_config('request.jwt.claims','{}',false); select set_config('role','authenticated',false); $*" 2>&1 | tail -1; }
export -f as; export P; export -f sid

echo "== A. GURUH TESTI (jonli), $N talaba =="
R=$(as "$TEACHER" "select public.class_create_session('load-topic', 5, $N, 30)")
SID=$(echo "$R" | python3 -c "import sys,json; d=json.load(sys.stdin); s=d.get('session',d); print(s.get('id',''))")
CODE=$(echo "$R" | python3 -c "import sys,json; d=json.load(sys.stdin); s=d.get('session',d); print(s.get('code',''))")
[ -n "$SID" ] && ok "ustoz sessiya yaratdi (kod $CODE)" || { bad "sessiya yaratilmadi: $R"; }
export SID CODE

OUT=$(seq 1 $N | xargs -P $N -I{} bash -c 'as "$(sid {})" "select public.class_join_session('"'"'$CODE'"'"', '"'"'Talaba {}'"'"')"')
OKN=$(echo "$OUT" | grep -c '"ok": *true')
check "$OKN" "$N" "bir vaqtda qo‘shilgan talabalar"
ERRS=$(echo "$OUT" | grep -c '"error"')
[ "$ERRS" != 0 ] && echo "      namuna xato: $(echo "$OUT" | grep '"error"' | sort | uniq -c | head -3)"
check "$ERRS" "0" "qo‘shilishda xato"
PART=$($P -c "select count(*) from public.class_participants where session_id='$SID'")
check "$PART" "$N" "bazadagi ishtirokchilar"

R=$(as "$TEACHER" "select public.class_start('$SID')")
echo "$R" | grep -q '"ok": *true' && ok "ustoz testni boshladi" || bad "start: $R"

for q in 0 1 2 3 4; do
  OUT=$(seq 1 $N | xargs -P $N -I{} bash -c 'as "$(sid {})" "select public.class_submit_answer('"'"'$SID'"'"', '$q', '"'"'o$(( {} % 4 ))'"'"')"')
  E=$(echo "$OUT" | grep -c '"error"'); A=$(echo "$OUT" | grep -c '"ok": *true')
  check "$A/$E" "$N/0" "savol $((q+1)): javoblar/xatolar"
  as "$TEACHER" "select public.class_close_question('$SID')" >/dev/null
  as "$TEACHER" "select public.class_next('$SID')" >/dev/null
done
as "$TEACHER" "select public.class_finish('$SID')" >/dev/null
ANS=$($P -c "select count(*) from public.class_answers where session_id='$SID'")
check "$ANS" "$((N*5))" "jami javoblar ($N talaba × 5 savol)"
RES=$(seq 1 $N | xargs -P $N -I{} bash -c 'as "$(sid {})" "select public.class_my_results('"'"'$SID'"'"')"' | grep -c '"error"')
check "$RES" "0" "talabalar o‘z natijasini ko‘rdi (xatosiz)"
DASH=$(as "$TEACHER" "select jsonb_array_length(coalesce(public.class_export_results('$SID')->'items', public.class_export_results('$SID')->'rows', '[]'::jsonb))")
check "$DASH" "$N" "ustoz natijalar ro‘yxati"

echo "== B. GURUH OG‘ZAKI IMTIHONI (QR), $N talaba =="
TICKETS=$(python3 -c "
import json
print(json.dumps([[{'id':f'q{t}-{i}','text':f'Savol {t}.{i}'} for i in range(1,6)] for t in range(1,$N+1)]))")
R=$(as "$TEACHER" "select public.oral_create_session('Yuklama', '$TICKETS'::jsonb, 0)")
OSID=$(echo "$R" | python3 -c "import sys,json; print(json.load(sys.stdin)['session']['id'])" 2>/dev/null)
OCODE=$(echo "$R" | python3 -c "import sys,json; print(json.load(sys.stdin)['session']['code'])" 2>/dev/null)
[ -n "$OSID" ] && ok "ustoz $N biletli imtihon yaratdi (kod $OCODE)" || bad "oral_create: $R"
export OSID OCODE

OUT=$(seq 1 $N | xargs -P $N -I{} bash -c 'as "$(sid {})" "select public.oral_join_session('"'"'$OCODE'"'"', '"'"'Talaba {}'"'"')"')
check "$(echo "$OUT" | grep -c '"ok": *true')" "$N" "bir vaqtda qo‘shilgan"
DIST=$($P -c "select count(distinct ticket_no) from public.oral_participants where session_id='$OSID'")
check "$DIST" "$N" "har talabaga BOSHQA bilet (takror yo‘q)"
OUT31=$(as "$(sid $((N+1)))" "select public.oral_join_session('$OCODE', 'Ortiqcha')")
echo "$OUT31" | grep -q '"full"' && ok "$((N+1))-talaba: «bilet qolmadi» (full)" || bad "ortiqcha talaba: $OUT31"
RE=$(seq 1 $N | xargs -P $N -I{} bash -c 'as "$(sid {})" "select public.oral_ready('"'"'$OSID'"'"')"' | grep -c '"ok": *true')
check "$RE" "$N" "hammasi «Javobga tayyorman» bosdi"
ST=$(as "$TEACHER" "select public.oral_teacher_state('$OSID')")
check "$(echo "$ST" | python3 -c "import sys,json; d=json.load(sys.stdin); print(sum(1 for p in d['participants'] if p['ready_at']))")" "$N" "ustoz navbatda $N ta tayyorni ko‘radi"
# ustoz har birini chaqiradi va baholaydi; talaba faqat O‘Z balini ko‘radi
IDS=$(echo "$ST" | python3 -c "import sys,json; d=json.load(sys.stdin); print(' '.join(p['id'] for p in d['participants']))")
GR=0
for pid in $IDS; do
  as "$TEACHER" "select public.oral_call('$OSID','$pid')" >/dev/null
  G=$(as "$TEACHER" "select public.oral_grade('$OSID','$pid', array[15,16,17,18,19])")
  echo "$G" | grep -q '"total": *85' && GR=$((GR+1))
done
check "$GR" "$N" "ustoz $N talabani baholadi (jami 85)"
MY=$(as "$(sid 7)" "select public.oral_my_state('$OSID')")
echo "$MY" | grep -q '"total": *85' && ok "talaba o‘z bali: 85" || bad "talaba bali: $MY"
echo "$MY" | grep -Eq 'Talaba (1|2|3|4|5|6|8|9)"' && bad "talaba BOSHQA talabaning ismini ko‘rdi!" || ok "talaba boshqalar ismini ko‘rmaydi"
LV=$(as "$(sid 7)" "select public.oral_report_leave('$OSID')")
echo "$LV" | grep -q 'not_allowed' && ok "baholangan talabaga «chiqdi» hisoblanmaydi" || bad "leave: $LV"
ST2=$(as "$TEACHER" "select public.oral_teacher_state('$OSID')")
check "$(echo "$ST2" | python3 -c "import sys,json; d=json.load(sys.stdin); print(sum(1 for p in d['participants'] if p['graded_at']))")" "$N" "ustozda $N ta baholangan"
as "$TEACHER" "select public.oral_finish('$OSID')" >/dev/null
LATE=$(as "$(sid $((N+1)))" "select public.oral_join_session('$OCODE', 'Kech')")
echo "$LATE" | grep -q 'finished' && ok "yakunlangach yangi talaba kira olmaydi" || bad "late: $LATE"

echo
if [ "$FAIL" = 0 ]; then echo "NATIJA: HAMMASI O‘TDI ($N talaba)"; else echo "NATIJA: $FAIL ta XATO"; exit 1; fi
