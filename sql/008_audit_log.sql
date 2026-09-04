-- Audit log (2026-09-04). Run in the Supabase SQL editor.
--
-- Ported from the sister GVG project's sql/audit_log.sql, which exists
-- because of a real incident there: a build got deleted from `builds` with
-- no way to tell who deleted it, when, or whether it was intentional - no
-- audit table existed, and the delete happens as a direct browser-to-
-- Supabase call from admin-dashboard.html, so it never touches any server
-- log either. Worth porting unconditionally rather than waiting for Strout
-- to have its own version of that incident.
--
-- Generic trigger-based audit log: one function, attachable to any table
-- with a single CREATE TRIGGER line. Captures INSERT/UPDATE/DELETE, the
-- full old and new row as JSON, and who did it (from the request's JWT, so
-- it reflects the actual logged-in admin, not just "someone").

-- 1) THE LOG TABLE
create table if not exists audit_log (
  id                uuid primary key default gen_random_uuid(),
  table_name        text not null,
  record_id         uuid,
  operation         text not null,        -- 'INSERT' | 'UPDATE' | 'DELETE'
  old_data          jsonb,                -- null on INSERT
  new_data          jsonb,                -- null on DELETE
  changed_by        uuid,                 -- auth.uid() of the acting session, null if not authenticated
  changed_by_email  text,                 -- denormalized from the JWT so this reads without joining auth.users
  created_at        timestamptz not null default now()
);

create index if not exists audit_log_table_record_idx on audit_log (table_name, record_id);
create index if not exists audit_log_created_at_idx on audit_log (created_at desc);

-- Admins can read the log; nobody (not even admins) can write to it
-- directly - the only writes come from the trigger function below, via its
-- own elevated privileges, so the log can't be edited after the fact by
-- anyone including a compromised admin session. This is what makes it
-- tamper-resistant rather than just another table an admin session can
-- clear out.
alter table audit_log enable row level security;

create policy "Admin read audit_log"
  on audit_log for select
  to authenticated
  using (is_admin());

-- 2) THE TRIGGER FUNCTION
-- security definer so it can insert into audit_log even though no role has
-- an INSERT policy on it above - runs with the privileges of whoever owns
-- this function (the role that ran this migration), not the caller's.
create or replace function log_audit_event()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_old jsonb;
  v_new jsonb;
  v_id uuid;
begin
  -- Referencing OLD in an INSERT trigger (or NEW in a DELETE trigger) isn't
  -- just null in PL/pgSQL, it raises "record ... is not assigned yet" - so
  -- this branches on TG_OP rather than leaning on coalesce()/CASE to paper
  -- over which one is actually populated.
  if TG_OP = 'INSERT' then
    v_new := to_jsonb(NEW);
    v_id := NEW.id;
  elsif TG_OP = 'UPDATE' then
    v_old := to_jsonb(OLD);
    v_new := to_jsonb(NEW);
    v_id := NEW.id;
  elsif TG_OP = 'DELETE' then
    v_old := to_jsonb(OLD);
    v_id := OLD.id;
  end if;

  insert into audit_log (table_name, record_id, operation, old_data, new_data, changed_by, changed_by_email)
  values (TG_TABLE_NAME, v_id, TG_OP, v_old, v_new, auth.uid(), auth.jwt() ->> 'email');

  if TG_OP = 'DELETE' then
    return OLD;
  else
    return NEW;
  end if;
end;
$$;

-- 3) ATTACH TO `builds`
-- Covers insert/update/delete - to cover another table later, it's just
-- this same three-line block with the table name swapped in, no changes
-- needed above.
drop trigger if exists builds_audit_trigger on builds;
create trigger builds_audit_trigger
  after insert or update or delete on builds
  for each row execute function log_audit_event();

-- 4) CONVENIENCE VIEW
-- Plain `select * from audit_log where table_name = 'builds' order by
-- created_at desc` works fine too - this just saves retyping that filter.
--
-- security_invoker = true is explicitly set so this view enforces the
-- QUERYING user's own RLS against audit_log (admins only), not the view
-- owner's. Omitting it lets a view silently bypass the base table's RLS
-- entirely - "grant select to authenticated" below would then hand every
-- signed-up account read access to the log regardless of is_admin(), even
-- though audit_log itself is admin-only. This is the exact bug GVG's own
-- security_hardening.sql documents fixing elsewhere in that project;
-- reproducing the fix here from the start instead of waiting to hit it live.
create or replace view builds_audit_log
with (security_invoker = true)
as
select
  id, record_id, operation,
  old_data ->> 'tracking_code' as old_tracking_code,
  new_data ->> 'tracking_code' as new_tracking_code,
  old_data ->> 'title' as old_title,
  new_data ->> 'title' as new_title,
  old_data ->> 'status' as old_status,
  new_data ->> 'status' as new_status,
  changed_by_email, created_at,
  old_data, new_data
from audit_log
where table_name = 'builds'
order by created_at desc;

grant select on builds_audit_log to authenticated;
