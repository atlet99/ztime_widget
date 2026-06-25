import 'package:flutter/material.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';

class DigitalTimeDisplay extends StatelessWidget {
  const DigitalTimeDisplay({super.key, required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');

    const digitStyle = TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.w200,
      color: AppColors.textPrimary,
      letterSpacing: 2,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(hours, style: digitStyle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ':',
              style: digitStyle.copyWith(color: AppColors.textDim),
            ),
          ),
          Text(minutes, style: digitStyle),
        ],
      ),
    );
  }
}
