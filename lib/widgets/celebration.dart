import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colourful paper pieces falling once across the whole screen (drawn in code,
/// no package). Put it in a Stack above the content; it ignores touches and
/// removes itself visually when it finishes.
class Confetti extends StatefulWidget {
  const Confetti(
      {super.key, this.duration = const Duration(milliseconds: 4200)});

  final Duration duration;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // "Remove animations" setting: no confetti at all.
    if (MediaQuery.of(context).disableAnimations) _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _ConfettiPainter(_c), size: Size.infinite),
    );
  }
}

class _Piece {
  _Piece(math.Random r)
      : x = r.nextDouble(),
        delay = r.nextDouble() * 0.35,
        speed = 0.85 + r.nextDouble() * 0.4,
        size = 6 + r.nextDouble() * 6,
        color = _colors[r.nextInt(_colors.length)],
        rot = r.nextDouble() * math.pi * 2,
        spin = (r.nextDouble() - 0.5) * 14,
        sway = 12 + r.nextDouble() * 26,
        freq = 1.5 + r.nextDouble() * 2.5,
        round = r.nextBool();

  final double x, delay, speed, size, rot, spin, sway, freq;
  final Color color;
  final bool round;

  static const List<Color> _colors = <Color>[
    Color(0xFF2FA8E8),
    Color(0xFF6CC8F3),
    Color(0xFFFFCC08),
    Color(0xFF16A34A),
    Color(0xFFFF6B57),
    Color(0xFFF59E0B),
    Color(0xFFDB2777),
  ];
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t) : super(repaint: t);

  final Animation<double> t;
  static final List<_Piece> _pieces = () {
    final math.Random r = math.Random(11);
    return List<_Piece>.generate(70, (_) => _Piece(r));
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final double v = t.value;
    if (v >= 1) return;
    for (final _Piece p in _pieces) {
      final double tt = ((v - p.delay) / (1 - p.delay)) * p.speed;
      if (tt <= 0 || tt >= 1) continue;
      final double y = -20 + Curves.easeIn.transform(tt) * (size.height + 40);
      final double x =
          p.x * size.width + math.sin(tt * p.freq * 2 * math.pi) * p.sway;
      final double fade = tt > 0.85 ? (1 - tt) / 0.15 : 1;
      final Paint paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot + tt * p.spin);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: p.size, height: p.size * 0.55),
              const Radius.circular(1.5)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => false;
}

/// Full celebration: the screen dims like a night sky, fireworks launch and
/// burst, and confetti falls. It ignores touches (the content below stays
/// usable) and fades away by itself after about 6 seconds.
class Celebration extends StatefulWidget {
  /// [dim] darkens the screen like a night sky; turn it off on dark pages.
  const Celebration({super.key, this.dim = true});

  final bool dim;

  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6));

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // "Remove animations" setting: skip everything.
    if (MediaQuery.of(context).disableAnimations) _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AnimatedBuilder(
            animation: _c,
            builder: (BuildContext context, Widget? child) {
              final double v = _c.value;
              double a = widget.dim ? 0.5 : 0;
              if (widget.dim && v < 0.08) a = 0.5 * (v / 0.08);
              if (widget.dim && v > 0.85) a = 0.5 * ((1 - v) / 0.15);
              return ColoredBox(
                  color: const Color(0xFF050B18)
                      .withValues(alpha: a.clamp(0.0, 0.5)));
            },
          ),
          CustomPaint(painter: _FireworksPainter(_c), size: Size.infinite),
          const Confetti(),
        ],
      ),
    );
  }
}

class _Burst {
  const _Burst(this.start, this.x, this.y, this.color, this.count, this.radius);

