import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ztime_widget/core/theme/app_colors.dart';
import 'package:ztime_widget/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:ztime_widget/i18n/strings.g.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  void _openSystemCalendar(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: 'content://com.android.calendar/time',
      arguments: <String, dynamic>{
        'beginTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
        'allDay': true,
      },
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    if (await intent.canResolveActivity() == true) {
      await intent.launch();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedCalendarDateProvider);
    final focusedDay = ref.watch(focusedCalendarDateProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.textPrimary,
        title: Text(context.t.calendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: AppColors.textDim),
            onPressed: () {
              final now = DateTime.now();
              ref.read(selectedCalendarDateProvider.notifier).select(now);
              ref.read(focusedCalendarDateProvider.notifier).focus(now);
            },
          ),
        ],
      ),
      body: TableCalendar<void>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        locale: locale,
        focusedDay: focusedDay,
        currentDay: DateTime.now(),
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) {
          ref.read(selectedCalendarDateProvider.notifier).select(selected);
          ref.read(focusedCalendarDateProvider.notifier).focus(focused);
          _openSystemCalendar(selected);
        },
        onPageChanged: (focused) =>
            ref.read(focusedCalendarDateProvider.notifier).focus(focused),
        availableCalendarFormats: {CalendarFormat.month: context.t.monthFormat},
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.textDim,
            size: 28.r,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.textDim,
            size: 28.r,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textDim,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textDim.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarStyle: CalendarStyle(
          defaultDecoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          weekendDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          selectedDecoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          outsideTextStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.2),
          ),
          outsideDecoration: const BoxDecoration(shape: BoxShape.circle),
          cellMargin: EdgeInsets.all(4.r),
        ),
      ),
    );
  }
}
