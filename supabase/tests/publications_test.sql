-- Expert Publications workflow (after admin_test.sql).
\set ON_ERROR_STOP 1
reset role;
-- admin_test.sql grants table DML to authenticated for its own checks;
-- restore the migration's state (no direct table privileges).
revoke all on public.publications, public.publication_reviews,
  public.publication_events, public.publication_reports from anon, authenticated;
create function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.as_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', false);
  perform set_config('role', 'anon', false);
end $$;
create function pg_temp.expect_error(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked): %', label; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;
create function pg_temp.check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not coalesce(ok, false) then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;
grant execute on function pg_temp.as_user(text), pg_temp.as_anon(),
  pg_temp.expect_error(text, text), pg_temp.check(boolean, text) to anon, authenticated;

-- a = author (also has a PAID grant), m = publication_moderator,
-- x = identity_admin who is also an author, o = other signed-in user.
insert into auth.users (id, email, created_at, email_confirmed_at) values
 ('30000000-0000-0000-0000-00000000000a', 'author@x', now(), now()),
 ('30000000-0000-0000-0000-00000000000b', 'moderator@x', now(), now()),
 ('30000000-0000-0000-0000-00000000000c', 'admin-author@x', now(), now()),
 ('30000000-0000-0000-0000-00000000000d', 'other@x', now(), now());
insert into account_roles (user_id, role, granted_by) values
 ('30000000-0000-0000-0000-00000000000b', 'publication_moderator', '30000000-0000-0000-0000-00000000000c'),
 ('30000000-0000-0000-0000-00000000000c', 'identity_admin', '30000000-0000-0000-0000-00000000000b');
insert into access_grants (user_id, tier) values
 ('30000000-0000-0000-0000-00000000000a', 'professionalPro');

create temp table ids (k text primary key, id uuid);
grant all on ids to authenticated, anon;

-- ---------------------------------------------------------------- author
select pg_temp.as_user('30000000-0000-0000-0000-00000000000a');
insert into ids select 'p1', save_draft(null, '{"title":"  Postmortem ethanol  ",
  "abstract":"Abstract text","keywords":["ethanol"," ","GC-MS"],"language":"en",
  "discipline_code":"forensic_toxicology","coauthors":[{"name":"A. Author"}],
  "doi":"not-a-doi","external_url":"http://insecure.example"}'::jsonb);
select pg_temp.check((select (p->>'status') = 'DRAFT' and p->>'title' = 'Postmortem ethanol'
  and jsonb_array_length(p->'keywords') = 2 and p->>'doi' is null and p->>'external_url' is null
  and jsonb_array_length(p->'events') = 1
  from jsonb_array_elements(my_publications()) p), 'draft saved, sanitised, creation logged');
select pg_temp.check(submit_publication((select id from ids where k = 'p1')) = 'CONFIRMATIONS_REQUIRED',
  'missing confirmations rejected');
select save_draft((select id from ids where k = 'p1'), '{"title":"Postmortem ethanol",
  "abstract":"Abstract text","discipline_code":"forensic_toxicology",
  "rights_confirmed":true,"publication_consent":true}'::jsonb);
select pg_temp.check(submit_publication((select id from ids where k = 'p1')) = 'CONFIRMATIONS_REQUIRED',
  'two of three confirmations rejected');
select save_draft((select id from ids where k = 'p1'), '{"title":"",
  "abstract":"Abstract text","discipline_code":"forensic_toxicology","rights_confirmed":true,
  "publication_consent":true,"no_personal_data_confirmed":true}'::jsonb);
select pg_temp.check(submit_publication((select id from ids where k = 'p1')) = 'INCOMPLETE',
  'empty title rejected');
select save_draft((select id from ids where k = 'p1'), '{"title":"Postmortem ethanol",
  "abstract":"Abstract text","discipline_code":"forensic_toxicology","rights_confirmed":true,
  "publication_consent":true,"no_personal_data_confirmed":true,"doi":"10.1000/xyz123"}'::jsonb);
