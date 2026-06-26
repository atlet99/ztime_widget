import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_constants.dart';

/// In-app full-screen clock face.
/// Glassmorphism style matching the widget design:
///   - Glass texture background
///   - Time large + bold, centered
///   - Date + day name to the right
///   - Calendar strip with rounded glass cards
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

        // Center content horizontally with max width
        final maxW = w < 480 ? w : 480.0;
        final sidePad = (w - maxW) / 2;
        final edgePad = maxW * 0.04;
        final topPad = padding.top + 16.0;

        // Zone A: time — large, bold, centered
        final timeSize = maxW * 0.22;

        // Zone B: date — right of time
        final dateFontSize = maxW * 0.042;
        final dayNameSize = maxW * 0.036;
        final dateLeft = maxW * 0.62;

        // Zone C: calendar cards
        final calNumSize = maxW * 0.04;
        final calLetterSize = maxW * 0.028;
        final cardH = h * 0.18;
        final cardRadius = maxW * 0.015;
        final calTop = h * 0.72;

        final shortLabels = AppDateUtils.getWeekdayLabelsShort(locale);
        final today = time.weekday - 1;
        final monday = time.subtract(Duration(days: time.weekday - 1));

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePad),
          child: Stack(
            children: [
              // Glass texture background
              Positioned.fill(
                child: Image.asset(
                  glassStyle.appPath,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),

              // Dark overlay for readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: WidgetColors.background.withValues(alpha: 0.55),
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

              // Zone A: Time — bold, centered-left
              Positioned(
                top: topPad,
                left: edgePad,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: timeSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),

              // Zone B: Date — right of time, vertically centered
              Positioned(
                top: topPad + timeSize * 0.25,
                left: sidePad + dateLeft,
                right: edgePad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy', locale).format(time),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE', locale).format(time),
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
                        width: (maxW - edgePad * 2) / 7 - 6,
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
          ),
        );
      },
    );
  }
}
