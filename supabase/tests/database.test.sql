-- pgTAP tests for schema, RLS, quota and leaderboard. Run: supabase test db
begin;
create extension if not exists pgtap with schema extensions;
select plan(25);

-- Fixtures: three users created through auth (profiles come from the trigger).
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@example.com'),
  ('00000000-0000-0000-0000-00000000000b', 'b@example.com'),
  ('00000000-0000-0000-0000-00000000000c', 'c@example.com');

select is(
  (select plan from public.profiles where id = '00000000-0000-0000-0000-00000000000a'),
  'free', 'signup trigger creates a free profile');

-- ---------- As user A ----------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}', true);

select is(
  public.get_my_quota(),
  '{"remaining": 30, "scanLimit": 30, "plan": "free", "planLabel": "Free", "isUnlimited": false}'::jsonb,
  'new user sees Free · 30 of 30');

select lives_ok(
  $$ update public.profiles set username = 'alice_1', weight_kg = 60, height_cm = 165, allergies = 'peanuts'
     where id = '00000000-0000-0000-0000-00000000000a' $$,
  'owner can update username and health fields');

select throws_ok(
  $$ update public.profiles set plan = 'pro_max' where id = '00000000-0000-0000-0000-00000000000a' $$,
  '42501', null, 'plan is not client-writable');

select throws_ok(
  $$ update public.profiles set scan_count = 0 where id = '00000000-0000-0000-0000-00000000000a' $$,
  '42501', null, 'scan_count is not client-writable');

select throws_ok(
  $$ update public.profiles set plan_expires_at = now() + interval '1 year' where id = '00000000-0000-0000-0000-00000000000a' $$,
  '42501', null, 'plan_expires_at is not client-writable');

select is(
  (select count(*) from public.profiles where id <> '00000000-0000-0000-0000-00000000000a'),
  0::bigint, 'cannot read other profiles');

select throws_ok(
  $$ insert into public.scans (user_id, scan_type, health_score, result)
     values ('00000000-0000-0000-0000-00000000000a', 'ingredients', 100, '{}') $$,
  '42501', null, 'clients cannot insert scans (leaderboard integrity)');

select throws_ok(
  $$ select * from public.barcode_cache $$,
  '42501', null, 'barcode_cache is not readable by clients');

select throws_ok(
  $$ select public.consume_quota('00000000-0000-0000-0000-00000000000a') $$,
  '42501', null, 'consume_quota is not callable by clients');

-- ---------- As user B ----------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}', true);

select throws_ok(
  $$ update public.profiles set username = 'ALICE_1' where id = '00000000-0000-0000-0000-00000000000b' $$,
  '23505', null, 'usernames are unique case-insensitively');

select throws_ok(
  $$ update public.profiles set username = 'no spaces!' where id = '00000000-0000-0000-0000-00000000000b' $$,
  '23514', null, 'username format is enforced');

select lives_ok(
  $$ update public.profiles set username = 'bob' where id = '00000000-0000-0000-0000-00000000000b' $$,
  'B sets a valid username');

-- ---------- Service role / owner: scans + quota ----------
reset role;

insert into public.scans (id, user_id, scan_type, health_score, result) values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a', 'ingredients', 80, '{}'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-00000000000a', 'ingredients', 71, '{}'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-00000000000a', 'barcode', 70, '{}'),
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-00000000000b', 'ingredients', 99, '{}'),
  ('10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-00000000000b', 'ingredients', 99, '{}');
-- C has 3 scans but no username.
insert into public.scans (user_id, scan_type, health_score, result)
select '00000000-0000-0000-0000-00000000000c', 'ingredients', 90, '{}' from generate_series(1, 3);
insert into public.consumption (id, user_id, scan_id, calories_kcal) values
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-000000000001', 120);

select results_eq(
  $$ select username, avg_score, scan_count from public.get_leaderboard() $$,
  $$ values ('alice_1'::text, 74::numeric, 3::bigint) $$,
  'leaderboard: min 3 scans, username required, rounded average');

select is(
  (select array_agg(c.parameter_name::text order by c.parameter_name::text)
   from information_schema.routines r
   join information_schema.parameters c on c.specific_name = r.specific_name
   where r.routine_name = 'get_leaderboard' and c.parameter_mode = 'OUT'),
  array['avg_score', 'scan_count', 'username'],
  'leaderboard exposes no health fields');

update public.profiles set scan_count = 29 where id = '00000000-0000-0000-0000-00000000000a';
select is(
  public.consume_quota('00000000-0000-0000-0000-00000000000a')->>'remaining', '0',
  'last free credit consumed');
select is(
  public.consume_quota('00000000-0000-0000-0000-00000000000a')->>'error', 'quota_exceeded',
  'quota exceeded at the limit');
select is(
  (select scan_count from public.profiles where id = '00000000-0000-0000-0000-00000000000a'), 30,
  'exceeded attempt does not increment');

update public.profiles set plan = 'pro', plan_expires_at = now() - interval '1 day', scan_count = 0
  where id = '00000000-0000-0000-0000-00000000000b';
select is(
  public.consume_quota('00000000-0000-0000-0000-00000000000b') - 'remaining',
  '{"ok": true, "plan": "free", "planLabel": "Free", "scanLimit": 30, "isUnlimited": false}'::jsonb,
  'expired paid plan resolves to free');

update public.profiles set plan = 'pro_plus', plan_expires_at = now() + interval '30 days'
  where id = '00000000-0000-0000-0000-00000000000b';
select is(
  public.consume_quota('00000000-0000-0000-0000-00000000000b')->>'scanLimit', '120',
  'active Pro+ has 120 scans');

insert into public.user_roles (user_id, role) values ('00000000-0000-0000-0000-00000000000c', 'founder');
select is(
  public.consume_quota('00000000-0000-0000-0000-00000000000c'),
  '{"ok": true, "plan": "pro_max", "planLabel": "Pro Max", "scanLimit": 999999, "remaining": 999999, "isUnlimited": true}'::jsonb,
  'founder role is unlimited, recorded as pro_max');

-- ---------- Cross-user consumption delete fails silently ----------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}', true);
delete from public.consumption where id = '20000000-0000-0000-0000-000000000001';
reset role;
select is(
  (select count(*) from public.consumption where id = '20000000-0000-0000-0000-000000000001'),
  1::bigint, 'cannot delete another user''s consumption row');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}', true);
select throws_ok(
  $$ insert into public.consumption (user_id, scan_id, calories_kcal)
     values ('00000000-0000-0000-0000-00000000000b', '10000000-0000-0000-0000-000000000001', 10) $$,
  '42501', null, 'cannot log consumption against another user''s scan');

select results_eq(
  $$ select count(*) from public.get_leaderboard() $$,
  $$ values (1::bigint) $$,
  'leaderboard is callable by signed-in users');

set local role anon;
select results_eq(
  $$ select count(*) from public.get_leaderboard() $$,
  $$ values (1::bigint) $$,
  'leaderboard is public');

select * from finish();
rollback;
