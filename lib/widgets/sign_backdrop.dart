import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Faint road signs scattered over the whole background that drift and turn
/// very slowly. Drawn in code (no image files). Every motion uses a whole
/// number of cycles per loop, so the loop never jumps.
///
/// To remove it: delete this file and the `SignBackdrop` use in welcome_screen.dart.
class SignBackdrop extends StatelessWidget {
  const SignBackdrop({super.key, required this.animation});

  /// Looping controller (0..1).
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SignBackdropPainter(animation),
          size: Size.infinite,
        ),
      ),
    );
  }
}

enum _Kind {
  speed,
  warning,
  person,
  yield,
  stop,
  parking,
  roundabout,
  noEntry,
  arrow,
  priority,
  bicycle
}

class _Item {
  const _Item(
      this.x, this.y, this.size, this.kind, this.rot, this.phase, this.cycles,
      {this.text = ''});

  final double x; // 0..1 of the width
  final double y; // 0..1 of the height
  final double size; // logical pixels
  final _Kind kind;
  final double rot; // resting tilt (radians)
  final double phase; // 0..2pi
  final int cycles; // 1 = slowest, 2 = a bit faster
  final String text;
}

const List<_Item> _items = <_Item>[
  _Item(0.08, 0.06, 92, _Kind.person, -0.10, 0.0, 1),
  _Item(0.38, 0.05, 80, _Kind.roundabout, 0.0, 1.1, 2),
  _Item(0.64, 0.10, 78, _Kind.noEntry, 0.12, 2.0, 1),
  _Item(0.92, 0.07, 92, _Kind.person, 0.10, 3.1, 2),
  _Item(0.20, 0.19, 96, _Kind.speed, 0.0, 4.0, 1, text: '80'),
  _Item(0.50, 0.21, 84, _Kind.warning, -0.05, 5.0, 1),
  _Item(0.86, 0.22, 84, _Kind.parking, 0.0, 0.6, 2),
  _Item(0.06, 0.34, 100, _Kind.roundabout, 0.0, 1.7, 1),
  _Item(0.30, 0.34, 88, _Kind.yield, 0.0, 2.6, 2),
  _Item(0.72, 0.36, 76, _Kind.stop, 0.0, 3.6, 1, text: 'STOP'),
  _Item(0.94, 0.42, 92, _Kind.roundabout, 0.0, 4.4, 2),
  _Item(0.05, 0.52, 92, _Kind.speed, 0.0, 5.4, 2, text: '30'),
  _Item(0.93, 0.55, 80, _Kind.bicycle, 0.0, 0.9, 1),
  _Item(0.10, 0.68, 86, _Kind.warning, 0.08, 1.9, 1),
  _Item(0.92, 0.70, 86, _Kind.arrow, 0.0, 2.8, 2),
  _Item(0.18, 0.84, 88, _Kind.person, -0.08, 3.8, 2),
  _Item(0.40, 0.90, 80, _Kind.stop, 0.0, 4.8, 1, text: 'STOP'),
  _Item(0.64, 0.86, 84, _Kind.priority, 0.0, 5.8, 2),
  _Item(0.86, 0.92, 90, _Kind.arrow, -0.10, 0.3, 1),
  _Item(0.06, 0.96, 80, _Kind.speed, 0.0, 1.4, 1, text: '50'),
];

class _SignBackdropPainter extends CustomPainter {
  _SignBackdropPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  static const Color _tint = Color(0xFF8FD3F5);
  final Map<String, TextPainter> _texts = <String, TextPainter>{};

