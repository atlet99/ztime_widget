import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztime_widget/core/constants/formats.dart';
import 'package:ztime_widget/core/constants/pref_keys.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// Widget background for home screen PNG.
/// Time is rendered by native Android TextClock — PNG only has date + calendar.
/// Canvas adapts to actual widget aspect ratio.
class WidgetLayout extends StatefulWidget {
  const WidgetLayout({
    super.key,
    required this.renderKey,
    this.glassStyle = GlassStyle.coldGlass,
  });

  final GlobalKey renderKey;
  final GlassStyle glassStyle;

  @override
  State<WidgetLayout> createState() => _WidgetLayoutState();
}

class _WidgetLayoutState extends State<WidgetLayout> {
  final double _canvasW = WidgetDimensions.baseWidth;
  double _canvasH = WidgetDimensions.defaultCanvasHeight;

  @override
  void initState() {
    super.initState();
    _loadDimensions();
  }

  Future<void> _loadDimensions() async {
    final prefs = await SharedPreferences.getInstance();
    final widgetW = prefs.getInt(PrefKeys.widgetWidth) ?? 400;
    final widgetH = prefs.getInt(PrefKeys.widgetHeight) ?? 200;
    final aspect = widgetW / widgetH;
    final h = (WidgetDimensions.baseWidth / aspect).clamp(
      WidgetDimensions.minHeight,
      WidgetDimensions.maxHeight,
    );
    if (mounted) {
      setState(() {
        _canvasH = h;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
    final today = now.weekday - 1;
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final w = _canvasW;
    final h = _canvasH;

    final safePadX = w * 0.065;
    final safePadY = h * 0.055;
    final contentW = w - safePadX * 2;
    final cellPad = contentW * WidgetDimensions.cellPadRatio;

    final dateFontSize = contentW * 0.065;
    final dayNameSize = contentW * 0.045;

    final calHeight = h * 0.32;
    final calNumSize = contentW * 0.063;
    final calLetterSize = contentW * 0.030;

    final dateTop = h * 0.18;

    return RepaintBoundary(
      key: widget.renderKey,
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                widget.glassStyle.widgetPath,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: WidgetColors.darkOverlay),
              ),
            ),
            Positioned(
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
            ),
            Positioned(
              top: dateTop,
              right: safePadX + w * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat(AppFormats.dateShort, locale).format(now),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: dateFontSize,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(AppFormats.weekdayFull, locale).format(now),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontSize: dayNameSize,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: safePadY,
              left: safePadX,
              right: safePadX,
              child: SizedBox(
                height: calHeight,
                child: Row(
                  children: List.generate(7, (i) {
                    final dayNum = monday.add(Duration(days: i)).day;
                    final isToday = i == today;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: cellPad),
                        child: Container(
                          decoration: BoxDecoration(
                            color: WidgetColors.calendarBg,
                            borderRadius: BorderRadius.circular(
                              WidgetDimensions.calCardRadius,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isToday
                                  ? IntrinsicWidth(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            WidgetDimensions.pillRadius,
                                          ),
                                        ),
                                        child: Text(
                                          dayNum.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: WidgetColors.textActive,
                                            fontSize: calNumSize,
                                            fontWeight: FontWeight.w400,
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
                                        fontWeight: FontWeight.w400,
                                        height: 1.1,
                                      ),
                                    ),
                              const SizedBox(height: 4),
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
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
