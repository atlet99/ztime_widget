import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _cache = <String, DateFormat>{};

  static DateFormat _get(String pattern, String locale) {
    final key = '$pattern|$locale';
    return _cache[key] ??= DateFormat(pattern, locale);
  }

  static String formatFullDate(DateTime date, String locale) {
    final fullDate = _get('yMMMMd', locale);
    final weekday = _get('EEEE', locale);
    return '${fullDate.format(date)} (${weekday.format(date)})';
  }

  static String formatTime(DateTime date, String locale) =>
      _get('Hm', locale).format(date);

  static List<String> getWeekdayLabels(String locale) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final fmt = _get('E', locale);
    return List.generate(7, (i) => fmt.format(monday.add(Duration(days: i))));
  }

  static List<String> getWeekdayLabelsShort(String locale) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final fmt = _get('EE', locale);
    return List.generate(7, (i) => fmt.format(monday.add(Duration(days: i))));
  }
}
