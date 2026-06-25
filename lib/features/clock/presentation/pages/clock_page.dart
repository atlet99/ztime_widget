import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_layout.dart';
import 'package:ztime_widget/core/widget/widget_renderer.dart';
import 'package:ztime_widget/features/clock/presentation/controllers/clock_controller.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/analog_clock_face.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/digital_time_display.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/weekdays_row.dart';

class ClockPage extends ConsumerStatefulWidget {
  const ClockPage({super.key});

  @override
  ConsumerState<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends ConsumerState<ClockPage> {
  final _widgetKey = GlobalKey();
  int _lastRenderMinute = -1;

  void _scheduleWidgetRender() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boundary = _widgetKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      WidgetRenderer.renderFrom(boundary);
    });
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(clockSecondsProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final timeLabel = AppDateUtils.formatTime(time, locale);

    // Only render widget PNG when the minute actually changes (~1x/min)
    final currentMinute = time.minute;
    if (currentMinute != _lastRenderMinute) {
      _lastRenderMinute = currentMinute;
      _scheduleWidgetRender();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Semantics(
            label: 'Текущее время: $timeLabel',
            liveRegion: true,
            excludeSemantics: true,
            child: _ClockContent(
              time: time,
              locale: locale,
            ),
          ),
          Offstage(
            offstage: false,
            child: WidgetLayout(renderKey: _widgetKey),
          ),
        ],
      ),
    );
  }
}

class _ClockContent extends StatelessWidget {
  const _ClockContent({
    required this.time,
    required this.locale,
  });

  final DateTime time;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final bottom = MediaQuery.of(context).padding.bottom;
        final textScaler = MediaQuery.textScalerOf(context);

        final clockSize = math.min(width * 0.78, height * 0.55);

        return Padding(
          padding: EdgeInsets.only(bottom: bottom + 16),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Center(
                      child: RepaintBoundary(
                        child: SizedBox(
                          width: clockSize,
                          height: clockSize,
                          child: AnalogClockFace(
                            time: time,
                            locale: locale,
                            textScaler: textScaler,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut),
                    SizedBox(height: height * 0.03),
                    DigitalTimeDisplay(time: time)
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: 150.ms,
                          curve: Curves.easeOut,
                        )
                        .slideY(
                          begin: -0.05,
                          duration: 400.ms,
                          delay: 150.ms,
                          curve: Curves.easeOut,
                        ),
                    SizedBox(height: height * 0.015),
                    // These two watch clockMinutesProvider (~1x/min rebuild)
                    const _DateSection(),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Separate widget that watches clockMinutesProvider.
/// Only rebuilds ~1x/min instead of ~1x/sec.
class _DateSection extends ConsumerWidget {
  const _DateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minuteTime = ref.watch(clockMinutesProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final textScaler = MediaQuery.textScalerOf(context);
    final clampedScaler = textScaler.clamp(maxScaleFactor: 1.4);

    return Column(
      children: [
        WeekdaysRow(
          currentDay: minuteTime.weekday,
          locale: locale,
        ).animate().fadeIn(
          duration: 400.ms,
          delay: 300.ms,
          curve: Curves.easeOut,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          AppDateUtils.formatFullDate(minuteTime, locale),
          textScaler: clampedScaler,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textDim,
          ),
        ).animate().fadeIn(
          duration: 400.ms,
          delay: 400.ms,
          curve: Curves.easeOut,
        ),
      ],
    );
  }
}
