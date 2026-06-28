import 'package:intl/intl.dart';
import 'package:ztime_widget/core/constants/formats.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _cache = <String, DateFormat>{};

  static DateFormat _get(String pattern, String locale) {
    final key = '$pattern|$locale';
    return _cache[key] ??= DateFormat(pattern, locale);
  }

  static String formatFullDate(DateTime date, String locale) {
    final fullDate = _get(AppFormats.dateFull, locale);
    final weekday = _get(AppFormats.weekdayFull, locale);
    return '${fullDate.format(date)} (${weekday.format(date)})';
  }

  static String formatTime(DateTime date, String locale) =>
      _get(AppFormats.time24h, locale).format(date);

  static List<String> getWeekdayLabels(String locale) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final fmt = _get(AppFormats.weekdayLabel, locale);
    return List.generate(7, (i) => fmt.format(monday.add(Duration(days: i))));
  }

  static List<String> getWeekdayLabelsShort(String locale) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final fmt = _get(AppFormats.weekdayShort, locale);
    return List.generate(7, (i) => fmt.format(monday.add(Duration(days: i))));
  }
}
