-- FORENSIC EXPERT — production'ga hali QO'LLANMAGAN qism (2026-10-18).
-- Sabab: ichida `delete from` bor, MCP tasdiq so'rovi 60 s ichida javobsiz qoldi.
-- Qo'llash: Supabase Dashboard → SQL Editor → shu faylni to'liq joylab Run.
-- Qolgan barcha qismlar (admin_extension 1/2a/2c/3a/3b, class_quiz 0–3) qo'llangan.
-- private.class_cleanup() hozir faqat eski sessiyalarni yopadi; bu fayl 30 kunlik o'chirishni yoqadi.

create function public.admin_set_role(p_user uuid, p_role text,
  p_grant boolean, p_reason text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  v_reason text := btrim(coalesce(p_reason, ''));
  v_result text;
begin
  if p_role is null or p_role not in ('identity_admin', 'publication_moderator') then
    return 'FORBIDDEN_ROLE';
  end if;
  if p_grant is null or length(v_reason) not between 5 and 300 then return 'INVALID'; end if;
  if not exists (select 1 from auth.users where id = p_user) then return 'NOT_FOUND'; end if;
  if p_role = 'identity_admin' then
    if p_user = me then return 'SELF_ADMIN_CHANGE'; end if;
    if p_grant and not (select s.allow_admin_grant_in_app from private.admin_settings s) then
      return 'FORBIDDEN_ROLE';
    end if;
  end if;
  if p_grant then
    if p_role = 'identity_admin' and not exists (select 1 from auth.users
         where id = p_user and email_confirmed_at is not null) then
      return 'EMAIL_UNCONFIRMED';
    end if;
    insert into public.account_roles (user_id, role, granted_by)
    values (p_user, p_role::public.account_role, me) on conflict do nothing;
    v_result := case when found then 'GRANTED' else 'UNCHANGED' end;
  else
    if p_role = 'identity_admin' and
       (select count(*) from public.account_roles where role = 'identity_admin') <= 1 then
      return 'LAST_ADMIN';
    end if;
    delete from public.account_roles where user_id = p_user and role = p_role::public.account_role;
    v_result := case when found then 'REVOKED' else 'UNCHANGED' end;
  end if;
  perform private.admin_log(me, 'ADMIN_ROLE_SET', 'user', p_user::text,
    jsonb_build_object('role', p_role, 'grant', p_grant, 'result', v_result,
      'reason', v_reason));
  return v_result;
end $$;

create function public.admin_set_suspension(p_user uuid, p_suspend boolean,
  p_reason text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  v_reason text := btrim(coalesce(p_reason, ''));
  v_was boolean;
begin
  if p_suspend is null or length(v_reason) not between 5 and 500 then return 'INVALID'; end if;
  if not exists (select 1 from auth.users where id = p_user) then return 'NOT_FOUND'; end if;
  if p_suspend then
    if p_user = me then return 'CANNOT_SUSPEND_SELF'; end if;
    if private.has_role(p_user, 'identity_admin') then return 'CANNOT_SUSPEND_ADMIN'; end if;
    v_was := exists (select 1 from public.account_suspensions where user_id = p_user);
    insert into public.account_suspensions (user_id, reason, suspended_by)
    values (p_user, v_reason, me)
    on conflict (user_id) do update set reason = excluded.reason,
      suspended_by = me, suspended_at = now();
    update auth.users set banned_until = now() + interval '36500 days' where id = p_user;
    delete from auth.refresh_tokens where user_id = p_user::text;
    delete from auth.sessions where user_id = p_user;
    perform private.admin_log(me, 'USER_SUSPENDED', 'user', p_user::text,
      jsonb_build_object('reason', v_reason));
    return case when v_was then 'UNCHANGED' else 'SUSPENDED' end;
  end if;
  v_was := exists (select 1 from public.account_suspensions where user_id = p_user);
  delete from public.account_suspensions where user_id = p_user;
  update auth.users set banned_until = null where id = p_user;
  perform private.admin_log(me, 'USER_RESTORED', 'user', p_user::text,
    jsonb_build_object('reason', v_reason));
  return case when v_was then 'RESTORED' else 'UNCHANGED' end;
end $$;

create function public.qa_unblock(p_block_id uuid) returns boolean
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'forbidden'; end if;
  delete from public.user_blocks where id = p_block_id and blocker_id = me;
  return found;
end $$;

create or replace function private.class_cleanup() returns int
language plpgsql security definer set search_path = '' as $$
declare n int;
begin
  -- Tugatilmay qolgan sessiyalar 24 soatdan keyin o'zi yopiladi.
  update public.class_sessions
     set status = 'finished', finished_at = now(),
         expires_at = now() + interval '30 days'
   where status <> 'finished' and created_at < now() - interval '24 hours';
  delete from public.class_sessions where expires_at is not null and expires_at < now();
  get diagnostics n = row_count;
  delete from public.class_join_attempts where hour < now() - interval '2 days';
  return n;
end $$;

revoke execute on function public.admin_set_role(uuid, text, boolean, text) from public, anon, authenticated;
revoke execute on function public.admin_set_suspension(uuid, boolean, text) from public, anon, authenticated;
revoke execute on function public.qa_unblock(uuid) from public, anon, authenticated;
revoke execute on function private.class_cleanup() from public, anon, authenticated;
grant execute on function public.admin_set_role(uuid, text, boolean, text) to authenticated;
grant execute on function public.admin_set_suspension(uuid, boolean, text) to authenticated;
grant execute on function public.qa_unblock(uuid) to authenticated;
