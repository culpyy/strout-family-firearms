-- Gallery seed data (2026-09-04). Run in the Supabase SQL editor.
--
-- Seed data reproducing gallery.html's pre-Supabase hardcoded sections -
-- safe to edit or delete via admin-dashboard.html once live; not sample/
-- fake data, these are Strout's real completed builds. Every photo_url below
-- points at an image file that already exists under images/ in this repo
-- (confirmed directly against the directory listing and against
-- gallery.html's actual data-src/data-title/data-sub attributes) - nothing
-- here is invented or re-uploaded.
--
-- Each project uses a `with proj as (insert ... returning id) insert ...
-- select ... from proj` pattern so the photos insert can reference the
-- project's freshly-generated id without a separate round trip or a
-- hardcoded uuid literal.

-- 1) HK21 - Light Machine Gun, 7.62x51mm NATO
with proj as (
  insert into gallery_projects (title, type, caliber, is_showcase)
  values ('Heckler & Koch HK21', 'Light Machine Gun', '7.62x51mm NATO', true)
  returning id
)
insert into gallery_project_photos (project_id, photo_url, label, position, layout_hint, media_type, poster_url)
select id, v.photo_url, v.label, v.position, v.layout_hint, v.media_type, v.poster_url
from proj
cross join (values
  ('images/HK21/Benny-HK21-left-feed-drum.jpg',   'HK21 - Left Side, Drum Mag', 0, 'wide', 'image', null),
  ('images/HK21/Benny-HK21-left.jpg',              'HK21 - Left Profile',        1, 'tall', 'image', null),
  ('images/HK21/Benny-HK21-right-barrel.jpg',      'HK21 - Barrel Detail',       2, null,   'image', null),
  ('images/HK21/Benny-HK21-right.jpg',             'HK21 - Right Side',          3, null,   'image', null),
  ('images/HK21/Benny-HK21-left-feed-drum-2.jpg',  'HK21 - Drum Mag, Alt Angle', 4, null,   'image', null),
  ('images/HK21/Benny-HK21-left-feed.jpg',         'HK21 - Left Feed',           5, null,   'image', null),
  ('images/HK21/Benny-HK21-rear.jpg',               'HK21 - Rear View',          6, null,   'image', null),
  ('images/HK21/Benny-HK21-right-ejection.jpg',     'HK21 - Right Ejection Port', 7, null,  'image', null),
  ('images/HK21/Benny-HK21-right-rear.jpg',         'HK21 - Right Rear',          8, 'wide', 'image', null)
) as v(photo_url, label, position, layout_hint, media_type, poster_url);

-- 2) MP5 - Submachine Gun, 9mm
with proj as (
  insert into gallery_projects (title, type, caliber, is_showcase)
  values ('Heckler & Koch MP5', 'Submachine Gun', '9x19mm Parabellum', true)
  returning id
)
insert into gallery_project_photos (project_id, photo_url, label, position, layout_hint, media_type, poster_url)
select id, v.photo_url, v.label, v.position, v.layout_hint, v.media_type, v.poster_url
from proj
cross join (values
  ('images/MP5/1000001364.jpg', 'MP5 - Stock Extended', 0, 'wide', 'image', null),
  ('images/MP5/1000001366.jpg', 'MP5 - Left Profile',   1, null,   'image', null),
  ('images/MP5/1000001369.jpg', 'MP5 - Right Side',     2, null,   'image', null)
) as v(photo_url, label, position, layout_hint, media_type, poster_url);

-- 3) SG-43 - Medium Machine Gun, 7.62x54mmR
-- One image row plus one video row - the only video in the gallery, so it's
-- the reason gallery_project_photos has media_type/poster_url at all
-- (006_gallery.sql). poster_url points at the still image so the video
-- shows a real frame instead of a blank box before playback.
with proj as (
  insert into gallery_projects (title, type, caliber, is_showcase)
  values ('Soviet SG-43 Goryunov', 'Medium Machine Gun', '7.62x54mmR', true)
  returning id
)
insert into gallery_project_photos (project_id, photo_url, label, position, layout_hint, media_type, poster_url)
select id, v.photo_url, v.label, v.position, v.layout_hint, v.media_type, v.poster_url
from proj
cross join (values
  ('images/SG-43/SG-43-on-cart.jpg',          'SG-43 - On Sokolov Cart', 0, 'wide', 'image', null),
  ('images/SG-43/SG-43-10-round-Burst.mp4',   'Live Fire',                1, null,   'video', 'images/SG-43/SG-43-on-cart.jpg')
) as v(photo_url, label, position, layout_hint, media_type, poster_url);

-- 4) Vickers - Water-Cooled HMG, .303 British
with proj as (
  insert into gallery_projects (title, type, caliber, is_showcase)
  values ('Vickers Machine Gun', 'Water-Cooled HMG', '.303 British', true)
  returning id
)
insert into gallery_project_photos (project_id, photo_url, label, position, layout_hint, media_type, poster_url)
select id, v.photo_url, v.label, v.position, v.layout_hint, v.media_type, v.poster_url
from proj
cross join (values
  ('images/Vickers/448794938_966090861977713_1507913551610780739_n.jpg', 'Vickers - Full View',        0, 'wide', 'image', null),
  ('images/Vickers/448768198_966090905311042_1663343854101752196_n.jpg', 'Vickers - Traversing Gear',  1, 'tall', 'image', null),
  ('images/Vickers/448866457_966090815311051_5249577123182383749_n.jpg', 'Vickers - Third Angle',      2, null,   'image', null)
) as v(photo_url, label, position, layout_hint, media_type, poster_url);
