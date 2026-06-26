import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

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

            final hPad = w * 0.05;
            final vPad = h * 0.05;
            final topDateSize = w * 0.035;
            final calNumSize = w * 0.035;
            final calDaySize = w * 0.025;
            final calPillW = calNumSize * 2.2;
            final calPillH = calNumSize * 1.8;
            final bottomRowSize = w * 0.03;
            final bottomDateSize = w * 0.028;

            return Container(
              color: WidgetColors.background,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 1. Top-right date (0.85 alpha)
                    Text(
                      '${DateFormat('dd/MM/yyyy', locale).format(now)}\n${DateFormat('EEEE', locale).format(now)}',
                      style: TextStyle(
                        color: WidgetColors.textActive,
                        fontSize: topDateSize,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.right,
                    ),

                    SizedBox(height: h * 0.06),

                    // 2. Mini-calendar (center)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (i) {
                        final dayNum = monday.add(Duration(days: i)).day;
                        final isToday = i == today;
                        return SizedBox(
                          width: calPillW * 1.4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Number with pill highlight for today
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

                    // 3. Empty zone for native TextClock
                    // Optical center: top spacer smaller, bottom larger
                    // Shifts empty zone ~3% above mathematical center
                    const Spacer(flex: 3),
                    const Spacer(flex: 4),

                    // 4. Bottom weekday abbreviations (0.40 alpha)
                    Text(
                      shortLabels.join('  '),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WidgetColors.textRow,
                        fontSize: bottomRowSize,
                        letterSpacing: 2.0,
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    // 5. Full date (0.30 alpha)
                    Text(
                      DateFormat('d MMMM yyyy г. (EEEE)', locale).format(now),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WidgetColors.textFullDate,
                        fontSize: bottomDateSize,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
