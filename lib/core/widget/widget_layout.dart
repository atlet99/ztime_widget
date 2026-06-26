import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// Widget background for home screen PNG.
/// Time is rendered by native Android TextClock — PNG only has date + calendar.
class WidgetLayout extends StatelessWidget {
  const WidgetLayout({
    super.key,
    required this.renderKey,
    this.glassStyle = GlassStyle.coldGlass,
  });

  final GlobalKey renderKey;
  final GlassStyle glassStyle;

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

            final safePadX = w * 0.065;
            final safePadY = h * 0.055;
            final contentW = w - safePadX * 2;

            // Date typography
            final dateFontSize = contentW * 0.065;
            final dayNameSize = contentW * 0.045;

            // Calendar strip — tight to time, minimal gap
            final calHeight = h * 0.32;
            final calNumSize = contentW * 0.063; // +20% bigger numbers
            final calLetterSize = contentW * 0.030;
            final calCardRadius = 12.0;
            final pillRadius = 8.0;
            final cellPad = 9.0;

            // Date aligned with TextClock baseline — slightly lower
            final dateTop = h * 0.18;

            return Stack(
              children: [
                // Glass texture background
                Positioned.fill(
                  child: Image.asset(
                    glassStyle.widgetPath,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),

                // Dark overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x8C1C1C1E),
                    ),
                  ),
                ),

                // Top highlight line
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.5,
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

                // Date — shifted 10% left
                Positioned(
                  top: dateTop,
                  right: safePadX + w * 0.05,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy', locale).format(now),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: dateFontSize,
                          fontWeight: FontWeight.w400,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE', locale).format(now),
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

                // Calendar strip — bottom, tight to time area
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
                                color: const Color(0x1A2C2C2E),
                                borderRadius:
                                    BorderRadius.circular(calCardRadius),
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
                                              borderRadius:
                                                  BorderRadius.circular(pillRadius),
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
                                            color: Colors.white
                                                .withValues(alpha: 0.55),
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
                                          : Colors.white
                                              .withValues(alpha: 0.35),
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
            );
          },
        ),
      ),
    );
  }
}
