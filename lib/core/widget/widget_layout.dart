import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

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
        width: WidgetDimensions.width,
        height: WidgetDimensions.height,
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

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawDateTopRight(canvas, size);
    _drawWeekdayPanel(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = WidgetColors.background;
    final rrect = RRect.fromLTRBR(
      0, 0, size.width, size.height,
      WidgetColors.backgroundRadius,
    );
    canvas.drawRRect(rrect, bgPaint);
  }

  void _drawDateTopRight(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);
    tp.text = TextSpan(
      text: '$dateStr\n$dayName',
      style: const TextStyle(
        color: WidgetColors.textDate,
        fontSize: 13,
        height: 1.3,
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        size.width - tp.width - WidgetDimensions.datePadding,
        WidgetDimensions.dateTop,
      ),
    );
  }

  void _drawWeekdayPanel(Canvas canvas, Size size) {
    final panelRect = RRect.fromLTRBR(
      WidgetDimensions.panelMargin,
      WidgetDimensions.panelTop,
      size.width - WidgetDimensions.panelMargin,
      WidgetDimensions.panelTop + WidgetDimensions.panelHeight,
      WidgetColors.panelRadius,
    );

    final panelPaint = Paint()..color = WidgetColors.panel;
    canvas.drawRRect(panelRect, panelPaint);

    final cellWidth =
        (size.width - WidgetDimensions.panelMargin * 2) / 7;
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);

    for (var i = 0; i < 7; i++) {
      final isToday = i == todayIndex;
      final color = isToday ? WidgetColors.textWhite : WidgetColors.textGray;
      final cellCenterX =
          WidgetDimensions.panelMargin + cellWidth * i + cellWidth / 2;

      tp.text = TextSpan(
        text: dates[i].toString(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
        ),
      );
      tp.layout();
      tp.paint(
          canvas, Offset(cellCenterX - tp.width / 2, WidgetDimensions.panelTop + 6));

      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      tp.layout();
      tp.paint(
          canvas, Offset(cellCenterX - tp.width / 2, WidgetDimensions.panelTop + 24));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
