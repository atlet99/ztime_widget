import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ztime_widget/app.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

const _workTask = 'ztime_widget_refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _workTask) {
      await _renderWidgetToPng();
      return true;
    }
    return false;
  });
}

Future<void> _renderWidgetToPng() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('ru', null),
    initializeDateFormatting('en', null),
  ]);

  const w = WidgetDimensions.width;
  const h = WidgetDimensions.height;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & const Size(w, h));

  final now = DateTime.now();
  const locale = 'ru';

  // Flat background
  canvas.drawColor(WidgetColors.background, BlendMode.src);

  // Layout metrics — must match widget_layout.dart exactly
  const edgePad = w * 0.04;
  const topPad = h * 0.08;
  const timePanelW = w * 0.55;
  const timePanelH = h * 0.52;
  const dateFontSize = w * 0.04;
  const dayNameSize = w * 0.036;
  const calNumSize = w * 0.036;
  const calLetterSize = w * 0.026;
  const cardH = h * 0.18;
  const cardRadius = 14.4; // w * 0.012
  const calTop = h * 0.72;

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  // Zone A: Frosted glass panel behind time
  final panelPaint = Paint()..color = WidgetColors.glassPanel;
  final panelBorderPaint = Paint()
    ..color = WidgetColors.glassBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final panelRect = RRect.fromLTRBR(
    edgePad - w * 0.01,
    topPad - h * 0.02,
    edgePad - w * 0.01 + timePanelW,
    topPad - h * 0.02 + timePanelH,
    Radius.circular(w * 0.02),
  );
  canvas.drawRRect(panelRect, panelPaint);
  canvas.drawRRect(panelRect, panelBorderPaint);

  // Zone B: Date top-right
  final dateStr = DateFormat('dd/MM/yyyy', locale).format(now);
  final dayName = DateFormat('EEEE', locale).format(now);
  final dateY = topPad + h * 0.06;

  tp.text = TextSpan(
    text: dateStr,
    style: const TextStyle(
      color: WidgetColors.textDate,
      fontSize: dateFontSize,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(w - edgePad - tp.width, dateY));

  tp.text = TextSpan(
    text: dayName,
    style: const TextStyle(
      color: WidgetColors.textDayName,
      fontSize: dayNameSize,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(w - edgePad - tp.width, dateY + dateFontSize * 1.2 + 2));

  // Zone C: Calendar strip with glass cards
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final shortLabels = <String>[];
  final dayFmt = DateFormat('EE', locale);
  for (var i = 0; i < 7; i++) {
    shortLabels.add(dayFmt.format(monday.add(Duration(days: i))));
  }
  final todayIndex = now.weekday - 1;
  const calWidth = w - edgePad * 2;
  const cellWidth = calWidth / 7;

  final cardPaint = Paint();
  final cardBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  for (var i = 0; i < 7; i++) {
    final isToday = i == todayIndex;
    final cx = edgePad + cellWidth * i;
    final dayNum = monday.add(Duration(days: i)).day;

    // Glass card
    final cardRect = RRect.fromLTRBR(
      cx + 3,
      calTop,
      cx + cellWidth - 3,
      calTop + cardH,
      Radius.circular(cardRadius),
    );
    cardPaint.color = isToday
        ? WidgetColors.glassCardActive
        : WidgetColors.glassCard;
    cardBorderPaint.color = WidgetColors.glassBorder;
    canvas.drawRRect(cardRect, cardPaint);
    canvas.drawRRect(cardRect, cardBorderPaint);

    // Day number
    final numColor = isToday
        ? WidgetColors.textActive
        : WidgetColors.textCalNum;
    tp.text = TextSpan(
      text: dayNum.toString(),
      style: TextStyle(
        color: numColor,
        fontSize: calNumSize,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(cx + cellWidth / 2 - tp.width / 2, calTop + cardH * 0.22),
    );

    // Day letter
    final letterColor = isToday
        ? WidgetColors.textActive
        : WidgetColors.textCalLetter;
    tp.text = TextSpan(
      text: shortLabels[i],
      style: TextStyle(
        color: letterColor,
        fontSize: calLetterSize,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(cx + cellWidth / 2 - tp.width / 2, calTop + cardH * 0.58),
    );
  }

  final picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(w.toInt(), h.toInt());
  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  final Uint8List pngBytes = byteData!.buffer.asUint8List();

  await HomeWidget.saveFile('widget_png', pngBytes, extension: 'png');
  await HomeWidget.updateWidget(
    qualifiedAndroidName: 'com.gosayram.ztime_widget.CustomClockWidgetProvider',
  );

  image.dispose();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('ru', null),
    initializeDateFormatting('en', null),
  ]);

  // Generate widget PNG immediately on startup so the widget has content
  // before ClockPage starts its minute-by-minute renders.
  await _renderWidgetToPng();

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'ztime-widget-id',
    _workTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

  runApp(const ProviderScope(child: ZTimeApp()));
}
