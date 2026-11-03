-- Imtihon paytida AI yopiq (egasi, 2026-11-03): talaba jonli testda yoki
-- baholanmagan og‘zaki biletda bo‘lsa, `ai-answer` funksiyasi uni rad etadi
-- (423 exam_locked). O‘rganish (o‘zim yechib ko‘rish, o‘qish) paytida AI ochiq.
-- Ustoz ishtirokchi emas — unga ta’sir qilmaydi. 6 soatdan eski sessiya
-- (tashlab ketilgan) hisobga olinmaydi.
create function private.ai_exam_locked(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select p_user is not null and (
    exists (
      select 1
        from public.class_participants p
        join public.class_sessions s on s.id = p.session_id
       where p.user_id = p_user
         and p.kicked_at is null
         and p.finished_at is null
         and s.status in ('lobby', 'running')
         and s.created_at > now() - interval '6 hours')
    or exists (
      select 1
        from public.oral_participants p
        join public.oral_sessions s on s.id = p.session_id
       where p.user_id = p_user
         and p.kicked_at is null
         and p.graded_at is null
         and s.status = 'open'
         and p.joined_at > now() - interval '6 hours')
  )
$$;

create function public.ai_exam_lock() returns boolean
language sql stable security definer set search_path = '' as $$
  select private.ai_exam_locked(auth.uid())
$$;

revoke execute on function private.ai_exam_locked(uuid) from public, anon, authenticated;
revoke execute on function public.ai_exam_lock() from public, anon;
grant execute on function public.ai_exam_lock() to authenticated;
