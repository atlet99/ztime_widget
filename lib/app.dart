import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:ztime_widget/core/theme/app_theme.dart';
import 'package:ztime_widget/features/clock/presentation/controllers/clock_controller.dart';
import 'package:ztime_widget/features/clock/presentation/pages/clock_page.dart';

class ZTimeApp extends ConsumerStatefulWidget {
  const ZTimeApp({super.key});

  @override
  ConsumerState<ZTimeApp> createState() => _ZTimeAppState();
}

class _ZTimeAppState extends ConsumerState<ZTimeApp>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel(
    'com.gosayram.ztime_widget/date_change',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterImmersive();
    _enableWakelock();
    _setupDateChannel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channel.setMethodCallHandler(null);
    _disableWakelock();
    super.dispose();
  }

  /// Listen for day-change signals from Kotlin BroadcastReceiver.
  void _setupDateChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDayChanged') {
        // Force clock rebuild → triggers widget PNG re-render in ClockPage
        ref.read(clockSecondsProvider.notifier).resume();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final seconds = ref.read(clockSecondsProvider.notifier);
    final minutes = ref.read(clockMinutesProvider.notifier);

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        seconds.pause();
        minutes.pause();
        _disableWakelock();
      case AppLifecycleState.resumed:
        seconds.resume();
        minutes.resume();
        _enterImmersive();
        _enableWakelock();
    }
  }

  void _enterImmersive() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  void _enableWakelock() {
    try {
      WakelockPlus.enable();
    } on PlatformException catch (_) {}
  }

  void _disableWakelock() {
    try {
      WakelockPlus.disable();
    } on PlatformException catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZTime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: const Locale('ru', 'RU'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
      home: const ClockPage(),
    );
  }
}
