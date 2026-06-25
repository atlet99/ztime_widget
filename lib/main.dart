import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
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

  final recorder = ui.PictureRecorder();
  const size = Size(400, 400);
  final canvas = Canvas(recorder, Offset.zero & size);

  final now = DateTime.now();
  final timeStr =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

  final bgPaint = Paint()..color = const Color(0xFF1A1A2E);
  final borderPaint = Paint()
    ..color = const Color(0xFF2D2D44)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.width / 2;

  canvas.drawCircle(center, radius, bgPaint);
  canvas.drawCircle(center, radius, borderPaint);

  final markPaint = Paint()
    ..color = const Color(0xFF666666)
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round;

  for (var i = 0; i < 12; i++) {
    final angle = (i / 12) * 2 * math.pi;
    final outer = radius * 0.72;
    final inner = radius * 0.64;
    canvas.drawLine(
      Offset(center.dx + inner * math.cos(angle), center.dy + inner * math.sin(angle)),
      Offset(center.dx + outer * math.cos(angle), center.dy + outer * math.sin(angle)),
      markPaint,
    );
  }

  final hourAngle = ((now.hour % 12) + now.minute / 60) / 12 * 2 * math.pi - math.pi / 2;
  final minAngle = (now.minute + now.second / 60) / 60 * 2 * math.pi - math.pi / 2;
  final secAngle = now.second / 60 * 2 * math.pi - math.pi / 2;

  _drawHand(canvas, center, hourAngle, radius * 0.45, 4.0, const Color(0xFFE0E0E0));
  _drawHand(canvas, center, minAngle, radius * 0.62, 2.5, const Color(0xFFBDBDBD));
  _drawHand(canvas, center, secAngle, radius * 0.68, 1.2, const Color(0xFF00BCD4));

  final dotPaint = Paint()
    ..color = const Color(0xFF00BCD4)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(center, 4, dotPaint);

  final timePainter = TextPainter(textDirection: TextDirection.ltr);
  timePainter.text = TextSpan(
    text: timeStr,
    style: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w200,
      color: Color(0xFFE0E0E0),
    ),
  );
  timePainter.layout();
  timePainter.paint(
      canvas, Offset(center.dx - timePainter.width / 2, center.dy + radius * 0.15));

  final picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(400, 400);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List pngBytes = byteData!.buffer.asUint8List();

  await HomeWidget.saveWidgetData('widget_png', pngBytes);
  await HomeWidget.updateWidget(
    qualifiedAndroidName:
        'com.gosayram.ztime_widget.CustomClockWidgetProvider',
  );

  image.dispose();
}

void _drawHand(Canvas canvas, Offset center, double angle, double length,
    double width, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;
  final end = Offset(
    center.dx + length * math.cos(angle),
    center.dy + length * math.sin(angle),
  );
  canvas.drawLine(center, end, paint);
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
