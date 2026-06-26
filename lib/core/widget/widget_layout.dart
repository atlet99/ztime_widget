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
            final bottomRowSize = w * 0.03;
            final bottomDateSize = w * 0.028;

            return Container(
              color: WidgetColors.background,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 1. Top-right date
                    Text(
                      '${DateFormat('dd/MM/yyyy', locale).format(now)}\n${DateFormat('EEEE', locale).format(now)}',
                      style: TextStyle(
                        color: WidgetColors.textDate,
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dayNum.toString(),
                                style: TextStyle(
                                  color: isToday
                                      ? WidgetColors.background
                                      : WidgetColors.textWhite,
                                  fontSize: calNumSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: calDaySize * 0.2),
                              Text(
                                shortLabels[i],
                                style: TextStyle(
                                  color: isToday
                                      ? WidgetColors.background
                                      : WidgetColors.textWhite70,
                                  fontSize: calDaySize,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    // 3. Empty slot for native TextClock
                    const Spacer(flex: 2),
                    const Spacer(flex: 3),

                    // 4. Bottom weekday abbreviations
                    Text(
                      shortLabels.join('  '),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WidgetColors.textWhite70,
                        fontSize: bottomRowSize,
                        letterSpacing: 2.0,
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    // 5. Full date
                    Text(
                      DateFormat('d MMMM yyyy г. (EEEE)', locale).format(now),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WidgetColors.textDim,
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
