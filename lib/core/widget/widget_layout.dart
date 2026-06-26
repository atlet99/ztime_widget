import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// Widget background for home screen PNG.
/// 3-zone layout:
///   Zone A (top-left): EMPTY — TextClock overlays here via ConstraintLayout
///   Zone B (top-right): Date + day name
///   Zone C (bottom third): Calendar strip with pill highlight
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

            // Mirrored padding — same 5% that XML TextClock uses
            final edgePad = w * 0.05;
            final topPad = h * 0.08;

            // Zone B: date (top-right)
            final dateFontSize = w * 0.038;
            final dayNameSize = w * 0.032;

            // Zone C: calendar strip (bottom third)
            final calNumSize = w * 0.04;
            final calLetterSize = w * 0.028;
            final pillH = calNumSize * 2.0;
            final calTop = h * 0.62;

            return Container(
              color: WidgetColors.background,
              child: Stack(
                children: [
                  // Zone B: Date top-right
                  Positioned(
                    top: topPad,
                    right: edgePad,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy', locale).format(now),
                          style: TextStyle(
                            color: WidgetColors.textDate,
                            fontSize: dateFontSize,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE', locale).format(now),
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
                          final numColor = isToday
                              ? WidgetColors.background
                              : WidgetColors.textCalNum;
                          final letterColor = isToday
                              ? WidgetColors.background
                              : WidgetColors.textCalLetter;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pill for active day, plain text for others
                              isToday
                                  ? Container(
                                      height: pillH,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: WidgetColors.textActive,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
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
        ),
      ),
    );
  }
}
