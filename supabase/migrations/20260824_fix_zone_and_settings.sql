-- =============================================================================
--  Fix: empty "Arrondissement" / "Quartier" dropdowns + subscription screen trap
-- =============================================================================
--
--  WHY THIS EXISTS
--  ---------------
--  1. The Flutter app reads zones from the `zone` table and expects the columns
--     `area`, `quartiers`, `latitude` and `longitude`. Those columns did not
--     exist, so the old client-side seeder (`seedArrondissements()`) failed with
--     PGRST204 on every launch and the table stayed empty — which is why the
--     Arrondissement dropdown rendered blank, and the Quartier dropdown (which
--     is derived from the selected zone) with it.
--
--  2. `vendor_categories` was missing the columns the app maps
--     (`photo`, `description`, `review_attributes`).
--
--  3. There was no `AdminCommission` row in `settings`. The splash gate treats a
--     missing/NULL AdminCommission as "subscriptions required" and pushed every
--     vendor onto the subscription screen via Get.offAll() — with no way back.
--
--  HOW TO RUN
--  ----------
--  Supabase Dashboard → SQL Editor → paste this file → Run.
--  It is idempotent: safe to run more than once.
--
-- =============================================================================

begin;

-- ─── 1. zone: add the columns the app expects ────────────────────────────────
-- `area` holds the polygon as a JSON array of {latitude, longitude} objects.
-- `quartiers` holds a JSON array of neighbourhood name strings.
alter table public.zone
  add column if not exists area      jsonb            not null default '[]'::jsonb,
  add column if not exists quartiers jsonb            not null default '[]'::jsonb,
  add column if not exists latitude  double precision,
  add column if not exists longitude double precision;

-- ─── 2. vendor_categories: add the columns the app maps ──────────────────────
alter table public.vendor_categories
  add column if not exists photo             text,
  add column if not exists description       text,
  add column if not exists review_attributes jsonb not null default '[]'::jsonb;

-- Prevent duplicate zones when seeding by name.
create unique index if not exists zone_name_key on public.zone (name);

-- ─── 3. Seed the 10 arrondissements of N'Djamena ─────────────────────────────
-- NOTE: `zone.id` is a TEXT column (not uuid), so we supply stable text ids.
--
-- The polygon below is the approximate N'Djamena bounding box carried over from
-- the previous Dart seeder. Replace it with real per-arrondissement polygons
-- when you have them.
--
-- IMPORTANT: only the 1er Arrondissement has its `quartiers` populated (these
-- are the values that were already hard-coded in the app). The remaining nine
-- are intentionally left as empty arrays rather than guessed at — fill them in
-- with authoritative data. While a zone has no quartiers, the app correctly
-- hides the Quartier dropdown for it.
insert into public.zone (id, name, publish, area, quartiers, latitude, longitude)
values
  (
    'zone-ndj-01', '1er Arrondissement', true,
    '[{"latitude":12.1645,"longitude":14.9904},
      {"latitude":12.1645,"longitude":15.1324},
      {"latitude":12.0628,"longitude":15.1324},
      {"latitude":12.0628,"longitude":14.9904}]'::jsonb,
    '["Farcha","Milezi","Madjorio","Guilmeye","Djougoulier","Karkandjeri",
      "Amsinéné","Guinébor","N''Djamena-Koudou","Massil Abcoma","Zaraf",
      "Allaya","Ardeb-Timan","Antona"]'::jsonb,
    12.1131, 15.0491
  ),
  ('zone-ndj-02', '2e Arrondissement',  true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491),
  ('zone-ndj-03', '3e Arrondissement',  true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491),
  ('zone-ndj-04', '4e Arrondissement',  true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491),
  ('zone-ndj-05', '5e Arrondissement',  true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491),
  ('zone-ndj-06', '6e Arrondissement',  true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491),
  ('zone-ndj-07', '7e Arrondissement',  true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491),
  ('zone-ndj-08', '8e Arrondissement',  true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491),
  ('zone-ndj-09', '9e Arrondissement',  true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491),
  ('zone-ndj-10', '10e Arrondissement', true, '[]'::jsonb, '[]'::jsonb, 12.1131, 15.0491)
on conflict (name) do update
  set publish   = excluded.publish,
      area      = excluded.area,
      quartiers = excluded.quartiers,
      latitude  = excluded.latitude,
      longitude = excluded.longitude;

-- ─── 4. settings: create the missing AdminCommission row ─────────────────────
-- `isEnabled: false` + the existing `restaurant.subscription_model: false`
-- means the splash gate sends vendors straight to the dashboard instead of
-- trapping them on the subscription screen.
--
-- Flip `isEnabled` to true (and set amount/commissionType) when you actually
-- want to charge a per-order commission.
insert into public.settings (key, data)
values (
  'AdminCommission',
  '{"isEnabled": false, "amount": "0", "commissionType": "Percent"}'::jsonb
)
on conflict (key) do nothing;

commit;

-- ─── Verify ──────────────────────────────────────────────────────────────────
-- select name, quartiers from public.zone order by name;
-- select key, data from public.settings where key in ('restaurant','AdminCommission');
