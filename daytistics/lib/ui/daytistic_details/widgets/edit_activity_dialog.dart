import 'dart:async';

import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/providers/services/activities/activities_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/shared/extensions/time.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/input/time_picker_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditActivityDialog extends ConsumerStatefulWidget {
  final Activity activity;

  const EditActivityDialog(this.activity, {super.key});

  @override
  ConsumerState<EditActivityDialog> createState() => _EditActivityDialogState();

  static void showDialog(BuildContext context, Activity activity) {
    showBottomDialog(context, child: EditActivityDialog(activity));
  }
}

class _EditActivityDialogState extends ConsumerState<EditActivityDialog> {
  final TextEditingController _activityController = TextEditingController();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _activityController.text = widget.activity.name;
    _startTime = TimeOfDay.fromDateTime(widget.activity.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.activity.endTime);
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.red,
                  ),
                ),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
                onPressed: _handleDeleteActivity,
              ),
              TextButton(
                onPressed: _handleEditActivity,
                child: const Text('Save Activity'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleEditActivity() async {
    final currentDaytisticNotifier =
        ref.read(currentDaytisticProvider.notifier);

    if (await maybeRedirectToConnectionErrorView(context)) return;

    if (_activityController.text.isEmpty) {
      if (mounted) showErrorDialog(context, message: 'Name cannot be empty');
      return;
    }

    if (_startTime.isAfter(_endTime)) {
      if (mounted) {
        showErrorDialog(
          context,
          message: 'Start time cannot be after end time',
        );
      }
      return;
    }

    if (_startTime == _endTime) {
      if (mounted) {
        showErrorDialog(
          context,
          message: 'Start time cannot be the same as end time',
        );
      }
      return;
    }

    final daytistic = ref.read(currentDaytisticProvider)!;

    final updatedActivities = daytistic.activities
        .map(
          (element) => element.id == widget.activity.id
              ? widget.activity.copyWith(
                  name: _activityController.text,
                  startTime: _startTime.toDateTime(),
                  endTime: _endTime.toDateTime(),
                )
              : element,
        )
        .toList();

    final updatedDaytistic = daytistic.copyWith(activities: updatedActivities);

    currentDaytisticNotifier.daytistic = updatedDaytistic;

    if (mounted) {
      Navigator.pop(context);
      showToast(context: context, message: 'Activity updated successfully');
    }

    await ref
        .read(activitiesServiceProvider.notifier)
        .updateActivity(
          activity: widget.activity,
          daytistic: daytistic,
          name: _activityController.text,
          startTime: _startTime,
          endTime: _endTime,
        )
        .then(
      (success) {
        if (!success) {
          showToast(
            message: 'Failed to update activity',
            type: ToastType.error,
          );
          currentDaytisticNotifier.daytistic =
              daytistic.copyWith(activities: daytistic.activities);
        }
      },
    );
  }

  Future<void> _handleDeleteActivity() async {
    final daytistic = ref.read(currentDaytisticProvider)!;
    final currentDaytisticNotifier =
        ref.read(currentDaytisticProvider.notifier);

    if (await maybeRedirectToConnectionErrorView(context)) return;

    final updatedActivities = daytistic.activities
        .where((element) => element.id != widget.activity.id)
        .toList();

    final updatedDaytistic = daytistic.copyWith(activities: updatedActivities);

    currentDaytisticNotifier.daytistic = updatedDaytistic;

    if (mounted) {
      Navigator.pop(context);

      showToast(context: context, message: 'Activity deleted successfully');
    }

    await ref
        .read(activitiesServiceProvider.notifier)
        .deleteActivity(
          widget.activity,
        )
        .then((success) {
      if (!success) {
        showToast(
          message: 'Failed to delete activity',
          type: ToastType.error,
        );
        currentDaytisticNotifier.daytistic =
            daytistic.copyWith(activities: daytistic.activities);
      }
    });
  }
}
