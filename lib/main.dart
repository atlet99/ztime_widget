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
import 'package:ztime_widget/i18n/strings.g.dart';

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

/// Reads the saved locale preference (0=system, 1=ru, 2=en).
/// Returns the language code string.
Future<String> _loadLocaleCode() async {
  final prefs = await SharedPreferences.getInstance();
  final index = prefs.getInt('app_locale') ?? 0;
  final localeEnum =
      AppLocale.values[index.clamp(0, AppLocale.values.length - 1)];
  return localeEnum.languageCode;
}

Future<ui.Image> _loadAssetImage(
  String assetPath,
  int targetW,
  int targetH,
) async {
  final data = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: targetW,
    targetHeight: targetH,
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
  final locale = await _loadLocaleCode();

  final prefs = await SharedPreferences.getInstance();
  final widgetW = prefs.getInt('widget_width') ?? 400;
  final widgetH = prefs.getInt('widget_height') ?? 200;

  final aspect = widgetW / widgetH;
  const w = 1200.0;
  final h = (w / aspect).clamp(400.0, 1800.0);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & Size(w, h));

  final now = DateTime.now();

  // Load and paint glass texture background
  try {
    final bgImage = await _loadAssetImage(
      glassStyle.widgetPath,
      w.toInt(),
      h.toInt(),
    );
    canvas.drawImageRect(
      bgImage,
      Rect.fromLTWH(0, 0, bgImage.width.toDouble(), bgImage.height.toDouble()),
      Rect.fromLTWH(0, 0, w, h),
      Paint()..filterQuality = FilterQuality.high,
    );
    bgImage.dispose();
  } catch (_) {
    canvas.drawColor(WidgetColors.background, BlendMode.src);
  }

  // Dark overlay
  final overlayPaint = Paint()..color = const Color(0x8C1C1C1E);
  canvas.drawRect(Rect.fromLTWH(0, 0, w, h), overlayPaint);

  // Top highlight line
  final highlightPaint = Paint()
    ..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(0, 1.5), [
      Colors.white.withValues(alpha: 0.35),
      Colors.white.withValues(alpha: 0.0),
    ]);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 1200.0, 1.5), highlightPaint);

  // All proportions are percentage-based — adapts to any aspect ratio
  const safePadX = 1200.0 * 0.065;
  final safePadY = h * 0.055;
  const contentW = w - safePadX * 2;

  // Date typography (time is handled by native TextClock)
  const dateFontSize = contentW * 0.065;
  const dayNameSize = contentW * 0.045;

  // Calendar strip — tight to time, minimal gap
  final calHeight = h * 0.32;
  final calTop = h - safePadY - calHeight;
  const calNumSize = contentW * 0.063;
  const calLetterSize = contentW * 0.030;
  const calCardRadius = 12.0;
  const pillRadius = 8.0;
  const cellPad = 9.0;

  final dateTop = h * 0.18;

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  // Date — top-right, aligned with TextClock
  final dateStr = DateFormat('dd/MM/yyyy', locale).format(now);
  tp.text = TextSpan(
    text: dateStr,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.85),
      fontSize: dateFontSize,
      fontWeight: FontWeight.w400,
      height: 1.1,
    ),
  );
  tp.layout();
  tp.paint(canvas, Offset(w - safePadX - w * 0.05 - tp.width, dateTop));

  // Day name — opacity 0.70, bigger
  final dayName = DateFormat('EEEE', locale).format(now);
  tp.text = TextSpan(
    text: dayName,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.70),
      fontSize: dayNameSize,
      fontWeight: FontWeight.w400,
      height: 1.1,
    ),
  );
  tp.layout();
  tp.paint(
    canvas,
    Offset(
      w - safePadX - w * 0.05 - tp.width,
      dateTop + dateFontSize * 1.1 + 4,
    ),
  );

  // Calendar strip
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final shortLabels = <String>[];
  final dayFmt = DateFormat('EE', locale);
  for (var i = 0; i < 7; i++) {
    shortLabels.add(dayFmt.format(monday.add(Duration(days: i))));
  }
  final todayIndex = now.weekday - 1;
  const calWidth = contentW;
  const cellWidth = calWidth / 7;

  final cardPaint = Paint();

  for (var i = 0; i < 7; i++) {
    final isToday = i == todayIndex;
    final cx = safePadX + cellWidth * i;
    final dayNum = monday.add(Duration(days: i)).day;

    // Glass card — #2C2C2E background, with cellPad each side
    final cardRect = RRect.fromLTRBR(
      cx + cellPad,
      calTop,
      cx + cellWidth - cellPad,
      calTop + calHeight,
      const Radius.circular(calCardRadius),
    );
    cardPaint.color = const Color(0x1A2C2C2E);
    canvas.drawRRect(cardRect, cardPaint);

    final dayText = dayNum.toString();

    if (isToday) {
      tp.text = TextSpan(
        text: dayText,
        style: const TextStyle(
          color: WidgetColors.textActive,
          fontSize: calNumSize,
          fontWeight: FontWeight.w400,
          height: 1.1,
        ),
      );
      tp.layout();

      final pillW = tp.width + 16;
      final pillH = tp.height + 8;
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + cellWidth / 2, calTop + calHeight * 0.33),
          width: pillW,
          height: pillH,
        ),
        const Radius.circular(pillRadius),
      );
      canvas.drawRRect(pillRect, Paint()..color = Colors.white);
    } else {
      tp.text = TextSpan(
        text: dayText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: calNumSize,
          fontWeight: FontWeight.w400,
          height: 1.1,
        ),
      );
      tp.layout();
    }

    tp.paint(
      canvas,
      Offset(cx + cellWidth / 2 - tp.width / 2, calTop + calHeight * 0.22),
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

  // Init slang: load saved locale or fall back to device locale
  final prefs = await SharedPreferences.getInstance();
  final localeIndex = prefs.getInt('app_locale') ?? 0;
  if (localeIndex == 0) {
    await LocaleSettings.useDeviceLocale();
  } else {
    final localeEnum =
        AppLocale.values[localeIndex.clamp(0, AppLocale.values.length - 1)];
    await LocaleSettings.setLocale(localeEnum);
  }

  // Generate widget PNG immediately on startup
  await _renderWidgetToPng();

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'ztime-widget-id',
    _workTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

  runApp(TranslationProvider(child: const ProviderScope(child: ZTimeApp())));
}
