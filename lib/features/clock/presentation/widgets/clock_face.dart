import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// In-app full-screen clock face.
/// Glassmorphism style matching the widget design:
///   Zone A (top-left): Glass panel + bold time digits
///   Zone B (top-right): Date + day name (bold)
///   Zone C (bottom): Calendar strip with rounded glass cards
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

        // Mirrored padding — same as widget
        final edgePad = maxW * 0.04;
        final topPad = padding.top + 16.0;

        // Zone A: time glass panel
        final timeSize = maxW * 0.2;
        final timePanelW = maxW * 0.55;
        final timePanelH = timeSize * 1.6;

        // Zone B: date
        final dateFontSize = maxW * 0.04;
        final dayNameSize = maxW * 0.036;

        // Zone C: calendar cards
        final calNumSize = maxW * 0.036;
        final calLetterSize = maxW * 0.026;
        final cardH = h * 0.13;
        final cardRadius = maxW * 0.012;

        final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
        final today = time.weekday - 1;
        final monday = time.subtract(Duration(days: time.weekday - 1));

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePad),
          child: Stack(
            children: [
              // Zone A: Glass panel behind time
              Positioned(
                top: topPad - 10,
                left: edgePad - 6,
                child: Container(
                  width: timePanelW,
                  height: timePanelH,
                  decoration: BoxDecoration(
                    color: WidgetColors.glassPanel,
                    borderRadius: BorderRadius.circular(maxW * 0.02),
                    border: Border.all(
                      color: WidgetColors.glassBorder,
                      width: 1.0,
                    ),
                  ),
                ),
              ),

              // Zone A: Time (top-left) — bold
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
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),

              // Zone B: Date (top-right) — bold
              Positioned(
                top: topPad + h * 0.04,
                right: edgePad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy', locale).format(time),
                      style: TextStyle(
                        color: WidgetColors.textDate,
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE', locale).format(time),
                      style: TextStyle(
                        color: WidgetColors.textDayName,
                        fontSize: dayNameSize,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Zone C: Calendar strip with glass cards
              Positioned(
                top: h * 0.72,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: edgePad),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      final dayNum = monday.add(Duration(days: i)).day;
                      final isToday = i == today;

                      return Container(
                        width: (maxW - edgePad * 2) / 7 - 6,
                        height: cardH,
                        decoration: BoxDecoration(
                          color: isToday
                              ? WidgetColors.glassCardActive
                              : WidgetColors.glassCard,
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(
                            color: WidgetColors.glassBorder,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNum.toString(),
                              style: TextStyle(
                                color: isToday
                                    ? WidgetColors.textActive
                                    : WidgetColors.textCalNum,
                                fontSize: calNumSize,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              shortLabels[i],
                              style: TextStyle(
                                color: isToday
                                    ? WidgetColors.textActive
                                    : WidgetColors.textCalLetter,
                                fontSize: calLetterSize,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
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
