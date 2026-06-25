import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/features/clock/presentation/controllers/clock_controller.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/analog_clock_face.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/digital_time_display.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/weekdays_row.dart';

class ClockPage extends ConsumerWidget {
  const ClockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(clockProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      backgroundColor: Colors.black,
      body: _ClockContent(time: time, locale: locale),
    );
  }
}

class _ClockContent extends StatelessWidget {
  const _ClockContent({required this.time, required this.locale});

  final DateTime time;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final bottom = MediaQuery.of(context).padding.bottom;

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
                          child: AnalogClockFace(time: time, locale: locale),
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
                    WeekdaysRow(
                      currentDay: time.weekday,
                      locale: locale,
                    ).animate().fadeIn(
                      duration: 400.ms,
                      delay: 300.ms,
                      curve: Curves.easeOut,
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      AppDateUtils.formatFullDate(time, locale),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textDim,
                      ),
                    ).animate().fadeIn(
                      duration: 400.ms,
                      delay: 400.ms,
                      curve: Curves.easeOut,
                    ),
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