select pg_temp.check(submit_publication((select id from ids where k = 'p1')) = 'SUBMITTED',
  'all confirmations: submitted (paid grant irrelevant)');
select pg_temp.check(submit_publication((select id from ids where k = 'p1')) = 'INVALID_STATE',
  'double submit rejected');
select pg_temp.expect_error($q$select save_draft((select id from ids where k = 'p1'), '{}'::jsonb)$q$,
  'author cannot edit after submit');
select pg_temp.expect_error($q$select moderate_publication((select id from ids where k = 'p1'), 'PUBLISHED', null)$q$,
  'author (no role) cannot moderate/publish');
select pg_temp.expect_error($q$select moderation_queue()$q$, 'author cannot read queue');
select pg_temp.check(can_moderate_publications() = false, 'author is not moderator');
select pg_temp.expect_error($q$update publications set status = 'PUBLISHED'$q$, 'no direct table update');
select pg_temp.expect_error($q$select * from publications$q$, 'no direct table read');
select pg_temp.expect_error($q$insert into publication_events (publication_id, to_status) values ((select id from ids where k = 'p1'), 'PUBLISHED')$q$,
  'no direct audit write');
select pg_temp.expect_error($q$select private.publication_log(null, null, null, 'X', null)$q$, 'private helpers not callable');
-- A second, never-submitted draft.
insert into ids select 'p2', save_draft(null, '{"title":"Secret draft","abstract":"x"}'::jsonb);

-- Other users cannot touch someone else's draft.
select pg_temp.as_user('30000000-0000-0000-0000-00000000000d');
select pg_temp.expect_error($q$select save_draft((select id from ids where k = 'p2'), '{"title":"hijack"}'::jsonb)$q$,
  'other user cannot edit draft');
select pg_temp.check(submit_publication((select id from ids where k = 'p2')) = 'NOT_FOUND', 'other user cannot submit draft');
select pg_temp.check(jsonb_array_length(my_publications()) = 0, 'other user sees no foreign drafts');

-- ---------------------------------------------------------------- anon / public
select pg_temp.as_anon();
select pg_temp.check(jsonb_array_length(list_published()) = 0, 'public: nothing published yet');
select pg_temp.expect_error($q$select my_publications()$q$, 'anon cannot read drafts (my_publications)');
select pg_temp.expect_error($q$select * from publications$q$, 'anon cannot read table');
select pg_temp.expect_error($q$select save_draft(null, '{}'::jsonb)$q$, 'anon cannot create draft');
select pg_temp.expect_error($q$select report_publication((select id from ids where k = 'p1'), 'ABUSE', null)$q$, 'anon cannot report');

-- ---------------------------------------------------------------- moderation
select pg_temp.as_user('30000000-0000-0000-0000-00000000000b');
select pg_temp.check(can_moderate_publications(), 'moderator role recognised');
select pg_temp.check((select jsonb_array_length(q->'items') = 1 and (q->'items'->0->>'own')::boolean = false
  and not (q->'items'->0 ? 'author_id') from (select moderation_queue() q) x), 'queue: only submitted, no author id');
select pg_temp.check(moderate_publication((select id from ids where k = 'p2'), 'SCREENING', null) = 'INVALID_TRANSITION',
  'draft cannot be screened');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'PUBLISHED', null) = 'INVALID_TRANSITION',
  'cannot skip SUBMITTED -> PUBLISHED');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'APPROVED', null) = 'INVALID_TRANSITION',
  'cannot skip SUBMITTED -> APPROVED');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'SCREENING', null) = 'SCREENING', 'SUBMITTED -> SCREENING');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'APPROVED', null) = 'INVALID_TRANSITION',
  'cannot skip SCREENING -> APPROVED');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'IN_REVIEW', 'ok') = 'IN_REVIEW', 'SCREENING -> IN_REVIEW');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'REJECTED', null) = 'COMMENT_REQUIRED',
  'reject needs a comment');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'REJECTED', 'Add method details') = 'REJECTED',
  'IN_REVIEW -> REJECTED');

