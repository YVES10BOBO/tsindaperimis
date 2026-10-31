-- Announcements (Ubutumwa) written by admins in the dashboard and shown in the
-- app's notifications screen. Run after 202610190001_admin_access.sql, which
-- defines public.is_admin().
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(btrim(title)) between 1 and 120),
  body text not null check (char_length(btrim(body)) between 1 and 1000),
  icon text not null default 'info'
    check (icon in ('info', 'new', 'tip', 'reminder', 'warning', 'exam')),
  published boolean not null default false,
  published_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists notifications_published_at_idx
  on public.notifications (published_at desc) where published;

-- Stamp the first publish time (shown to learners) and keep updated_at current.
create or replace function public.notifications_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  if new.published and new.published_at is null then
    new.published_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists notifications_before_write on public.notifications;
create trigger notifications_before_write
  before insert or update on public.notifications
  for each row execute function public.notifications_before_write();

alter table public.notifications enable row level security;

-- Learners see published, unexpired messages; admins also see drafts.
drop policy if exists "published notifications are readable" on public.notifications;
create policy "published notifications are readable"
  on public.notifications for select to anon, authenticated
  using (
    (published and (expires_at is null or expires_at > now()))
    or (select public.is_admin())
  );

drop policy if exists "admins manage notifications" on public.notifications;
create policy "admins manage notifications"
  on public.notifications for all to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

grant select on public.notifications to anon, authenticated;
grant insert, update, delete on public.notifications to authenticated;
