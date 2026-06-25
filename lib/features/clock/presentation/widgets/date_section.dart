import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/features/clock/presentation/controllers/clock_controller.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/weekdays_row.dart';

/// Separate widget that watches clockMinutesProvider.
/// Only rebuilds ~1x/min instead of ~1x/sec.
class DateSection extends ConsumerWidget {
  const DateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minuteTime = ref.watch(clockMinutesProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      children: [
        WeekdaysRow(currentDay: minuteTime.weekday, locale: locale)
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms, curve: Curves.easeOut),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          AppDateUtils.formatFullDate(minuteTime, locale),
          style: const TextStyle(fontSize: 16, color: AppColors.textDim),
        ).animate().fadeIn(
          duration: 400.ms,
          delay: 400.ms,
          curve: Curves.easeOut,
        ),
      ],
    );
  }
}
