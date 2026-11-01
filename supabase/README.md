# Supabase content setup

1. Create a Supabase project.
2. Run `migrations/202610180001_content.sql` in the Supabase SQL Editor.
   If the project already has content, also run
   `migrations/202610190002_lesson_created_at.sql` to enable lesson creation-date
   sorting and the Today/Yesterday filters in the admin dashboard. Existing
   lessons receive the migration date because their original dates were not
   recorded.
3. Generate the initial content seed from the app's current bundled questions and lessons:

```powershell
flutter run -d chrome -t tool/export_supabase_seed.dart
```

Click **Download seed.sql** in the page that opens. In the Supabase SQL Editor, create a second query, paste the downloaded file's contents, and run it. This fills `content_categories`, `lessons`, `lesson_sections`, `questions`, and `question_options`; each correct answer is represented by `question_options.is_correct = true`.
4. Run the Flutter app with the project URL and publishable key in `supabase.local.json`:

```powershell
flutter run --dart-define-from-file=supabase.local.json
```

The publishable key is safe to ship in the app because row-level security only allows reading published content. Never put a service-role key in Flutter.

Until the project is configured and the content tables are populated, the app uses its bundled data and caches it in SQLite on supported mobile platforms. On startup it refreshes that cache from Supabase when published categories and questions are available. Images belong in the public `road-signs` Storage bucket; store each image's object path in the matching `image_path` column.

## Admin dashboard

See [`../admin-dashboard/README.md`](../admin-dashboard/README.md) for setup. Run `migrations/202610190001_admin_access.sql`, create an email/password user in Supabase Auth, then add that user's ID to `public.admin_users` from the SQL Editor. Never give ordinary learners an admin membership.

## Notifications (Ubutumwa)

After the admin migration, run `migrations/202610310001_notifications.sql`. Admins write, publish, and delete messages from the dashboard's **Ubutumwa** page; the app shows published messages that have not passed their optional end date, and keeps the last copy for offline use. Until this migration runs, the dashboard shows a setup notice on that page and the app shows an empty Ubutumwa screen.

## Question numbers and dates

Run `migrations/202611010001_question_numbers_and_dates.sql` to give every question a permanent number (`#57`) plus "added" and "last edited" dates, and lessons a "last edited" date. Existing questions are numbered in their current dashboard order and get the migration time as their added date. In the dashboard, search `#57` to open a question directly and sort by number, newest added, or recently edited. Learners still get random order and shuffled answers; the app shows "Ikibazo #57" under the explanation so they can report a mistake. Until the migration runs, the dashboard and app work as before without numbers.

## Question reports (Tanga ikosa)

Run `migrations/202611010002_question_reports.sql` after the numbers migration. Learners tap **Tanga ikosa** under a question's explanation (practice, or the exam review), choose what is wrong and optionally comment; the report lands on the dashboard's **Raporo** page with the question's #number. Learners and guests can only send reports; only admins can read, resolve or delete them. A signed-in learner can have one open report per question.

## Audio (listen buttons)

Run `migrations/202611010003_audio.sql` to add `audio_path` to lessons and questions and create the public `audio` Storage bucket (admins upload; anyone can listen). In the dashboard, the lesson and question editors get an audio field with a player to check the recording before saving. In the app, the 🔊 button on a lesson or practice question appears only when a recording exists; it streams the file, so it needs internet. Device text-to-speech is not used because phones do not ship a Kinyarwanda voice.

## Password reset email

The app resets passwords with a 6-digit code (no deep link needed): the learner enters their email, types the code from the email, then chooses a new password. In Supabase:

1. **Authentication → Emails → Reset Password**: make the template show the code, for example:

   ```html
   <h2>Guhindura ijambo ry'ibanga</h2>
   <p>Kode yawe yo guhindura ijambo ry'ibanga ni:</p>
   <p style="font-size:28px;font-weight:bold;letter-spacing:6px">{{ .Token }}</p>
   <p>Iyandike muri app. Niba atari wowe wabisabye, wirengagize iyi email.</p>
   ```

2. **Authentication → Providers → Email**: keep **Email OTP Length** at 6, which the app's code screen expects.

Changing a password while signed in (**Ibindi → Hindura ijambo ry'ibanga**) checks the current password first, then calls `updateUser`.

## Account deletion

Run `migrations/202610310002_delete_my_account.sql` so learners can delete their own account in the app (**Ibindi → Siba konti**), which Google Play requires for apps with sign-up. The app asks for the password again, then calls `public.delete_my_account()`, which deletes the signed-in user and, through `ON DELETE CASCADE`, their `user_progress` row. Admin accounts are refused. Admins can also delete a learner from the dashboard's Abakoresha page.
