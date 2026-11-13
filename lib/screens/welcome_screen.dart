import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/common.dart';

import '../core/app_colors.dart';
import '../core/app_info.dart';
import '../state/app_state.dart';
import '../widgets/road_scene.dart';
import 'auth_screen.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Plays once when the screen opens (logo, texts, buttons appear one by one).
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));

  // Loops forever: drives the road scene and the logo's gentle float.
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 24));

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      // Respect the phone's "remove animations" setting: show the final state.
      _intro.value = 1;
      _loop
        ..stop()
        ..value = 0.3;
    } else if (!_started || !_loop.isAnimating) {
      _started = true;
      _intro.forward();
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  /// Fades and slides a child in between [begin] and [end] (0..1) of the intro.
  Widget _reveal({
    required double begin,
    required double end,
    required Widget child,
    Offset from = const Offset(0, 0.25),
  }) {
    final Animation<double> a = CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: from, end: Offset.zero).animate(a),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> logoIn = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );
    // Same space above and below: the larger of the status bar / nav bar, plus 16.
    final EdgeInsets inset = MediaQuery.of(context).padding;
    final double edge =
        (inset.top > inset.bottom ? inset.top : inset.bottom) + 16;
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0B3C66),
              Color(0xFF0F4C81),
              Color(0xFF14609F)
            ],
          ),
        ),
        child: SafeArea(
          // Top and bottom get the same space (below) so the group is truly centred.
          top: false,
          bottom: false,
          // Fixed page (no scrolling): the group stays centred and, on very
          // small screens, is scaled down to fit instead.
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) => Padding(
              padding: EdgeInsets.fromLTRB(24, edge, 24, edge),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: box.maxWidth - 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ScaleTransition(
                          scale: logoIn,
                          child: AnimatedBuilder(
                            animation: _loop,
                            builder: (BuildContext context, Widget? child) {
                              // Floats up and down by a few pixels (2 cycles per loop).
                              final double dy = _intro.isCompleted
                                  ? 4 * math.sin(_loop.value * 12 * 2 * math.pi)
                                  : 0;
                              return Transform.translate(
                                  offset: Offset(0, dy), child: child);
                            },
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                      color: Color(0x4D000000),
                                      blurRadius: 24,
                                      offset: Offset(0, 10)),
                                ],
                              ),
                              child: const Icon(Icons.directions_car,
                                  size: 52, color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _reveal(
                          begin: 0.25,
                          end: 0.65,
                          child: Text(
                            AppInfo.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _reveal(
                          begin: 0.38,
                          end: 0.78,
                          child: const Text(
                            AppInfo.tagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFBFE3F7),
                                fontSize: 16,
                                height: 1.5),
                          ),
                        ),
                        // Fixed-height scene (shrinks only if the screen is tiny), so the
                        // whole group (logo, title, scene) stays centred on the screen.
                        SizedBox(
                          height: 190,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _intro,
                                curve: const Interval(0.5, 1.0,
                                    curve: Curves.easeOut),
                              ),
                              child: RoadScene(animation: _loop),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _reveal(
                          begin: 0.55,
                          end: 0.9,
                          from: const Offset(0, 0.6),
                          child: PressScale(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryDark,
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const AuthScreen(isRegister: false)),
                            ),
                            child: const Text('Injira'),
                          )),
                        ),
                        const SizedBox(height: 12),
                        _reveal(
                          begin: 0.65,
                          end: 1.0,
                          from: const Offset(0, 0.6),
                          child: PressScale(
                              child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const AuthScreen(isRegister: true)),
                            ),
                            child: const Text('Iyandikishe'),
                          )),
                        ),
                        const SizedBox(height: 8),
                        _reveal(
                          begin: 0.75,
                          end: 1.0,
                          from: const Offset(0, 0.6),
                          child: PressScale(
                              child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () {
                              AppScope.of(context).continueAsGuest();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                    builder: (_) => const MainShell()),
                              );
                            },
                            child: const Text(
                                'Komeza nka Mushyitsi (utiyandikishije)'),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
