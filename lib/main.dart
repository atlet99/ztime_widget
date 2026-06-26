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

  // Background
  canvas.drawRRect(
    RRect.fromLTRBR(0, 0, w, h, WidgetColors.backgroundRadius),
    Paint()..color = WidgetColors.background,
  );

  // Proportional values (mirror widget_layout.dart LayoutBuilder)
  const hPad = w * 0.05;
  const vPad = h * 0.05;
  const topDateSize = w * 0.035;
  const calNumSize = w * 0.035;
  const calDaySize = w * 0.025;
  const bottomRowSize = w * 0.03;
  const bottomDateSize = w * 0.028;

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  // 1. Top-right date
  tp.text = TextSpan(
    text: '${DateFormat('dd/MM/yyyy', locale).format(now)}\n${DateFormat('EEEE', locale).format(now)}',
    style: const TextStyle(color: WidgetColors.textDate, fontSize: topDateSize, height: 1.3),
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
    final color = isToday ? WidgetColors.background : WidgetColors.textWhite;
    final dayColor = isToday ? WidgetColors.background : WidgetColors.textWhite70;
    final dayNum = monday.add(Duration(days: i)).day;
    final cx = hPad + cellWidth * i + cellWidth / 2;

    tp.text = TextSpan(
      text: dayNum.toString(),
      style: TextStyle(color: color, fontSize: calNumSize, fontWeight: FontWeight.bold),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, calTop));

    tp.text = TextSpan(
      text: shortLabels[i],
      style: TextStyle(color: dayColor, fontSize: calDaySize),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, calTop + calNumSize * 1.2));
  }

  // 3–4. Bottom section
  const bottomY = h - vPad - bottomDateSize * 1.3 - h * 0.03 - bottomRowSize * 1.3;

  // Weekday abbreviations
  tp.text = TextSpan(
    text: shortLabels.join('  '),
    style: const TextStyle(color: WidgetColors.textWhite70, fontSize: bottomRowSize, letterSpacing: 2.0),
  );
  tp.layout();
  tp.paint(canvas, Offset((w - tp.width) / 2, bottomY));

  // Full date
  tp.text = TextSpan(
    text: DateFormat('d MMMM yyyy г. (EEEE)', locale).format(now),
    style: const TextStyle(color: WidgetColors.textDim, fontSize: bottomDateSize),
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
