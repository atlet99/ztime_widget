import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztime_widget/core/constants/pref_keys.dart';

/// Shared constants for widget rendering.
/// Used by both WidgetLayout (widget PNG) and ClockFace (in-app display).
class WidgetColors {
  WidgetColors._();

  static const background = Color(0xFF1C1C1E);
  static const darkOverlay = Color(0x8C1C1C1E);
  static const glassPanel = Color(0x26FFFFFF);
  static const glassCard = Color(0x14FFFFFF);
  static const glassCardActive = Color(0xE6FFFFFF);
  static const glassBorder = Color(0x1FFFFFFF);
  static const textTime = Color(0xFFFFFFFF);
  static const textDate = Color(0xD9FFFFFF);
  static const textDayName = Color(0xB3FFFFFF);
  static const textCalNum = Color(0x8CFFFFFF);
  static const textCalLetter = Color(0x59FFFFFF);
  static const textActive = Color(0xFF1C1C1E);
  static const calendarBg = Color(0x1A2C2C2E);
}

class WidgetDimensions {
  WidgetDimensions._();

  static const baseWidth = 1200.0;
  static const defaultWidgetW = 400;
  static const defaultWidgetH = 200;
  static const minHeight = 400.0;
  static const maxHeight = 1800.0;
  static const defaultCanvasHeight = 600.0;

  static const calCardRadius = 12.0;
  static const pillRadius = 8.0;
  static const cellPad = 9.0;
  static const highlightLineHeight = 1.5;

  /// Compute canvas height matching widget aspect ratio.
  static Future<double> computeHeight() async {
    final prefs = await SharedPreferences.getInstance();
    final widgetW = prefs.getInt(PrefKeys.widgetWidth) ?? 400;
    final widgetH = prefs.getInt(PrefKeys.widgetHeight) ?? 200;
    final aspect = widgetW / widgetH;
    return (baseWidth / aspect).clamp(400.0, 1800.0);
  }

  /// Synchronous version — uses cached values.
  static double cachedHeight = 600.0;

  static Future<void> refresh() async {
    cachedHeight = await computeHeight();
  }
}
