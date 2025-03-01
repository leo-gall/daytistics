import 'package:daytistics/application/providers/services/activities/activities_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
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
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

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
    try {
      await ref.read(activitiesServiceProvider.notifier).addActivity(
            name: _activityController.text,
            startTime: _startTime,
            endTime: _endTime,
          );
    } on InvalidInputException catch (e) {
      if (!mounted) return;
      showErrorDialog(context, message: e.message);
      return;
    }

    if (!mounted) return;

    Navigator.pop(context);

    showToast(context, message: 'Activity added successfully');
  }
}
