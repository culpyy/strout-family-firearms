-- Storage bucket + policies (2026-09-04). Run in the Supabase SQL editor.
--
-- Under this project's "no Cloudflare Worker for now" decision, photo
-- uploads go straight to Supabase Storage from the browser (anon/
-- authenticated key + RLS as the security boundary), not to R2 through a
-- Worker like GVG's admin dashboard does. One bucket, `site-media`, serves
-- both future build-photo uploads and gallery-photo uploads from
-- admin-dashboard.html - no need to split buckets per feature at this scale.
insert into storage.buckets (id, name, public)
values ('site-media', 'site-media', true)
on conflict (id) do nothing;

-- Public read - the bucket is marked public above for direct URL access
-- (img src="<public-url>"), and this policy is what actually lets anon/
-- authenticated SELECT the object rows themselves through the Storage API.
create policy "Public read site-media"
  on storage.objects for select
  using (bucket_id = 'site-media');

-- Admin-only write. Same is_admin() function as every table in this
-- project - Storage RLS policies can call it exactly like table policies
-- since it's just a plain SQL function, not something scoped to `public`
-- schema tables only.
create policy "Admin write site-media"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'site-media' and is_admin());

create policy "Admin update site-media"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'site-media' and is_admin())
  with check (bucket_id = 'site-media' and is_admin());

create policy "Admin delete site-media"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'site-media' and is_admin());

-- Note: the gallery rows seeded in 007_gallery_seed.sql keep their
-- relative `images/...` paths untouched by this file - photo_url is just a
-- text column, it doesn't care whether it holds a relative path served by
-- GitHub Pages or a full Supabase Storage public URL. Future gallery/build
-- uploads through admin-dashboard.html will store real
-- https://<project>.supabase.co/storage/v1/object/public/site-media/...
-- URLs in that same column, side by side with the seeded relative ones.
