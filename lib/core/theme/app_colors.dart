import 'package:flutter/material.dart';

sealed class AppColors {
  AppColors._();

  // Brand
  static const accent = Color(0xFF6C63FF);
  static const accentDim = Color(0xFF1A1A2E);

  // Clock face
  static const clockBg = Color(0xFF0D0D1A);
  static const clockBorder = Color(0x4D6C63FF);

  // Hands
  static const handHour = Color(0xFFE0E0E0);
  static const handMinute = Color(0xFFBDBDBD);
  static const handSecond = Color(0xFF6C63FF);

  // Text
  static const textPrimary = Colors.white;
  static const textDim = Color(0x66FFFFFF);
  static const textMuted = Color(0x33FFFFFF);
}
