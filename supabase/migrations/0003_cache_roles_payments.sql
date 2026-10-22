-- barcode_cache, user_roles, payments (PRD §11.2, architecture.md §3.1)

create table public.barcode_cache (
  barcode text primary key,
  result jsonb not null,      -- shared analysis; registry identity + rule-based organs
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_roles (
  user_id uuid references public.profiles(id) on delete cascade,
  role text not null check (role in ('admin', 'founder', 'collaborator', 'user')),
  primary key (user_id, role)
);

create table public.payments (   -- server-only writes (Razorpay, INR paise)
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  order_id text,
  payment_id text,
  amount_paise int,
  status text,
  created_at timestamptz not null default now()
);

create index payments_user on public.payments (user_id, created_at desc);

alter table public.barcode_cache enable row level security;
alter table public.user_roles enable row level security;
alter table public.payments enable row level security;

-- barcode_cache: no client policies at all. Clients read through analyze-scan,
-- which consumes quota; querying the cache directly would skip it.
revoke all on public.barcode_cache from anon, authenticated;

-- user_roles / payments: read own rows; writes are service-role only.
create policy "user_roles: owner can read"
  on public.user_roles for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "payments: owner can read"
  on public.payments for select to authenticated
  using ((select auth.uid()) = user_id);
