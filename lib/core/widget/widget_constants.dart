import 'dart:ui';

/// Shared constants for widget rendering.
/// Used by both WidgetLayout (widget PNG) and ClockFace (in-app display).
class WidgetColors {
  WidgetColors._();

  // Background
  static const background = Color(0xFF1C1C1E);

  // Alpha channel hierarchy (Master Plan Block 3)
  static const textTime = Color(0xFFFFFFFF); // 1.0 — time digits
  static const textActive = Color(0xD9FFFFFF); // 0.85 — date top, active day
  static const textInactive = Color(0x80FFFFFF); // 0.50 — inactive mini-cal days
  static const textRow = Color(0x66FFFFFF); // 0.40 — bottom weekday row
  static const textFullDate = Color(0x4DFFFFFF); // 0.30 — full date bottom
}

class WidgetDimensions {
  WidgetDimensions._();

  /// Golden canvas — covers 99.9% of devices.
  static const width = 1200.0;
  static const height = 600.0;
}
