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
import 'package:ztime_widget/core/constants/android_constants.dart';
import 'package:ztime_widget/core/constants/durations.dart';
import 'package:ztime_widget/core/constants/formats.dart';
import 'package:ztime_widget/core/constants/home_widget_keys.dart';
import 'package:ztime_widget/core/constants/pref_keys.dart';
import 'package:ztime_widget/core/device/launcher_capabilities.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';
import 'package:ztime_widget/i18n/strings.g.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == HomeWidgetKeys.workTask) {
      await _renderWidgetToPng();
      return true;
    }
    return false;
  });
}

Future<GlassStyle> _loadGlassStyle() async {
  final prefs = await SharedPreferences.getInstance();
  final index = prefs.getInt(PrefKeys.glassStyle) ?? 0;
  if (index < GlassStyle.values.length) return GlassStyle.values[index];
  return GlassStyle.coldGlass;
}

/// Reads the saved locale preference (0=system, 1=ru, 2=en).
/// Returns the language code string.
Future<String> _loadLocaleCode() async {
  final prefs = await SharedPreferences.getInstance();
  final index = prefs.getInt(PrefKeys.appLocale) ?? 0;
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
  final widgetW =
      prefs.getInt(PrefKeys.widgetWidth) ?? WidgetDimensions.defaultWidgetW;
  final widgetH =
      prefs.getInt(PrefKeys.widgetHeight) ?? WidgetDimensions.defaultWidgetH;

  final aspect = widgetW / widgetH;
  const w = WidgetDimensions.baseWidth;
  final h = (w / aspect).clamp(
    WidgetDimensions.minHeight,
    WidgetDimensions.maxHeight,
  );

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

  // Dark overlay — adaptive based on device transparency support
  final capabilities = await LauncherCapabilities.detect();
  final overlayAlpha = switch (capabilities.transparencySupport) {
    TransparencySupport.full => 0x14, // light overlay, blur handled by launcher
    TransparencySupport.partial => 0x4D, // 30% black
    TransparencySupport.none => 0x8C, // 55% black (original)
  };
  final overlayPaint = Paint()..color = Color(overlayAlpha << 24 | 0x1C1C1E);
  canvas.drawRect(Rect.fromLTWH(0, 0, w, h), overlayPaint);

  // Top highlight line
  final highlightPaint = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(0, 0),
      const Offset(0, WidgetDimensions.highlightLineHeight),
      [
        Colors.white.withValues(alpha: 0.35),
        Colors.white.withValues(alpha: 0.0),
      ],
    );
  canvas.drawRect(
    const Rect.fromLTWH(
      0,
      0,
      WidgetDimensions.baseWidth,
      WidgetDimensions.highlightLineHeight,
    ),
    highlightPaint,
  );

  // All proportions are percentage-based — adapts to any aspect ratio
  const safePadX = WidgetDimensions.baseWidth * 0.065;
  final safePadY = h * 0.055;
  const contentW = w - safePadX * 2;
  const cellPad = contentW * WidgetDimensions.cellPadRatio;

  // Date typography (time is handled by native TextClock)
  const dateFontSize = contentW * 0.065;
  const dayNameSize = contentW * 0.045;

  // Calendar strip — tight to time, minimal gap
  final calHeight = h * 0.32;
  final calTop = h - safePadY - calHeight;
  const calNumSize = contentW * 0.063;
  const calLetterSize = contentW * 0.030;

  final dateTop = h * 0.18;

  final tp = TextPainter(textDirection: ui.TextDirection.ltr);

  // Date — top-right, aligned with TextClock
  final dateStr = DateFormat(AppFormats.dateShort, locale).format(now);
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
  final dayName = DateFormat(AppFormats.weekdayFull, locale).format(now);
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
  final dayFmt = DateFormat(AppFormats.weekdayShort, locale);
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

    // Glass card — calendarBg background, with cellPad each side
    final cardRect = RRect.fromLTRBR(
      cx + cellPad,
      calTop,
      cx + cellWidth - cellPad,
      calTop + calHeight,
      const Radius.circular(WidgetDimensions.calCardRadius),
    );
    cardPaint.color = WidgetColors.calendarBg;
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
        const Radius.circular(WidgetDimensions.pillRadius),
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

  await HomeWidget.saveFile(
    HomeWidgetKeys.widgetPng,
    pngBytes,
    extension: 'png',
  );
  await HomeWidget.updateWidget(
    qualifiedAndroidName: AndroidConstants.widgetProvider,
  );

  image.dispose();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init date formatting + detect device transparency support
  await Future.wait([
    initializeDateFormatting('ru', null),
    initializeDateFormatting('en', null),
    LauncherCapabilities.detect(),
  ]);

  // Init slang: load saved locale or fall back to device locale
  final prefs = await SharedPreferences.getInstance();
  final localeIndex = prefs.getInt(PrefKeys.appLocale) ?? 0;
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
    HomeWidgetKeys.workTaskId,
    HomeWidgetKeys.workTask,
    frequency: AppDurations.workmanagerFrequency,
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

  runApp(TranslationProvider(child: const ProviderScope(child: ZTimeApp())));
}
