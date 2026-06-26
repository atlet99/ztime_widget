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
  int _lastRenderMinute = -1;

  void _scheduleWidgetRender() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boundary =
          _widgetKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      WidgetRenderer.renderFrom(boundary);
    });
  }

  @override
  Widget build(BuildContext context) {
    final time = ref.watch(clockSecondsProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timeLabel = AppDateUtils.formatTime(time, locale);

    final currentMinute = time.minute;
    if (currentMinute != _lastRenderMinute) {
      _lastRenderMinute = currentMinute;
      _scheduleWidgetRender();
    }

    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Screen A: In-app clock face (full-screen, adaptive, dynamic time)
          Semantics(
            label: 'Текущее время: $timeLabel',
            liveRegion: true,
            excludeSemantics: true,
            child: ClockFace(time: time, locale: locale),
          ),

          // Settings button
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

          // Screen B: Widget layout (invisible, only used for PNG rendering)
          // Visibility with maintainSize keeps it laid out but invisible,
          // so RepaintBoundary can still capture it to PNG.
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
