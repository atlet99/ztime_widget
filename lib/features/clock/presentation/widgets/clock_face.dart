import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// In-app full-screen clock face.
/// Apple-style 3-zone hard-anchor layout.
///   Top bar:    Time (Thin, w100) + Date (Regular, w400), baseline-aligned
///   Spring:     Empty space (~45-50% height)
///   Bottom bar: Calendar strip, fixed height, anchored to bottom
///   Safe area:  6.5% horizontal, 5.5% vertical
class ClockFace extends StatelessWidget {
  const ClockFace({
    super.key,
    required this.time,
    required this.locale,
    this.glassStyle = GlassStyle.coldGlass,
  });

  final DateTime time;
  final String locale;
  final GlassStyle glassStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final padding = MediaQuery.of(context).padding;

        // Center content for tablets
        final maxW = w < 480 ? w : 480.0;
        final sidePad = (w - maxW) / 2;

        // Rule 3: Safe area — 6.5% horizontal, 5.5% vertical
        final safePadX = maxW * 0.065;
        final safePadY = padding.top + 16.0;

        // Rule 1: Top bar
        final timeSize = maxW * 0.24;
        final dateFontSize = maxW * 0.036;
        final dayNameSize = maxW * 0.030;

        // Rule 2: Calendar strip — fixed height
        final calHeight = h * 0.15;
        final calNumSize = maxW * 0.038;
        final calLetterSize = maxW * 0.026;
        const calCardRadius = 12.0;
        const pillRadius = 8.0;

        final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
        final today = time.weekday - 1;
        final monday = time.subtract(Duration(days: time.weekday - 1));

        return Stack(
          children: [
            // Glass texture background
            Positioned.fill(
              child: Image.asset(
                glassStyle.appPath,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),

            // Dark overlay
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0x8C1C1C1E)),
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

            // Rule 1: Top bar — Time + Date, baseline-aligned
            Positioned(
              top: safePadY,
              left: sidePad + safePadX,
              right: sidePad + safePadX,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Time — Thin/Ultralight, weight 100, letterSpacing 0.09
                  Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: timeSize,
                      fontWeight: FontWeight.w100,
                      letterSpacing: 0.09,
                      height: 0.85,
                    ),
                  ),

                  const Spacer(),

                  // Date — Regular weight 400, opacity 0.85
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy', locale).format(time),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: dateFontSize,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEEE', locale).format(time),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: dayNameSize,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Rule 2: Bottom bar — Calendar strip, fixed height, anchored bottom
            Positioned(
              bottom: safePadY,
              left: sidePad + safePadX,
              right: sidePad + safePadX,
              child: SizedBox(
                height: calHeight,
                child: Row(
                  children: List.generate(7, (i) {
                    final dayNum = monday.add(Duration(days: i)).day;
                    final isToday = i == today;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x1A2C2C2E),
                            borderRadius: BorderRadius.circular(calCardRadius),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Active day: pill with white bg + black text
                              isToday
                                  ? IntrinsicWidth(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            pillRadius,
                                          ),
                                        ),
                                        child: Text(
                                          dayNum.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: WidgetColors.textActive,
                                            fontSize: calNumSize,
                                            fontWeight: FontWeight.w500,
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      dayNum.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.55,
                                        ),
                                        fontSize: calNumSize,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                    ),
                              const SizedBox(height: 2),
                              // Day letters: opacity 0.35, Regular weight
                              Text(
                                shortLabels[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isToday
                                      ? Colors.white.withValues(alpha: 0.70)
                                      : Colors.white.withValues(alpha: 0.35),
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
    );
  }
}
