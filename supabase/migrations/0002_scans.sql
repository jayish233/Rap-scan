-- scans, consumption, scan_feedback (PRD §11.2, architecture.md §3.1)

create table public.scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_name text,
  scan_type text not null check (scan_type in ('ingredients', 'barcode')),
  rating text check (rating in ('good', 'okay', 'caution', 'avoid')),
  health_score int,
  calories_kcal int,
  summary text,
  input_text text,            -- pasted ingredients or barcode; NEVER photos (PRD §13)
  result jsonb not null,      -- full PRD §11.1 object
  created_at timestamptz not null default now()
);

create index scans_user_created on public.scans (user_id, created_at desc);

create table public.consumption (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  scan_id uuid not null references public.scans(id) on delete cascade,
  product_name text,
  calories_kcal int,
  consumed_at timestamptz not null default now()
);

create index consumption_user_consumed on public.consumption (user_id, consumed_at desc);

create table public.scan_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  scan_id uuid not null references public.scans(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  buy_again text not null check (buy_again in ('yes', 'maybe', 'no')),
  comment text check (char_length(comment) <= 1000),
  created_at timestamptz not null default now(),
  unique (user_id, scan_id)
);

alter table public.scans enable row level security;
alter table public.consumption enable row level security;
alter table public.scan_feedback enable row level security;

-- scans: owner may read and delete. Rows are written only by the analyze-scan
-- edge function (service role) so clients cannot fabricate scores that would
-- feed the leaderboard.
create policy "scans: owner can read"
  on public.scans for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "scans: owner can delete"
  on public.scans for delete to authenticated
  using ((select auth.uid()) = user_id);

-- consumption: owner-only, and only against the owner's own scans.
create policy "consumption: owner can read"
  on public.consumption for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "consumption: owner can insert"
  on public.consumption for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (select 1 from public.scans s where s.id = scan_id and s.user_id = (select auth.uid()))
  );

create policy "consumption: owner can update"
  on public.consumption for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "consumption: owner can delete"
  on public.consumption for delete to authenticated
  using ((select auth.uid()) = user_id);

-- scan_feedback: owner-only, one row per (user, scan); re-save is an upsert.
create policy "feedback: owner can read"
  on public.scan_feedback for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "feedback: owner can insert"
  on public.scan_feedback for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (select 1 from public.scans s where s.id = scan_id and s.user_id = (select auth.uid()))
  );

create policy "feedback: owner can update"
  on public.scan_feedback for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "feedback: owner can delete"
  on public.scan_feedback for delete to authenticated
  using ((select auth.uid()) = user_id);
