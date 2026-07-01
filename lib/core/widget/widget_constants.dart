import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztime_widget/core/constants/pref_keys.dart';

/// Widget color tokens — monotonic alpha scale.
///
/// Glass layers (back to front): overlay(8%) → card(12%) → panel(16%) → border(24%)
/// Text hierarchy: time(95%) → date(75%) → dayName(65%) → calNum(88%) → calLetter(50%)
///
/// Architectural note: neon-blur (ImageFilter + ShaderMask) is in-app ONLY.
/// RemoteViews does not support BackdropFilter — glass blur is baked into the
/// static PNG. Do NOT add blur effects to WidgetPngRenderer.
class WidgetColors {
  WidgetColors._();

  // Base
  static const background = Color(0xFF1C1C1E);

  // Glass layers — monotonic alpha: 8 → 12 → 16 → 24
  static const glassOverlay = Color(0x14FFFFFF); // 8%
  static const glassCard = Color(0x1FFFFFFF); // 12%
  static const glassPanel = Color(0x29FFFFFF); // 16%
  static const glassBorder = Color(0x3DFFFFFF); // 24%

  // Legacy aliases (keep existing references working)
  static const darkOverlay = glassOverlay;
  static const glassPanelColor = glassPanel;

  // Text — hierarchical alpha
  static const textTime = Color(0xF2FFFFFF); // 95%
  static const textDate = Color(0xBFFFFFFF); // 75%
  static const textDayName = Color(0xA6FFFFFF); // 65%
  static const textCalNum = Color(0xE0FFFFFF); // 88%
  static const textCalLetter = Color(0x80FFFFFF); // 50%

  // Active state — accent pill with white text
  static const textActive = Color(0xFFFFFFFF); // 100%
  static const pillBg = Color(0xFF7C4DFF); // accent

  // Calendar cell background — recessed area over glass
  static const calendarBg = Color(0x33000000); // black 20%
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
  static const cellPadRatio = 0.008;
  static const highlightLineHeight = 1.5;

  /// Scrim radius under text zones — ensures contrast on light wallpapers.
  static const scrimRadius = 0.35; // 35% of canvas width

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
