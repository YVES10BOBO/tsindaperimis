-- Learner reports about a question ("Tanga ikosa"): sent from the app, read and
-- resolved by admins on the dashboard's Raporo page.
-- Run after 202610190001_admin_access.sql, which defines public.is_admin().
create table if not exists public.question_reports (
  id uuid primary key default gen_random_uuid(),
  question_id text not null references public.questions(id) on delete cascade,
  reason text not null check (reason in ('wrong_answer', 'typo', 'image', 'other')),
  comment text check (comment is null or char_length(comment) <= 500),
  -- Null for guests; set automatically for signed-in learners.
  reporter_id uuid default auth.uid() references auth.users(id) on delete set null,
  status text not null default 'new' check (status in ('new', 'resolved')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create index if not exists question_reports_status_created_idx
  on public.question_reports (status, created_at desc);

-- A signed-in learner can have only one open report per question.
create unique index if not exists question_reports_one_open_per_learner
  on public.question_reports (question_id, reporter_id)
  where reporter_id is not null and status = 'new';

alter table public.question_reports enable row level security;

-- Learners (and guests) can only send a new report, in their own name.
drop policy if exists "learners send reports" on public.question_reports;
create policy "learners send reports"
  on public.question_reports for insert to anon, authenticated
  with check (
    status = 'new'
    and resolved_at is null
    and reporter_id is not distinct from (select auth.uid())
  );

-- Only admins can read, resolve or delete reports.
drop policy if exists "admins manage reports" on public.question_reports;
create policy "admins manage reports"
  on public.question_reports for all to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

grant insert on public.question_reports to anon, authenticated;
grant select, update, delete on public.question_reports to authenticated;
