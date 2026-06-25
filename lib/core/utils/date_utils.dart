import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatFullDate(DateTime date, String locale) {
    final fullDate = DateFormat.yMMMMd(locale);
    final weekday = DateFormat.EEEE(locale);
    return '${fullDate.format(date)} (${weekday.format(date)})';
  }

  static String formatTime(DateTime date, String locale) =>
      DateFormat.Hm(locale).format(date);

  static String formatWeekdayShort(DateTime date, String locale) =>
      DateFormat.E(locale).format(date);

  static List<String> getWeekdayLabels(String locale) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(
      7,
      (i) => DateFormat.E(locale).format(monday.add(Duration(days: i))),
    );
  }
}
