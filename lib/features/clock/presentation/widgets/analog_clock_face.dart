import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';

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

  static final _bgPaint = Paint()
    ..color = AppColors.clockBg
    ..style = PaintingStyle.fill;

  static final _borderPaint = Paint()
    ..color = AppColors.clockBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final _hourMarkPaint = Paint()
    ..color = AppColors.textMuted
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;

  static final _minuteMarkPaint = Paint()
    ..color = AppColors.textMuted
    ..strokeWidth = 0.8
    ..strokeCap = StrokeCap.round;

  static final _handPaint = Paint()..strokeCap = StrokeCap.round;

  static final _shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.4)
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    _drawBackground(canvas, center, radius);
    _drawMinuteMarks(canvas, center, radius);
    _drawHourMarks(canvas, center, radius);
    _drawWeekdays(canvas, center, radius);
    _drawHands(canvas, center, radius);
    _drawCenterDot(canvas, center);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, _bgPaint);
    canvas.drawCircle(center, radius, _borderPaint);
  }

  void _drawMinuteMarks(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < 60; i++) {
      if (i % 5 == 0) continue;
      final angle = (i / 60) * 2 * math.pi;
      final outer = radius * 0.72;
      final inner = radius * 0.69;
      canvas.drawLine(
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        Offset(
          center.dx + outer * math.cos(angle),
          center.dy + outer * math.sin(angle),
        ),
        _minuteMarkPaint,
      );
    }
  }

  void _drawHourMarks(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final outer = radius * 0.72;
      final inner = radius * 0.64;
      canvas.drawLine(
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        Offset(
          center.dx + outer * math.cos(angle),
          center.dy + outer * math.sin(angle),
        ),
        _hourMarkPaint,
      );
    }
  }

  void _drawWeekdays(Canvas canvas, Offset center, double radius) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final today = time.weekday - 1;
    final fontSize = radius * 0.09;

    for (var i = 0; i < 7; i++) {
      final angle = (i / 7) * 2 * math.pi - math.pi / 2;
      final textRadius = radius * 0.84;

      canvas.save();
      canvas.translate(
        center.dx + textRadius * math.cos(angle),
        center.dy + textRadius * math.sin(angle),
      );

      tp.text = TextSpan(
        text: _weekdays[i],
        style: TextStyle(
          color: i == today ? AppColors.accent : AppColors.textDim,
          fontSize: fontSize,
          fontWeight: i == today ? FontWeight.bold : FontWeight.normal,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();
    }
  }

  void _drawHands(Canvas canvas, Offset center, double radius) {
    final hourAngle =
        ((time.hour % 12) + time.minute / 60) / 12 * 2 * math.pi - math.pi / 2;
    final minAngle =
        (time.minute + time.second / 60) / 60 * 2 * math.pi - math.pi / 2;
    final secAngle = time.second / 60 * 2 * math.pi - math.pi / 2;

    // Shadow imitations (offset by 2px, no MaskFilter — Impeller safe)
    _drawHand(
      canvas,
      center + const Offset(1.5, 1.5),
      hourAngle,
      radius * 0.45,
      4.0,
      _shadowPaint.color,
    );
    _drawHand(
      canvas,
      center + const Offset(1, 1),
      minAngle,
      radius * 0.62,
      2.5,
      _shadowPaint.color,
    );

    // Actual hands
    _drawHand(
      canvas,
      center,
      hourAngle,
      radius * 0.45,
      4.0,
      AppColors.handHour,
    );
    _drawHand(
      canvas,
      center,
      minAngle,
      radius * 0.62,
      2.5,
      AppColors.handMinute,
    );

    // Second hand (no shadow — too thin)
    _drawHand(
      canvas,
      center,
      secAngle,
      radius * 0.68,
      1.2,
      AppColors.handSecond,
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
    _handPaint
      ..color = color
      ..strokeWidth = width;

    final end = Offset(
      center.dx + length * math.cos(angle),
      center.dy + length * math.sin(angle),
    );
    canvas.drawLine(center, end, _handPaint);
  }

  void _drawCenterDot(Canvas canvas, Offset center) {
    final ringPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, ringPaint);
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.time.second != time.second;
}
