-- profiles: one row per auth user (PRD §11.2, architecture.md §3.1)

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  username text check (username is null or username ~ '^[A-Za-z0-9_]{3,20}$'),
  gender text not null default '' check (gender in ('', 'female', 'male', 'non_binary', 'other')),
  age int check (age between 1 and 129),
  weight_kg numeric check (weight_kg > 0 and weight_kg < 500),
  height_cm numeric check (height_cm > 0 and height_cm < 300),
  illnesses text not null default '' check (char_length(illnesses) <= 500),
  allergies text not null default '' check (char_length(allergies) <= 500),
  scan_count int not null default 0,
  plan text not null default 'free' check (plan in ('free', 'pro', 'pro_plus', 'pro_max')),
  plan_expires_at timestamptz,
  is_subscribed boolean not null default false,
  subscription_expires_at timestamptz,
  created_at timestamptz not null default now()
);

-- Usernames are unique case-insensitively (PRD §7.9, §15).
create unique index profiles_username_lower on public.profiles (lower(username))
  where username is not null;

alter table public.profiles enable row level security;

-- Owner-only access. Profiles are created by the signup trigger below, never by
-- the client, so there is no insert policy. Account deletion goes to the team.
create policy "profiles: owner can read"
  on public.profiles for select to authenticated
  using ((select auth.uid()) = id);

create policy "profiles: owner can update"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Create a free profile for every new auth user.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
