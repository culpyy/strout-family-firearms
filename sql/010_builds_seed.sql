-- Builds seed data (2026-09-04). Run in the Supabase SQL editor.
--
-- *** DEMO/SAMPLE DATA - NOT REAL CUSTOMERS ***
-- Ported from the 5 sample builds currently hardcoded in js/builds.js, so
-- inshop.html/track.html/admin-dashboard.html have something real-shaped to
-- render and generateTrackingCode() has an existing SFF-2026-NNN sequence
-- to increment from on first use. Safe and expected to be deleted via
-- admin-dashboard.html before real use (see the go-live checklist) -
-- js/builds.js never collected customer_name/email/phone, so those columns
-- are left null here rather than invented.
--
-- Old flat status -> new adaptive-stage mapping:
-- js/builds.js only had 7 flat statuses (intake, parts-ordered, in-progress,
-- testing, atf-filed, atf-approved, ready). The new schema uses adaptive
-- pipelines (9-stage standard / 11-stage NFA, see the plan) with more
-- granularity in the middle of the build - there's no exact old-to-new
-- mapping for "in-progress", just a best guess from each build's notes:
--   - Vickers (atf-filed, is_nfa) -> status stays 'atf-filed', unchanged.
--   - Custom 1911 (parts-ordered) -> status stays 'parts-ordered', unchanged.
--   - Remington 700 (intake) -> status stays 'intake', unchanged.
--   - SBR Form 1 build (in-progress, 65%, is_nfa) -> best-guess mapped to
--     'machining' (upper build in progress). JUDGMENT CALL - correct this
--     to whatever its real current stage is once this is live data.
--   - HK MP5 parts-kit build (in-progress, 45%, not NFA-regulated as a
--     parts-kit build) -> best-guess mapped to 'weld' (receiver work done,
--     kit fitting in progress). JUDGMENT CALL - same caveat as above.
insert into builds (title, type, caliber, status, received, eta, atf_form, atf_filed, notes, is_nfa, tracking_code)
values
  ('Vickers Mk.I Restoration', 'Water-Cooled HMG', '.303 British', 'atf-filed',
   '2026-04-15', '2026-07-15', 'Form 3', '2026-06-05',
   'Build complete. Range session done, timing and headspace verified. ATF Form 3 submitted. Awaiting approval to transfer.',
   true, 'SFF-2026-001'),

  ('SBR Form 1 Build', 'Short-Barreled Rifle', '.300 Blackout', 'machining',
   '2026-05-02', '2026-06-28', 'Form 1', null,
   'Form 1 pre-approved by ATF. Upper build in progress.',
   true, 'SFF-2026-002'),

  ('HK MP5 Parts Kit Build', 'Submachine Gun', '9mm Parabellum', 'weld',
   '2026-05-10', '2026-07-10', null, null,
   'Receiver work done. Parts kit fitting in progress.',
   false, 'SFF-2026-003'),

  ('Custom 1911 Full Build', 'Pistol', '.45 ACP', 'parts-ordered',
   '2026-05-20', '2026-07-18', null, null,
   'Barrel, slide, and frame on order. Will call when parts arrive.',
   false, 'SFF-2026-004'),

  ('Remington 700 Precision Build', 'Bolt-Action Rifle', '.308 Winchester', 'intake',
   '2026-06-05', null, null, null,
   'Assessment in progress. Quote within 48 hours.',
   false, 'SFF-2026-005');
