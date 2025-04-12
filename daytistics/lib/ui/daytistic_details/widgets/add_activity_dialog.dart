import 'dart:async';

import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/services/activities/activities_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/shared/extensions/time.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/input/time_picker_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddActivityDialog extends ConsumerStatefulWidget {
  const AddActivityDialog({super.key});

  @override
  ConsumerState<AddActivityDialog> createState() => AddActivityDialogState();

  static void showDialog(BuildContext context) {
    showBottomDialog(context, child: const AddActivityDialog());
  }
}

class AddActivityDialogState extends ConsumerState<AddActivityDialog> {
  final TextEditingController _activityController = TextEditingController();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    final Daytistic? currentDaytistic = ref.read(currentDaytisticProvider);

    if (currentDaytistic == null) {
      _startTime = TimeOfDay.now();
      return;
    } else {
      setState(() {
        _startTime = currentDaytistic.activities.isNotEmpty
            ? TimeOfDay.fromDateTime(currentDaytistic.activities.last.endTime)
            : const TimeOfDay(hour: 0, minute: 0);

        _endTime = TimeOfDay(
          hour: _startTime.hour + 1 > 23 ? 0 : _startTime.hour + 1,
          minute: _startTime.minute,
        );
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _activityController,
            decoration: const InputDecoration(
              labelText: 'I spend my time with...',
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TimePickerInputField(
                  onChanged: (time) => _startTime = time,
                  title: 'Start Time',
                  initialTime: _startTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TimePickerInputField(
                  onChanged: (time) => _endTime = time,
                  title: 'End Time',
                  initialTime: _endTime,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextButton(
            onPressed: _handleAddActivity,
            child: const Text('Add Activity'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddActivity() async {
    final currentDaytisticNotifier =
        ref.read(currentDaytisticProvider.notifier);

    if (await maybeRedirectToConnectionErrorView(context)) return;

    if (_activityController.text.isEmpty && mounted) {
      showErrorDialog(context, message: 'Please enter an activity name');
      return;
    }

    if ((_startTime.isAfter(_endTime) || _startTime == _endTime) && mounted) {
      showErrorDialog(context, message: 'Start time cannot be after end time');
      return;
    }

    final daytistic = ref.read(currentDaytisticProvider)!;

    final Daytistic updatedDaytistic = daytistic.copyWith(
      activities: [
        ...daytistic.activities,
        Activity(
          name: _activityController.text,
          daytisticId: daytistic.id,
          startTime: _startTime.toDateTime(),
          endTime: _endTime.toDateTime(),
        ),
      ],
    );

    currentDaytisticNotifier.daytistic = updatedDaytistic;

    if (mounted) {
      showToast(context: context, message: 'Activity added successfully');
      Navigator.pop(context);
    }

    await ref
        .read(activitiesServiceProvider.notifier)
        .addActivity(
          name: _activityController.text,
          startTime: _startTime,
          endTime: _endTime,
          daytistic: daytistic,
        )
        .then(
      (success) {
        if (!success) {
          showToast(message: 'Failed to add activity', type: ToastType.error);

          // undo the changes
          currentDaytisticNotifier.daytistic = daytistic.copyWith(
            activities: daytistic.activities
                .where((element) => element.name != _activityController.text)
                .toList(),
          );
        }
      },
    );
  }
}
