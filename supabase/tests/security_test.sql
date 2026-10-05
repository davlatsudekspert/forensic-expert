-- Security tests for the FORENSIC EXPERT migration (run as superuser; each
-- check switches to the `authenticated` role with a given JWT subject).
\set ON_ERROR_STOP 1
grant select, insert, update on all tables in schema public to authenticated;
grant usage on all sequences in schema public to authenticated;
grant select, insert on storage.objects to authenticated;

insert into auth.users values
 ('00000000-0000-0000-0000-00000000000a','applicant@x'),
 ('00000000-0000-0000-0000-00000000000b','admin@x'),
 ('00000000-0000-0000-0000-00000000000c','peer@x'),
 ('00000000-0000-0000-0000-00000000000d','peer-nogrant@x'),
 ('00000000-0000-0000-0000-00000000000e','student@x'),
 ('00000000-0000-0000-0000-00000000000f','owner@x'),
 ('00000000-0000-0000-0000-000000000010','applicant2@x');
-- Roles / grants set out-of-band (owner).
insert into account_roles values
 ('00000000-0000-0000-0000-00000000000b','identity_admin','00000000-0000-0000-0000-00000000000f',now());
insert into verification(user_id,status) values
 ('00000000-0000-0000-0000-00000000000c','VERIFIED_PROFESSIONAL'),
 ('00000000-0000-0000-0000-00000000000d','VERIFIED_PROFESSIONAL');
insert into verifier_grants values
 ('00000000-0000-0000-0000-00000000000c','FORENSIC_TOXICOLOGY','00000000-0000-0000-0000-00000000000f',now(),null);
insert into reviewer_scopes values
 ('00000000-0000-0000-0000-00000000000c','FORENSIC_TOXICOLOGY','00000000-0000-0000-0000-00000000000f',now(),null);
insert into professional_profiles(user_id,display_name,country_code,organization,position,primary_specialty,education) values
 ('00000000-0000-0000-0000-00000000000a','Applicant','UZ','Lab','Chemist','forensicToxicology','MSc'),
 ('00000000-0000-0000-0000-00000000000c','Peer','UZ','Lab B','Toxicologist','forensicToxicology','PhD'),
 ('00000000-0000-0000-0000-000000000010','Applicant2','UZ','Lab','Chemist','forensicToxicology','MSc');
insert into content_records values ('morphine','2026.10.7','{FORENSIC_TOXICOLOGY,FORENSIC_CHEMISTRY}','high');

create function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  perform set_config('role', 'authenticated', false);
end $$;
create function pg_temp.expect_error(q text, label text) returns void language plpgsql as $$
begin
  begin execute q; exception when others then
    raise notice 'PASS (blocked): %', label; return; end;
  raise exception 'FAIL (allowed): %', label;
end $$;

-- 1) Applicant submits; status APPLICATION_PENDING automatically.
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select submit_application();
insert into credential_documents(user_id,kind,mime_type,size_bytes,sha256,storage_key)
 values (auth.uid(),'diploma','application/pdf',100,repeat('a',64),auth.uid()::text||'/doc1');
-- Cannot insert a document for someone else / outside own folder.
select pg_temp.expect_error($q$insert into credential_documents(user_id,kind,mime_type,size_bytes,sha256,storage_key)
 values ('00000000-0000-0000-0000-000000000010','diploma','application/pdf',100,repeat('a',64),'00000000-0000-0000-0000-000000000010/x')$q$,'document IDOR insert');
-- Cannot set own status directly.
update verification set status='VERIFIED_PROFESSIONAL' where user_id=auth.uid();
reset role;
do $$ begin
  if (select status from verification where user_id='00000000-0000-0000-0000-00000000000a') <> 'APPLICATION_PENDING'
  then raise exception 'FAIL: client changed own status'; end if;
  raise notice 'PASS (blocked): direct status update by client';
end $$;

