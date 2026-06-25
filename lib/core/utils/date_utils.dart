import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _fullDate = DateFormat.yMMMMd('ru');
  static final _weekday = DateFormat.EEEE('ru');
  static final _time = DateFormat.Hm('ru');
  static final _timeWithSec = DateFormat.Hms('ru');
  static final _weekdayShort = DateFormat.E('ru');

  static String formatFullDate(DateTime date) =>
      '${_fullDate.format(date)} (${_weekday.format(date)})';

  static String formatTime(DateTime date) => _time.format(date);

  static String formatTimeWithSeconds(DateTime date) =>
      _timeWithSec.format(date);

  static String formatWeekdayShort(DateTime date) => _weekdayShort.format(date);
}
