import 'dart:ui';

/// Shared constants for widget rendering.
/// Used by both WidgetLayout (widget PNG) and ClockFace (in-app display).
class WidgetColors {
  WidgetColors._();

  // Background
  static const background = Color(0xFF1C1C1E);

  // Glass panels (frosted glass illusion)
  static const glassPanel = Color(0x26FFFFFF); // 15% white — time backdrop
  static const glassCard = Color(0x1AFFFFFF); // 10% white — calendar cards
  static const glassCardActive = Color(0xE6FFFFFF); // 90% white — active day card
  static const glassBorder = Color(0x1FFFFFFF); // 12% white — card borders

  // Text — high contrast hierarchy
  static const textTime = Color(0xFFFFFFFF); // 1.0 — time digits (bold, prominent)
  static const textDate = Color(0xFFFFFFFF); // 1.0 — date top-right
  static const textDayName = Color(0xCCFFFFFF); // 0.80 — day name under date
  static const textCalNum = Color(0xE6FFFFFF); // 0.90 — calendar day numbers
  static const textCalLetter = Color(0x99FFFFFF); // 0.60 — calendar day letters
  static const textActive = Color(0xFF1C1C1E); // dark text on active card
}

class WidgetDimensions {
  WidgetDimensions._();

  /// Golden canvas — covers 99.9% of devices.
  static const width = 1200.0;
  static const height = 600.0;
}
