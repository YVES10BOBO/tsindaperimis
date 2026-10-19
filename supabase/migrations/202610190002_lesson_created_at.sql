-- Track when each lesson was created so admins can sort and filter by date.
-- Existing lessons receive the migration time because their original creation
-- timestamps were not previously stored.
alter table public.lessons
  add column if not exists created_at timestamptz not null default now();

create index if not exists lessons_created_at_idx
  on public.lessons (created_at desc);
