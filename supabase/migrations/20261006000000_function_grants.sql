-- Harden RPC grants: PostgreSQL grants EXECUTE to PUBLIC by default (which
-- includes `anon`). Only signed-in users may call the RPCs; the functions
-- additionally check auth.uid() and roles internally.
revoke execute on function public.submit_application() from public;
revoke execute on function public.decide_identity(uuid, text, public.reviewer_scope, uuid[], text, text) from public;
revoke execute on function public.submit_review(text, text, text, public.reviewer_scope, public.review_action, text, text) from public;
revoke execute on function public.publish_record_version(text, text, public.reviewer_scope[], text) from public;
grant execute on function public.submit_application() to authenticated;
grant execute on function public.decide_identity(uuid, text, public.reviewer_scope, uuid[], text, text) to authenticated;
grant execute on function public.submit_review(text, text, text, public.reviewer_scope, public.review_action, text, text) to authenticated;
grant execute on function public.publish_record_version(text, text, public.reviewer_scope[], text) to authenticated;
