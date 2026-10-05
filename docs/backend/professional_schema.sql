-- FORENSIC EXPERT — professional verification & professional review
-- Reference server schema (PostgreSQL 15+, Row Level Security).
--
-- STATUS: architecture reference only. NOT deployed. No production
-- database, storage bucket or admin account exists for this yet.
--
-- Principles enforced HERE (server), never trusted from the client:
--   * usage mode (Student / Professional) is NOT stored as a privilege;
--   * VERIFIED_PROFESSIONAL is set only by manual review of a human
--     identity admin OR an already verified professional holding the same
--     specialty scope; never self-approval; every decision is recorded
--     (approver, time, checked credential, scope);
--   * review scopes are granted separately by a scope grantor;
--   * an identity admin is NOT a scientific reviewer;
--   * reviews are tied to the exact content version and never deleted;
--   * credential documents live in a PRIVATE bucket, no public URLs;
--   * HUMAN_VERIFIED is computed by policy, never set by a single review,
--     an admin role, an AI agent or an automated identifier check.

create type verification_status as enum (
  'UNVERIFIED', 'APPLICATION_PENDING', 'VERIFIED_PROFESSIONAL',
  'CHANGES_REQUESTED', 'REJECTED', 'SUSPENDED');

create type reviewer_scope as enum (
  'FORENSIC_TOXICOLOGY', 'FORENSIC_CHEMISTRY', 'FORENSIC_MEDICINE',
  'LAB_ANALYTICS', 'FORENSIC_BIOCHEMISTRY', 'PATHOLOGY_HISTOLOGY',
  'GENETICS_DNA', 'ANTHROPOLOGY', 'ODONTOLOGY', 'LEGAL_JURISDICTION',
  'TRANSLATION');

create type review_action as enum (
  'APPROVE', 'REQUEST_CHANGE', 'FLAG_CONFLICT', 'FLAG_OUTDATED', 'REJECT');

create type account_role as enum ('identity_admin', 'scope_grantor');

-- Accounts come from the auth provider (auth.users). Only human accounts.
create table account_roles (
  user_id    uuid not null references auth.users(id) on delete cascade,
  role       account_role not null,
  granted_by uuid not null references auth.users(id),
  granted_at timestamptz not null default now(),
  primary key (user_id, role),
  check (user_id <> granted_by)
);

-- Professional profile submitted with an application. No passport / ID
-- number columns by design.
create table professional_profiles (
  user_id               uuid primary key references auth.users(id) on delete cascade,
  display_name          text not null check (length(display_name) between 1 and 120),
  country_code          char(2) not null,
  city                  text,
  organization          text not null,
  show_organization     boolean not null default false,
  position              text not null,
  primary_specialty     text not null,
  additional_specialties text[] not null default '{}',
  years_experience      int check (years_experience between 0 and 70),
  education             text not null,
  work_email            text,           -- private
  license_number        text,           -- private, optional, jurisdiction dependent
  bio                   text check (length(bio) <= 600),
  updated_at            timestamptz not null default now()
);

create table verification (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  status      verification_status not null default 'UNVERIFIED',
  decided_by  uuid references auth.users(id),
  decided_at  timestamptz,
  applicant_message text,               -- visible to the applicant
  internal_note     text,               -- identity admins only, never public
  check (decided_by is null or decided_by <> user_id)
);

-- Private credential documents: metadata only; the bytes are in the
-- private bucket "credentials" (no public access, signed URLs of <=5 min
-- for identity admins only, generated server-side; never logged).
create table credential_documents (
  document_id uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  kind        text not null,
  mime_type   text not null check (mime_type in ('application/pdf','image/jpeg','image/png')),
  size_bytes  int not null check (size_bytes between 1 and 10485760),
  sha256      text not null,
  storage_key text not null unique,     -- credentials/<user_id>/<document_id>
  uploaded_at timestamptz not null default now()
);

