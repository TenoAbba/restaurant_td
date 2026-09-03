-- =============================================================================
--  Seed: vendor_categories
-- =============================================================================
--  The migration that added columns to vendor_categories left the table empty.
--  This file seeds a set of sensible default restaurant/food delivery categories.
--
--  HOW TO RUN
--  ----------  
--  Supabase Dashboard → SQL Editor → paste this file → Run.
--  It is idempotent: safe to run more than once (uses ON CONFLICT).
--
-- =============================================================================

begin;

-- Prevent duplicate categories by name.
create unique index if not exists vendor_categories_name_key
  on public.vendor_categories (name);

insert into public.vendor_categories (id, name, photo, description, review_attributes)
values
  ('cat-fast-food',    'Fast Food',    null, 'Burgers, pizza, fried chicken and similar quick-service meals.', '[]'::jsonb),
  ('cat-cafe',        'Café',        null, 'Coffee, pastries, sandwiches and light bites.',                  '[]'::jsonb),
  ('cat-traditional',  'Traditional',  null, 'Local and traditional dishes from the region.',               '[]'::jsonb),
  ('cat-grill',       'Grill & BBQ', null, 'Grilled meats, kebabs, roasts and BBQ specialties.',         '[]'::jsonb),
  ('cat-pizza',       'Pizza',        null, 'Wood-fired, Neapolitan, delivery pizzas and more.',           '[]'::jsonb),
  ('cat-asian',       'Asian',        null, 'Chinese, Thai, Vietnamese, Japanese and other Asian cuisines.','[]'::jsonb),
  ('cat-african',     'African',      null, 'West African, North African and pan-African cuisine.',         '[]'::jsonb),
  ('cat-lebanese',    'Lebanese',    null, 'Mezze, kebabs, falafel and Levantine specialties.',          '[]'::jsonb),
  ('cat-bakery',      'Bakery',      null, 'Fresh bread, pastries, cakes and baked goods.',               '[]'::jsonb),
  ('cat-desserts',    'Desserts',    null, 'Ice cream, shakes, pastries and sweet treats.',              '[]'::jsonb),
  ('cat-healthy',     'Healthy',     null, 'Salads, bowls, juices and health-conscious meals.',           '[]'::jsonb)
on conflict (name) do nothing;

commit;

-- verify:
-- select name from public.vendor_categories order by name;
