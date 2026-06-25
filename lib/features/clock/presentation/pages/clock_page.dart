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
    final timeAsync = ref.watch(currentTimeProvider);

    return Scaffold(
      body: SafeArea(
        child: timeAsync.when(
          data: (time) => _ClockContent(time: time),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) => Center(
            child: Text(
              'Ошибка: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClockContent extends StatelessWidget {
  const _ClockContent({required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clockSize = constraints.maxWidth * 0.75;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Center(
                    child: RepaintBoundary(
                      child: SizedBox(
                        width: clockSize,
                        height: clockSize,
                        child: AnalogClockFace(time: time),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 16),
                  WeekdaysRow(currentDay: time.weekday).animate().fadeIn(
                    duration: 400.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppDateUtils.formatFullDate(time),
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
        );
      },
    );
  }
}
