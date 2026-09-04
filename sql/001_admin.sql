-- Admin identity (2026-09-04). Run in the Supabase SQL editor.
--
-- Single source of truth for "who is actually an admin." Every RLS policy
-- in every file that follows (002 through 010) calls this one function
-- instead of duplicating a UID list or checking auth.role() = 'authenticated'
-- (which only proves someone is logged in, not that they're Kevin/Braeden -
-- GVG shipped that exact bug for a while, see the sister project's
-- security_hardening.sql). To add or remove an admin later, this is the
-- ONLY place that ever needs editing.
--
-- *** PLACEHOLDER UUID - THIS WILL NOT WORK UNTIL REPLACED ***
-- '00000000-0000-0000-0000-000000000000' is a placeholder. No real
-- auth.users row will ever have this UUID, so as shipped every "using
-- (is_admin())" policy in this project locks EVERYONE out, including the
-- real admin - that's the safe failure mode for code-readiness (nobody can
-- accidentally get in), not a bug.
--
-- TODO before go-live (see the plan's go-live checklist):
--   1. Create the real admin account in Supabase Dashboard > Authentication > Users.
--   2. Copy that user's UUID.
--   3. Replace the placeholder below with it and re-run this file
--      (CREATE OR REPLACE FUNCTION is idempotent - safe to run again).
--   4. Turn off public signup (Authentication > Providers > Email) so no one
--      else can ever create an account, let alone get added here.
create or replace function is_admin()
returns boolean
language sql
stable
as $$
  select auth.uid() in (
    '00000000-0000-0000-0000-000000000000' -- TODO: replace with the real admin user's UUID after they sign up
  );
$$;
