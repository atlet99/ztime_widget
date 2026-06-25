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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterImmersive();
    _enableWakelock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final clock = ref.read(clockProvider.notifier);

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        clock.pause();
        WakelockPlus.disable();
      case AppLifecycleState.resumed:
        clock.resume();
        _enableWakelock();
      case AppLifecycleState.hidden:
        clock.pause();
        WakelockPlus.disable();
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
    WakelockPlus.enable();
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
