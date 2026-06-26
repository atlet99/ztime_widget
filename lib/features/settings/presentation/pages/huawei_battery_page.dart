import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';

class HuaweiBatteryPage extends ConsumerStatefulWidget {
  const HuaweiBatteryPage({super.key});

  @override
  ConsumerState<HuaweiBatteryPage> createState() => _HuaweiBatteryPageState();
}

class _HuaweiBatteryPageState extends ConsumerState<HuaweiBatteryPage> {
  @override
  void initState() {
    super.initState();
    ref.read(glassStyleProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final currentStyle = ref.watch(glassStyleProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Стиль фона виджета',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Выберите текстуру стекла для фона виджета',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDim,
            ),
          ),
          const SizedBox(height: 16),
          ...GlassStyle.values.map((style) {
            final isSelected = currentStyle == style;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => ref.read(glassStyleProvider.notifier).setStyle(style),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.15),
                      width: isSelected ? 2.5 : 1.0,
                    ),
                    image: DecorationImage(
                      image: AssetImage(style.widgetPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: AppColors.accent, size: 22)
                        else
                          Icon(Icons.circle_outlined,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 22),
                        const SizedBox(width: 12),
                        Text(
                          style.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          const Text(
            'Оптимизация батареи',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Для корректной работы виджета на Huawei Nova 5T '
            'необходимо отключить оптимизацию батареи для ZTime.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDim,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBatterySettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    try {
      final canResolve = await intent.canResolveActivity();
      if (canResolve == true) {
        await intent.launch();
      }
    } on Exception catch (_) {}
  }
}
