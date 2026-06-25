import 'package:flutter/material.dart';

class WeekdaysRow extends StatelessWidget {
  const WeekdaysRow({super.key, required this.currentDay});

  final int currentDay;

  static const _days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) {
        final isToday = i == currentDay - 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            _days[i],
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday
                  ? const Color(0xFF6C63FF)
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        );
      }),
    );
  }
}