-- 2) Self approval blocked (applicant tries).
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select pg_temp.expect_error($q$select decide_identity('00000000-0000-0000-0000-00000000000a','VERIFY','FORENSIC_TOXICOLOGY',(select array_agg(document_id) from credential_documents),'ok reason','m')$q$,'self approval');
-- 3) Student blocked.
reset role; select pg_temp.as_user('00000000-0000-0000-0000-00000000000e');
select pg_temp.expect_error($q$select decide_identity('00000000-0000-0000-0000-00000000000a','VERIFY','FORENSIC_TOXICOLOGY','{}','ok reason','m')$q$,'student approval');
-- 4) Verified peer WITHOUT verifier grant blocked.
reset role; select pg_temp.as_user('00000000-0000-0000-0000-00000000000d');
select pg_temp.expect_error($q$select decide_identity('00000000-0000-0000-0000-00000000000a','VERIFY','FORENSIC_TOXICOLOGY','{}','ok reason','m')$q$,'verified peer without CAN_VERIFY grant');
-- 5) Peer with grant but WRONG specialty blocked.
reset role; select pg_temp.as_user('00000000-0000-0000-0000-00000000000c');
select pg_temp.expect_error($q$select decide_identity('00000000-0000-0000-0000-00000000000a','VERIFY','GENETICS_DNA','{}','ok reason','m')$q$,'wrong-specialty approval');
-- 6) VERIFY without checked credential blocked.
select pg_temp.expect_error($q$select decide_identity('00000000-0000-0000-0000-00000000000a','VERIFY','FORENSIC_TOXICOLOGY','{}','ok reason','m')$q$,'verify without checked credential');
-- 7) Correct peer verifies with the applicant's credential.
reset role;
create temp table doc as select document_id from credential_documents where user_id='00000000-0000-0000-0000-00000000000a';
grant select on doc to authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-00000000000c');
select decide_identity('00000000-0000-0000-0000-00000000000a','VERIFY','FORENSIC_TOXICOLOGY',(select array_agg(document_id) from doc),'Checked diploma and employment','');
-- 8) Replay / double decision blocked.
select pg_temp.expect_error($q$select decide_identity('00000000-0000-0000-0000-00000000000a','VERIFY','FORENSIC_TOXICOLOGY',(select array_agg(document_id) from doc),'again reason','')$q$,'double decision / replay');
-- 9) Peer cannot suspend (admin only).
select pg_temp.expect_error($q$select decide_identity('00000000-0000-0000-0000-00000000000a','SUSPEND','FORENSIC_TOXICOLOGY','{}','reason text','')$q$,'peer suspend');
reset role;
do $$ declare r record; begin
  select * into r from verification_decisions order by decision_id desc limit 1;
  if r.approver_id <> '00000000-0000-0000-0000-00000000000c' or r.approver_kind <> 'verified_peer'
     or r.scope <> 'FORENSIC_TOXICOLOGY' or cardinality(r.checked_documents) <> 1
     or r.from_status <> 'APPLICATION_PENDING' or r.to_status <> 'VERIFIED_PROFESSIONAL'
  then raise exception 'FAIL: decision record incomplete'; end if;
  raise notice 'PASS: decision recorded (who, when, credential, scope, reason, from/to)';
end $$;

-- 10) Newly verified professional has NO reviewer scope → cannot review.
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select pg_temp.expect_error($q$select submit_review('morphine',null,'2026.10.7','FORENSIC_TOXICOLOGY','APPROVE','A sufficiently long review note here.',null)$q$,'identity-verified without reviewer scope');
-- 11) Scoped reviewer: wrong scope / stale version blocked; correct accepted.
reset role; select pg_temp.as_user('00000000-0000-0000-0000-00000000000c');
select pg_temp.expect_error($q$select submit_review('morphine',null,'2026.10.7','GENETICS_DNA','APPROVE','A sufficiently long review note here.',null)$q$,'review outside scope');
select pg_temp.expect_error($q$select submit_review('morphine',null,'2026.01.1','FORENSIC_TOXICOLOGY','APPROVE','A sufficiently long review note here.',null)$q$,'review of stale version');
select pg_temp.expect_error($q$select submit_review('morphine',null,'2026.10.7','FORENSIC_TOXICOLOGY','APPROVE','short',null)$q$,'review note too short');
select submit_review('morphine',null,'2026.10.7','FORENSIC_TOXICOLOGY','REQUEST_CHANGE','Concentration context needs the specimen type.',null);
-- 12) Reviews are append-only for clients (no delete policy).
select pg_temp.expect_error($q$delete from professional_reviews$q$,'client delete of reviews');
reset role;
do $$ begin
  if (select count(*) from professional_reviews) <> 1 then raise exception 'FAIL: review deleted'; end if;
  raise notice 'PASS (blocked): client cannot delete reviews';
end $$;
-- 13) Other users cannot read applicant documents.
select pg_temp.as_user('00000000-0000-0000-0000-00000000000e');
do $$ begin
  if (select count(*) from credential_documents) <> 0 then raise exception 'FAIL: documents visible to other user'; end if;
  raise notice 'PASS (blocked): credential metadata enumeration';
end $$;
reset role;
-- 14) AI usage counter: own rows only; no spoofed user_id.
grant select, insert on public.ai_usage to authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
insert into ai_usage default values;
select pg_temp.expect_error($q$insert into ai_usage(user_id) values ('00000000-0000-0000-0000-00000000000e')$q$,'ai_usage spoofed user');
select pg_temp.as_user('00000000-0000-0000-0000-00000000000e');
do $$ begin
  if (select count(*) from ai_usage) <> 0 then raise exception 'FAIL: ai_usage visible to other user'; end if;
  raise notice 'PASS (blocked): ai_usage enumeration';
end $$;
reset role;
select 'ALL SECURITY TESTS PASSED' as result;
