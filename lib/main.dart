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
  final overlayPaint = Paint()..color = const Color(0x8C1C1C1E);
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

  // Safe area — 6.5% horizontal, 5.5% vertical
  final safePadX = w * 0.065;
  final safePadY = h * 0.055;
  final contentW = w - safePadX * 2;

  // Date typography (time is handled by native TextClock)
  final dateFontSize = contentW * 0.042;
  final dayNameSize = contentW * 0.032;

  // Calendar strip
  final calHeight = h * 0.18;
  final calTop = h - safePadY - calHeight;
  final calNumSize = contentW * 0.038;
  final calLetterSize = contentW * 0.026;
  final calCardRadius = 12.0;
  final pillRadius = 8.0;

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  // Date — top-right, Regular weight 400, opacity 0.85
  final dateStr = DateFormat('dd/MM/yyyy', locale).format(now);
  tp.text = TextSpan(
    text: dateStr,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.85),
      fontSize: dateFontSize,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(w - safePadX - tp.width, safePadY));

  // Day name — opacity 0.70, Regular weight
  final dayName = DateFormat('EEEE', locale).format(now);
  tp.text = TextSpan(
    text: dayName,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.70),
      fontSize: dayNameSize,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(w - safePadX - tp.width, safePadY + dateFontSize * 1.2 + 2));

  // Calendar strip
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final shortLabels = <String>[];
  final dayFmt = DateFormat('EE', locale);
  for (var i = 0; i < 7; i++) {
    shortLabels.add(dayFmt.format(monday.add(Duration(days: i))));
  }
  final todayIndex = now.weekday - 1;
  final calWidth = contentW;
  final cellWidth = calWidth / 7;

  final cardPaint = Paint();

  for (var i = 0; i < 7; i++) {
    final isToday = i == todayIndex;
    final cx = safePadX + cellWidth * i;
    final dayNum = monday.add(Duration(days: i)).day;

    // Glass card — #2C2C2E background
    final cardRect = RRect.fromLTRBR(
      cx + 2,
      calTop,
      cx + cellWidth - 2,
      calTop + calHeight,
      Radius.circular(calCardRadius),
    );
    cardPaint.color = const Color(0x1A2C2C2E);
    canvas.drawRRect(cardRect, cardPaint);

    final dayText = dayNum.toString();

    if (isToday) {
      // Active day: white pill, black text
      tp.text = TextSpan(
        text: dayText,
        style: TextStyle(
          color: WidgetColors.textActive,
          fontSize: calNumSize,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      );
      tp.layout();

      final pillW = tp.width + 12;
      final pillH = tp.height + 6;
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + cellWidth / 2, calTop + calHeight * 0.35),
          width: pillW,
          height: pillH,
        ),
        Radius.circular(pillRadius),
      );
      canvas.drawRRect(pillRect, Paint()..color = Colors.white);
    } else {
      // Inactive: opacity 0.55
      tp.text = TextSpan(
        text: dayText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: calNumSize,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      );
      tp.layout();
    }

    tp.paint(
      canvas,
      Offset(cx + cellWidth / 2 - tp.width / 2, calTop + calHeight * 0.25),
    );

    // Day letters — opacity 0.35 Regular, active 0.70
    tp.text = TextSpan(
      text: shortLabels[i],
      style: TextStyle(
        color: isToday
            ? Colors.white.withValues(alpha: 0.70)
            : Colors.white.withValues(alpha: 0.35),
        fontSize: calLetterSize,
        fontWeight: FontWeight.w400,
        height: 1.1,
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(cx + cellWidth / 2 - tp.width / 2, calTop + calHeight * 0.65),
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
