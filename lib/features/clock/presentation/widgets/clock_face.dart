import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/constants/formats.dart';
import 'package:ztime_widget/core/device/launcher_capabilities.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// In-app full-screen clock face.
///
/// 100% flex-based layout — no .sp, no .w, no .h.
/// All sizes derived from screen height (h) or width (w) as percentages.
/// Adapts to any screen: phone portrait, phone landscape, tablet portrait,
/// tablet landscape.
///
/// Portrait:
///   Column
///   ├── Safe padding
///   ├── Expanded → Row [Time (left) | Date+DayName (right)]
///   ├── Spacer (spring)
///   └── Calendar strip (12% of h)
///
/// Landscape:
///   Row
///   ├── Safe padding left
///   ├── Expanded(weight 3) → Column [Time, Date, DayName]
///   ├── Spacer
///   ├── Expanded(weight 2) → Calendar strip vertical (7 rows)
///   └── Safe padding right
class ClockFace extends StatelessWidget {
  const ClockFace({
    super.key,
    required this.time,
    required this.locale,
    this.glassStyle = GlassStyle.coldGlass,
  });

  final DateTime time;
  final String locale;
  final GlassStyle glassStyle;

  void _openCalendarForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: 'content://com.android.calendar/time',
      arguments: <String, dynamic>{
        'beginTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
        'allDay': true,
      },
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    if (await intent.canResolveActivity() == true) {
      await intent.launch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final padding = MediaQuery.paddingOf(context);

        // Safe padding: 6% of smaller dimension
        final padBase = w < h ? w : h;
        final safePadX = padBase * 0.06;
        final safePadY = padBase * 0.04;

        final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
        final today = time.weekday - 1;
        final monday = time.subtract(Duration(days: time.weekday - 1));
        final timeStr =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

        final isLandscape = w > h;

        if (isLandscape) {
          return _buildLandscape(
            w,
            h,
            padding,
            safePadX,
            safePadY,
            shortLabels,
            today,
            monday,
            timeStr,
          );
        }
        return _buildPortrait(
          w,
          h,
          padding,
          safePadX,
          safePadY,
          shortLabels,
          today,
          monday,
          timeStr,
        );
      },
    );
  }

  // ─── PORTRAIT ──────────────────────────────────────────────────────

  Widget _buildPortrait(
    double w,
    double h,
    EdgeInsets padding,
    double safePadX,
    double safePadY,
    List<String> shortLabels,
    int today,
    DateTime monday,
    String timeStr,
  ) {
    // Font sizes: percentage of h — works on any screen
    final timeFontSize = h * 0.10;
    final dateFontSize = h * 0.022;
    final dayNameSize = h * 0.018;

    // Calendar: 12% of h
    final calHeight = h * 0.12;
    final calNumSize = h * 0.022;
    final calLetterSize = h * 0.015;

    return Stack(
      children: [
        _glassBackground(),
        _darkOverlay(),
        _highlightLine(),

        Column(
          children: [
            // Safe top padding
            SizedBox(height: padding.top + safePadY),

            // Time + Date row — takes all available space
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: safePadX),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Time (left side, neon glow)
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: _buildGlowingTime(
                          timeStr,
                          timeFontSize,
                          minFontSize: 30,
                        ),
                      ),
                    ),

                    // Date + Day name (right side)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat(AppFormats.dateShort, locale).format(time),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: dateFontSize,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: h * 0.005),
                        Text(
                          DateFormat(
                            AppFormats.weekdayFull,
                            locale,
                          ).format(time),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.70),
                            fontSize: dayNameSize,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Spring
            const Spacer(),

            // Calendar strip
            Padding(
              padding: EdgeInsets.symmetric(horizontal: safePadX),
              child: SizedBox(
                height: calHeight,
                child: Row(
                  children: List.generate(7, (i) {
                    final dayDate = monday.add(Duration(days: i));
                    final dayNum = dayDate.day;
                    final isToday = i == today;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _openCalendarForDate(dayDate),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: safePadX * 0.5,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: WidgetColors.calendarBg,
                              borderRadius: BorderRadius.circular(
                                calHeight * 0.12,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isToday
                                    ? IntrinsicWidth(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: calHeight * 0.08,
                                            vertical: calHeight * 0.02,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              calHeight * 0.1,
                                            ),
                                          ),
                                          child: Text(
                                            dayNum.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: WidgetColors.textActive,
                                              fontSize: calNumSize,
                                              fontWeight: FontWeight.w500,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        dayNum.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: calNumSize,
                                          fontWeight: FontWeight.w500,
                                          height: 1.1,
                                        ),
                                      ),
                                SizedBox(height: calHeight * 0.04),
                                Text(
                                  shortLabels[i],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isToday
                                        ? Colors.white.withValues(alpha: 0.70)
                                        : Colors.white.withValues(alpha: 0.35),
                                    fontSize: calLetterSize,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Safe bottom padding
            SizedBox(height: safePadY),
          ],
        ),
      ],
    );
  }

  // ─── LANDSCAPE ─────────────────────────────────────────────────────

  Widget _buildLandscape(
    double w,
    double h,
    EdgeInsets padding,
    double safePadX,
    double safePadY,
    List<String> shortLabels,
    int today,
    DateTime monday,
    String timeStr,
  ) {
    // Font sizes: percentage of h
    final timeFontSize = h * 0.30;
    final dateFontSize = h * 0.065;
    final dayNameSize = h * 0.055;

    // Calendar vertical strip
    final calNumSize = h * 0.055;

    return Stack(
      children: [
        _glassBackground(),
        _darkOverlay(),
        _highlightLine(),

        Row(
          children: [
            // Safe left padding
            SizedBox(width: safePadX),

            // Left: Time + Date (flex 3)
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: safePadY),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time with neon glow
                    _buildGlowingTime(timeStr, timeFontSize, minFontSize: 20),
                    SizedBox(height: h * 0.02),
                    Text(
                      DateFormat(AppFormats.dateShort, locale).format(time),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: h * 0.01),
                    Text(
                      DateFormat(AppFormats.weekdayFull, locale).format(time),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: dayNameSize,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Spacer
            const Spacer(),

            // Right: Calendar strip (flex 2)
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: safePadY,
                  horizontal: safePadX,
                ),
                child: Column(
                  children: List.generate(7, (i) {
                    final dayDate = monday.add(Duration(days: i));
                    final dayNum = dayDate.day;
                    final isToday = i == today;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _openCalendarForDate(dayDate),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: safePadX * 0.3,
                            vertical: h * 0.004,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: WidgetColors.calendarBg,
                              borderRadius: BorderRadius.circular(h * 0.015),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isToday)
                                  Container(
                                    width: h * 0.012,
                                    height: h * 0.012,
                                    margin: EdgeInsets.only(
                                      right: safePadX * 0.4,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Text(
                                  '$dayNum ${shortLabels[i]}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isToday
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.55),
                                    fontSize: calNumSize,
                                    fontWeight: isToday
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Safe right padding
            SizedBox(width: safePadX),
          ],
        ),
      ],
    );
  }

  // ─── NEON GLOW TIME ───────────────────────────────────────────────
  // 3 layers: blurred backdrop, stroke outline, filled top with gradient mask

  Widget _buildGlowingTime(
    String timeStr,
    double fontSize, {
    required double minFontSize,
  }) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // Layer 1: blurred blue ambient glow on background
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Text(
            timeStr,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xCCB3E5FC),
            ),
          ),
        ),

        // Layer 2: stroke outline — always visible, thin white contour
        Text(
          timeStr,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6
              ..color = Colors.white,
          ),
        ),

        // Layer 3: filled top half only (gradient mask cuts off bottom)
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, 0.45, 0.75],
          ).createShader(bounds),
          child: AutoSizeText(
            timeStr,
            maxLines: 1,
            minFontSize: minFontSize,
            maxFontSize: fontSize,
            stepGranularity: 1,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.04,
              height: 0.85,
              shadows: const [
                Shadow(color: Colors.white, blurRadius: 6),
                Shadow(color: Color(0xFF81D4FA), blurRadius: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── SHARED ────────────────────────────────────────────────────────

  Widget _glassBackground() {
    return Positioned.fill(
      child: Image.asset(
        glassStyle.appPath,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }

  Widget _darkOverlay() {
    final support = LauncherCapabilities.current.transparencySupport;
    return Positioned.fill(
      child: switch (support) {
        TransparencySupport.full => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.white.withValues(alpha: 0.08)),
        ),
        TransparencySupport.partial => Container(
          color: Colors.black.withValues(alpha: 0.30),
        ),
        TransparencySupport.none => const DecoratedBox(
          decoration: BoxDecoration(color: WidgetColors.darkOverlay),
        ),
      },
    );
  }

  Widget _highlightLine() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: WidgetDimensions.highlightLineHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.35),
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
