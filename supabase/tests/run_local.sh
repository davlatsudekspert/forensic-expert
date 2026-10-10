#!/usr/bin/env bash
# Local verification of the Supabase migration on a throwaway PostgreSQL 16.
set -euo pipefail
PGBIN="${PGBIN:-/usr/lib/postgresql/16/bin}"
D="$(mktemp -d)"
trap '"$PGBIN/pg_ctl" -D "$D/data" stop -m immediate >/dev/null 2>&1 || true; rm -rf "$D"' EXIT
HERE="$(cd "$(dirname "$0")" && pwd)"
if [ "$(id -u)" = 0 ]; then RUN="runuser -u postgres --"; chown postgres "$D"; else RUN=""; fi
$RUN "$PGBIN/initdb" -D "$D/data" -A trust -U postgres >/dev/null
$RUN "$PGBIN/pg_ctl" -D "$D/data" -o "-p 54329 -k $D -c listen_addresses=''" -l "$D/log" start >/dev/null
for i in $(seq 1 30); do "$PGBIN/pg_isready" -h "$D" -p 54329 >/dev/null 2>&1 && break; sleep 0.5; done
P="psql -h $D -p 54329 -U postgres -v ON_ERROR_STOP=1 -q"
$P -c "create database fe"
$P -d fe -f "$HERE/stubs.sql"
for m in "$HERE"/../migrations/*.sql; do $P -d fe -f "$m"; done
$P -d fe -f "$HERE/security_test.sql"
$P -d fe -f "$HERE/referral_test.sql"
$P -d fe -f "$HERE/admin_test.sql"
$P -d fe -f "$HERE/publications_test.sql"
$P -d fe -f "$HERE/support_admin_test.sql"
$P -d fe -f "$HERE/admin_verification_test.sql"
# RLS role matrix: fresh database with Supabase-like default table grants
# (the files above grant/revoke privileges for their own checks). Roles are
# cluster-wide, so stubs.sql is loaded without its CREATE ROLE lines.
$P -c "create database fe_matrix"
grep -v '^create role ' "$HERE/stubs.sql" | $P -d fe_matrix
$P -d fe_matrix -f "$HERE/stubs_supabase_defaults.sql"
for m in "$HERE"/../migrations/*.sql; do $P -d fe_matrix -f "$m"; done
$P -d fe_matrix -f "$HERE/rls_role_matrix_test.sql"
