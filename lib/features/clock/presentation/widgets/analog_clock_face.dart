import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnalogClockFace extends StatelessWidget {
  const AnalogClockFace({super.key, required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClockPainter(time: time),
      size: Size.infinite,
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.time});

  final DateTime time;

  static const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    _drawBackground(canvas, center, radius);
    _drawWeekdays(canvas, center, radius);
    _drawHourMarks(canvas, center, radius);
    _drawHands(canvas, center, radius);
    _drawCenterDot(canvas, center);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF6C63FF).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawWeekdays(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final today = time.weekday - 1;

    for (var i = 0; i < 7; i++) {
      final angle = (i / 7) * 2 * math.pi - math.pi / 2;
      final textRadius = radius * 0.82;
      final offset = Offset(
        center.dx + textRadius * math.cos(angle),
        center.dy + textRadius * math.sin(angle),
      );

      textPainter.text = TextSpan(
        text: _weekdays[i],
        style: TextStyle(
          color: i == today
              ? const Color(0xFF6C63FF)
              : Colors.white.withValues(alpha: 0.4),
          fontSize: radius * 0.09,
          fontWeight: i == today ? FontWeight.bold : FontWeight.normal,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawHourMarks(Canvas canvas, Offset center, double radius) {
    final markPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final outer = radius * 0.72;
      final inner = radius * 0.66;

      canvas.drawLine(
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        Offset(
          center.dx + outer * math.cos(angle),
          center.dy + outer * math.sin(angle),
        ),
        markPaint,
      );
    }
  }

  void _drawHands(Canvas canvas, Offset center, double radius) {
    // Hour hand
    final hourAngle =
        ((time.hour % 12) + time.minute / 60) / 12 * 2 * math.pi - math.pi / 2;
    _drawHand(
      canvas,
      center,
      hourAngle,
      radius * 0.45,
      4.0,
      const Color(0xFFE0E0E0),
    );

    // Minute hand
    final minAngle =
        (time.minute + time.second / 60) / 60 * 2 * math.pi - math.pi / 2;
    _drawHand(
      canvas,
      center,
      minAngle,
      radius * 0.62,
      2.5,
      const Color(0xFFE0E0E0),
    );

    // Second hand
    final secAngle = time.second / 60 * 2 * math.pi - math.pi / 2;
    _drawHand(
      canvas,
      center,
      secAngle,
      radius * 0.68,
      1.2,
      const Color(0xFF6C63FF),
    );
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double width,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final end = Offset(
      center.dx + length * math.cos(angle),
      center.dy + length * math.sin(angle),
    );
    canvas.drawLine(center, end, paint);
  }

  void _drawCenterDot(Canvas canvas, Offset center) {
    final dotPaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) => true;
}
