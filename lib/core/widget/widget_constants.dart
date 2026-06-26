import 'dart:ui';

/// Shared constants for widget rendering.
/// Used by both WidgetLayout (widget PNG) and ClockFace (in-app display).
class WidgetColors {
  WidgetColors._();

  // Background
  static const background = Color(0xFF1C1C1E);

  // Alpha channel hierarchy (Edge-Anchored Layout spec)
  static const textTime = Color(0xFFFFFFFF); // 1.0 — time digits
  static const textDate = Color(0xE6FFFFFF); // 0.90 — date top-right
  static const textDayName = Color(0x99FFFFFF); // 0.60 — day name under date
  static const textCalNum = Color(
    0x80FFFFFF,
  ); // 0.50 — inactive calendar numbers
  static const textCalLetter = Color(
    0x59FFFFFF,
  ); // 0.35 — inactive calendar letters
  static const textActive = Color(
    0xFFFFFFFF,
  ); // 1.0 — active day (white pill, black text)
}

class WidgetDimensions {
  WidgetDimensions._();

  /// Golden canvas — covers 99.9% of devices.
  static const width = 1200.0;
  static const height = 600.0;
}
