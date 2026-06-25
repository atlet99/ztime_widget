import 'package:flutter/material.dart';

/// Shared constants for widget rendering.
/// Used by both WidgetLayout (in-app) and main.dart (background WorkManager task).
class WidgetColors {
  WidgetColors._();

  static const background = Color(0xFF1C1C1E);
  static const panel = Color(0xFF2C2C2E);
  static const textWhite = Color(0xFFFFFFFF);
  static const textGray = Color(0xFF8E8E93);
  static const textDate = Color(0xCCFFFFFF);

  // Proportional to golden canvas 1200×600 (old 360×180 ×3.33)
  static const backgroundRadius = Radius.circular(53);
  static const panelRadius = Radius.circular(30);
}

class WidgetDimensions {
  WidgetDimensions._();

  /// Golden canvas — covers 99.9% of devices (Samsung Ultra, Huawei, Fold, Tab).
  /// Android scales this down via centerCrop, preserving sharpness.
  static const width = 1200.0;
  static const height = 600.0;

  // Proportional layout constants (based on 1200×600 canvas)
  static const hPad = 0.04; // 4% horizontal padding
  static const vPad = 0.06; // 6% vertical padding
  static const dateFontScale = 0.038;
  static const dayNumFontScale = 0.032;
  static const dayAxisFontScale = 0.028;
  static const panelPaddingScale = 0.015;
  static const panelRadiusScale = 0.025;
}
