-- Lets a signed-in learner permanently delete their own account from the app
-- (required by Google Play for apps with sign-up). Deleting the auth user also
-- removes public.user_progress through its ON DELETE CASCADE.
-- Run after 202610190001_admin_access.sql, which defines public.admin_users.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Sign in before deleting an account.' using errcode = '28000';
  end if;

  -- Admin memberships are managed by the project owner, so an admin cannot
  -- remove themselves (and possibly the last admin) from the app.
  if exists (select 1 from public.admin_users where user_id = current_user_id) then
    raise exception 'Admin accounts cannot be deleted from the app.' using errcode = '42501';
  end if;

  delete from auth.users where id = current_user_id;
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
