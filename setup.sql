-- Campus guessing game: database setup.
-- Paste this whole file into Supabase > SQL Editor and press Run. Safe to run again.

-- 1. Tables -----------------------------------------------------------------

create table if not exists public.locations (
  id          uuid primary key default gen_random_uuid(),
  name        text,
  image_path  text not null,
  lat         double precision not null,
  lng         double precision not null,
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

create table if not exists public.settings (
  id          int primary key default 1 check (id = 1),
  game_title  text not null default 'FLAME Guessr',
  rounds      int  not null default 5    check (rounds between 1 and 20),
  flash_ms    int  not null default 1000 check (flash_ms between 100 and 10000),
  map_style   text not null default 'street' check (map_style in ('street', 'satellite')),
  south       double precision,
  west        double precision,
  north       double precision,
  east        double precision,
  updated_at  timestamptz not null default now()
);

insert into public.settings (id) values (1) on conflict (id) do nothing;

-- People allowed to use the admin panel.
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade
);

-- 2. Who is an admin? ---------------------------------------------------------

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admins where user_id = (select auth.uid())
  );
$$;

-- 3. Permissions: everyone can read, only admins can change -------------------

alter table public.locations enable row level security;
alter table public.settings  enable row level security;
alter table public.admins    enable row level security;  -- no policies: nobody reads it directly

grant select on public.locations, public.settings to anon, authenticated;
grant insert, update, delete on public.locations to authenticated;
grant insert, update on public.settings to authenticated;
grant execute on function public.is_admin() to anon, authenticated;

drop policy if exists "players see active photos" on public.locations;
create policy "players see active photos" on public.locations
  for select using (active or public.is_admin());

drop policy if exists "admins add photos" on public.locations;
create policy "admins add photos" on public.locations
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admins edit photos" on public.locations;
create policy "admins edit photos" on public.locations
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins delete photos" on public.locations;
create policy "admins delete photos" on public.locations
  for delete to authenticated using (public.is_admin());

drop policy if exists "everyone reads settings" on public.settings;
create policy "everyone reads settings" on public.settings
  for select using (true);

drop policy if exists "admins add settings" on public.settings;
create policy "admins add settings" on public.settings
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admins edit settings" on public.settings;
create policy "admins edit settings" on public.settings
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- 4. Photo storage ------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 5242880, array['image/jpeg'])
on conflict (id) do nothing;

drop policy if exists "admins see photo files" on storage.objects;
create policy "admins see photo files" on storage.objects
  for select to authenticated using (bucket_id = 'photos' and public.is_admin());

drop policy if exists "admins upload photo files" on storage.objects;
create policy "admins upload photo files" on storage.objects
  for insert to authenticated with check (bucket_id = 'photos' and public.is_admin());

drop policy if exists "admins delete photo files" on storage.objects;
create policy "admins delete photo files" on storage.objects
  for delete to authenticated using (bucket_id = 'photos' and public.is_admin());

-- 5. Make yourself an admin ---------------------------------------------------
-- First create your user under Authentication > Users > Add user.
-- Then put your email below, remove the two dashes at the start of the next
-- two lines, and run just those lines.

-- insert into public.admins (user_id)
-- select id from auth.users where email = 'you@example.com';