  Paint get _fill => Paint()..color = _tint.withAlpha(22);
  Paint _stroke(double w) => Paint()
    ..color = _tint.withAlpha(58)
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final double v = t.value;
    for (final _Item it in _items) {
      final double a = v * 2 * math.pi * it.cycles + it.phase;
      final double dx = math.sin(a) * 14;
      final double dy = math.cos(a * 0.9 + 0.7) * 16;
      final double tilt = it.rot + math.sin(a) * 0.07;
      canvas.save();
      canvas.translate(size.width * it.x + dx, size.height * it.y + dy);
      canvas.rotate(tilt);
      _sign(canvas, it);
      canvas.restore();
    }
  }

  void _sign(Canvas c, _Item it) {
    final double r = it.size / 2;
    switch (it.kind) {
      case _Kind.speed:
        _ring(c, r);
        _text(c, it.text, r * 0.95);
      case _Kind.warning:
        _triangle(c, r, up: true);
        final Paint ink = _stroke(r * 0.12);
        c.drawLine(Offset(0, -r * 0.22), Offset(0, r * 0.22), ink);
        c.drawCircle(Offset(0, r * 0.5), r * 0.07, ink);
      case _Kind.person:
        _triangle(c, r, up: true);
        final Paint ink = _stroke(r * 0.11);
        c.drawCircle(Offset(-r * 0.02, -r * 0.18), r * 0.1, ink);
        c.drawLine(
            Offset(-r * 0.02, -r * 0.05), Offset(-r * 0.12, r * 0.28), ink);
        c.drawLine(
            Offset(-r * 0.02, -r * 0.05), Offset(r * 0.14, r * 0.22), ink);
        c.drawLine(Offset(-r * 0.1, r * 0.12), Offset(r * 0.12, r * 0.1), ink);
      case _Kind.yield:
        _triangle(c, r, up: false);
      case _Kind.stop:
        final Path p = Path();
        for (int i = 0; i < 8; i++) {
          final double ang = math.pi / 8 + i * math.pi / 4;
          final Offset o = Offset(math.cos(ang) * r, math.sin(ang) * r);
          if (i == 0) {
            p.moveTo(o.dx, o.dy);
          } else {
            p.lineTo(o.dx, o.dy);
          }
        }
        p.close();
        c.drawPath(p, _fill);
        c.drawPath(p, _stroke(r * 0.1));
        _text(c, it.text, r * 0.5);
      case _Kind.parking:
        final RRect box = RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: r * 1.8, height: r * 1.8),
            Radius.circular(r * 0.18));
        c.drawRRect(box, _fill);
        c.drawRRect(box, _stroke(r * 0.1));
        _text(c, 'P', r * 1.2);
      case _Kind.roundabout:
        _ring(c, r);
        final Paint ink = _stroke(r * 0.1);
        for (int i = 0; i < 3; i++) {
          final double start = i * 2 * math.pi / 3;
          c.drawArc(Rect.fromCircle(center: Offset.zero, radius: r * 0.42),
              start, 1.5, false, ink);
          final double end = start + 1.5;
          final Offset tip = Offset(math.cos(end), math.sin(end)) * (r * 0.42);
          c.drawLine(
              tip,
              tip +
                  Offset(math.cos(end - 0.5), math.sin(end - 0.5)) * (r * 0.16),
              ink);
        }
      case _Kind.noEntry:
        c.drawCircle(Offset.zero, r, _fill);
        c.drawCircle(Offset.zero, r * 0.92, _stroke(r * 0.1));
        c.drawLine(Offset(-r * 0.5, 0), Offset(r * 0.5, 0), _stroke(r * 0.24));
      case _Kind.arrow:
        _ring(c, r);
        final Paint ink = _stroke(r * 0.12);
        c.drawLine(Offset(0, r * 0.45), Offset(0, -r * 0.42), ink);
        c.drawLine(Offset(0, -r * 0.45), Offset(-r * 0.28, -r * 0.15), ink);
        c.drawLine(Offset(0, -r * 0.45), Offset(r * 0.28, -r * 0.15), ink);
      case _Kind.priority:
        final Path d = Path()
          ..moveTo(0, -r)
          ..lineTo(r, 0)
          ..lineTo(0, r)
          ..lineTo(-r, 0)
          ..close();
        c.drawPath(d, _fill);
        c.drawPath(d, _stroke(r * 0.1));
        c.save();
        c.scale(0.62);
        c.drawPath(d, _stroke(r * 0.12));
        c.restore();
      case _Kind.bicycle:
        _ring(c, r);
        final Paint ink = _stroke(r * 0.08);
        c.drawCircle(Offset(-r * 0.3, r * 0.2), r * 0.2, ink);
        c.drawCircle(Offset(r * 0.3, r * 0.2), r * 0.2, ink);
        c.drawLine(Offset(-r * 0.3, r * 0.2), Offset(0, -r * 0.1), ink);
        c.drawLine(Offset(0, -r * 0.1), Offset(r * 0.3, r * 0.2), ink);
        c.drawLine(Offset(0, -r * 0.1), Offset(r * 0.14, -r * 0.3), ink);
    }
  }

  void _ring(Canvas c, double r) {
    c.drawCircle(Offset.zero, r, _fill);
    c.drawCircle(Offset.zero, r * 0.88, _stroke(r * 0.14));
  }

  void _triangle(Canvas c, double r, {required bool up}) {
    final double s = up ? 1 : -1;
    final Path p = Path()
      ..moveTo(0, -r * 0.95 * s)
      ..lineTo(r * 0.98, r * 0.78 * s)
      ..lineTo(-r * 0.98, r * 0.78 * s)
      ..close();
    c.drawPath(p, _fill);
    c.drawPath(p, _stroke(r * 0.12));
  }

  void _text(Canvas c, String text, double fontSize) {
    final TextPainter tp = _texts.putIfAbsent(
      '$text@${fontSize.round()}',
      () => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
              color: _tint.withAlpha(70),
              fontSize: fontSize,
              fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
    tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SignBackdropPainter old) => false;
}
