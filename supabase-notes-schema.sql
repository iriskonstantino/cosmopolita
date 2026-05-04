create table if not exists public.reader_notes (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  chapter_id text not null,
  body text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists reader_notes_user_chapter_idx
  on public.reader_notes (user_id, chapter_id);

alter table public.reader_notes enable row level security;

create policy "Users can read their own notes"
  on public.reader_notes
  for select
  using (auth.uid() = user_id);

create policy "Users can create their own notes"
  on public.reader_notes
  for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own notes"
  on public.reader_notes
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own notes"
  on public.reader_notes
  for delete
  using (auth.uid() = user_id);
