create table if not exists public.chapters (
  id text primary key,
  position integer not null default 0,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.chapters enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'chapters'
      and policyname = 'Anyone can read chapters'
  ) then
    create policy "Anyone can read chapters"
      on public.chapters
      for select
      using (true);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'chapters'
      and policyname = 'Admin can create chapters'
  ) then
    create policy "Admin can create chapters"
      on public.chapters
      for insert
      with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'chapters'
      and policyname = 'Admin can update chapters'
  ) then
    create policy "Admin can update chapters"
      on public.chapters
      for update
      using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com')
      with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'chapters'
      and policyname = 'Admin can delete chapters'
  ) then
    create policy "Admin can delete chapters"
      on public.chapters
      for delete
      using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');
  end if;
end $$;
