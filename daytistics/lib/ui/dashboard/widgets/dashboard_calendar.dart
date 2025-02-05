import 'package:daytistics/ui/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardCalendar extends ConsumerWidget {
  const DashboardCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardViewModelState = ref.watch(dashboardViewModelProvider);

    return TableCalendar<dynamic>(
      rowHeight: 45,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      focusedDay: dashboardViewModelState.selectedDate,
      selectedDayPredicate: (day) {
        return isSameDay(dashboardViewModelState.selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        ref.read(dashboardViewModelProvider.notifier).selectedDate =
            selectedDay;
      },
    );
  }
}
