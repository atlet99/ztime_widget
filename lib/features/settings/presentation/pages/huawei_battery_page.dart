import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ztime_widget/core/app_constants.dart';
import 'package:ztime_widget/core/constants/android_constants.dart';
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
        padding: EdgeInsets.all(24.r),
        children: [
          // Language selector
          Text(
            context.t.language,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
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
          SizedBox(height: 24.h),
          const Divider(color: Colors.white12),
          SizedBox(height: 16.h),
          // Widget glass style
          Text(
            context.t.widgetBgStyle,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.t.chooseGlassTexture,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textDim),
          ),
          SizedBox(height: 16.h),
          ...GlassStyle.values.map((style) {
            final isSelected = currentStyle == style;
            final label = _glassLabel(context, style);
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GestureDetector(
                onTap: () =>
                    ref.read(glassStyleProvider.notifier).setStyle(style),
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
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
                      borderRadius: BorderRadius.circular(16.r),
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.3),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.accent,
                            size: 22.r,
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 22.r,
                          ),
                        SizedBox(width: 12.w),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16.sp,
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
          SizedBox(height: 32.h),
          const Divider(color: Colors.white12),
          SizedBox(height: 16.h),
          Text(
            context.t.batteryOptimization,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.t.batteryOptDesc,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textDim,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _openBatterySettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                context.t.openBatterySettings,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          const Divider(color: Colors.white12),
          SizedBox(height: 16.h),
          // About
          Text(
            context.t.about,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.t.aboutDesc,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textDim),
          ),
          SizedBox(height: 12.h),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '';
              return Text(
                context.t.version(version: version),
                style: TextStyle(fontSize: 13.sp, color: AppColors.textDim),
              );
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton(
              onPressed: () => launchUrl(Uri.parse(AppConstants.githubUrl)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.code, size: 18.r),
                  SizedBox(width: 8.w),
                  Text(context.t.viewOnGithub),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
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
      padding: EdgeInsets.only(bottom: 8.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
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
                Icon(Icons.check_circle, color: AppColors.accent, size: 20.r)
              else
                Icon(
                  Icons.circle_outlined,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 20.r,
                ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
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
      action: AndroidConstants.batterySettingsAction,
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
