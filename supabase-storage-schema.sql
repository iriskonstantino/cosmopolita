insert into storage.buckets (id, name, public)
values ('character-images', 'character-images', true)
on conflict (id) do update set public = true;

create policy "Anyone can read character images"
on storage.objects
for select
using (bucket_id = 'character-images');

create policy "Admin can upload character images"
on storage.objects
for insert
with check (
  bucket_id = 'character-images'
  and (auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com'
);

create policy "Admin can update character images"
on storage.objects
for update
using (
  bucket_id = 'character-images'
  and (auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com'
)
with check (
  bucket_id = 'character-images'
  and (auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com'
);

create policy "Admin can delete character images"
on storage.objects
for delete
using (
  bucket_id = 'character-images'
  and (auth.jwt() ->> 'email') = 'pcygnus2112@gmail.com'
);
