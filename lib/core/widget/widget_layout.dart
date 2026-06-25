import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';

class WidgetLayout extends StatelessWidget {
  const WidgetLayout({super.key, required this.renderKey});

  final GlobalKey renderKey;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final labels = AppDateUtils.getWeekdayLabelsShort(locale);
    final today = now.weekday - 1;
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return RepaintBoundary(
      key: renderKey,
      child: SizedBox(
        width: 360,
        height: 180,
        child: CustomPaint(
          painter: _WidgetPainter(
            dateStr: DateFormat('dd/MM/yyyy', locale).format(now),
            dayName: DateFormat('EEEE', locale).format(now),
            labels: labels,
            dates: List.generate(7, (i) => monday.add(Duration(days: i)).day),
            todayIndex: today,
          ),
        ),
      ),
    );
  }
}

class _WidgetPainter extends CustomPainter {
  _WidgetPainter({
    required this.dateStr,
    required this.dayName,
    required this.labels,
    required this.dates,
    required this.todayIndex,
  });

  final String dateStr;
  final String dayName;
  final List<String> labels;
  final List<int> dates;
  final int todayIndex;

  static const _bgColor = Color(0xFF1C1C1E);
  static const _panelColor = Color(0xFF2C2C2E);
  static const _textWhite = Color(0xFFFFFFFF);
  static const _textGray = Color(0xFF8E8E93);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawDateTopRight(canvas, size);
    _drawWeekdayPanel(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = _bgColor;
    final rrect = RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(16));
    canvas.drawRRect(rrect, bgPaint);
  }

  void _drawDateTopRight(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);

    // Date line
    tp.text = TextSpan(
      text: '$dateStr\n$dayName',
      style: const TextStyle(
        color: Color(0xCCFFFFFF),
        fontSize: 13,
        height: 1.3,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(size.width - tp.width - 16, 12));
  }

  void _drawWeekdayPanel(Canvas canvas, Size size) {
    const panelTop = 120.0;
    const panelHeight = 52.0;
    const panelMargin = 12.0;
    const cornerRadius = Radius.circular(12);

    final panelRect = RRect.fromLTRBR(
      panelMargin,
      panelTop,
      size.width - panelMargin,
      panelTop + panelHeight,
      cornerRadius,
    );

    final panelPaint = Paint()..color = _panelColor;
    canvas.drawRRect(panelRect, panelPaint);

    final cellWidth = (size.width - panelMargin * 2) / 7;
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);

    for (var i = 0; i < 7; i++) {
      final isToday = i == todayIndex;
      final color = isToday ? _textWhite : _textGray;
      final cellCenterX = panelMargin + cellWidth * i + cellWidth / 2;

      // Date number (top)
      tp.text = TextSpan(
        text: dates[i].toString(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(cellCenterX - tp.width / 2, panelTop + 6));

      // Day abbreviation (bottom)
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(cellCenterX - tp.width / 2, panelTop + 24));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
