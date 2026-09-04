-- Builds table (2026-09-04). Run in the Supabase SQL editor.
--
-- Replaces the hardcoded `builds` array in js/builds.js with a real table so
-- Kevin can add/edit/complete builds from admin-dashboard.html instead of
-- hand-editing a JS file and pushing to GitHub every time a build moves
-- stages. This is the base table - RLS locks it to admins only, see
-- 003_builds_public_view.sql for the customer-facing read path.
--
-- `progress` is deliberately NOT a column here. Storing it separately from
-- `status` would create a second source of truth that can drift (someone
-- edits status and forgets to bump progress, or vice versa) - it's computed
-- client-side instead, from status + is_nfa, via a shared calcProgress()
-- function in js/main.js so inshop.html/track.html/admin-dashboard.html all
-- agree on what "65% done" means for a given stage without a DB round trip.
--
-- `price`/`payment_status`/`pay_url`/`order_id` are also deliberately
-- excluded - those are shop/checkout/payment concerns (Authorize.net,
-- pay-links, distributor sync), which this build explicitly leaves out of
-- scope per the plan. Nothing here assumes they'll ever be added.
create table if not exists builds (
  id              uuid primary key default gen_random_uuid(),
  title           text not null,
  type            text,
  caliber         text,
  status          text not null default 'intake',
  received        date,
  eta             date,
  atf_form        text,
  atf_filed       date,
  tracking_code   text unique,
  notes           text,
  internal_notes  text,
  is_nfa          boolean not null default false,
  customer_name   text,
  customer_email  text,
  customer_phone  text,
  completed_at    timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists builds_tracking_code_idx on builds(tracking_code);

-- Admin-only, full stop. No anon/public policy exists on this base table at
-- all - customer_name/customer_email/customer_phone live here, and the only
-- sanctioned public read path is the builds_public view (next file), which
-- excludes them by construction. Anyone reading/writing the base table has
-- to be an admin, checked the same way everywhere else in this project.
alter table builds enable row level security;

create policy "Admin read builds"
  on builds for select
  to authenticated
  using (is_admin());

create policy "Admin write builds"
  on builds for all
  to authenticated
  using (is_admin())
  with check (is_admin());

-- Keeps updated_at honest without every admin-dashboard write remembering to
-- set it by hand.
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists builds_set_updated_at on builds;
create trigger builds_set_updated_at
  before update on builds
  for each row execute function set_updated_at();
