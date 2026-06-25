import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';

class HuaweiBatteryPage extends StatelessWidget {
  const HuaweiBatteryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Настройки батареи'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.battery_saver, size: 48, color: AppColors.accent),
            const SizedBox(height: 16),
            const Text(
              'Оптимизация батареи',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Для корректной работы виджета на Huawei Nova 5T '
              'необходимо отключить оптимизацию батареи для ZTime.\n\n'
              'Иначе система убьёт обновления виджета через ~5 минут.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textDim,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Шаг 1: Открыть настройки батареи',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Battery → App launch → ZTime → выключить автозапуск\n'
              'и ручное управление → отключить все ограничения',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textDim,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Шаг 2: Дополнительные настройки',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Settings → Battery → App launch → ZTime\n'
              '→ "Run manually" → disable all restrictions',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textDim,
                height: 1.5,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _openBatterySettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Открыть настройки батареи',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBatterySettings() {
    const intent = AndroidIntent(
      action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch().catchError((_) {});
  }
}
