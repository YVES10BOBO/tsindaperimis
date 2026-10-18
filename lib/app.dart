import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'core/app_info.dart';
import 'core/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';

class AmategekoApp extends StatefulWidget {
  const AmategekoApp({super.key});

  @override
  State<AmategekoApp> createState() => _AmategekoAppState();
}

class _AmategekoAppState extends State<AmategekoApp> with WidgetsBindingObserver {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _state.dispose();
    super.dispose();
  }

  // Telefoni ihinduye Light/Dark (iyo umukoresha yahisemo "Bijyane na telefoni")
  @override
  void didChangePlatformBrightness() {
    if (_state.themeMode == ThemeMode.system) setState(() {});
  }

  bool _isDark() {
    switch (_state.themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (BuildContext context, Widget? _) {
        final bool dark = _isDark();
        AppColors.isDark = dark;
        return AppScope(
          notifier: _state,
          child: MaterialApp(
            title: AppInfo.name,
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(dark: dark),
            home: const WelcomeScreen(),
          ),
        );
      },
    );
  }
}
