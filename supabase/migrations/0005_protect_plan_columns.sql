-- Plan and quota columns are never client-writable (PRD §8, §11.2).
-- Two layers: column-level grants, and a trigger as a backstop in case a
-- future migration re-grants table-wide UPDATE.

revoke insert, update, delete on public.profiles from anon, authenticated;
grant update (username, gender, age, weight_kg, height_cm, illnesses, allergies)
  on public.profiles to authenticated;

create or replace function public.protect_plan_columns()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  -- Security-definer functions (consume_quota) and the service role run as a
  -- privileged user; only API roles are restricted.
  if current_user in ('anon', 'authenticated') and (
       new.plan is distinct from old.plan
    or new.plan_expires_at is distinct from old.plan_expires_at
    or new.scan_count is distinct from old.scan_count
    or new.is_subscribed is distinct from old.is_subscribed
    or new.subscription_expires_at is distinct from old.subscription_expires_at
    or new.email is distinct from old.email
    or new.id is distinct from old.id
  ) then
    raise exception 'plan, quota and subscription columns are not client-writable'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger profiles_protect_plan_columns
  before update on public.profiles
  for each row execute function public.protect_plan_columns();
