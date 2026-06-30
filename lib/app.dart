import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:ztime_widget/core/constants/android_constants.dart';
import 'package:ztime_widget/core/theme/app_theme.dart';
import 'package:ztime_widget/features/clock/presentation/controllers/clock_controller.dart';
import 'package:ztime_widget/features/clock/presentation/pages/clock_page.dart';
import 'package:ztime_widget/i18n/strings.g.dart';

class ZTimeApp extends ConsumerStatefulWidget {
  const ZTimeApp({super.key});

  @override
  ConsumerState<ZTimeApp> createState() => _ZTimeAppState();
}

class _ZTimeAppState extends ConsumerState<ZTimeApp>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel(AndroidConstants.methodChannel);

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

  void _setupDateChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDayChanged') {
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
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return MaterialApp(
          title: t.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            // Lock system text-scale so clock doesn't balloon
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
              child: ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: const [
                  Breakpoint(start: 0, end: 600, name: MOBILE),
                  Breakpoint(start: 601, end: 1024, name: TABLET),
                  Breakpoint(start: 1025, end: double.infinity, name: DESKTOP),
                ],
                breakpointsLandscape: const [
                  Breakpoint(start: 0, end: 480, name: MOBILE),
                  Breakpoint(start: 481, end: 1024, name: TABLET),
                  Breakpoint(start: 1025, end: double.infinity, name: DESKTOP),
                ],
              ),
            );
          },
          home: const ClockPage(),
        );
      },
    );
  }
}
