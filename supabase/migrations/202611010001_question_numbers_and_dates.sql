-- Permanent question numbers (#57) and added/edited dates.
-- Learners still get questions in random order with shuffled answers; the
-- number is a fixed label so a question can be found in the admin dashboard.
-- Existing questions are numbered in their current dashboard order and get
-- this migration's time as their "added" date (no earlier date was recorded).

alter table public.questions add column if not exists number integer;
alter table public.questions add column if not exists created_at timestamptz not null default now();
alter table public.questions add column if not exists updated_at timestamptz;
alter table public.lessons add column if not exists updated_at timestamptz;

-- Number existing questions 1, 2, 3, ... in dashboard order (safe to re-run).
with ordered as (
  select id, row_number() over (order by sort_order, id) as n
  from public.questions
  where number is null
)
update public.questions q
set number = o.n + coalesce((select max(number) from public.questions), 0)
from ordered o
where q.id = o.id;

-- New questions take the next number automatically.
create sequence if not exists public.questions_number_seq owned by public.questions.number;
select setval(
  'public.questions_number_seq',
  greatest(coalesce((select max(number) from public.questions), 0), 1),
  (select max(number) is not null from public.questions)
);
alter table public.questions alter column number set default nextval('public.questions_number_seq');
alter table public.questions alter column number set not null;
create unique index if not exists questions_number_key on public.questions (number);

-- Admins insert questions as the authenticated role, which needs the sequence.
grant usage, select on sequence public.questions_number_seq to authenticated;
