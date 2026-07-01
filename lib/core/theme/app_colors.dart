import 'package:flutter/material.dart';

/// App-wide color tokens.
/// Accent: Deep Purple A200 — complements neon blue on the color wheel.
sealed class AppColors {
  AppColors._();

  // Brand
  static const accent = Color(0xFF7C4DFF);
  static const accentDim = Color(0xFF1A1A2E);

  // Clock face
  static const clockBg = Color(0xFF0D0D1A);
  static const clockBorder = Color(0x4D7C4DFF);

  // Hands
  static const handHour = Color(0xF2F5F5F7); // #F5F5F7 @ 95%
  static const handMinute = Color(0xE6E4E4E8); // #E4E4E8 @ 90%
  static const handSecond = Color(0xFF7C4DFF); // accent

  // Text
  static const textPrimary = Colors.white;
  static const textDim = Color(0x66FFFFFF);
  static const textMuted = Color(0x33FFFFFF);
}
