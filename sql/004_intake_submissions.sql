-- Intake submissions (2026-09-04). Run in the Supabase SQL editor.
--
-- Backs intake.html's ship-to-us wizard. Under this project's "no
-- Cloudflare Worker for now" decision, the wizard writes directly from the
-- anon browser client straight to Supabase (anon key + RLS as the security
-- boundary) - there's no server in between to validate or relay the
-- submission, so the table and its policies have to do that work.
create table if not exists intake_submissions (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  email         text,
  phone         text,
  service       text not null,
  firearm_type  text,
  caliber       text,
  is_nfa        boolean not null default false,
  notes         text,
  is_read       boolean not null default false,
  intake_code   text unique,
  created_at    timestamptz not null default now()
);

-- Admins can read/update/delete (admin-dashboard.html's Intake tab).
-- Anon can INSERT ONLY - no anon select/update/delete policy exists at all,
-- so a customer who just submitted the wizard can't read their own row back
-- (or anyone else's), only ever add a new one. This is the anon-insert-only
-- pattern used for every customer-facing form in this project in place of
-- the Worker+email flow GVG uses.
alter table intake_submissions enable row level security;

create policy "Admin read intake"
  on intake_submissions for select
  to authenticated
  using (is_admin());

create policy "Admin update intake"
  on intake_submissions for update
  to authenticated
  using (is_admin())
  with check (is_admin());

create policy "Admin delete intake"
  on intake_submissions for delete
  to authenticated
  using (is_admin());

create policy "Anon insert intake"
  on intake_submissions for insert
  to anon
  with check (true);

-- Intake code generator ------------------------------------------------
--
-- Customers write this code on the OUTSIDE of the box before shipping, so
-- Kevin can match an unlabeled package to a submission the moment it shows
-- up. It has to exist the instant the customer finishes the wizard (before
-- they've taped the box shut), which rules out generating it later from the
-- admin side.
--
-- Why a trigger and not client-side JS: under the no-Worker design, the
-- anon browser client only has INSERT rights on this table (see the policy
-- above) - there's no service-role key or Worker available to the browser
-- to generate and reserve a code server-side before the insert. A
-- `security definer` trigger runs with this function's owning privileges
-- rather than the caller's, so it can still safely do the collision-checked
-- generation server-side despite the anon client itself having no read
-- access to check anything.
--
-- Alphabet excludes ambiguous characters (0/O, 1/I) - this code gets
-- handwritten on a shipping box and read back by a person, not scanned.
create or replace function generate_intake_code()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  candidate text;
  i int;
  attempt int := 0;
begin
  -- Only generate when the caller didn't already supply one - lets an
  -- explicit code (e.g. a manual admin-side insert) pass through untouched
  -- instead of being clobbered.
  if new.intake_code is not null then
    return new;
  end if;

  loop
    attempt := attempt + 1;
    if attempt > 10 then
      -- Should never happen at this alphabet size (32^6 ≈ 1.07 billion
      -- combinations) - defensive only, so a runaway retry loop fails loudly
      -- instead of hanging the insert.
      raise exception 'generate_intake_code: could not generate a unique intake_code after 10 attempts';
    end if;

    candidate := 'SFF-SHIP-';
    for i in 1..6 loop
      candidate := candidate || substr(alphabet, (floor(random() * length(alphabet)) + 1)::int, 1);
    end loop;

    exit when not exists (select 1 from intake_submissions where intake_code = candidate);
  end loop;

  new.intake_code := candidate;
  return new;
end;
$$;

drop trigger if exists intake_submissions_generate_code on intake_submissions;
create trigger intake_submissions_generate_code
  before insert on intake_submissions
  for each row execute function generate_intake_code();
