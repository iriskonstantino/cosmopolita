create table if not exists public.manuscripts (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.manuscripts enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'manuscripts'
      and policyname = 'Admin can read manuscripts'
  ) then
    create policy "Admin can read manuscripts"
      on public.manuscripts
      for select
      using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'manuscripts'
      and policyname = 'Admin can create manuscripts'
  ) then
    create policy "Admin can create manuscripts"
      on public.manuscripts
      for insert
      with check ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'manuscripts'
      and policyname = 'Admin can update manuscripts'
  ) then
    create policy "Admin can update manuscripts"
      on public.manuscripts
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
      and tablename = 'manuscripts'
      and policyname = 'Admin can delete manuscripts'
  ) then
    create policy "Admin can delete manuscripts"
      on public.manuscripts
      for delete
      using ((auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com');
  end if;
end $$;
