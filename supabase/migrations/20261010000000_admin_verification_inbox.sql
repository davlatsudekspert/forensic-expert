-- FORENSIC EXPERT — admin «Tasdiqlash arizalari» (identity verification inbox).
--
-- Why: public.decide_identity() existed but the admin panel had no way to LIST
-- pending applications, so an admin could not approve anybody. Self-approval
-- stays forbidden (decide_identity + CHECK constraints are NOT changed).
--
-- Security model (enforced HERE; the Flutter client is never trusted):
--   * admin_pending_verifications() is SECURITY DEFINER and goes through
--     private.admin_guard() (identity_admin from account_roles, plus the MFA
--     switch). Ordinary users and verified peers get 'forbidden'.
--     Peers holding verifier_grants are NOT served by this RPC on purpose:
--     there is no server-side specialty -> reviewer_scope mapping yet, and a
--     peer must not see every applicant's documents. decide_identity() itself
--     still accepts a scoped peer.
--   * Returns metadata only: profile fields the admin needs to judge the
--     application and, per credential document, document_id, kind, mime,
--     size, sha256, uploaded_at. NEVER storage_key, file bytes or URLs, and
--     never private columns (work_email, license_number, bio).
--   * The caller's own application is returned with is_self = true so the UI
--     can say "another authorised admin must decide"; decide_identity()
--     rejects it anyway ('self approval').
--   * Every call writes one private.admin_audit row (ids/counts only).
--
-- ROLLBACK (manual, owner-approved):
--   drop function if exists public.admin_pending_verifications(int, int);

create function public.admin_pending_verifications(
  p_limit int default 50, p_offset int default 0)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.admin_guard();
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
  v_result jsonb;
begin
  select jsonb_build_object(
    'total', (select count(*) from public.verification v
              where v.status = 'APPLICATION_PENDING'),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'applicant_id', x.user_id,
        'display_name', x.display_name,
        'position', x.position,
        'organization', x.organization,
        'country_code', x.country_code,
        'primary_specialty', x.primary_specialty,
        'additional_specialties', to_jsonb(x.additional_specialties),
        'years_experience', x.years_experience,
        'education', x.education,
        'submitted_at', x.submitted_at,
        'is_self', (x.user_id = me),
        'credential_documents', coalesce((
          select jsonb_agg(jsonb_build_object(
              'document_id', d.document_id, 'kind', d.kind,
              'mime_type', d.mime_type, 'size_bytes', d.size_bytes,
              'sha256', d.sha256, 'uploaded_at', d.uploaded_at)
            order by d.uploaded_at)
          from public.credential_documents d where d.user_id = x.user_id),
          '[]'::jsonb))
        order by x.submitted_at asc nulls last)
      from (select v.user_id, v.submitted_at, p.display_name, p.position,
                   p.organization, p.country_code, p.primary_specialty,
                   p.additional_specialties, p.years_experience, p.education
            from public.verification v
            left join public.professional_profiles p on p.user_id = v.user_id
            where v.status = 'APPLICATION_PENDING'
            order by v.submitted_at asc nulls last
            limit v_limit offset v_offset) x), '[]'::jsonb))
  into v_result;
  perform private.admin_log(me, 'VERIFICATIONS_VIEW', 'verification', null,
    jsonb_build_object('offset', v_offset,
      'count', jsonb_array_length(v_result->'items')));
  return v_result;
end $$;

revoke execute on function public.admin_pending_verifications(int, int) from public, anon;
grant execute on function public.admin_pending_verifications(int, int) to authenticated;
