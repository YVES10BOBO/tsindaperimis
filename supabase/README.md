# Supabase content setup

1. Create a Supabase project.
2. Run `migrations/202610180001_content.sql` in the Supabase SQL Editor.
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
