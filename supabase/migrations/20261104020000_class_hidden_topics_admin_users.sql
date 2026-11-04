-- Production'ga 2026-11-04 da qo'llangan (migration yozuvi repoga keyin qo'shildi).
-- 1) Test mavzularini vaqtincha yashirish (jadval bo'sh; qaytarish: delete from public.class_hidden_topics).
create table if not exists public.class_hidden_topics (
  topic_id text primary key, note text, created_at timestamptz not null default now());
alter table public.class_hidden_topics enable row level security;
revoke all on public.class_hidden_topics from anon, authenticated;
-- class_topics() va class_practice_topics() endi shu jadvaldagi mavzularni chiqarmaydi
-- (to'liq tana — production'dagi funksiya ta'rifi; qarang: pg_get_functiondef).
-- 2) admin_users(): sahifa kamida 150 qator (v_limit := least(greatest(coalesce(p_limit,50),150),200)).
