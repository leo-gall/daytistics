import 'package:daytistics/ui/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardCalendar extends ConsumerWidget {
  const DashboardCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardViewModelNotifier =
        ref.read(dashboardViewModelProvider.notifier);

    final selectedDate = ref.watch(dashboardViewModelProvider).selectedDate;

    return CalendarDatePicker(
      initialDate: selectedDate,
      firstDate: DateTime.utc(2025),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      onDateChanged: (date) => onDateChanged(date, dashboardViewModelNotifier),
    );
  }

  void onDateChanged(
    DateTime selectedDay,
    DashboardViewModel dashboardViewModelNotifier,
  ) {
    dashboardViewModelNotifier.updateSelectedDate(selectedDay);
  }
}
