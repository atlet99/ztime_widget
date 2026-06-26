import 'package:flutter/material.dart';

/// Shared constants for widget rendering.
/// Used by both WidgetLayout (in-app) and main.dart (background WorkManager task).
class WidgetColors {
  WidgetColors._();

  static const background = Color(0xFF1C1C1E);
  static const textWhite = Color(0xFFFFFFFF);
  static const textWhite70 = Color(0xB3FFFFFF);
  static const textGray = Color(0xFF8E8E93);
  static const textDim = Color(0x80FFFFFF);
  static const textDate = Color(0xCCFFFFFF);
}

class WidgetDimensions {
  WidgetDimensions._();

  /// Golden canvas — covers 99.9% of devices (Samsung Ultra, Huawei, Fold, Tab).
  /// Android scales this down via centerCrop, preserving sharpness.
  static const width = 1200.0;
  static const height = 600.0;
}
