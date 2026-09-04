-- Contact submissions (2026-09-04). Run in the Supabase SQL editor.
--
-- Backs contact.html, whose submit handler is currently decorative - fields
-- get validated in the browser and then go nowhere, no message has ever
-- actually reached anyone. This table plus the anon-insert policy below is
-- what a real rewired handler writes to, matching contact.html's existing
-- fields exactly so no markup changes are needed.
create table if not exists contact_submissions (
  id          uuid primary key default gen_random_uuid(),
  first_name  text not null,
  last_name   text not null,
  email       text not null,
  phone       text,
  subject     text not null,
  message     text not null,
  is_read     boolean not null default false,
  created_at  timestamptz not null default now()
);

-- Same anon-insert-only pattern as intake_submissions: admins get full
-- read/update/delete via is_admin(), anon can insert only and never read
-- back what it just submitted.
alter table contact_submissions enable row level security;

create policy "Admin read contact"
  on contact_submissions for select
  to authenticated
  using (is_admin());

create policy "Admin update contact"
  on contact_submissions for update
  to authenticated
  using (is_admin())
  with check (is_admin());

create policy "Admin delete contact"
  on contact_submissions for delete
  to authenticated
  using (is_admin());

create policy "Anon insert contact"
  on contact_submissions for insert
  to anon
  with check (true);
