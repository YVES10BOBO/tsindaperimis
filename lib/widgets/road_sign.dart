import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../data/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shows an uploaded road-sign photo when available and falls back to the
/// built-in vector illustration when offline or when loading fails.
class RoadSignVisual extends StatelessWidget {
  const RoadSignVisual({
    super.key,
    this.type,
    this.imagePath,
    this.size = 96,
    this.label,
  });

  final SignType? type;
  final String? imagePath;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            path,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _fallback(),
          ),
        );
      }
      try {
        final url = Supabase.instance.client.storage
            .from('road-signs')
            .getPublicUrl(path);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _fallback(),
          ),
        );
      } catch (_) {
        // Supabase may not be configured in bundled/offline-only builds.
      }
    }
    return _fallback();
  }

  Widget _fallback() => type == null
      ? SizedBox(width: size, height: size)
      : RoadSign(type: type!, size: size, label: label);
}

/// Ishushanya ibimenyetso by'umuhanda hakoreshejwe code (nta mafoto akenewe).
/// Nyuma ushobora kubisimbuza amafoto nyayo (assets) y'ibimenyetso byemewe.
class RoadSign extends StatelessWidget {
  const RoadSign({super.key, required this.type, this.size = 96, this.label});

  final SignType type;
  final double size;
  final String? label;