create table reviewer_scopes (
  user_id    uuid not null references auth.users(id) on delete cascade,
  scope      reviewer_scope not null,
  granted_by uuid not null references auth.users(id),
  granted_at timestamptz not null default now(),
  revoked_at timestamptz,
  primary key (user_id, scope),
  check (user_id <> granted_by)
);

-- Professional reviews: append-only (withdrawn, never deleted).
create table professional_reviews (
  review_id        uuid primary key default gen_random_uuid(),
  record_id        text not null,
  claim_id         text,
  content_version  text not null,
  reviewer_user_id uuid not null references auth.users(id),
  reviewer_scope   reviewer_scope not null,
  reviewer_status_at_review verification_status not null,
  action           review_action not null,
  review_text      text not null check (length(btrim(review_text)) >= 20),
  source_reference text,
  created_at       timestamptz not null default now(),
  withdrawn_at     timestamptz
);

create table review_audit (
  entry_id        bigserial primary key,
  record_id       text not null,
  claim_id        text,
  content_version text not null,
  actor_user_id   uuid,                 -- null = content publication job
  actor_scope     reviewer_scope,
  action          review_action,
  note            text,
  review_id       uuid references professional_reviews(review_id),
  previous_state  text not null,
  new_state       text not null,
  at              timestamptz not null default now()
);

-- Helper predicates ---------------------------------------------------------
create function is_verified_professional(uid uuid) returns boolean
language sql stable as $$
  select exists (select 1 from verification v
                 where v.user_id = uid and v.status = 'VERIFIED_PROFESSIONAL')
$$;

create function has_role(uid uuid, r account_role) returns boolean
language sql stable as $$
  select exists (select 1 from account_roles a where a.user_id = uid and a.role = r)
$$;

-- RLS -----------------------------------------------------------------------
alter table professional_profiles enable row level security;
alter table verification          enable row level security;
alter table credential_documents  enable row level security;
alter table reviewer_scopes       enable row level security;
alter table professional_reviews  enable row level security;
alter table review_audit          enable row level security;

-- Applicant: own profile, own status, own documents (insert/read metadata).
create policy own_profile on professional_profiles
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_status_read on verification
  for select using (user_id = auth.uid() or has_role(auth.uid(), 'identity_admin'));
-- Status changes ONLY through the security-definer functions below.
create policy own_docs_insert on credential_documents
  for insert with check (user_id = auth.uid());
create policy docs_read on credential_documents
  for select using (user_id = auth.uid() or has_role(auth.uid(), 'identity_admin'));

-- Reviews: anyone can read; insert only with an active, verified scope that
-- matches the subject (subject scopes are checked in submit_review()).
create policy reviews_read on professional_reviews for select using (true);
create policy audit_read on review_audit for select using (true);

-- Every identity decision is recorded: who, when, which credential(s)
-- were checked, for which specialty scope. Append-only.
create table verification_decisions (
  decision_id    bigserial primary key,
  applicant_id   uuid not null references auth.users(id),
  approver_id    uuid not null references auth.users(id),
  approver_kind  text not null check (approver_kind in ('identity_admin','verified_peer')),
  decision       text not null check (decision in
                   ('VERIFY','REQUEST_MORE_INFORMATION','REJECT','SUSPEND')),
  scope          reviewer_scope not null,
  from_status    verification_status not null,
  to_status      verification_status not null,
  checked_documents uuid[] not null default '{}',
  note           text,                -- internal, never public
  at             timestamptz not null default now(),
  check (approver_id <> applicant_id),
  check (decision <> 'VERIFY' or cardinality(checked_documents) > 0)
);
alter table verification_decisions enable row level security;
create policy decisions_read on verification_decisions
  for select using (applicant_id = auth.uid() or has_role(auth.uid(), 'identity_admin'));

