import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/content_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (url.isEmpty || key.isEmpty) {
    // The address and key are given when the app is built:
    //   flutter run --dart-define-from-file=supabase.local.json
    debugPrint(
        'SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY are missing: sign-in and '
        'online content will not work. Build with --dart-define-from-file=supabase.local.json');
  } else {
    try {
      await Supabase.initialize(url: url, publishableKey: key);
    } catch (error) {
      // Offline mode continues from the bundled/SQLite content cache.
      debugPrint('Supabase.initialize failed: $error');
    }
  }
  await ContentRepository.instance.initialize();
  runApp(const AmategekoApp());
}
