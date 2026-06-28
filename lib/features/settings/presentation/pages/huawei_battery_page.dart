import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ztime_widget/core/app_constants.dart';
import 'package:ztime_widget/core/constants/pref_keys.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/i18n/strings.g.dart';

class HuaweiBatteryPage extends ConsumerStatefulWidget {
  const HuaweiBatteryPage({super.key});

  @override
  ConsumerState<HuaweiBatteryPage> createState() => _HuaweiBatteryPageState();
}

class _HuaweiBatteryPageState extends ConsumerState<HuaweiBatteryPage> {
  String _glassLabel(BuildContext context, GlassStyle style) {
    switch (style) {
      case GlassStyle.coldGlass:
        return context.t.coldGlass;
      case GlassStyle.icyBlue:
        return context.t.icyBlue;
      case GlassStyle.warmMilk:
        return context.t.warmMilk;
    }
  }

  String _localeLabel(BuildContext context, AppLocale locale) {
    switch (locale) {
      case AppLocale.ru:
        return context.t.langRu;
      case AppLocale.en:
        return context.t.langEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStyle = ref.watch(glassStyleProvider);
    final currentLocale = LocaleSettings.currentLocale;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.textPrimary,
        title: Text(context.t.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Language selector
          Text(
            context.t.language,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // "System" option (useDeviceLocale)
          _buildLocaleOption(
            context,
            label: context.t.langSystem,
            isSelected: false, // system is not a saved AppLocale
            onTap: () async {
              await LocaleSettings.useDeviceLocale();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(PrefKeys.appLocale, 0);
            },
          ),
          ...AppLocale.values.map((locale) {
            final isSelected = locale == currentLocale;
            final label = _localeLabel(context, locale);
            return _buildLocaleOption(
              context,
              label: label,
              isSelected: isSelected,
              onTap: () async {
                await LocaleSettings.setLocale(locale);
                final index = AppLocale.values.indexOf(locale);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt(PrefKeys.appLocale, index + 1);
              },
            );
          }),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          // Widget glass style
          Text(
            context.t.widgetBgStyle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t.chooseGlassTexture,
            style: const TextStyle(fontSize: 13, color: AppColors.textDim),
          ),
          const SizedBox(height: 16),
          ...GlassStyle.values.map((style) {
            final isSelected = currentStyle == style;
            final label = _glassLabel(context, style);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () =>
                    ref.read(glassStyleProvider.notifier).setStyle(style),
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
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.accent,
                            size: 22,
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 22,
                          ),
                        const SizedBox(width: 12),
                        Text(
                          label,
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
          Text(
            context.t.batteryOptimization,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t.batteryOptDesc,
            style: const TextStyle(
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
              child: Text(
                context.t.openBatterySettings,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          // About
          Text(
            context.t.about,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t.aboutDesc,
            style: const TextStyle(fontSize: 13, color: AppColors.textDim),
          ),
          const SizedBox(height: 12),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '';
              return Text(
                context.t.version(version: version),
                style: const TextStyle(fontSize: 13, color: AppColors.textDim),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => launchUrl(Uri.parse(AppConstants.githubUrl)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.code, size: 18),
                  const SizedBox(width: 8),
                  Text(context.t.viewOnGithub),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLocaleOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                  size: 20,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 20,
                ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
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
