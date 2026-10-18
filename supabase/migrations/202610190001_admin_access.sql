-- Admin membership is managed by the project owner in the SQL Editor.
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;
revoke all on public.admin_users from anon, authenticated;
grant select on public.admin_users to authenticated;

drop policy if exists "admins can read their own membership" on public.admin_users;
create policy "admins can read their own membership"
  on public.admin_users for select to authenticated
  using ((select auth.uid()) = user_id);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admin_users
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

-- Admins can read unpublished content; learners can read published content.
drop policy if exists "published categories are readable" on public.content_categories;
create policy "published categories are readable"
  on public.content_categories for select to anon, authenticated
  using (published or (select public.is_admin()));

drop policy if exists "published lessons are readable" on public.lessons;
create policy "published lessons are readable"
  on public.lessons for select to anon, authenticated
  using (published or (select public.is_admin()));

drop policy if exists "published lesson sections are readable" on public.lesson_sections;
create policy "published lesson sections are readable"
  on public.lesson_sections for select to anon, authenticated
  using (exists (
    select 1 from public.lessons l
    where l.id = lesson_id and (l.published or (select public.is_admin()))
  ));

drop policy if exists "published questions are readable" on public.questions;
create policy "published questions are readable"
  on public.questions for select to anon, authenticated
  using (published or (select public.is_admin()));

drop policy if exists "published question options are readable" on public.question_options;
create policy "published question options are readable"
  on public.question_options for select to anon, authenticated
  using (exists (
    select 1 from public.questions q
    where q.id = question_id and (q.published or (select public.is_admin()))
  ));

-- Writes are only allowed for authenticated users listed in admin_users.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'content_categories', 'lessons', 'lesson_sections', 'questions', 'question_options'
  ] loop
    execute format('drop policy if exists "admins manage %I" on public.%I', table_name, table_name);
    execute format(
      'create policy %I on public.%I for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()))',
      'admins manage ' || table_name, table_name
    );
    execute format('grant select, insert, update, delete on public.%I to authenticated', table_name);
  end loop;
end;
$$;

-- The road-sign bucket is public for app display; only admins may change files.
drop policy if exists "admins upload road sign images" on storage.objects;
create policy "admins upload road sign images"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'road-signs' and (select public.is_admin()));

drop policy if exists "admins update road sign images" on storage.objects;
create policy "admins update road sign images"
  on storage.objects for update to authenticated
  using (bucket_id = 'road-signs' and (select public.is_admin()))
  with check (bucket_id = 'road-signs' and (select public.is_admin()));

drop policy if exists "admins delete road sign images" on storage.objects;
create policy "admins delete road sign images"
  on storage.objects for delete to authenticated
  using (bucket_id = 'road-signs' and (select public.is_admin()));