  final double start; // when it launches (0..1 of the whole animation)
  final double x, y; // where it explodes (fractions of the screen)
  final Color color;
  final int count;
  final double radius;
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  static const double _life = 0.30; // each firework lasts this part of the loop
  static const List<_Burst> _bursts = <_Burst>[
    _Burst(0.00, 0.25, 0.30, Color(0xFFFFD84D), 30, 120),
    _Burst(0.10, 0.76, 0.22, Color(0xFF6CC8F3), 32, 130),
    _Burst(0.20, 0.50, 0.38, Color(0xFFFF6B57), 34, 140),
    _Burst(0.30, 0.18, 0.52, Color(0xFF7CFFB2), 28, 110),
    _Burst(0.40, 0.84, 0.46, Color(0xFFFF7BD5), 30, 120),
    _Burst(0.50, 0.46, 0.20, Color(0xFFB69CFF), 34, 135),
    _Burst(0.58, 0.28, 0.28, Color(0xFFFFD84D), 30, 120),
    _Burst(0.62, 0.70, 0.34, Color(0xFFFF6B57), 32, 125),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double v = t.value;
    if (v >= 1) return;
    final double w = size.width;
    final double h = size.height;
    for (final _Burst b in _bursts) {
      final double u = (v - b.start) / _life;
      if (u <= 0 || u >= 1) continue;
      final double cx = b.x * w;
      final double cy = b.y * h;
      if (u < 0.28) {
        // The rocket rises with a short tail.
        final double k = Curves.easeOut.transform(u / 0.28);
        final double ry = h - (h - cy) * k;
        canvas.drawLine(
          Offset(cx, ry + 34),
          Offset(cx, ry),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.8)
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(Offset(cx, ry), 3, Paint()..color = Colors.white);
      } else {
        // The burst: sparks fly outwards, fall a little and fade.
        final double e = (u - 0.28) / 0.72;
        final double ease = Curves.easeOutCubic.transform(e);
        final double alpha = math.pow(1 - e, 1.2).toDouble();
        final Paint spark = Paint()
          ..color = b.color.withValues(alpha: alpha)
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round;
        final Paint glow = Paint()
          ..color = b.color.withValues(alpha: alpha * 0.25);
        // A soft flash at the moment of the explosion.
        if (e < 0.18) {
          canvas.drawCircle(
              Offset(cx, cy),
              26 * (1 - e / 0.18),
              Paint()
                ..color =
                    Colors.white.withValues(alpha: 0.55 * (1 - e / 0.18)));
        }
        for (int i = 0; i < b.count; i++) {
          final double a = 2 * math.pi * i / b.count +
              (i.isEven ? 0 : 0.5 * math.pi / b.count);
          final double sp = b.radius * (0.72 + 0.28 * ((i * 37) % 7) / 6);
          final Offset dir = Offset(math.cos(a), math.sin(a));
          final Offset pos =
              Offset(cx, cy) + dir * (sp * ease) + Offset(0, 50 * e * e);
          canvas.drawLine(pos, pos - dir * (10 * (1 - ease) + 2), spark);
          canvas.drawCircle(pos, 6 * (1 - e) + 2, glow);
          canvas.drawCircle(pos, 2.2 * (1 - e) + 0.8, spark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter old) => false;
}

/// A gift box that wiggles until it is tapped, then the lid flies open with a
/// golden glow. [onOpened] is called when the opening animation ends.
class GiftBox extends StatefulWidget {
  const GiftBox(
      {super.key,
      required this.color,
      required this.onOpened,
      this.size = 170});

  final Color color;
  final VoidCallback onOpened;
  final double size;

  @override
  State<GiftBox> createState() => _GiftBoxState();
}

class _GiftBoxState extends State<GiftBox> with TickerProviderStateMixin {
  late final AnimationController _open = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _wiggle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();
  bool _tapped = false;

  @override
  void dispose() {
    _open.dispose();
    _wiggle.dispose();
    super.dispose();
  }

  void _tap() {
    if (_tapped) return;
    _tapped = true;
    HapticFeedback.heavyImpact();
    _wiggle.stop();
    _open.forward().then((_) {
      if (mounted) widget.onOpened();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Impano. Kanda ukingure.',
      child: GestureDetector(
        onTap: _tap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[_open, _wiggle]),
            builder: (BuildContext context, Widget? child) {
              // Small shake every cycle until the box is opened.
              final double w = _tapped
                  ? 0
                  : math.sin(_wiggle.value * 2 * math.pi * 3) *
                      0.06 *
                      (1 - _wiggle.value);
              return CustomPaint(
                painter: _GiftPainter(widget.color, _open.value, w),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GiftPainter extends CustomPainter {
  _GiftPainter(this.color, this.open, this.wiggle);

  final Color color;
  final double open; // 0 closed .. 1 open
  final double wiggle; // small rotation in radians

  static const Color _gold = Color(0xFFFFD84D);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    canvas.save();
    canvas.translate(w / 2, h * 0.95);
    canvas.rotate(wiggle);
    canvas.translate(-w / 2, -h * 0.95);

    // Golden glow and rays that grow while the lid opens.
    if (open > 0) {
      final Offset c = Offset(w / 2, h * 0.5);
      final double r = w * (0.2 + open * 0.8);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: <Color>[
            _gold.withValues(alpha: 0.9 * (1 - open * 0.4)),
            _gold.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: c, radius: r)),
      );
      final Paint ray = Paint()
        ..color = Colors.white.withValues(alpha: 0.7 * open)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 10; i++) {
        final double a = -math.pi + i * math.pi / 9;
        canvas.drawLine(
          c + Offset(math.cos(a), math.sin(a)) * (w * 0.3),
          c + Offset(math.cos(a), math.sin(a)) * (w * (0.3 + 0.35 * open)),
          ray,
        );
      }
    }

    // Box body with a gold ribbon.
    final RRect body = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.14, h * 0.52, w * 0.86, h * 0.95),
        const Radius.circular(8));
    canvas.drawRRect(body, Paint()..color = color);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.14, h * 0.52, w * 0.86, h * 0.60),
          const Radius.circular(4)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRect(Rect.fromLTRB(w * 0.46, h * 0.52, w * 0.54, h * 0.95),
        Paint()..color = _gold);

    // Lid: slides up and tilts when opening.
    canvas.save();
    canvas.translate(w * 0.08, h * 0.54);
    canvas.rotate(-open * 0.6);
    canvas.translate(-w * 0.08, -h * 0.54 - open * h * 0.32);
    final Rect lid = Rect.fromLTRB(w * 0.08, h * 0.36, w * 0.92, h * 0.54);
    canvas.drawRRect(RRect.fromRectAndRadius(lid, const Radius.circular(8)),
        Paint()..color = Color.lerp(color, Colors.white, 0.18)!);
    canvas.drawRect(Rect.fromLTRB(w * 0.46, h * 0.36, w * 0.54, h * 0.54),
        Paint()..color = _gold);
    final Paint bow = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.39, h * 0.31),
            width: w * 0.22,
            height: h * 0.14),
        bow);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.61, h * 0.31),
            width: w * 0.22,
            height: h * 0.14),
        bow);
    canvas.drawCircle(
        Offset(w * 0.5, h * 0.35), w * 0.045, Paint()..color = _gold);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GiftPainter old) =>
      old.open != open || old.wiggle != wiggle || old.color != color;
}
