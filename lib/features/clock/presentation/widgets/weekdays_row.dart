import 'package:flutter/material.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';

class WeekdaysRow extends StatelessWidget {
  const WeekdaysRow({
    super.key,
    required this.currentDay,
    required this.locale,
  });

  final int currentDay;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final labels = AppDateUtils.getWeekdayLabels(locale);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) {
        final isToday = i == currentDay - 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            labels[i],
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? AppColors.accent : AppColors.textDim,
            ),
          ),
        );
      }),
    );
  }
}
