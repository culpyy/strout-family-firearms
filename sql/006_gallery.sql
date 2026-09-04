-- Gallery projects + photos (2026-09-04). Run in the Supabase SQL editor.
--
-- Replaces gallery.html's 4 hardcoded build sections with real tables so
-- Kevin can add/edit/reorder gallery projects from admin-dashboard.html
-- instead of hand-editing HTML and pushing to GitHub. One project (an HK21,
-- an MP5, ...) holds any number of ordered, optionally-labeled photos, so a
-- multi-angle build shows as one gallery card instead of disconnected tiles.
--
-- Extended beyond a plain photo-only shape with media_type/poster_url/
-- layout_hint - needed because Strout's actual gallery has a real video
-- (the SG-43 live-fire clip) and masonry-style sizing (some tiles render
-- "wide" or "tall") that a photo-only table can't represent.
create table if not exists gallery_projects (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  type        text,
  caliber     text,
  is_showcase boolean not null default false,
  created_at  timestamptz not null default now()
);

create table if not exists gallery_project_photos (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references gallery_projects(id) on delete cascade,
  photo_url   text not null,
  label       text,
  position    integer not null default 0,
  media_type  text not null default 'image',
  poster_url  text,
  layout_hint text,
  created_at  timestamptz not null default now(),
  constraint gallery_project_photos_media_type_check
    check (media_type in ('image', 'video')),
  constraint gallery_project_photos_layout_hint_check
    check (layout_hint in ('wide', 'tall') or layout_hint is null)
);

create index if not exists gallery_project_photos_project_id_idx on gallery_project_photos(project_id);

-- Public read (gallery.html is anon-facing, no login involved), admin-only
-- write - same is_admin() pattern as every other admin-managed table in
-- this project.
alter table gallery_projects enable row level security;
alter table gallery_project_photos enable row level security;

create policy "Public read gallery_projects"
  on gallery_projects for select
  using (true);

create policy "Admin write gallery_projects"
  on gallery_projects for all
  to authenticated
  using (is_admin())
  with check (is_admin());

create policy "Public read gallery_project_photos"
  on gallery_project_photos for select
  using (true);

create policy "Admin write gallery_project_photos"
  on gallery_project_photos for all
  to authenticated
  using (is_admin())
  with check (is_admin());

grant select on gallery_projects, gallery_project_photos to anon, authenticated;
