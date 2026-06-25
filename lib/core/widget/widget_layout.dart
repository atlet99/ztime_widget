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
    final labels = AppDateUtils.getWeekdayLabelsShort(locale);
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

            final hPad = w * WidgetDimensions.hPad;
            final vPad = h * WidgetDimensions.vPad;
            final dateFontSize = w * WidgetDimensions.dateFontScale;
            final dayNumSize = w * WidgetDimensions.dayNumFontScale;
            final dayAxisSize = w * WidgetDimensions.dayAxisFontScale;
            final panelPad = w * WidgetDimensions.panelPaddingScale;
            final panelRad = w * WidgetDimensions.panelRadiusScale;

            return Container(
              color: WidgetColors.background,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${DateFormat('dd/MM/yyyy', locale).format(now)}\n${DateFormat('EEEE', locale).format(now)}',
                      style: TextStyle(
                        color: WidgetColors.textDate,
                        fontSize: dateFontSize,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const Spacer(),
                    // Empty slot for native Android TextClock
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.all(panelPad),
                      decoration: BoxDecoration(
                        color: WidgetColors.panel,
                        borderRadius: BorderRadius.circular(panelRad),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(7, (i) {
                          final dayNum = monday.add(Duration(days: i)).day;
                          final isToday = i == today;
                          final color = isToday
                              ? WidgetColors.textWhite
                              : WidgetColors.textGray;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dayNum.toString(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: dayNumSize,
                                  fontWeight: isToday
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: dayAxisSize * 0.3),
                              Text(
                                labels[i],
                                style: TextStyle(
                                  color: color,
                                  fontSize: dayAxisSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }),
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
