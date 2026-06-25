import 'package:flutter/material.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';

class DigitalTimeDisplay extends StatelessWidget {
  const DigitalTimeDisplay({super.key, required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final now = AppDateUtils.formatTime(time);
    final parts = now.split(':');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          parts[0],
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w200,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        Text(
          parts[1],
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
