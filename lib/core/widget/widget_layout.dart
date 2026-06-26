import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// Widget background for home screen PNG.
/// Glassmorphism style matching iOS reference:
///   - Glass texture background
///   - Time large + bold, centered-left
///   - Date + day name to the right of time
///   - Calendar strip with rounded glass cards
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

            // Layout metrics — matching reference proportions
            final edgePad = w * 0.04;

            // Zone A: time — large, bold, top-left area
            final timeSize = h * 0.38;
            final timeTop = h * 0.08;

            // Zone B: date — to the right of time, vertically centered
            final dateFontSize = w * 0.038;
            final dayNameSize = w * 0.032;
            final dateLeft = w * 0.64;

            // Zone C: calendar cards — bottom row, prominent
            final calNumSize = w * 0.04;
            final calLetterSize = w * 0.028;
            final cardH = h * 0.28;
            final cardRadius = w * 0.015;
            final calTop = h * 0.68;

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

                // Dark overlay for text readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: WidgetColors.background.withValues(alpha: 0.55),
                    ),
                  ),
                ),

                // Top highlight line — glass reflection
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

                // Zone B: Date + day name — right of time
                Positioned(
                  top: timeTop + timeSize * 0.35,
                  left: dateLeft,
                  right: edgePad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy', locale).format(now),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: dateFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE', locale).format(now),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
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
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(cardRadius),
                            border: Border.all(
                              color: isToday
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.12),
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
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.9),
                                  fontSize: calNumSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                shortLabels[i],
                                style: TextStyle(
                                  color: isToday
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Colors.white.withValues(alpha: 0.5),
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
            );
          },
        ),
      ),
    );
  }
}
