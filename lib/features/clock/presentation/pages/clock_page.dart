import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/glass_style.dart';
import 'package:ztime_widget/core/widget/widget_png_renderer.dart';
import 'package:ztime_widget/features/calendar/presentation/pages/calendar_page.dart';
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

  void _forceWidgetRender(String date, String locale, String glass) {
    _lastRenderDate = date;
    _lastRenderLocale = locale;
    _lastRenderGlass = glass;
    WidgetPngRenderer.render();
  }

  @override
  Widget build(BuildContext context) {
    // select() — ClockPage only rebuilds when the DATE changes, not every second
    final dateStr = ref.watch(
      clockSecondsProvider.select((t) => '${t.year}-${t.month}-${t.day}'),
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    final glassStyle = ref.watch(glassStyleProvider);

    final currentGlass = glassStyle.assetKey;
    if (dateStr != _lastRenderDate ||
        locale != _lastRenderLocale ||
        currentGlass != _lastRenderGlass) {
      _forceWidgetRender(dateStr, locale, currentGlass);
    }

    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Consumer — only this subtree rebuilds every second
          Consumer(
            builder: (context, ref, _) {
              final time = ref.watch(clockSecondsProvider);
              final timeLabel = AppDateUtils.formatTime(time, locale);
              return Semantics(
                label: context.t.timeCurrent(time: timeLabel),
                liveRegion: true,
                excludeSemantics: true,
                child: ClockFace(
                  time: time,
                  locale: locale,
                  glassStyle: glassStyle,
                ),
              );
            },
          ),

          // Settings button — does NOT rebuild every second
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

          // Calendar button
          Positioned(
            top: padding.top + 12.h,
            right: padding.right + 16.w,
            child: IconButton(
              icon: Icon(
                Icons.calendar_month,
                color: AppColors.textDim,
                size: 22.r,
              ),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const CalendarPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
