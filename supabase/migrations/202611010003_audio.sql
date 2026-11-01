-- Recorded audio for lessons and questions, played by the app's listen (🔊)
-- buttons. Admins upload recordings from the dashboard; a button only shows
-- when a recording exists. Run after 202610190001_admin_access.sql.
alter table public.lessons add column if not exists audio_path text;
alter table public.questions add column if not exists audio_path text;

-- Public bucket so the app can stream files; 20 MB limit, audio types only.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('audio', 'audio', true, 20971520,
        array['audio/mpeg', 'audio/mp4', 'audio/x-m4a', 'audio/aac', 'audio/ogg', 'audio/wav', 'audio/x-wav', 'audio/webm'])
on conflict (id) do nothing;

drop policy if exists "public can read audio" on storage.objects;
create policy "public can read audio"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'audio');

drop policy if exists "admins upload audio" on storage.objects;
create policy "admins upload audio"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'audio' and (select public.is_admin()));

drop policy if exists "admins update audio" on storage.objects;
create policy "admins update audio"
  on storage.objects for update to authenticated
  using (bucket_id = 'audio' and (select public.is_admin()))
  with check (bucket_id = 'audio' and (select public.is_admin()));

drop policy if exists "admins delete audio" on storage.objects;
create policy "admins delete audio"
  on storage.objects for delete to authenticated
  using (bucket_id = 'audio' and (select public.is_admin()));
