#!/usr/bin/env bash
# «Ustoz–talaba testi»: ilovaning HAQIQIY Supabase adapteri
# (SupabaseClassGroupsService) → lokal PostgreSQL 16 dagi haqiqiy RPC'lar.
# PostgREST o'rniga test transporti har RPC'ni psql bilan, so'rovchi
# foydalanuvchi JWT `sub` i va `authenticated` roli bilan chaqiradi.
# 1 ustoz + 3 talaba: har talabaga boshqa savollar (Dart hisobi == server),
# natijalar ustoz panelida. Production'ga tegmaydi.
set -euo pipefail
PGBIN="${PGBIN:-/usr/lib/postgresql/16/bin}"
D="$(mktemp -d)"
trap '"$PGBIN/pg_ctl" -D "$D/data" stop -m immediate >/dev/null 2>&1 || true; rm -rf "$D"' EXIT
HERE="$(cd "$(dirname "$0")" && pwd)"
if [ "$(id -u)" = 0 ]; then RUN="runuser -u postgres --"; chown postgres "$D"; else RUN=""; fi
$RUN "$PGBIN/initdb" -D "$D/data" -A trust -U postgres -E UTF8 --locale=C.UTF-8 >/dev/null
$RUN "$PGBIN/pg_ctl" -D "$D/data" -o "-p 54331 -k $D -c listen_addresses=''" -l "$D/log" start >/dev/null
for i in $(seq 1 30); do "$PGBIN/pg_isready" -h "$D" -p 54331 >/dev/null 2>&1 && break; sleep 0.5; done
P="psql -h $D -p 54331 -U postgres -v ON_ERROR_STOP=1 -q"
$P -c "create database fe"
$P -d fe -f "$HERE/stubs.sql"
for m in "$HERE"/../migrations/*.sql; do $P -d fe -f "$m"; done
$P -d fe <<'SQL'
-- PostgREST o'rnini bosuvchi: public.<fname>(nomli argumentlar) — chaqiruvchi
-- rolida (security invoker), natija jsonb.
create schema e2e_tools;
create function e2e_tools.rpc(fname text, args jsonb) returns jsonb
language plpgsql as $$
declare
  pr record;
  parts text[] := '{}';
  i int;
  n text;
  t text;
  r jsonb;
begin
  select p.proargnames as names, p.proargtypes::oid[] as types into pr
  from pg_proc p where p.proname = fname and p.pronamespace = 'public'::regnamespace;
  if not found then raise exception 'no function %', fname using errcode = '42883'; end if;
  for i in 1 .. coalesce(array_length(pr.names, 1), 0) loop
    n := pr.names[i];
    t := format_type(pr.types[i - 1], null);
    continue when not (args ? n);
    parts := parts || format('%I => %s', n, case
      when jsonb_typeof(args -> n) = 'null' then 'null::' || t
      when t = 'jsonb' then quote_literal((args -> n)::text) || '::jsonb'
      -- PostgREST JSON massivni text[] ga o'zi aylantiradi; bu yerda ham.
      when t like '%[]' then format('array(select jsonb_array_elements_text(%L::jsonb))::%s',
                                    (args -> n)::text, t)
      else quote_literal(args ->> n) || '::' || t end);
  end loop;
  execute format('select to_jsonb(public.%I(%s))', fname, array_to_string(parts, ', ')) into r;
  return r;
end $$;
grant usage on schema e2e_tools to authenticated;
grant execute on function e2e_tools.rpc(text, jsonb) to authenticated;
insert into auth.users (id, email) values
 ('7d000000-0000-0000-0000-0000000000a1', 'dart-teacher@secret.example'),
 ('7d000000-0000-0000-0000-0000000000b1', 'dart-s1@secret.example'),
 ('7d000000-0000-0000-0000-0000000000b2', 'dart-s2@secret.example'),
 ('7d000000-0000-0000-0000-0000000000b3', 'dart-s3@secret.example');
insert into account_roles (user_id, role, granted_by)
values ('7d000000-0000-0000-0000-0000000000a1', 'teacher', null);
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'dart-tox', 'Toksikologiya: CO', g, 'Dart e2e savol ' || g,
       jsonb_build_array('A' || g, 'B' || g, 'C' || g, 'D' || g), (g % 4)::smallint,
       'Izoh ' || g, '{"author":"Muallif","title":"Darslik","page":"41"}'::jsonb
from generate_series(1, 20) g;
insert into public.class_quiz_questions
  (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'dart-co', 'Toksikologiya: CO', g, 'Dart CO savol ' || g,
       jsonb_build_array('A', 'B', 'C', 'D'), 1, '',
       '{"author":"Muallif","title":"Darslik","page":"9"}'::jsonb
from generate_series(1, 6) g;
SQL
cd "$HERE/../../apps/mobile"
export PATH="/opt/flutter/bin:$PATH"
FE_LOCAL_PG_HOST="$D" FE_LOCAL_PG_PORT=54331 flutter test test/integration/class_groups_local_pg_test.dart
