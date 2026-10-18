# Amategeko Admin Dashboard

Responsive Next.js + TypeScript web dashboard for managing the Supabase driving-theory content. Learner access stays in Flutter; the dashboard uses Supabase Auth and the same PostgreSQL tables and `road-signs` Storage bucket.

## Local setup

1. Run the existing content migration and seed as documented in [`../supabase/README.md`](../supabase/README.md).
2. Run [`../supabase/migrations/202610190001_admin_access.sql`](../supabase/migrations/202610190001_admin_access.sql) in the Supabase SQL Editor.
3. In Supabase Authentication → Users, create an admin login with an email and password. The dashboard uses email/password; it does not depend on phone SMS setup.
4. In the SQL Editor, replace the example email and run this to grant that user admin access:

   ```sql
   insert into public.admin_users (user_id)
   select id from auth.users where email = 'admin@example.com'
   on conflict (user_id) do nothing;
   ```

   Check that exactly one row was inserted. Only trusted project owners should be able to change `admin_users`.
5. Copy `.env.example` to `.env.local` and set your Supabase project URL and **publishable** key. Do not put a service-role key in this app.
6. From this folder run:

   ```powershell
   npm install
   npm run dev
   ```

   Open `http://localhost:3000` and sign in using the admin account from step 3.

## Current dashboard features

- Email/password admin sign-in and a database membership check.
- Create, edit, publish/unpublish, search, and delete questions and lessons.
- Manage categories and create new categories as drafts.
- Set a question's correct option and add explanations.
- Upload road-sign images to the public `road-signs` bucket; only admins can upload or delete stored objects.
- Row Level Security grants content writes only to users in `admin_users`.

An uploaded image is saved as a Storage object path in `image_path`. Flutter lesson, practice, exam, and review screens use that path to display the uploaded sign, and fall back to the built-in illustration when one is available.
