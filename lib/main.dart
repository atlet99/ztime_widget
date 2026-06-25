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

  const size = Size(WidgetDimensions.width, WidgetDimensions.height);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);

  final now = DateTime.now();
  const locale = 'ru';

  // Background
  final bgPaint = Paint()..color = WidgetColors.background;
  final bgRRect = RRect.fromLTRBR(
    0, 0, size.width, size.height,
    WidgetColors.backgroundRadius,
  );
  canvas.drawRRect(bgRRect, bgPaint);

  // Date top-right
  final dateStr = DateFormat('dd/MM/yyyy', locale).format(now);
  final dayName = DateFormat('EEEE', locale).format(now);
  TextPainter(textDirection: ui.TextDirection.ltr)
    ..text = TextSpan(
      text: '$dateStr\n$dayName',
      style: const TextStyle(color: WidgetColors.textDate, fontSize: 13, height: 1.3),
    )
    ..layout()
    ..paint(canvas, Offset(
      size.width - WidgetDimensions.datePadding - 80,
      WidgetDimensions.dateTop,
    ));

  // Weekday panel
  final panelPaint = Paint()..color = WidgetColors.panel;
  final panelRRect = RRect.fromLTRBR(
    WidgetDimensions.panelMargin, WidgetDimensions.panelTop,
    size.width - WidgetDimensions.panelMargin,
    WidgetDimensions.panelTop + WidgetDimensions.panelHeight,
    WidgetColors.panelRadius,
  );
  canvas.drawRRect(panelRRect, panelPaint);

  final monday = now.subtract(Duration(days: now.weekday - 1));
  final dayFmt = DateFormat('EE', locale);
  final cellWidth = (size.width - WidgetDimensions.panelMargin * 2) / 7;
  final todayIndex = now.weekday - 1;
  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  for (var i = 0; i < 7; i++) {
    final isToday = i == todayIndex;
    final color = isToday ? WidgetColors.textWhite : WidgetColors.textGray;
    final cellCenterX =
        WidgetDimensions.panelMargin + cellWidth * i + cellWidth / 2;
    final day = monday.add(Duration(days: i));

    tp.text = TextSpan(
      text: day.day.toString(),
      style: TextStyle(color: color, fontSize: 12, fontWeight: isToday ? FontWeight.w600 : FontWeight.normal),
    );
    tp.layout();
    tp.paint(canvas, Offset(cellCenterX - tp.width / 2, WidgetDimensions.panelTop + 6));

    tp.text = TextSpan(
      text: dayFmt.format(day),
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    );
    tp.layout();
    tp.paint(canvas, Offset(cellCenterX - tp.width / 2, WidgetDimensions.panelTop + 24));
  }

  final picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(
    WidgetDimensions.width.toInt(),
    WidgetDimensions.height.toInt(),
  );
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
