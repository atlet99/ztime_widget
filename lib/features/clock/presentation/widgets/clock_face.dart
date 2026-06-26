import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// In-app full-screen clock face.
/// Mirrors the widget design but adapts to the phone's aspect ratio (19.5:9).
/// Uses Riverpod for dynamic time (no TextClock — that's for the widget only).
class ClockFace extends StatelessWidget {
  const ClockFace({super.key, required this.time, required this.locale});

  final DateTime time;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final padding = MediaQuery.of(context).padding;

        // Clamp max width so it doesn't stretch on tablets
        final maxW = w < 480 ? w : 400.0;
        final sidePad = (w - maxW) / 2;

        // Proportional sizes
        final topDateSize = maxW * 0.04;
        final calNumSize = maxW * 0.045;
        final calDaySize = maxW * 0.032;
        final calPillW = calNumSize * 2.2;
        final calPillH = calNumSize * 1.8;
        final timeSize = maxW * 0.22;
        final bottomRowSize = maxW * 0.038;
        final bottomDateSize = maxW * 0.035;

        final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
        final today = time.weekday - 1;
        final monday = time.subtract(Duration(days: time.weekday - 1));

        return Padding(
          padding: EdgeInsets.only(
            top: padding.top + 16,
            bottom: padding.bottom + 16,
          ),
          child: Column(
            children: [
              // 1. Top-right date (0.85 alpha)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad + 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${DateFormat('dd/MM/yyyy', locale).format(time)}\n${DateFormat('EEEE', locale).format(time)}',
                    style: TextStyle(
                      color: WidgetColors.textActive,
                      fontSize: topDateSize,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),

              SizedBox(height: h * 0.03),

              // 2. Mini-calendar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (i) {
                    final dayNum = monday.add(Duration(days: i)).day;
                    final isToday = i == today;
                    return SizedBox(
                      width: calPillW * 1.4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: calPillW,
                            height: calPillH,
                            child: Center(
                              child: isToday
                                  ? Container(
                                      width: calPillW,
                                      height: calPillH,
                                      decoration: BoxDecoration(
                                        color: WidgetColors.textTime,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          dayNum.toString(),
                                          style: TextStyle(
                                            color: WidgetColors.background,
                                            fontSize: calNumSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      dayNum.toString(),
                                      style: TextStyle(
                                        color: WidgetColors.textTime,
                                        fontSize: calNumSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: calDaySize * 0.2),
                          Text(
                            shortLabels[i],
                            style: TextStyle(
                              color: isToday
                                  ? WidgetColors.textActive
                                  : WidgetColors.textInactive,
                              fontSize: calDaySize,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              // 3. Giant time — optical center (top flex:3, bottom flex:4)
              const Spacer(flex: 3),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: WidgetColors.textTime,
                      fontSize: timeSize,
                      fontWeight: FontWeight.w100,
                      letterSpacing: 4,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 4),

              // 4. Bottom weekday abbreviations (0.40 alpha)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                child: Text(
                  shortLabels.join('  '),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: WidgetColors.textRow,
                    fontSize: bottomRowSize,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              SizedBox(height: h * 0.015),

              // 5. Full date (0.30 alpha)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                child: Text(
                  DateFormat('d MMMM yyyy г. (EEEE)', locale).format(time),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: WidgetColors.textFullDate,
                    fontSize: bottomDateSize,
                  ),
                ),
              ),

              SizedBox(height: padding.bottom),
            ],
          ),
        );
      },
    );
  }
}
