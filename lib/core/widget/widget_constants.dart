import 'dart:ui';

/// Shared constants for widget rendering.
/// Used by both WidgetLayout (widget PNG) and ClockFace (in-app display).
class WidgetColors {
  WidgetColors._();

  // Background
  static const background = Color(0xFF1C1C1E);

  // Glass panels (frosted glass illusion)
  static const glassPanel = Color(0x26FFFFFF); // 15% white — time backdrop
  static const glassCard = Color(0x14FFFFFF); // 8% white — calendar cards
  static const glassCardActive = Color(0xE6FFFFFF); // 90% white — active day card
  static const glassBorder = Color(0x1FFFFFFF); // 12% white — card borders

  // Text — Apple-style hierarchy
  static const textTime = Color(0xFFFFFFFF); // 1.0 — time digits (thin, airy)
  static const textDate = Color(0xD9FFFFFF); // 0.85 — date top-right (slightly muted)
  static const textDayName = Color(0xB3FFFFFF); // 0.70 — day name under date
  static const textCalNum = Color(0x8CFFFFFF); // 0.55 — calendar inactive numbers
  static const textCalLetter = Color(0x59FFFFFF); // 0.35 — calendar day letters
  static const textActive = Color(0xFF1C1C1E); // dark text on active pill
  static const calendarBg = Color(0x1A2C2C2E); // #2C2C2E at 10% — calendar container
}

class WidgetDimensions {
  WidgetDimensions._();

  /// Golden canvas — covers 99.9% of devices.
  static const width = 1200.0;
  static const height = 600.0;
}
