-- Supabase content schema for the driving theory learning app.
-- Run this migration before importing supabase/seed.sql.

create table if not exists public.content_categories (
  id text primary key,
  title text not null,
  subtitle text not null default '',
  icon_code integer not null,
  icon_font_family text,
  icon_font_package text,
  icon_match_text_direction boolean not null default false,
  color_value bigint not null,
  soft_color_value bigint not null,
  sort_order integer not null default 0,
  published boolean not null default true
);

create table if not exists public.lessons (
  id text primary key,
  category_id text not null references public.content_categories(id) on delete cascade,
  title text not null,
  minutes integer not null default 5 check (minutes > 0),
  sort_order integer not null default 0,
  is_extra boolean not null default false,
  published boolean not null default true
);

create table if not exists public.lesson_sections (
  id text primary key,
  lesson_id text not null references public.lessons(id) on delete cascade,
  position integer not null,
  heading text not null,
  body text not null,
  sign_type text,
  sign_label text,
  image_path text,
  unique (lesson_id, position)
);

create table if not exists public.questions (
  id text primary key,
  category_id text not null references public.content_categories(id) on delete restrict,
  prompt text not null,
  explanation text not null default '',
  sign_type text,
  sign_label text,
  image_path text,
  is_exam_question boolean not null default true,
  sort_order integer not null default 0,
  published boolean not null default true
);

create table if not exists public.question_options (
  id text primary key,
  question_id text not null references public.questions(id) on delete cascade,
  position integer not null,
  option_text text not null,
  is_correct boolean not null default false,
  unique (question_id, position)
);

create index if not exists lessons_category_order_idx
  on public.lessons(category_id, sort_order);
create index if not exists questions_category_order_idx
  on public.questions(category_id, sort_order) where published;
create index if not exists question_options_question_order_idx
  on public.question_options(question_id, position);

alter table public.content_categories enable row level security;
alter table public.lessons enable row level security;
alter table public.lesson_sections enable row level security;
alter table public.questions enable row level security;
alter table public.question_options enable row level security;

drop policy if exists "published categories are readable" on public.content_categories;
create policy "published categories are readable"
  on public.content_categories for select to anon, authenticated
  using (published);

drop policy if exists "published lessons are readable" on public.lessons;
create policy "published lessons are readable"
  on public.lessons for select to anon, authenticated
  using (published);

drop policy if exists "published lesson sections are readable" on public.lesson_sections;
create policy "published lesson sections are readable"
  on public.lesson_sections for select to anon, authenticated
  using (exists (
    select 1 from public.lessons l
    where l.id = lesson_id and l.published
  ));

drop policy if exists "published questions are readable" on public.questions;
create policy "published questions are readable"
  on public.questions for select to anon, authenticated
  using (published);

drop policy if exists "published question options are readable" on public.question_options;
create policy "published question options are readable"
  on public.question_options for select to anon, authenticated
  using (exists (
    select 1 from public.questions q
    where q.id = question_id and q.published
  ));

-- No client INSERT/UPDATE/DELETE policies are created here. Manage content from
-- the Supabase dashboard until a separately protected admin dashboard exists.

insert into storage.buckets (id, name, public)
values ('road-signs', 'road-signs', true)
on conflict (id) do nothing;

drop policy if exists "public can read road sign images" on storage.objects;
create policy "public can read road sign images"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'road-signs');

-- Upload/delete policies are intentionally omitted. Upload files through the
-- Supabase dashboard until an admin-only workflow has been implemented.
