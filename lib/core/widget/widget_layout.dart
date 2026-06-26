import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// Widget background for home screen PNG.
/// Glassmorphism style matching iOS reference:
///   Zone A (top-left): Glass panel + bold time digits
///   Zone B (top-right): Date + day name (bold)
///   Zone C (bottom): Calendar strip with rounded glass cards
class WidgetLayout extends StatelessWidget {
  const WidgetLayout({super.key, required this.renderKey});

  final GlobalKey renderKey;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
    final today = now.weekday - 1;
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return RepaintBoundary(
      key: renderKey,
      child: SizedBox(
        width: WidgetDimensions.width,
        height: WidgetDimensions.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // Layout metrics
            final edgePad = w * 0.04;
            final topPad = h * 0.08;

            // Zone A: time
            final timePanelW = w * 0.55;
            final timePanelH = h * 0.52;

            // Zone B: date
            final dateFontSize = w * 0.04;
            final dayNameSize = w * 0.036;

            // Zone C: calendar cards
            final calNumSize = w * 0.036;
            final calLetterSize = w * 0.026;
            final cardH = h * 0.18;
            final cardRadius = w * 0.012;
            final calTop = h * 0.72;

            return Container(
              color: WidgetColors.background,
              child: Stack(
                children: [
                  // Zone A: Frosted glass panel behind time
                  Positioned(
                    top: topPad - h * 0.02,
                    left: edgePad - w * 0.01,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(w * 0.02),
                      child: Container(
                        width: timePanelW,
                        height: timePanelH,
                        decoration: BoxDecoration(
                          color: WidgetColors.glassPanel,
                          borderRadius: BorderRadius.circular(w * 0.02),
                          border: Border.all(
                            color: WidgetColors.glassBorder,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Zone B: Date top-right
                  Positioned(
                    top: topPad + h * 0.06,
                    right: edgePad,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy', locale).format(now),
                          style: TextStyle(
                            color: WidgetColors.textDate,
                            fontSize: dateFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE', locale).format(now),
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
                    top: calTop,
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
                            width: (w - edgePad * 2) / 7 - 6,
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
        ),
      ),
    );
  }
}
