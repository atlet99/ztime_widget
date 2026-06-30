import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ztime_widget/core/app_constants.dart';
import 'package:ztime_widget/core/constants/android_constants.dart';
import 'package:ztime_widget/core/constants/pref_keys.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/i18n/strings.g.dart';

/// Settings page — 100% layout-based sizing.
/// On tablets, content is constrained to max 600px width.
class HuaweiBatteryPage extends ConsumerStatefulWidget {
  const HuaweiBatteryPage({super.key});

  @override
  ConsumerState<HuaweiBatteryPage> createState() => _HuaweiBatteryPageState();
}

class _HuaweiBatteryPageState extends ConsumerState<HuaweiBatteryPage> {
  String? _installerStore;
  bool _pinSupported = false;

  @override
  void initState() {
    super.initState();
    _loadInstallerInfo();
  }

  Future<void> _loadInstallerInfo() async {
    final info = await PackageInfo.fromPlatform();
    final supported = await HomeWidget.isRequestPinWidgetSupported();
    if (mounted) {
      setState(() {
        _installerStore = info.installerStore;
        _pinSupported = supported ?? false;
      });
    }
  }

  bool get _isHuaweiInstall => _installerStore == 'com.huawei.appmarket';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final contentW = w > 600 ? 600.0 : w;
          final padX = w * 0.06;

          // Font sizes as percentage of content width
          const sectionTitlePct = 0.05;
          const bodyTextPct = 0.035;
          const smallTextPct = 0.032;
          const iconPct = 0.05;
          final sectionTitle = contentW * sectionTitlePct;
          final bodyText = contentW * bodyTextPct;
          final smallText = contentW * smallTextPct;
          final iconSize = contentW * iconPct;
          const btnHeight = 48.0;
          const glassCardH = 72.0;
          const borderRadius = 12.0;
          const gap = 12.0;
          const bigGap = 24.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: padX, vertical: 16),
                children: [
                  // ── Language ──
                  Text(
                    context.t.language,
                    style: TextStyle(
                      fontSize: sectionTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: gap),
                  _buildLocaleOption(
                    context,
                    bodyText: bodyText,
                    iconSize: iconSize,
                    borderRadius: borderRadius,
                    label: context.t.langSystem,
                    isSelected: false,
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
                      bodyText: bodyText,
                      iconSize: iconSize,
                      borderRadius: borderRadius,
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
                  const SizedBox(height: bigGap),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: gap),

                  // ── Widget glass style ──
                  Text(
                    context.t.widgetBgStyle,
                    style: TextStyle(
                      fontSize: sectionTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.t.chooseGlassTexture,
                    style: TextStyle(
                      fontSize: smallText,
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: gap),
                  ...GlassStyle.values.map((style) {
                    final isSelected = currentStyle == style;
                    final label = _glassLabel(context, style);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(glassStyleProvider.notifier)
                            .setStyle(style),
                        child: Container(
                          height: glassCardH,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
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
                              borderRadius: BorderRadius.circular(borderRadius),
                              color: isSelected
                                  ? AppColors.accent.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.3),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: padX * 0.6,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? AppColors.accent
                                      : Colors.white.withValues(alpha: 0.3),
                                  size: iconSize,
                                ),
                                const SizedBox(width: gap),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: bodyText,
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
                  const SizedBox(height: bigGap),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: gap),

                  // ── Add widget ──
                  if (_pinSupported) ...[
                    Text(
                      context.t.addWidget,
                      style: TextStyle(
                        fontSize: sectionTitle,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.t.addWidgetDesc,
                      style: TextStyle(
                        fontSize: smallText,
                        color: AppColors.textDim,
                      ),
                    ),
                    const SizedBox(height: gap),
                    _buildActionButton(
                      label: context.t.addWidget,
                      fontSize: bodyText,
                      height: btnHeight,
                      borderRadius: borderRadius,
                      onPressed: () => HomeWidget.requestPinWidget(
                        qualifiedAndroidName: AndroidConstants.widgetProvider,
                      ),
                    ),
                    const SizedBox(height: bigGap),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: gap),
                  ],

                  // ── Battery optimization ──
                  Text(
                    context.t.batteryOptimization,
                    style: TextStyle(
                      fontSize: sectionTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isHuaweiInstall
                        ? context.t.batteryOptDesc
                        : context.t.batteryOptDescGeneric,
                    style: TextStyle(
                      fontSize: smallText,
                      color: AppColors.textDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: gap),
                  _buildActionButton(
                    label: context.t.openBatterySettings,
                    fontSize: bodyText,
                    height: btnHeight,
                    borderRadius: borderRadius,
                    onPressed: _openBatterySettings,
                  ),
                  const SizedBox(height: bigGap),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: gap),

                  // ── About ──
                  Text(
                    context.t.about,
                    style: TextStyle(
                      fontSize: sectionTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.t.aboutDesc,
                    style: TextStyle(
                      fontSize: smallText,
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? '';
                      return Text(
                        context.t.version(version: version),
                        style: TextStyle(
                          fontSize: smallText,
                          color: AppColors.textDim,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: gap),
                  _buildOutlineButton(
                    label: context.t.viewOnGithub,
                    fontSize: bodyText,
                    height: btnHeight,
                    borderRadius: borderRadius,
                    onPressed: () =>
                        launchUrl(Uri.parse(AppConstants.githubUrl)),
                  ),
                  const SizedBox(height: bigGap),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Locale option ──

  Widget _buildLocaleOption(
    BuildContext context, {
    required double bodyText,
    required double iconSize,
    required double borderRadius,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
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
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? AppColors.accent
                    : Colors.white.withValues(alpha: 0.3),
                size: iconSize,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: bodyText,
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

  // ── Primary action button ──

  Widget _buildActionButton({
    required String label,
    required double fontSize,
    required double height,
    required double borderRadius,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── Outline button ──

  Widget _buildOutlineButton({
    required String label,
    required double fontSize,
    required double height,
    required double borderRadius,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, size: fontSize),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: fontSize)),
          ],
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
