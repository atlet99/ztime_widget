import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_controller.g.dart';

/// Currently selected date in the calendar (for month view).
@Riverpod(keepAlive: true)
class SelectedCalendarDate extends _$SelectedCalendarDate {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

/// Which month the calendar is focused on (controls visible page).
@Riverpod(keepAlive: true)
class FocusedCalendarDate extends _$FocusedCalendarDate {
  @override
  DateTime build() => DateTime.now();

  void focus(DateTime date) => state = date;
}
