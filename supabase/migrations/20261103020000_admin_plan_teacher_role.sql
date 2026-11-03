-- Admin «Pro berish»: «Ustoz Pro» (plan 'teacher') berilganda server ustoz roli
-- (account_roles 'teacher') ham beriladi — aks holda ustoz taqdimotlar/guruh
-- testini ocha olmaydi (egasi, 2026-11-03: Dehqonovda reja bor, taqdimot ochilmadi).
-- Rolni REJA OLIB TASHLANGANDA o‘chirmaymiz (boshqa yo‘l bilan berilgan bo‘lishi
-- mumkin); olib tashlash — alohida, qo‘lda. Qolgan mantiq o‘zgarmagan.

create or replace function public.admin_set_plan(p_email text, p_plan text, p_until timestamptz)
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare me uuid := private.admin_guard(); target uuid; v_result text; r public.plans;
  store_active boolean;
begin
  select id into target from auth.users where lower(email) = lower(trim(p_email));
  if target is null then
    v_result := 'NOT_FOUND';
  elsif p_plan is null then
    select * into r from public.plans where user_id = target;
    if found and r.source = 'store' and (r.expires_at is null or r.expires_at > now()) then
      update public.plans set alt_plan = null, alt_source = null, alt_expires_at = null,
        updated_at = now() where user_id = target;
    else
      delete from public.plans where user_id = target;
    end if;
    v_result := 'REVOKED';
  elsif p_plan not in ('student', 'teacher', 'expert', 'premium')
        or (p_until is not null and p_until <= now()) then
    v_result := 'INVALID';
  else
    select * into r from public.plans where user_id = target;
    store_active := found and r.source = 'store' and (r.expires_at is null or r.expires_at > now());
    if store_active then
      if p_until is null or r.expires_at is null or p_until > r.expires_at then
        update public.plans set alt_plan = p_plan, alt_source = 'admin', alt_expires_at = p_until,
          updated_at = now() where user_id = target;
      end if;
    else
      insert into public.plans (user_id, plan, source, platform, expires_at, auto_renew, note, updated_at)
      values (target, p_plan, 'admin', 'other', p_until, false, 'admin panel', now())
      on conflict (user_id) do update
        set plan = excluded.plan, source = 'admin', platform = 'other', product_id = null,
            original_transaction_id = null, started_at = now(), expires_at = excluded.expires_at,
            auto_renew = false, note = 'admin panel', alt_plan = null, alt_source = null,
            alt_expires_at = null, updated_at = now();
    end if;
    -- Ustoz rejasi → ustoz roli (taqdimotlar, guruh testi). Audit trigger yozadi.
    if p_plan = 'teacher' then
      insert into public.account_roles (user_id, role, granted_by)
      values (target, 'teacher', case when target <> me then me end)
      on conflict (user_id, role) do nothing;
    end if;
    v_result := 'GRANTED';
  end if;
  perform private.plan_event(target, me, 'ADMIN_' || v_result, p_plan, 'admin', p_until, '{}'::jsonb);
  perform private.admin_log(me, 'PLAN_SET', 'user', target::text,
    jsonb_build_object('plan', p_plan, 'until', p_until, 'result', v_result));
  return jsonb_build_object('result', v_result);
end $$;
