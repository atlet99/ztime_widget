import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ztime_widget/app.dart';
import 'package:ztime_widget/core/constants/durations.dart';
import 'package:ztime_widget/core/constants/home_widget_keys.dart';
import 'package:ztime_widget/core/constants/pref_keys.dart';
import 'package:ztime_widget/core/device/launcher_capabilities.dart';
import 'package:ztime_widget/core/widget/widget_png_renderer.dart';
import 'package:ztime_widget/i18n/strings.g.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == HomeWidgetKeys.workTask) {
      await WidgetPngRenderer.render();
      return true;
    }
    return false;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('ru', null),
    initializeDateFormatting('en', null),
    LauncherCapabilities.detect(),
  ]);

  // Init slang: load saved locale or fall back to device locale
  final prefs = await SharedPreferences.getInstance();
  final localeIndex = prefs.getInt(PrefKeys.appLocale) ?? 0;
  if (localeIndex == 0) {
    await LocaleSettings.useDeviceLocale();
  } else if (localeIndex == 1) {
    await LocaleSettings.setLocale(AppLocale.ru);
  } else {
    await LocaleSettings.setLocale(AppLocale.en);
  }

  // Generate widget PNG immediately on startup
  await WidgetPngRenderer.render();

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    HomeWidgetKeys.workTaskId,
    HomeWidgetKeys.workTask,
    frequency: AppDurations.workmanagerFrequency,
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

  runApp(TranslationProvider(child: const ProviderScope(child: ZTimeApp())));
}
