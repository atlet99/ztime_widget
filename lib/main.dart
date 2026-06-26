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

  // Inner vignette — subtle depth simulation (matches widget_layout.dart)
  final vignettePaint = Paint()
    ..shader = ui.Gradient.radial(
      const Offset(w / 2, h / 2),
      w * 0.75,
      [const Color(0x00000000), const Color(0x18000000)],
      [0.0, 1.0],
    );
  canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), vignettePaint);

  // Mirrored padding — same 5% that XML TextClock uses
  const edgePad = w * 0.05;
  const topPad = h * 0.08;

  // Zone B: date (top-right)
  const dateFontSize = w * 0.038;
  const dayNameSize = w * 0.032;

  // Zone C: calendar strip (bottom third)
  const calNumSize = w * 0.04;
  const calLetterSize = w * 0.028;
  const pillH = calNumSize * 2.0;
  const calTop = h * 0.62;

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  // Zone B: Date top-right
  final dateStr = DateFormat('dd/MM/yyyy', locale).format(now);
  final dayName = DateFormat('EEEE', locale).format(now);

  tp.text = TextSpan(
    text: dateStr,
    style: const TextStyle(
      color: WidgetColors.textDate,
      fontSize: dateFontSize,
      height: 1.2,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(w - edgePad - tp.width, topPad));

  tp.text = TextSpan(
    text: dayName,
    style: const TextStyle(
      color: WidgetColors.textDayName,
      fontSize: dayNameSize,
      height: 1.2,
    ),
  );
  tp.layout();
  tp.paint(
    canvas,
    Offset(w - edgePad - tp.width, topPad + dateFontSize * 1.2 + 2),
  );

  // Zone C: Calendar strip
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final shortLabels = <String>[];
  final dayFmt = DateFormat('EE', locale);
  for (var i = 0; i < 7; i++) {
    shortLabels.add(dayFmt.format(monday.add(Duration(days: i))));
  }
  final todayIndex = now.weekday - 1;
  const calWidth = w - edgePad * 2;
  const cellWidth = calWidth / 7;

  for (var i = 0; i < 7; i++) {
    final isToday = i == todayIndex;
    final cx = edgePad + cellWidth * i + cellWidth / 2;
    final dayNum = monday.add(Duration(days: i)).day;

    if (isToday) {
      // White pill
      final pillPaint = Paint()..color = WidgetColors.textActive;
      final pillRect = RRect.fromLTRBR(
        cx - cellWidth / 2 + 4,
        calTop,
        cx + cellWidth / 2 - 4,
        calTop + pillH,
        const Radius.circular(100),
      );
      canvas.drawRRect(pillRect, pillPaint);
    }

    // Day number
    final numColor = isToday
        ? WidgetColors.background
        : WidgetColors.textCalNum;
    tp.text = TextSpan(
      text: dayNum.toString(),
      style: TextStyle(
        color: numColor,
        fontSize: calNumSize,
        fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
        height: 1.1,
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(cx - tp.width / 2, calTop + (pillH - tp.height) / 2),
    );

    // Day letter
    final letterColor = isToday
        ? WidgetColors.background
        : WidgetColors.textCalLetter;
    tp.text = TextSpan(
      text: shortLabels[i],
      style: TextStyle(
        color: letterColor,
        fontSize: calLetterSize,
        height: 1.1,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, calTop + pillH + 4));
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
