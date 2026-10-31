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
5. Copy `.env.example` to `.env.local` and set your Supabase project URL and **publishable** key. To enable the admin users screen, also set `SUPABASE_SERVICE_ROLE_KEY` to the server-side secret from Supabase **Project Settings → API Keys**. Keep that key server-only: do not add `NEXT_PUBLIC_`, commit `.env.local`, paste the key into chat, or put it in the Flutter app. Restart `npm run dev` after changing environment variables.
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
- Admin overview with published/draft counts, content shortcuts, and a review queue.
- Search and paginate Auth users, see sign-in and learner-progress summaries, and suspend or restore learner accounts. Admin accounts and your own account are protected from suspension here.
- Set a question's correct option and add explanations.
- Upload road-sign images to the public `road-signs` bucket; only admins can upload or delete stored objects. Replaced, removed, or unsaved uploads are deleted when no question or lesson section uses them.
- Reorder categories, lessons within a category, and sections within a lesson; questions take 2–4 answers.
- Edit category colours and app icon; delete a category once it has no lessons or questions.
- Permanently delete a learner account (type SIBA to confirm). Admin accounts and your own account are protected.
- Write, publish, schedule an end date for, and delete app notifications (Ubutumwa). Requires [`../supabase/migrations/202610310001_notifications.sql`](../supabase/migrations/202610310001_notifications.sql).
- Row Level Security grants content writes only to users in `admin_users`.

An uploaded image is saved as a Storage object path in `image_path`. Flutter lesson, practice, exam, and review screens use that path to display the uploaded sign, and fall back to the built-in illustration when one is available.
