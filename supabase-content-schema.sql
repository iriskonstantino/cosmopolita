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

alter table public.characters enable row level security;
alter table public.codex_entries enable row level security;

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
