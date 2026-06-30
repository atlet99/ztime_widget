import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:ztime_widget/core/constants/formats.dart';
import 'package:ztime_widget/core/device/launcher_capabilities.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// In-app full-screen clock face.
/// Adaptive layout using ResponsiveBreakpoints + ScreenUtil.
///
/// Portrait:
///   Top bar:    Time (Thin, w100) + Date (Regular, w400), baseline-aligned
///   Spring:     Empty space
///   Bottom bar: Calendar strip, tappable cells → open that date in calendar
///
/// Landscape (phone):
///   Left:       Time (large) + Date below
///   Right:      Calendar strip (vertical, compact)
///
/// Safe area: 6.5% horizontal, 5.5% vertical
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

        // ResponsiveBreakpoints — logical breakpoint checks
        final rb = ResponsiveBreakpoints.of(context);
        final isMobile = rb.isMobile;
        final isTablet = rb.isTablet;

        final isLandscape = w > h;
        if (isLandscape && h < 700) {
          return _buildLandscape(w, h, padding, isMobile, isTablet);
        }
        return _buildPortrait(w, h, padding, isMobile, isTablet);
      },
    );
  }

  /// Portrait layout — time + date top, calendar bottom.
  Widget _buildPortrait(
    double w,
    double h,
    EdgeInsets padding,
    bool isMobile,
    bool isTablet,
  ) {
    final safePadX = 24.w;
    final safePadY = padding.top + 16.h;

    // AutoSizeText: time fills available space, auto-scales for any device
    final timeHeight = h * 0.14;
    final timeFontSize = h * 0.12;
    final dateFontSize = isMobile ? 13.sp : (isTablet ? 16.sp : 24.sp);
    final dayNameSize = isMobile ? 11.sp : (isTablet ? 13.sp : 20.sp);

    // Calendar strip — capped so it doesn't dominate on tablets
    final calHeight = h * 0.12 < 110 ? h * 0.12 : 110.0;
    final cellPad = 10.w;
    final calNumSize = isMobile ? 14.sp : (isTablet ? 16.sp : 28.sp);
    final calLetterSize = isMobile ? 10.sp : (isTablet ? 11.sp : 18.sp);

    final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
    final today = time.weekday - 1;
    final monday = time.subtract(Duration(days: time.weekday - 1));
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Stack(
      children: [
        _glassBackground(),
        _darkOverlay(),
        _highlightLine(),

        // Top bar — Time + Date, baseline-aligned
        Positioned(
          top: safePadY,
          left: safePadX,
          right: safePadX,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: timeHeight,
                child: AutoSizeText(
                  timeStr,
                  maxLines: 1,
                  minFontSize: 30,
                  stepGranularity: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: timeFontSize,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 0.09,
                    height: 0.85,
                  ),
                ),
              ),
              const Spacer(),
              Column(
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
                  SizedBox(height: 4.h),
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
            ],
          ),
        ),

        // Bottom bar — Calendar strip, tappable cells
        Positioned(
          bottom: safePadY,
          left: safePadX,
          right: safePadX,
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
                      padding: EdgeInsets.symmetric(horizontal: cellPad),
                      child: Container(
                        decoration: BoxDecoration(
                          color: WidgetColors.calendarBg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isToday
                                ? IntrinsicWidth(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
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
                            SizedBox(height: 3.h),
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
      ],
    );
  }

  /// Landscape layout — time + date left, calendar right.
  /// Used when height < 700 (phone in landscape).
  Widget _buildLandscape(
    double w,
    double h,
    EdgeInsets padding,
    bool isMobile,
    bool isTablet,
  ) {
    final safePadX = 16.w;
    final safePadY = padding.top + 8.h;

    // Left column: time + date (55% width)
    final leftW = w * 0.55;
    final timeHeight = h * 0.30;
    final timeFontSize = h * 0.28;
    final dateFontSize = isMobile ? 11.sp : (isTablet ? 14.sp : 16.sp);
    final dayNameSize = isMobile ? 9.sp : (isTablet ? 11.sp : 13.sp);

    // Right column: calendar strip (vertical)
    final rightX = w * 0.58;
    final rightW = w - rightX - safePadX;
    final cellPad = 8.w;
    final calNumSize = isMobile ? 11.sp : (isTablet ? 13.sp : 16.sp);

    final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
    final today = time.weekday - 1;
    final monday = time.subtract(Duration(days: time.weekday - 1));
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Stack(
      children: [
        _glassBackground(),
        _darkOverlay(),
        _highlightLine(),

        // Left: Time + Date
        Positioned(
          top: safePadY + h * 0.05,
          left: safePadX,
          width: leftW,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: timeHeight,
                child: AutoSizeText(
                  timeStr,
                  maxLines: 1,
                  minFontSize: 24,
                  stepGranularity: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: timeFontSize,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 0.09,
                    height: 0.85,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                DateFormat(AppFormats.dateShort, locale).format(time),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: dateFontSize,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 3.h),
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

        // Right: Calendar strip (vertical)
        Positioned(
          top: safePadY,
          right: safePadX,
          width: rightW,
          bottom: safePadY,
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
                      horizontal: cellPad,
                      vertical: 2.h,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: WidgetColors.calendarBg,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isToday)
                            Container(
                              width: 6.r,
                              height: 6.r,
                              margin: EdgeInsets.only(right: 6.w),
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
      ],
    );
  }

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
