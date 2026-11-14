import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/celebration.dart';
import '../widgets/common.dart';
import '../widgets/sign_backdrop.dart';
import 'lesson_screen.dart';

/// Shown right after the learner finishes a lesson.
/// - Normal lesson: award badge, fireworks, and progress in the category.
/// - Last lesson of a category: a gift box to tap; opening it reveals the
///   category award with a bigger celebration.
class CompletionScreen extends StatefulWidget {
  const CompletionScreen({
    super.key,
    required this.lesson,
    required this.category,
    required this.categoryCompleted,
  });

  final Lesson lesson;
  final LearnCategory category;
  final bool categoryCompleted;

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 24));
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  bool _giftOpened = false;

  @override
  void initState() {
    super.initState();
    _loop.repeat();
    _intro.forward();
    if (!widget.categoryCompleted) HapticFeedback.heavyImpact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _intro.value = 1;
      _loop
        ..stop()
        ..value = 0.3;
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _intro.dispose();
    super.dispose();
  }

  Lesson? get _next {
    final List<Lesson> all = widget.category.lessons;
    final AppState state = AppScope.of(context);
    final int i = all.indexWhere((Lesson l) => l.id == widget.lesson.id);
    for (int k = i + 1; k < all.length; k++) {
      if (!state.isLessonDone(all[k].id)) return all[k];
    }
    for (final Lesson l in all) {
      if (!state.isLessonDone(l.id) && l.id != widget.lesson.id) return l;
    }
    return null;
  }

  Widget _badge(
      {required IconData icon, required List<Color> colors, double size = 96}) {
    return ScaleTransition(
      scale: CurvedAnimation(
          parent: _intro,
          curve: const Interval(0, 0.6, curve: Curves.elasticOut)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.8), width: 3),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: colors.last.withValues(alpha: 0.5),
                blurRadius: 28,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Icon(icon, size: size * 0.5, color: Colors.white),
      ),
    );
  }

  Widget _fade(double begin, double end, Widget child) {
    final Animation<double> a = CurvedAnimation(
        parent: _intro,
        curve: Interval(begin, end, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(a),
        child: child,
      ),
    );
  }

  List<Widget> _lessonDone(AppState state) {
    final int done = state.completedIn(widget.category);
    final int total = widget.category.lessons.length;
    return <Widget>[
      _badge(
          icon: Icons.star_rounded,
          colors: const <Color>[Color(0xFFFFD84D), Color(0xFFF59E0B)]),
      const SizedBox(height: 22),
      _fade(
        0.3,
        0.8,
        Column(children: <Widget>[
          const Text('Isomo rirangiye!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Warangije "${widget.lesson.title}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFFBFE3F7), fontSize: 16, height: 1.4)),
        ]),
      ),
      const SizedBox(height: 24),
      _fade(
        0.5,
        1.0,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Icon(widget.category.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.category.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
                Text('$done / $total',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : done / total,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFFFD84D)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                total - done > 0
                    ? 'Hasigaye amasomo ${total - done} kugira ngo urangize icyiciro.'
                    : 'Warangije amasomo yose y\'iki cyiciro.',
                style: const TextStyle(color: Color(0xFFBFE3F7), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _giftClosed() {
    return <Widget>[
      _fade(
        0.0,
        0.5,
        Column(children: const <Widget>[
          Text('Isomo rirangiye!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text(
              'Warangije amasomo yose y\'iki cyiciro. Hari impano igutegereje!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFFBFE3F7), fontSize: 16, height: 1.4)),
        ]),
      ),
      const SizedBox(height: 20),
      GiftBox(
        color: widget.category.color,
        onOpened: () => setState(() => _giftOpened = true),
      ),
      const SizedBox(height: 14),
      const Text('Kanda impano ukingure',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
    ];
  }

  List<Widget> _giftOpenedView() {
    return <Widget>[
      _badge(
        icon: widget.category.icon,
        size: 120,
        colors: <Color>[
          Color.lerp(widget.category.color, Colors.white, 0.25)!,
          widget.category.color,
        ],
      ),
      const SizedBox(height: 20),
      _fade(
        0.3,
        0.8,
        Column(children: <Widget>[
          const Text('Wabonye igihembo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFFFD84D), Color(0xFFF59E0B)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const Icon(Icons.emoji_events, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Umuhanga: ${widget.category.title}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Text(
              'Wujuje icyiciro cyose cya "${widget.category.title}". Komeza gutyo!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFFBFE3F7), fontSize: 15, height: 1.4)),
        ]),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final Lesson? next = _next;
    final bool gift = widget.categoryCompleted;
    final bool showGiftClosed = gift && !_giftOpened;

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
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: SignBackdrop(animation: _loop)),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) =>
                    SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ...(showGiftClosed
                              ? _giftClosed()
                              : (gift
                                  ? _giftOpenedView()
                                  : _lessonDone(state))),
                          const SizedBox(height: 28),
                          if (!showGiftClosed) ...<Widget>[
                            if (next != null)
                              PressScale(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primaryDark,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pushReplacement(
                                    MaterialPageRoute<void>(
                                        builder: (_) =>
                                            LessonScreen(lesson: next)),
                                  ),
                                  child: const Text('Isomo rikurikira'),
                                ),
                              ),
                            const SizedBox(height: 8),
                            PressScale(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Subira inyuma'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Fireworks: right away for a normal lesson, after the gift opens for a category.
            if (!gift || _giftOpened)
              Positioned.fill(
                  child: Celebration(
                      key: ValueKey<bool>(_giftOpened), dim: false)),
          ],
        ),
      ),
    );
  }
}
