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

  static const backgroundRadius = Radius.circular(16);
  static const panelRadius = Radius.circular(12);
}

class WidgetDimensions {
  WidgetDimensions._();

  static const width = 360.0;
  static const height = 180.0;
  static const panelTop = 120.0;
  static const panelHeight = 52.0;
  static const panelMargin = 12.0;
  static const datePadding = 16.0;
  static const dateTop = 12.0;
}