  static const List<Offset> _octagon = <Offset>[
    Offset(0.3, 0),
    Offset(0.7, 0),
    Offset(1, 0.3),
    Offset(1, 0.7),
    Offset(0.7, 1),
    Offset(0.3, 1),
    Offset(0, 0.7),
    Offset(0, 0.3),
  ];
  static const List<Offset> _triangleUp = <Offset>[
    Offset(0.5, 0.05),
    Offset(0.96, 0.9),
    Offset(0.04, 0.9),
  ];
  static const List<Offset> _triangleDown = <Offset>[
    Offset(0.04, 0.1),
    Offset(0.96, 0.1),
    Offset(0.5, 0.95),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ikimenyetso cy\'umuhanda',
      child: SizedBox(width: size, height: size, child: _buildSign()),
    );
  }

  Widget _buildSign() {
    switch (type) {
      case SignType.stop:
        return CustomPaint(
          painter: _PolyPainter(
              _octagon, AppColors.signRed, Colors.white, size * 0.04),
          child: Center(
            child: Text('STOP',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.24,
                    letterSpacing: 1)),
          ),
        );
      case SignType.giveWay:
        return CustomPaint(
          painter: _PolyPainter(
              _triangleDown, Colors.white, AppColors.signRed, size * 0.09),
        );
      case SignType.noEntry:
        return _circle(
          fill: AppColors.signRed,
          child: Container(
            width: size * 0.62,
            height: size * 0.16,
            color: Colors.white,
          ),
        );
      case SignType.speedLimit:
        return _prohibitory(
          Text(label ?? '40',
              style: TextStyle(
                  color: AppColors.signBlack,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.34)),
        );
      case SignType.noOvertaking:
        return _prohibitory(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.directions_car,
                  color: AppColors.signRed, size: size * 0.3),
              Icon(Icons.directions_car,
                  color: AppColors.signBlack, size: size * 0.3),
            ],
          ),
        );
      case SignType.noParking:
        return Stack(
          children: <Widget>[
            _circle(fill: AppColors.signBlue, border: AppColors.signRed),
            CustomPaint(
              size: Size(size, size),
              painter: _SlashPainter(AppColors.signRed, size * 0.1),
            ),
          ],
        );
      case SignType.danger:
        return _warning(
          Text('!',
              style: TextStyle(
                  color: AppColors.signBlack,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.42)),
        );
      case SignType.steepAscent:
        return _warning(
          Text(label ?? '10%',
              style: TextStyle(
                  color: AppColors.signBlack,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.27)),
        );
      case SignType.trafficLight:
        return Container(
          margin: EdgeInsets.symmetric(horizontal: size * 0.28),
          padding: EdgeInsets.all(size * 0.07),
          decoration: BoxDecoration(
            color: AppColors.signBlack,
            borderRadius: BorderRadius.circular(size * 0.12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _signalLamp(Colors.red, false),
              _signalLamp(Colors.amber, false),
              _signalLamp(Colors.green, true),
            ],
          ),
        );
      case SignType.plainWarningTriangle:
        return _warning(const SizedBox.shrink());
      case SignType.sideRoadRight:
        return _warning(
          Icon(Icons.call_merge, color: AppColors.signBlack, size: size * 0.48),
        );
      case SignType.crosswind:
        return _warning(
          Icon(Icons.air, color: AppColors.signBlack, size: size * 0.48),
        );
      case SignType.deadEnd:
        return Container(
          color: AppColors.signBlue,
          padding: EdgeInsets.all(size * 0.13),
          child: Column(
            children: <Widget>[
              Container(height: size * 0.12, color: Colors.white),
              Expanded(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: size * 0.30),
                    Expanded(child: Container(color: Colors.white)),
                    SizedBox(width: size * 0.30),
                  ],
                ),
              ),
            ],
          ),
        );
      case SignType.railwayCrossing:
        return _warning(
          Icon(Icons.train, color: AppColors.signBlack, size: size * 0.46),
        );
      case SignType.priorityOverOncoming:
        return _prohibitory(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.arrow_downward,
                  color: AppColors.signRed, size: size * 0.38),
              Icon(Icons.arrow_upward,
                  color: AppColors.signBlack, size: size * 0.38),
            ],
          ),
        );
      case SignType.twoWayTraffic:
        return _warning(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.arrow_downward,
                  color: AppColors.signBlack, size: size * 0.34),
              Icon(Icons.arrow_upward,
                  color: AppColors.signBlack, size: size * 0.34),
            ],
          ),
        );
      case SignType.speedBump:
        return _warning(
          CustomPaint(
            size: Size(size * 0.56, size * 0.3),
            painter: const _SpeedBumpPainter(AppColors.signBlack),
          ),
        );
      case SignType.children:
        return _warning(
          Icon(Icons.escalator_warning,
              color: AppColors.signBlack, size: size * 0.38),
        );
      case SignType.aheadOnly:
        return _mandatory(Icons.arrow_upward);
      case SignType.turnRight:
        return _mandatory(Icons.turn_right);
      case SignType.roundabout:
        return _mandatory(Icons.autorenew);
      case SignType.turnLeft:
        return _mandatory(Icons.turn_left);
      case SignType.noLeftTurn:
        return _prohibitedIcon(Icons.turn_left);
      case SignType.noUTurn:
        return _prohibitedIcon(Icons.u_turn_left);
      case SignType.noPedestrians:
        return _prohibitedIcon(Icons.directions_walk);
      case SignType.roadWorks:
        return _warning(Icon(Icons.construction,
            color: AppColors.signBlack, size: size * 0.38));
      case SignType.trafficSignalsAhead:
        return _warning(
            Icon(Icons.traffic, color: AppColors.signBlack, size: size * 0.38));
      case SignType.pedestriansAhead:
        return _warning(Icon(Icons.directions_walk,
            color: AppColors.signBlack, size: size * 0.38));
      case SignType.parking:
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.signBlue,
            borderRadius: BorderRadius.circular(size * 0.12),
          ),
          child: Text('P',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.6)),
        );
      case SignType.pedestrianCrossing:
        return Container(
          decoration: BoxDecoration(
            color: AppColors.signBlue,
            borderRadius: BorderRadius.circular(size * 0.1),
          ),
          padding: EdgeInsets.all(size * 0.1),
          child: CustomPaint(
            painter: _PolyPainter(const <Offset>[
              Offset(0.5, 0.02),
              Offset(1, 0.95),
              Offset(0, 0.95)
            ], Colors.white, null, 0),
            child: Align(
              alignment: const Alignment(0, 0.45),
              child: Icon(Icons.directions_walk,
                  color: AppColors.signBlack, size: size * 0.4),
            ),
          ),
        );
    }
  }

  Widget _circle({required Color fill, Color? border, Widget? child}) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: border == null
            ? null
            : Border.all(color: border, width: size * 0.1),
      ),
      child: child,
    );
  }

  Widget _prohibitory(Widget child) =>
      _circle(fill: Colors.white, border: AppColors.signRed, child: child);

  /// Ikimenyetso kibuza: uruziga rutukura, ishusho, n'umurongo uyambukiranya.
  Widget _prohibitedIcon(IconData icon) {
    return Stack(
      children: <Widget>[
        _prohibitory(Icon(icon, color: AppColors.signBlack, size: size * 0.5)),
        CustomPaint(
          size: Size(size, size),
          painter: _SlashPainter(AppColors.signRed, size * 0.09),
        ),
      ],
    );
  }

  Widget _mandatory(IconData icon) => _circle(
        fill: AppColors.signBlue,
        child: Icon(icon, color: Colors.white, size: size * 0.6),
      );

  Widget _warning(Widget child) {
    return CustomPaint(
      painter: _PolyPainter(
          _triangleUp, Colors.white, AppColors.signRed, size * 0.09),
      child: Align(alignment: const Alignment(0, 0.4), child: child),
    );
  }

  Widget _signalLamp(Color color, bool active) => Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: active ? color : color.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
}

class _PolyPainter extends CustomPainter {
  _PolyPainter(this.points, this.fill, this.stroke, this.strokeWidth);

  final List<Offset> points;
  final Color fill;
  final Color? stroke;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final Offset p in points.skip(1)) {
      path.lineTo(p.dx * size.width, p.dy * size.height);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fill);
    final Color? s = stroke;
    if (s != null && strokeWidth > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = s
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PolyPainter oldDelegate) => false;
}

class _SpeedBumpPainter extends CustomPainter {
  const _SpeedBumpPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Path path = Path()
      ..moveTo(0, size.height * 0.72)
      ..lineTo(size.width * 0.18, size.height * 0.72)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.72,
        size.width * 0.35,
        size.height * 0.18,
        size.width * 0.5,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.18,
        size.width * 0.66,
        size.height * 0.72,
        size.width * 0.82,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height * 0.72);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpeedBumpPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SlashPainter extends CustomPainter {
  _SlashPainter(this.color, this.width);

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final double inset = size.width * 0.17;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      Paint()
        ..color = color
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(covariant _SlashPainter oldDelegate) => false;
}