-- Identity decision. Allowed approvers (checked HERE, never from client):
--   * identity_admin, or
--   * an already VERIFIED_PROFESSIONAL with an active reviewer scope equal
--     to p_scope (peer verification); SUSPEND is identity_admin only.
-- Never: self-approval, students, unverified/suspended users, AI/service
-- accounts. VERIFY requires >= 1 checked credential that belongs to the
-- applicant. A decision grants no reviewer scope by itself.
create function decide_identity(applicant uuid, decision text,
  p_scope reviewer_scope, checked uuid[], message text, note text)
returns verification_status language plpgsql security definer as $$
declare cur verification_status; nxt verification_status; kind text;
begin
  if applicant = auth.uid() then raise exception 'self approval'; end if;
  if has_role(auth.uid(), 'identity_admin') then
    kind := 'identity_admin';
  elsif is_verified_professional(auth.uid()) and exists (
      select 1 from reviewer_scopes s where s.user_id = auth.uid()
        and s.scope = p_scope and s.revoked_at is null) then
    kind := 'verified_peer';
  else
    raise exception 'forbidden';
  end if;
  if decision = 'SUSPEND' and kind <> 'identity_admin' then
    raise exception 'forbidden';
  end if;
  select status into cur from verification where user_id = applicant for update;
  nxt := case
    when cur = 'APPLICATION_PENDING' and decision = 'VERIFY' then 'VERIFIED_PROFESSIONAL'
    when cur = 'APPLICATION_PENDING' and decision = 'REQUEST_MORE_INFORMATION' then 'CHANGES_REQUESTED'
    when cur = 'APPLICATION_PENDING' and decision = 'REJECT' then 'REJECTED'
    when cur = 'VERIFIED_PROFESSIONAL' and decision = 'SUSPEND' then 'SUSPENDED'
    when cur = 'SUSPENDED' and decision = 'VERIFY' then 'VERIFIED_PROFESSIONAL'
    else null end::verification_status;
  if nxt is null then raise exception 'invalid transition'; end if;
  if decision = 'VERIFY' then
    if coalesce(cardinality(checked), 0) = 0 then raise exception 'no credential checked'; end if;
    if exists (select 1 from unnest(checked) c where not exists (
        select 1 from credential_documents d
        where d.document_id = c and d.user_id = applicant)) then
      raise exception 'unknown credential';
    end if;
  end if;
  update verification set status = nxt, decided_by = auth.uid(), decided_at = now(),
    applicant_message = message, internal_note = note where user_id = applicant;
  insert into verification_decisions(applicant_id, approver_id, approver_kind,
    decision, scope, from_status, to_status, checked_documents, note)
  values (applicant, auth.uid(), kind, decision, p_scope, cur, nxt,
    coalesce(checked, '{}'), note);
  return nxt;
end $$;

-- Submit review: server re-checks verification + scope; content_version
-- must equal the currently published version of the record.
create function submit_review(p_record text, p_claim text, p_version text,
  p_scope reviewer_scope, p_action review_action, p_text text, p_source text)
returns uuid language plpgsql security definer as $$
declare rid uuid;
begin
  if not is_verified_professional(auth.uid()) then raise exception 'not verified'; end if;
  if not exists (select 1 from reviewer_scopes s where s.user_id = auth.uid()
                 and s.scope = p_scope and s.revoked_at is null) then
    raise exception 'scope not granted';
  end if;
  -- record_scopes(p_record) and published_version(p_record) are provided by
  -- the content service (not shown).
  if not p_scope = any(record_scopes(p_record)) then raise exception 'scope mismatch'; end if;
  if p_version <> published_version(p_record) then raise exception 'stale version'; end if;
  insert into professional_reviews(record_id, claim_id, content_version,
    reviewer_user_id, reviewer_scope, reviewer_status_at_review, action,
    review_text, source_reference)
  values (p_record, p_claim, p_version, auth.uid(), p_scope,
    'VERIFIED_PROFESSIONAL', p_action, p_text, p_source)
  returning review_id into rid;
  -- review_state(...) applies the configured verification policy
  -- (2 independent approvals; high risk: distinct organisations) and
  -- appends to review_audit. A single review never yields HUMAN_VERIFIED.
  return rid;
end $$;
