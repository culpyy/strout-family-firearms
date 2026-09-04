-- Public builds view (2026-09-04). Run in the Supabase SQL editor.
--
-- builds (previous file) is admin-only - no anon or public policy on it at
-- all. This view is the ONLY sanctioned way inshop.html, track.html, and
-- index.html ever read build data: same rows, minus every PII column.
--
-- Deliberately excludes customer_name, customer_email, customer_phone, and
-- internal_notes - that exclusion IS the entire PII boundary for every
-- public-facing page in this project. There is no query shape, filter, or
-- role that can pull those four columns through this view, because they
-- were never selected into it in the first place.
--
-- *** IMPORTANT: any future column addition MUST be appended to the END of
-- this SELECT list, never inserted in the middle. ***
-- CREATE OR REPLACE VIEW treats a mid-list insertion as RENAMING the column
-- it displaced, not adding a new one - Postgres error 42P16 if the type
-- doesn't match, or worse, a silent rename if it does. This is a real
-- footgun confirmed the hard way on the sister GVG project (see that repo's
-- build_completion_public.sql/build_gallery.sql comments) - always add new
-- columns after completed_at below, never before it.
create or replace view builds_public as
select
  id, title, type, caliber, status, received, eta,
  atf_form, atf_filed, tracking_code, notes, is_nfa,
  created_at, updated_at,
  completed_at
from builds;

grant select on builds_public to anon, authenticated;
