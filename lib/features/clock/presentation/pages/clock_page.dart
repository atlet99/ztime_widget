import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ztime_widget/core/utils/date_utils.dart';
import 'package:ztime_widget/core/widget/widget_layout.dart';
import 'package:ztime_widget/core/widget/widget_renderer.dart';
import 'package:ztime_widget/features/clock/presentation/controllers/clock_controller.dart';
import 'package:ztime_widget/features/clock/presentation/widgets/clock_face.dart';
import 'package:ztime_widget/features/settings/presentation/pages/huawei_battery_page.dart';

class ClockPage extends ConsumerStatefulWidget {
  const ClockPage({super.key});

  @override
  ConsumerState<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends ConsumerState<ClockPage> {
  final _widgetKey = GlobalKey();
  String _lastRenderDate = '';
  String _lastRenderLocale = '';

  void _scheduleWidgetRender() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boundary =
          _widgetKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      WidgetRenderer.renderFrom(boundary);
    });
  }

  /// Force re-render of widget PNG (called on resume when date/locale changed).
  void _forceWidgetRender(String date, String locale) {
    _lastRenderDate = date;
    _lastRenderLocale = locale;
    _scheduleWidgetRender();
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(clockSecondsProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timeLabel = AppDateUtils.formatTime(time, locale);

    // Use Case 2+3+4: Re-render widget if date or locale changed (midnight, timezone, language switch)
    final currentDate = '${time.year}-${time.month}-${time.day}';
    if (currentDate != _lastRenderDate || locale != _lastRenderLocale) {
      _forceWidgetRender(currentDate, locale);
    }

    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Semantics(
            label: 'Текущее время: $timeLabel',
            liveRegion: true,
            excludeSemantics: true,
            child: ClockFace(time: time, locale: locale),
          ),

          Positioned(
            top: top + 12,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Color(0x66FFFFFF),
                size: 22,
              ),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const HuaweiBatteryPage(),
                  ),
                );
              },
            ),
          ),

          // Widget layout (invisible, only used for PNG rendering)
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: WidgetLayout(renderKey: _widgetKey),
          ),
        ],
      ),
    );
  }
}
