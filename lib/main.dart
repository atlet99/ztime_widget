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
  const hPad = w * WidgetDimensions.hPad;
  const vPad = h * WidgetDimensions.vPad;
  const dateFontSize = w * WidgetDimensions.dateFontScale;
  const dayNumSize = w * WidgetDimensions.dayNumFontScale;
  const dayAxisSize = w * WidgetDimensions.dayAxisFontScale;
  const panelPad = w * WidgetDimensions.panelPaddingScale;
  const panelRad = w * WidgetDimensions.panelRadiusScale;

  // Date top-right
  final tp = TextPainter(textDirection: ui.TextDirection.ltr);
  tp.text = TextSpan(
    text:
        '${DateFormat('dd/MM/yyyy', locale).format(now)}\n${DateFormat('EEEE', locale).format(now)}',
    style: const TextStyle(
      color: WidgetColors.textDate,
      fontSize: dateFontSize,
      height: 1.3,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(w - hPad - tp.width, vPad));

  // Weekday panel (positioned at bottom)
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final dayFmt = DateFormat('EE', locale);
  final todayIndex = now.weekday - 1;
  const cellWidth = (w - hPad * 2) / 7;

  // Estimate panel height: num line + spacing + axis line + 2× padding
  const panelLineHeight = dayNumSize * 1.3;
  const panelSpacing = dayAxisSize * 0.3;
  const panelAxisHeight = dayAxisSize * 1.3;
  const panelHeight =
      panelLineHeight + panelSpacing + panelAxisHeight + panelPad * 2;
  const panelTop = h - vPad - panelHeight;

  canvas.drawRRect(
    RRect.fromLTRBR(
      hPad,
      panelTop,
      w - hPad,
      h - vPad,
      const Radius.circular(panelRad),
    ),
    Paint()..color = WidgetColors.panel,
  );

  for (var i = 0; i < 7; i++) {
    final isToday = i == todayIndex;
    final color = isToday ? WidgetColors.textWhite : WidgetColors.textGray;
    final cx = hPad + cellWidth * i + cellWidth / 2;
    final day = monday.add(Duration(days: i));

    tp.text = TextSpan(
      text: day.day.toString(),
      style: TextStyle(
        color: color,
        fontSize: dayNumSize,
        fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, panelTop + panelPad));

    tp.text = TextSpan(
      text: dayFmt.format(day),
      style: TextStyle(
        color: color,
        fontSize: dayAxisSize,
        fontWeight: FontWeight.w600,
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        cx - tp.width / 2,
        panelTop + panelPad + panelLineHeight + panelSpacing,
      ),
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

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'ztime-widget-id',
    _workTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

  runApp(const ProviderScope(child: ZTimeApp()));
}
