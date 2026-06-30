import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_png_renderer.dart';
import 'package:ztime_widget/features/clock/presentation/controllers/clock_controller.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/clock_face.dart';
import 'package:ztime_widget/features/settings/presentation/pages/huawei_battery_page.dart';
import 'package:ztime_widget/i18n/strings.g.dart';

class ClockPage extends ConsumerStatefulWidget {
  const ClockPage({super.key});

  @override
  ConsumerState<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends ConsumerState<ClockPage> {
  String _lastRenderDate = '';
  String _lastRenderLocale = '';
  String _lastRenderGlass = '';

  @override
  void initState() {
    super.initState();
    ref.read(glassStyleProvider.notifier).load();
  }

  void _forceWidgetRender(String date, String locale, String glass) {
    _lastRenderDate = date;
    _lastRenderLocale = locale;
    _lastRenderGlass = glass;
    WidgetPngRenderer.render();
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(clockSecondsProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final glassStyle = ref.watch(glassStyleProvider);
    final timeLabel = AppDateUtils.formatTime(time, locale);

    final currentDate = '${time.year}-${time.month}-${time.day}';
    final currentGlass = glassStyle.assetKey;
    if (currentDate != _lastRenderDate ||
        locale != _lastRenderLocale ||
        currentGlass != _lastRenderGlass) {
      _forceWidgetRender(currentDate, locale, currentGlass);
    }

    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Semantics(
            label: context.t.timeCurrent(time: timeLabel),
            liveRegion: true,
            excludeSemantics: true,
            child: ClockFace(
              time: time,
              locale: locale,
              glassStyle: glassStyle,
            ),
          ),

          // Settings button
          Positioned(
            top: padding.top + 12.h,
            left: padding.left + 16.w,
            child: IconButton(
              icon: Icon(Icons.settings, color: AppColors.textDim, size: 22.r),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const HuaweiBatteryPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
