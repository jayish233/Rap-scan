-- "I ate this" logs the scan's own per-serving estimate (PRD §7.7). Copy the
-- product name and calories from the scan row so a client cannot log
-- arbitrary values.
create or replace function public.consumption_from_scan()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  select s.product_name, least(greatest(coalesce(s.calories_kcal, 0), 0), 5000)
    into new.product_name, new.calories_kcal
  from public.scans s
  where s.id = new.scan_id and s.user_id = new.user_id;
  return new;
end;
$$;

create trigger consumption_fill_from_scan
  before insert on public.consumption
  for each row execute function public.consumption_from_scan();