-- Author revises the rejected text and resubmits.
select pg_temp.as_user('30000000-0000-0000-0000-00000000000a');
select pg_temp.check((select p->'reviews'->-1->>'comment' = 'Add method details' and not (p->'reviews'->-1 ? 'reviewer_id')
  from jsonb_array_elements(my_publications()) p where p->>'id' = (select id::text from ids where k = 'p1')),
  'author sees moderator comment, not reviewer id');
select save_draft((select id from ids where k = 'p1'), '{"title":"Postmortem ethanol v2",
  "abstract":"Abstract with methods","discipline_code":"forensic_toxicology","rights_confirmed":true,
  "publication_consent":true,"no_personal_data_confirmed":true}'::jsonb);
select pg_temp.check(submit_publication((select id from ids where k = 'p1')) = 'SUBMITTED', 'REJECTED -> DRAFT -> SUBMITTED');

select pg_temp.as_user('30000000-0000-0000-0000-00000000000b');
select moderate_publication((select id from ids where k = 'p1'), 'SCREENING', null);
select moderate_publication((select id from ids where k = 'p1'), 'IN_REVIEW', null);
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'APPROVED', 'Accepted') = 'APPROVED', 'IN_REVIEW -> APPROVED');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'RETRACTED', 'x') = 'INVALID_TRANSITION',
  'APPROVED cannot be retracted');
select pg_temp.check(moderate_publication((select id from ids where k = 'p1'), 'PUBLISHED', null) = 'PUBLISHED', 'APPROVED -> PUBLISHED');
reset role;
select pg_temp.check((select array_agg(coalesce(from_status, '-') || '>' || to_status order by id)
  = array['->DRAFT', 'DRAFT>SUBMITTED', 'SUBMITTED>SCREENING', 'SCREENING>IN_REVIEW',
          'IN_REVIEW>REJECTED', 'REJECTED>DRAFT', 'DRAFT>SUBMITTED', 'SUBMITTED>SCREENING',
          'SCREENING>IN_REVIEW', 'IN_REVIEW>APPROVED', 'APPROVED>PUBLISHED']
  from publication_events where publication_id = (select id from ids where k = 'p1')), 'full audit trail');
select pg_temp.check((select count(*) = 7 and bool_and(reviewer_id = '30000000-0000-0000-0000-00000000000b')
  from publication_reviews where publication_id = (select id from ids where k = 'p1')), 'review rows by moderator');
select pg_temp.check((select published_at is not null from publications where id = (select id from ids where k = 'p1')), 'published_at set');

-- Public sees only PUBLISHED, safe columns.
select pg_temp.as_anon();
select pg_temp.check((select jsonb_array_length(l) = 1 and l->0->>'title' = 'Postmortem ethanol v2'
  and not (l->0 ? 'author_id') and not (l->0 ? 'events') and not (l->0 ? 'reviews')
  and l->0->>'status' = 'PUBLISHED' and position('author@x' in l::text) = 0
  from (select list_published() l) x), 'public: only PUBLISHED, safe columns, no email');
select pg_temp.check(jsonb_array_length(list_published('ethanol', 'forensic_toxicology')) = 1, 'search + discipline filter');
select pg_temp.check(jsonb_array_length(list_published(null, 'forensic_genetics')) = 0, 'discipline filter excludes');
select pg_temp.check(position('Secret draft' in list_published()::text) = 0, 'draft not public');

-- Reports by any signed-in user.
select pg_temp.as_user('30000000-0000-0000-0000-00000000000d');
select pg_temp.check(report_publication((select id from ids where k = 'p1'), 'PLAGIARISM', 'copied') = 'REPORTED', 'user reports');
select pg_temp.check(report_publication((select id from ids where k = 'p1'), 'PLAGIARISM', 'again') = 'ALREADY_REPORTED', 'one report per user');
select pg_temp.check(report_publication((select id from ids where k = 'p2'), 'ABUSE', null) = 'NOT_FOUND', 'drafts cannot be reported');
select pg_temp.check(report_publication((select id from ids where k = 'p1'), 'SPAM!', null) = 'INVALID_REASON', 'reason validated');

