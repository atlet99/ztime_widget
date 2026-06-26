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

  // Proportional values (mirror widget_layout.dart exactly)
  const hPad = w * 0.05;
  const vPad = h * 0.05;
  const topDateSize = w * 0.035;
  const calNumSize = w * 0.035;
  const calDaySize = w * 0.025;
  const calPillW = calNumSize * 2.2;
  const calPillH = calNumSize * 1.8;
  const bottomRowSize = w * 0.03;
  const bottomDateSize = w * 0.028;

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  // 1. Top-right date (0.85 alpha)
  tp.text = TextSpan(
    text: '${DateFormat('dd/MM/yyyy', locale).format(now)}\n${DateFormat('EEEE', locale).format(now)}',
    style: const TextStyle(color: WidgetColors.textActive, fontSize: topDateSize, height: 1.3),
  );
  tp.layout();
  tp.paint(canvas, Offset(w - hPad - tp.width, vPad));

  // 2. Mini-calendar (center)
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final shortLabels = <String>[];
  final dayFmt = DateFormat('EE', locale);
  for (var i = 0; i < 7; i++) {
    shortLabels.add(dayFmt.format(monday.add(Duration(days: i))));
  }
  final todayIndex = now.weekday - 1;
  const calWidth = w - hPad * 2;
  const cellWidth = calWidth / 7;
  const calTop = vPad + h * 0.06 + topDateSize * 1.3 + h * 0.06;

  for (var i = 0; i < 7; i++) {
    final isToday = i == todayIndex;
    final cx = hPad + cellWidth * i + cellWidth / 2;
    final dayNum = monday.add(Duration(days: i)).day;

    if (isToday) {
      // White pill behind today's number
      final pillPaint = Paint()..color = WidgetColors.textTime;
      final pillRect = RRect.fromLTRBR(
        cx - calPillW / 2,
        calTop,
        cx + calPillW / 2,
        calTop + calPillH,
        const Radius.circular(8),
      );
      canvas.drawRRect(pillRect, pillPaint);
    }

    // Day number
    tp.text = TextSpan(
      text: dayNum.toString(),
      style: TextStyle(
        color: isToday ? WidgetColors.background : WidgetColors.textTime,
        fontSize: calNumSize,
        fontWeight: FontWeight.bold,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, calTop + (calPillH - tp.height) / 2));

    // Day abbreviation
    final dayColor = isToday ? WidgetColors.textActive : WidgetColors.textInactive;
    tp.text = TextSpan(
      text: shortLabels[i],
      style: TextStyle(color: dayColor, fontSize: calDaySize),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, calTop + calPillH + calDaySize * 0.2));
  }

  // 3–4. Bottom section
  const bottomY = h - vPad - bottomDateSize * 1.3 - h * 0.03 - bottomRowSize * 1.3;

  // Weekday abbreviations (0.40 alpha)
  tp.text = TextSpan(
    text: shortLabels.join('  '),
    style: const TextStyle(color: WidgetColors.textRow, fontSize: bottomRowSize, letterSpacing: 2.0),
  );
  tp.layout();
  tp.paint(canvas, Offset((w - tp.width) / 2, bottomY));

  // Full date (0.30 alpha)
  tp.text = TextSpan(
    text: DateFormat('d MMMM yyyy г. (EEEE)', locale).format(now),
    style: const TextStyle(color: WidgetColors.textFullDate, fontSize: bottomDateSize),
  );
  tp.layout();
  tp.paint(canvas, Offset((w - tp.width) / 2, bottomY + bottomRowSize * 1.3 + h * 0.03));

  final picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(w.toInt(), h.toInt());
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
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

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'ztime-widget-id',
    _workTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

  runApp(const ProviderScope(child: ZTimeApp()));
}
