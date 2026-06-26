import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ztime_widget/app.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
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

Future<GlassStyle> _loadGlassStyle() async {
  final prefs = await SharedPreferences.getInstance();
  final index = prefs.getInt('glass_style') ?? 0;
  if (index < GlassStyle.values.length) return GlassStyle.values[index];
  return GlassStyle.coldGlass;
}

Future<ui.Image> _loadAssetImage(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: WidgetDimensions.width.toInt(),
    targetHeight: WidgetDimensions.height.toInt(),
  );
  final frame = await codec.getNextFrame();
  return frame.image;
}

Future<void> _renderWidgetToPng() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('ru', null),
    initializeDateFormatting('en', null),
  ]);

  final glassStyle = await _loadGlassStyle();

  const w = WidgetDimensions.width;
  const h = WidgetDimensions.height;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & const Size(w, h));

  final now = DateTime.now();
  const locale = 'ru';

  // Load and paint glass texture background
  try {
    final bgImage = await _loadAssetImage(glassStyle.widgetPath);
    canvas.drawImageRect(
      bgImage,
      Rect.fromLTWH(0, 0, bgImage.width.toDouble(), bgImage.height.toDouble()),
      const Rect.fromLTWH(0, 0, w, h),
      Paint()..filterQuality = FilterQuality.high,
    );
    bgImage.dispose();
  } catch (_) {
    canvas.drawColor(WidgetColors.background, BlendMode.src);
  }

  // Dark overlay for text readability
  final overlayPaint = Paint()..color = const Color(0x8C1C1C1E); // 55% alpha
  canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), overlayPaint);

  // Top highlight line — glass reflection
  final highlightPaint = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(0, 0),
      const Offset(0, 1.5),
      [
        Colors.white.withValues(alpha: 0.35),
        Colors.white.withValues(alpha: 0.0),
      ],
    );
  canvas.drawRect(const Rect.fromLTWH(0, 0, w, 1.5), highlightPaint);

  // Layout metrics — matching widget_layout.dart
  const edgePad = w * 0.04;
  final timeSize = h * 0.38;
  final timeTop = h * 0.08;
  final dateLeft = w * 0.62;
  final dateFontSize = w * 0.042;
  final dayNameSize = w * 0.036;
  final calNumSize = w * 0.04;
  final calLetterSize = w * 0.028;
  final cardH = h * 0.28;
  final cardRadius = w * 0.015;
  final calTop = h * 0.68;

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  // Zone B: Date + day name — right of time
  final dateStr = DateFormat('dd/MM/yyyy', locale).format(now);
  final dayName = DateFormat('EEEE', locale).format(now);
  final dateY = timeTop + timeSize * 0.35;

  tp.text = TextSpan(
    text: dateStr,
    style: TextStyle(
      color: Colors.white,
      fontSize: dateFontSize,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(dateLeft, dateY));

  tp.text = TextSpan(
    text: dayName,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.75),
      fontSize: dayNameSize,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(dateLeft, dateY + dateFontSize * 1.2 + 4));

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
        ? const Color(0x40FFFFFF) // 25% white
        : const Color(0x14FFFFFF); // 8% white
    cardBorderPaint.color = isToday
        ? const Color(0x80FFFFFF) // 50% white
        : const Color(0x1FFFFFFF); // 12% white
    canvas.drawRRect(cardRect, cardPaint);
    canvas.drawRRect(cardRect, cardBorderPaint);

    // Day number
    tp.text = TextSpan(
      text: dayNum.toString(),
      style: TextStyle(
        color: isToday
            ? Colors.white
            : Colors.white.withValues(alpha: 0.9),
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
    tp.text = TextSpan(
      text: shortLabels[i],
      style: TextStyle(
        color: isToday
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.5),
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

  // Generate widget PNG immediately on startup
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
