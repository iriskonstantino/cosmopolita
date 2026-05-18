create table if not exists public.characters (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.codex_entries (
  entry_key text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.chapters (
  id text primary key,
  position integer not null default 0,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.poetic_engines (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.characters enable row level security;
alter table public.codex_entries enable row level security;
alter table public.chapters enable row level security;
alter table public.poetic_engines enable row level security;

create policy "Anyone can read characters"
  on public.characters
  for select
  using (true);

create policy "Admin can create characters"
  on public.characters
  for insert
  with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Admin can update characters"
  on public.characters
  for update
  using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Admin can delete characters"
  on public.characters
  for delete
  using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Anyone can read codex entries"
  on public.codex_entries
  for select
  using (true);

create policy "Admin can create codex entries"
  on public.codex_entries
  for insert
  with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Admin can update codex entries"
  on public.codex_entries
  for update
  using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Admin can delete codex entries"
  on public.codex_entries
  for delete
  using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Anyone can read chapters"
  on public.chapters
  for select
  using (true);

create policy "Admin can create chapters"
  on public.chapters
  for insert
  with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Admin can update chapters"
  on public.chapters
  for update
  using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Admin can delete chapters"
  on public.chapters
  for delete
  using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Anyone can read poetic engines"
  on public.poetic_engines
  for select
  using (true);

create policy "Admin can create poetic engines"
  on public.poetic_engines
  for insert
  with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Admin can update poetic engines"
  on public.poetic_engines
  for update
  using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');

create policy "Admin can delete poetic engines"
  on public.poetic_engines
  for delete
  using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');
