import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ztime_widget/app.dart';

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

  const size = Size(360, 180);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);

  final now = DateTime.now();
  const locale = 'ru';

  // Colors
  const bgColor = Color(0xFF1C1C1E);
  const panelColor = Color(0xFF2C2C2E);
  const textWhite = Color(0xFFFFFFFF);
  const textGray = Color(0xFF8E8E93);

  // Background
  final bgPaint = Paint()..color = bgColor;
  final bgRRect = RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(16));
  canvas.drawRRect(bgRRect, bgPaint);

  // Date top-right
  final dateStr = DateFormat('dd/MM/yyyy', locale).format(now);
  final dayName = DateFormat('EEEE', locale).format(now);
  TextPainter(textDirection: ui.TextDirection.ltr)
    ..text = TextSpan(
      text: '$dateStr\n$dayName',
      style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13, height: 1.3),
    )
    ..layout()
    ..paint(canvas, Offset(size.width - 16 - 80, 12));

  // Weekday panel
  const panelTop = 120.0;
  const panelHeight = 52.0;
  const panelMargin = 12.0;
  final panelPaint = Paint()..color = panelColor;
  final panelRRect = RRect.fromLTRBR(
    panelMargin, panelTop,
    size.width - panelMargin, panelTop + panelHeight,
    const Radius.circular(12),
  );
  canvas.drawRRect(panelRRect, panelPaint);

  final monday = now.subtract(Duration(days: now.weekday - 1));
  final dayFmt = DateFormat('EE', locale);
  final cellWidth = (size.width - panelMargin * 2) / 7;
  final todayIndex = now.weekday - 1;
  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  for (var i = 0; i < 7; i++) {
    final isToday = i == todayIndex;
    final color = isToday ? textWhite : textGray;
    final cellCenterX = panelMargin + cellWidth * i + cellWidth / 2;
    final day = monday.add(Duration(days: i));

    // Date number
    tp.text = TextSpan(
      text: day.day.toString(),
      style: TextStyle(color: color, fontSize: 12, fontWeight: isToday ? FontWeight.w600 : FontWeight.normal),
    );
    tp.layout();
    tp.paint(canvas, Offset(cellCenterX - tp.width / 2, panelTop + 6));

    // Day abbreviation
    tp.text = TextSpan(
      text: dayFmt.format(day),
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    );
    tp.layout();
    tp.paint(canvas, Offset(cellCenterX - tp.width / 2, panelTop + 24));
  }

  final picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(360, 180);
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
    constraints: Constraints(
      networkType: NetworkType.notRequired,
    ),
  );

  runApp(const ProviderScope(child: ZTimeApp()));
}
