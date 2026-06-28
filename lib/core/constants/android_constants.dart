class AndroidConstants {
  AndroidConstants._();

  static const packageName = 'com.gosayram.ztime_widget';
  static const methodChannel = '$packageName/date_change';
  static const widgetProvider = '$packageName.CustomClockWidgetProvider';
  static const batterySettingsAction =
      'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS';
}
