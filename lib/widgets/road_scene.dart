import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated road scene for the landing page, drawn entirely in code
/// (no image files): a road with moving lane dashes, a car, a motorcycle, a
/// bus and a truck driving past, a faint city skyline and road signs that
/// float gently. Everything loops seamlessly with the controller value
/// (0..1) because every motion uses a whole number of cycles.
///
/// To remove it: delete this file and the `RoadScene` use in welcome_screen.dart.
class RoadScene extends StatelessWidget {
  const RoadScene({super.key, required this.animation});

  /// Looping controller (0..1). When motion is reduced, pass a stopped one.
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ShaderMask(
        // Fade the scene out on the left and right edges.
        shaderCallback: (Rect r) => const LinearGradient(
          colors: <Color>[
            Color(0x00FFFFFF),
            Colors.white,
            Colors.white,
            Color(0x00FFFFFF)
          ],
          stops: <double>[0, 0.12, 0.88, 1],
        ).createShader(r),
        blendMode: BlendMode.dstIn,
        child: CustomPaint(
          painter: _RoadScenePainter(animation),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _RoadScenePainter extends CustomPainter {
  _RoadScenePainter(this.t) : super(repaint: t);

  final Animation<double> t;

  // Whole cycles per loop, so the loop has no visible jump.
  static const int _loopSeconds = 24; // controller duration
  static const double _dashPeriod = 40;

  static const Color _road = Color(0xFF0A3558);
  static const Color _roadEdge = Color(0xFF2B7DB8);
  static const Color _tire = Color(0xFF07182B);
  static const Color _hub = Color(0xFFB7DEF5);
  static const Color _glass = Color(0xFF0F4C81);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    if (w < 80 || h < 50) return;
    final double v = t.value;

    final double roadH = math.min(h * 0.46, 64);
    final double roadTop = h - roadH;
    final double s = roadH / 62; // vehicle scale

    _skyline(canvas, w, roadTop);
    _signs(canvas, w, roadTop, v);

    // Road
    canvas.drawRect(
        Rect.fromLTWH(0, roadTop, w, roadH), Paint()..color = _road);
    canvas.drawRect(
        Rect.fromLTWH(0, roadTop, w, 2), Paint()..color = _roadEdge);

    // Lane dashes scroll left (so vehicles seem to drive right).
    final Paint dash = Paint()..color = const Color(0x99FFFFFF);
    final double shift = ((v * _loopSeconds) % 1) * _dashPeriod;
    final double dy = roadTop + roadH * 0.6;
    for (double x = -_dashPeriod - shift;
        x < w + _dashPeriod;
        x += _dashPeriod) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + _dashPeriod, dy, 20, 2.5),
            const Radius.circular(1.5)),
        dash,
      );
    }

    final double wheelAngle = v * _loopSeconds * 2 * math.pi;

    // Far lane (smaller): bus and truck. Near lane: car and motorcycle.
    final double farY = roadTop + roadH * 0.52;
    final double nearY = h - roadH * 0.1;
    final double farS = s * 0.8;

    _drive(canvas, w, v, 1, 0.0, 100 * farS,
        (double x) => _bus(canvas, x, farY, farS, wheelAngle));
    _drive(canvas, w, v, 1, 0.5, 100 * farS,
        (double x) => _truck(canvas, x, farY, farS, wheelAngle));
    _drive(canvas, w, v, 2, 0.1, 70 * s,
        (double x) => _car(canvas, x, nearY, s, wheelAngle));
    _drive(canvas, w, v, 2, 0.6, 50 * s,
        (double x) => _moto(canvas, x, nearY, s, wheelAngle));
  }

  /// Moves a vehicle across the width [laps] times per loop.
  void _drive(Canvas canvas, double w, double v, int laps, double offset,
      double vehicleWidth, void Function(double x) draw) {
    final double span = w + 2 * vehicleWidth;
    final double x = (((v * laps) + offset) % 1) * span - vehicleWidth;
    draw(x);
  }

  // ---------- Background ----------

  void _skyline(Canvas canvas, double w, double roadTop) {
    final Paint p = Paint()..color = const Color(0x33B7DEF5);
    const List<List<double>> b = <List<double>>[
      // x fraction, width fraction, height fraction of roadTop
      <double>[0.04, 0.08, 0.32],
      <double>[0.14, 0.06, 0.5],
      <double>[0.22, 0.09, 0.28],
      <double>[0.34, 0.07, 0.42],
      <double>[0.55, 0.08, 0.36],
      <double>[0.66, 0.06, 0.52],
      <double>[0.76, 0.09, 0.3],
      <double>[0.88, 0.07, 0.44],
    ];
    for (final List<double> r in b) {
      final double bh = roadTop * r[2];
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(w * r[0], roadTop - bh, w * r[1], bh),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        p,
      );
    }
  }

  void _signs(Canvas canvas, double w, double roadTop, double v) {
    final double size = (roadTop * 0.2).clamp(15.0, 30.0);
    final double baseY = roadTop * 0.3;
    final List<double> xs = <double>[0.13, 0.37, 0.63, 0.87];
    for (int i = 0; i < xs.length; i++) {
      final double bob = math.sin((v * 2 * math.pi * 2) + i * 1.6) * 5;
      final Offset c = Offset(w * xs[i], baseY + (i.isOdd ? 8 : 0) + bob);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(size / 30);
      switch (i) {
        case 0:
          _speedSign(canvas);
        case 1:
          _warningSign(canvas);
        case 2:
          _stopSign(canvas);
        default:
          _aheadSign(canvas);
      }
      canvas.restore();
    }
  }

  // Signs are drawn in a 30x30 box centred on (0,0), slightly transparent.
  void _speedSign(Canvas c) {
    c.drawCircle(Offset.zero, 15, Paint()..color = const Color(0xCCFFFFFF));
    c.drawCircle(
        Offset.zero,
        12,
        Paint()
          ..color = const Color(0xDDD32F2F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
    final TextPainter tp = TextPainter(
      text: const TextSpan(
          text: '50',
          style: TextStyle(
              color: Color(0xFF111111),
              fontSize: 12,
              fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  }

  void _warningSign(Canvas c) {
    final Path tri = Path()
      ..moveTo(0, -15)
      ..lineTo(15, 12)
      ..lineTo(-15, 12)
      ..close();
    c.drawPath(tri, Paint()..color = const Color(0xCCFFFFFF));
    c.drawPath(
        tri,
        Paint()
          ..color = const Color(0xDDD32F2F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeJoin = StrokeJoin.round);
    final Paint ink = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(0, -5), const Offset(0, 3), ink);
    c.drawCircle(const Offset(0, 7.5), 1.7, ink);
  }

  void _stopSign(Canvas c) {
    final Path oct = Path();
    for (int i = 0; i < 8; i++) {
      final double a = math.pi / 8 + i * math.pi / 4;
      final Offset p = Offset(math.cos(a) * 15.5, math.sin(a) * 15.5);
      if (i == 0) {
        oct.moveTo(p.dx, p.dy);
      } else {
        oct.lineTo(p.dx, p.dy);
      }
    }
    oct.close();
    c.drawPath(oct, Paint()..color = const Color(0xDDD32F2F));
    c.drawPath(
        oct,
        Paint()
          ..color = const Color(0xCCFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(-9, -2.5, 9, 2.5), const Radius.circular(1.5)),
        Paint()..color = Colors.white);
  }

  void _aheadSign(Canvas c) {
    c.drawCircle(Offset.zero, 15, Paint()..color = const Color(0xDD1565C0));
    c.drawCircle(
        Offset.zero,
        15,
        Paint()
          ..color = const Color(0xCCFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    final Paint ink = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    c.drawLine(const Offset(0, 9), const Offset(0, -8), ink);
    c.drawPath(
        Path()
          ..moveTo(-6, -3)
          ..lineTo(0, -9)
          ..lineTo(6, -3),
        ink);
  }

  // ---------- Vehicles (facing right, origin = bottom-left, y = ground) ----------

  void _wheel(Canvas c, Offset centre, double r, double angle) {
    c.drawCircle(centre, r, Paint()..color = _tire);
    c.drawCircle(centre, r * 0.55, Paint()..color = _hub);
    final Paint spoke = Paint()
      ..color = _tire
      ..strokeWidth = math.max(1, r * 0.18);
    for (int i = 0; i < 3; i++) {
      final double a = angle + i * math.pi / 3;
      final Offset d = Offset(math.cos(a), math.sin(a)) * (r * 0.5);
      c.drawLine(centre - d, centre + d, spoke);
    }
  }

  void _light(Canvas c, Offset p, double r, Color color) {
    c.drawCircle(p, r, Paint()..color = color);
  }

  void _car(Canvas c, double x, double y, double s, double wa) {
    c.save();
    c.translate(x, y);
    c.scale(s);
    final Paint body = Paint()..color = const Color(0xFFE8F6FD);
    final Paint cabin = Paint()..color = const Color(0xFF6CC8F3);
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(0, -19, 64, -6), const Radius.circular(5)),
        body);
    final Path top = Path()
      ..moveTo(13, -19)
      ..lineTo(21, -31)
      ..lineTo(46, -31)
      ..lineTo(55, -19)
      ..close();
    c.drawPath(top, cabin);
    final Paint glass = Paint()..color = _glass;
    c.drawPath(
        Path()
          ..moveTo(18, -20)
          ..lineTo(23, -28.5)
          ..lineTo(32, -28.5)
          ..lineTo(32, -20)
          ..close(),
        glass);
    c.drawPath(
        Path()
          ..moveTo(35, -20)
          ..lineTo(35, -28.5)
          ..lineTo(45, -28.5)
          ..lineTo(51, -20)
          ..close(),
        glass);
    _light(c, const Offset(62, -13), 2.2, const Color(0xFFFFE08A));
    _light(c, const Offset(2, -13), 2, const Color(0xFFE53935));
    _wheel(c, const Offset(14, -7), 7, wa);
    _wheel(c, const Offset(50, -7), 7, wa);
    c.restore();
  }

  void _bus(Canvas c, double x, double y, double s, double wa) {
    c.save();
    c.translate(x, y);
    c.scale(s);
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(0, -38, 94, -6), const Radius.circular(5)),
        Paint()..color = const Color(0xFF2FA8E8));
    c.drawRect(const Rect.fromLTRB(0, -17, 94, -14),
        Paint()..color = const Color(0x66FFFFFF));
    final Paint glass = Paint()..color = _glass;
    for (int i = 0; i < 5; i++) {
      c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(7.0 + i * 15, -32, 11, 11),
              const Radius.circular(2)),
          glass);
    }
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(82, -32, 91, -19), const Radius.circular(2)),
        glass);
    _light(c, const Offset(92.5, -10), 2, const Color(0xFFFFE08A));
    _wheel(c, const Offset(19, -7), 7, wa);
    _wheel(c, const Offset(75, -7), 7, wa);
    c.restore();
  }

  void _truck(Canvas c, double x, double y, double s, double wa) {
    c.save();
    c.translate(x, y);
    c.scale(s);
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(0, -38, 62, -9), const Radius.circular(3)),
        Paint()..color = const Color(0xFFE8F6FD));
    c.drawRect(const Rect.fromLTRB(0, -12, 96, -8),
        Paint()..color = const Color(0xFF1E6FA8));
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(64, -29, 96, -9), const Radius.circular(4)),
        Paint()..color = const Color(0xFF2FA8E8));
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(80, -26, 92, -16), const Radius.circular(2)),
        Paint()..color = _glass);
    _light(c, const Offset(94.5, -13), 2, const Color(0xFFFFE08A));
    _wheel(c, const Offset(13, -7), 7, wa);
    _wheel(c, const Offset(30, -7), 7, wa);
    _wheel(c, const Offset(80, -7), 7, wa);
    c.restore();
  }

  void _moto(Canvas c, double x, double y, double s, double wa) {
    c.save();
    c.translate(x, y);
    c.scale(s);
    final Paint frame = Paint()
      ..color = const Color(0xFFF5A524)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    c.drawPath(
        Path()
          ..moveTo(8, -7)
          ..lineTo(21, -18)
          ..lineTo(35, -18)
          ..lineTo(40, -7),
        frame);
    c.drawLine(const Offset(38, -9), const Offset(36, -22), frame);
    final Paint rider = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(23, -20), const Offset(28, -32), rider);
    c.drawLine(
        const Offset(28, -30),
        const Offset(35, -22),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
    c.drawCircle(
        const Offset(29, -38), 4.2, Paint()..color = const Color(0xFFE8F6FD));
    _light(c, const Offset(42, -20), 2, const Color(0xFFFFE08A));
    _wheel(c, const Offset(8, -7), 7, wa);
    _wheel(c, const Offset(40, -7), 7, wa);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _RoadScenePainter old) => false;
}
