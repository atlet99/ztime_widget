import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';

class WidgetLayout extends StatelessWidget {
  const WidgetLayout({super.key, required this.renderKey});

  final GlobalKey renderKey;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timeStr = AppDateUtils.formatTime(now, locale);
    final dateStr = AppDateUtils.formatFullDate(now, locale);
    final parts = timeStr.split(':');
    final labels = AppDateUtils.getWeekdayLabels(locale);
    final today = now.weekday - 1;

    return RepaintBoundary(
      key: renderKey,
      child: Container(
        width: 400,
        height: 400,
        decoration: const BoxDecoration(
          color: AppColors.clockBg,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: CustomPaint(
          painter: _WidgetPainter(
            hour: parts[0],
            minute: parts[1],
            date: dateStr,
            labels: labels,
            todayIndex: today,
          ),
        ),
      ),
    );
  }
}

class _WidgetPainter extends CustomPainter {
  _WidgetPainter({
    required this.hour,
    required this.minute,
    required this.date,
    required this.labels,
    required this.todayIndex,
  });

  final String hour;
  final String minute;
  final String date;
  final List<String> labels;
  final int todayIndex;

  static final _bgPaint = Paint()
    ..color = AppColors.clockBg
    ..style = PaintingStyle.fill;

  static final _borderPaint = Paint()
    ..color = AppColors.clockBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final _markPaint = Paint()
    ..color = AppColors.textMuted
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round;

  static final _handPaint = Paint()..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    _drawClockFace(canvas, center, radius);
    _drawWeekdayRing(canvas, center, radius);
    _drawHands(canvas, center, radius);
    _drawDigitalTime(canvas, center, radius);
    _drawDate(canvas, center, radius);
  }

  void _drawClockFace(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, _bgPaint);
    canvas.drawCircle(center, radius, _borderPaint);

    for (var i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final outer = radius * 0.72;
      final inner = radius * 0.64;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle),
            center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle),
            center.dy + outer * math.sin(angle)),
        _markPaint,
      );
    }
  }

  void _drawWeekdayRing(Canvas canvas, Offset center, double radius) {
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);
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
        text: labels[i],
        style: TextStyle(
          color: i == todayIndex ? AppColors.accent : AppColors.textDim,
          fontSize: fontSize,
          fontWeight: i == todayIndex ? FontWeight.bold : FontWeight.normal,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  void _drawHands(Canvas canvas, Offset center, double radius) {
    final now = DateTime.now();
    final hourAngle =
        ((now.hour % 12) + now.minute / 60) / 12 * 2 * math.pi - math.pi / 2;
    final minAngle =
        (now.minute + now.second / 60) / 60 * 2 * math.pi - math.pi / 2;
    final secAngle = now.second / 60 * 2 * math.pi - math.pi / 2;

    _drawHand(canvas, center + const Offset(1.5, 1.5), hourAngle,
        radius * 0.45, 4.0, Colors.black.withValues(alpha: 0.4));
    _drawHand(canvas, center + const Offset(1, 1), minAngle,
        radius * 0.62, 2.5, Colors.black.withValues(alpha: 0.4));

    _drawHand(
        canvas, center, hourAngle, radius * 0.45, 4.0, AppColors.handHour);
    _drawHand(
        canvas, center, minAngle, radius * 0.62, 2.5, AppColors.handMinute);
    _drawHand(
        canvas, center, secAngle, radius * 0.68, 1.2, AppColors.handSecond);

    final dotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, dotPaint);
  }

  void _drawHand(Canvas canvas, Offset center, double angle, double length,
      double width, Color color) {
    _handPaint
      ..color = color
      ..strokeWidth = width;
    final end = Offset(
      center.dx + length * math.cos(angle),
      center.dy + length * math.sin(angle),
    );
    canvas.drawLine(center, end, _handPaint);
  }

  void _drawDigitalTime(Canvas canvas, Offset center, double radius) {
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);
    tp.text = TextSpan(
      text: '$hour:$minute',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w200,
        color: AppColors.textPrimary,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
    tp.layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy + radius * 0.15));
  }

  void _drawDate(Canvas canvas, Offset center, double radius) {
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);
    tp.text = TextSpan(
      text: date,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textDim,
      ),
    );
    tp.layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy + radius * 0.30));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
