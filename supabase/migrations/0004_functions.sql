-- Database functions: plan resolution, quota, leaderboard (PRD §7.3, §7.8, §8)

-- Plan limits: free 30 · pro 60 · pro_plus 120 · pro_max 240 · unlimited 999999.
-- Effective plan: a paid plan whose plan_expires_at is in the past is 'free'.
-- Roles admin/founder/collaborator: unlimited, recorded as pro_max.
create or replace function public.resolve_plan(p_user uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_profile public.profiles%rowtype;
  v_plan text;
  v_unlimited boolean;
  v_limit int;
begin
  select * into v_profile from public.profiles where id = p_user;
  if not found then
    return null;
  end if;

  v_unlimited := exists (
    select 1 from public.user_roles r
    where r.user_id = p_user and r.role in ('admin', 'founder', 'collaborator')
  );

  if v_unlimited then
    v_plan := 'pro_max';
  elsif v_profile.plan <> 'free'
        and v_profile.plan_expires_at is not null
        and v_profile.plan_expires_at < now() then
    v_plan := 'free';
  else
    v_plan := v_profile.plan;
  end if;

  v_limit := case
    when v_unlimited then 999999
    when v_plan = 'pro' then 60
    when v_plan = 'pro_plus' then 120
    when v_plan = 'pro_max' then 240
    else 30
  end;

  return jsonb_build_object(
    'plan', v_plan,
    'planLabel', case v_plan
      when 'pro' then 'Pro'
      when 'pro_plus' then 'Pro+'
      when 'pro_max' then 'Pro Max'
      else 'Free'
    end,
    'scanLimit', v_limit,
    'isUnlimited', v_unlimited,
    'scanCount', v_profile.scan_count
  );
end;
$$;

-- Called only by the analyze-scan edge function (service role), at pipeline
-- step 3, before the model call. Lifetime counter: a monthly reset is an open
-- server decision (PRD §16) and is deliberately not implemented here.
create or replace function public.consume_quota(p_user uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_plan jsonb;
  v_limit int;
  v_count int;
  v_unlimited boolean;
begin
  -- Serialise concurrent scans from the same user.
  perform 1 from public.profiles where id = p_user for update;
  v_plan := public.resolve_plan(p_user);
  if v_plan is null then
    return jsonb_build_object('ok', false, 'error', 'profile_not_found');
  end if;

  v_limit := (v_plan->>'scanLimit')::int;
  v_count := (v_plan->>'scanCount')::int;
  v_unlimited := (v_plan->>'isUnlimited')::boolean;

  if not v_unlimited and v_count >= v_limit then
    return jsonb_build_object(
      'ok', false,
      'error', 'quota_exceeded',
      'remaining', 0,
      'scanLimit', v_limit,
      'plan', v_plan->>'plan',
      'planLabel', v_plan->>'planLabel',
      'isUnlimited', false
    );
  end if;

  update public.profiles set scan_count = scan_count + 1 where id = p_user;

  return jsonb_build_object(
    'ok', true,
    'remaining', case when v_unlimited then v_limit else greatest(v_limit - v_count - 1, 0) end,
    'scanLimit', v_limit,
    'plan', v_plan->>'plan',
    'planLabel', v_plan->>'planLabel',
    'isUnlimited', v_unlimited
  );
end;
$$;

-- Read-only quota for the signed-in caller (drives the Scan screen chip).
-- Never mutates anything; the client only displays these numbers.
create or replace function public.get_my_quota()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_plan jsonb;
  v_limit int;
  v_unlimited boolean;
begin
  v_plan := public.resolve_plan(auth.uid());
  if v_plan is null then
    return null;
  end if;
  v_limit := (v_plan->>'scanLimit')::int;
  v_unlimited := (v_plan->>'isUnlimited')::boolean;
  return jsonb_build_object(
    'remaining', case when v_unlimited then v_limit
                      else greatest(v_limit - (v_plan->>'scanCount')::int, 0) end,
    'scanLimit', v_limit,
    'plan', v_plan->>'plan',
    'planLabel', v_plan->>'planLabel',
    'isUnlimited', v_unlimited
  );
end;
$$;

-- Leaderboard (PRD §7.8): usernames with >= 3 scored scans, avg desc, count
-- desc, cap 50. Exposes username + aggregates only — never health fields.
create or replace function public.get_leaderboard()
returns table (username text, avg_score numeric, scan_count bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select p.username,
         round(avg(s.health_score)) as avg_score,
         count(*) as scan_count
  from public.scans s
  join public.profiles p on p.id = s.user_id
  where p.username is not null and s.health_score is not null
  group by p.id, p.username
  having count(*) >= 3
  order by avg(s.health_score) desc, count(*) desc
  limit 50;
$$;

revoke execute on function public.resolve_plan(uuid) from public, anon, authenticated;
revoke execute on function public.consume_quota(uuid) from public, anon, authenticated;
grant execute on function public.consume_quota(uuid) to service_role;
revoke execute on function public.get_my_quota() from public, anon;
grant execute on function public.get_my_quota() to authenticated;
revoke execute on function public.get_leaderboard() from public;
grant execute on function public.get_leaderboard() to anon, authenticated;
