import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// In-app full-screen clock face.
/// 3-zone edge-anchored layout matching the widget design.
/// Time is rendered by Flutter (Riverpod 1s tick), not TextClock.
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

        // Clamp max width for tablets
        final maxW = w < 480 ? w : 400.0;
        final sidePad = (w - maxW) / 2;

        // Mirrored padding — same 5% that widget uses
        final edgePad = maxW * 0.05;
        final topPad = padding.top + 16.0;

        // Zone A: time (top-left)
        final timeSize = maxW * 0.18;

        // Zone B: date (top-right)
        final dateFontSize = maxW * 0.04;
        final dayNameSize = maxW * 0.034;

        // Zone C: calendar strip (bottom third)
        final calNumSize = maxW * 0.045;
        final calLetterSize = maxW * 0.032;
        final pillH = calNumSize * 2.0;

        final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
        final today = time.weekday - 1;
        final monday = time.subtract(Duration(days: time.weekday - 1));

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePad),
          child: Stack(
            children: [
              // Zone A: Time (top-left) — dynamic, rendered by Flutter
              Positioned(
                top: topPad,
                left: edgePad,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
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

              // Zone B: Date (top-right)
              Positioned(
                top: topPad,
                right: edgePad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy', locale).format(time),
                      style: TextStyle(
                        color: WidgetColors.textDate,
                        fontSize: dateFontSize,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE', locale).format(time),
                      style: TextStyle(
                        color: WidgetColors.textDayName,
                        fontSize: dayNameSize,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Zone C: Calendar strip (bottom third, full width)
              Positioned(
                top: h * 0.62,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: edgePad),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      final dayNum = monday.add(Duration(days: i)).day;
                      final isToday = i == today;
                      final numColor = isToday
                          ? WidgetColors.background
                          : WidgetColors.textCalNum;
                      final letterColor = isToday
                          ? WidgetColors.background
                          : WidgetColors.textCalLetter;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isToday
                              ? Container(
                                  height: pillH,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: WidgetColors.textActive,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: Text(
                                      dayNum.toString(),
                                      style: TextStyle(
                                        color: numColor,
                                        fontSize: calNumSize,
                                        fontWeight: FontWeight.w600,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: pillH,
                                  child: Center(
                                    child: Text(
                                      dayNum.toString(),
                                      style: TextStyle(
                                        color: numColor,
                                        fontSize: calNumSize,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 4),
                          Text(
                            shortLabels[i],
                            style: TextStyle(
                              color: letterColor,
                              fontSize: calLetterSize,
                              height: 1.1,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