-- New version supersedes the old one when published.
select pg_temp.as_user('30000000-0000-0000-0000-00000000000a');
insert into ids select 'p3', save_draft(null, jsonb_build_object('supersedes', (select id from ids where k = 'p1'),
  'title', 'Postmortem ethanol v3', 'abstract', 'Updated', 'discipline_code', 'forensic_toxicology',
  'rights_confirmed', true, 'publication_consent', true, 'no_personal_data_confirmed', true));
select pg_temp.expect_error($q$select save_draft(null, jsonb_build_object('supersedes', (select id from ids where k = 'p2')))$q$,
  'cannot supersede a non-published / foreign item');
select submit_publication((select id from ids where k = 'p3'));

-- Admin who is also an author cannot moderate own submission.
select pg_temp.as_user('30000000-0000-0000-0000-00000000000c');
insert into ids select 'p4', save_draft(null, '{"title":"Admin paper","abstract":"a",
  "discipline_code":"forensic_genetics","rights_confirmed":true,"publication_consent":true,
  "no_personal_data_confirmed":true}'::jsonb);
select submit_publication((select id from ids where k = 'p4'));
select pg_temp.check(can_moderate_publications(), 'identity_admin can moderate');
select pg_temp.check(moderate_publication((select id from ids where k = 'p4'), 'SCREENING', null) = 'FORBIDDEN_OWN',
  'admin cannot moderate own article');
select pg_temp.check((select (q->'reports'->0->>'reason') = 'PLAGIARISM' from (select moderation_queue() q) x), 'reports visible to moderator');
select moderate_publication((select id from ids where k = 'p3'), 'SCREENING', null);
select moderate_publication((select id from ids where k = 'p3'), 'IN_REVIEW', null);
select moderate_publication((select id from ids where k = 'p3'), 'APPROVED', null);
select pg_temp.check(moderate_publication((select id from ids where k = 'p3'), 'PUBLISHED', null) = 'PUBLISHED', 'v3 published');
reset role;
select pg_temp.check((select status = 'SUPERSEDED' from publications where id = (select id from ids where k = 'p1'))
  and (select version = 2 from publications where id = (select id from ids where k = 'p3')), 'old version superseded, version bumped');
select pg_temp.check(exists (select 1 from publication_events where publication_id = (select id from ids where k = 'p1')
  and from_status = 'PUBLISHED' and to_status = 'SUPERSEDED'), 'supersede logged');

-- Retraction (moderator) and terminal states.
select pg_temp.as_user('30000000-0000-0000-0000-00000000000b');
select pg_temp.check(moderate_publication((select id from ids where k = 'p3'), 'RETRACTED', null) = 'COMMENT_REQUIRED', 'retract needs reason');
select pg_temp.check(moderate_publication((select id from ids where k = 'p3'), 'RETRACTED', 'Data issue') = 'RETRACTED', 'PUBLISHED -> RETRACTED');
select pg_temp.check(moderate_publication((select id from ids where k = 'p3'), 'PUBLISHED', null) = 'INVALID_TRANSITION', 'retracted is terminal');
select pg_temp.check(moderate_publication((select id from ids where k = 'p2'), 'DRAFT', null) = 'INVALID_TRANSITION', 'moderator cannot set DRAFT');
select pg_temp.as_anon();
select pg_temp.check(jsonb_array_length(list_published()) = 0, 'retracted/superseded not public');
reset role;
select pg_temp.check(not exists (select 1 from information_schema.role_table_grants
  where table_name in ('publications', 'publication_reviews', 'publication_events', 'publication_reports')
    and grantee in ('anon', 'authenticated')), 'no client table privileges');
-- Account deletion cascades.
delete from auth.users where id = '30000000-0000-0000-0000-00000000000a';
select pg_temp.check((select count(*) = 0 from publications where author_id = '30000000-0000-0000-0000-00000000000a'), 'deletion cascades');
select 'ALL PUBLICATION TESTS PASSED' as result;
