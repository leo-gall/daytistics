import 'package:daytistics/features/activities/models/activity_entry.dart';
import 'package:daytistics/features/activities/viewmodels/activity_tracker_view_model.dart';
import 'package:daytistics/shared/widgets/styled_input_time_picker_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ActivityModal extends ConsumerStatefulWidget {
  final ActivityEntry? activityEntry;

  const ActivityModal({super.key, this.activityEntry});

  @override
  ConsumerState<ActivityModal> createState() => _ActivityModalState();

  static void showModal(BuildContext context, {ActivityEntry? activityEntry}) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ActivityModal(activityEntry: activityEntry);
      },
    );
  }
}

class _ActivityModalState extends ConsumerState<ActivityModal> {
  @override
  Widget build(BuildContext context) {
    final activityTrackerViewModel =
        ref.watch(activityTrackerViewModelProvider.notifier);
    final activityTrackerState = ref.watch(activityTrackerViewModelProvider);

    return Container(
      height: 330,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.stop,
                ),
                onPressed: () {
                  // activityTrackerViewModel.stopActivity();
                },
              ),
              if (activityTrackerState.isActivityInProgress)
                Text(
                  activityTrackerState.getCurrentActivityDurationAsString ??
                      'Nope',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Form(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'I spend my time with...',
                    ),
                    initialValue: widget.activityEntry?.name,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: StyledInputTimePickerFormField(
                          onChanged: (TimeOfDay time) => print(time),
                          title: 'Start Time',
                          initialTime: TimeOfDay.now(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StyledInputTimePickerFormField(
                          onChanged: (TimeOfDay time) => print(time),
                          title: 'End Time',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: InputDatePickerFormField(
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    initialDate: DateTime.now(),
                    fieldLabelText: 'Date',
                    onDateSubmitted: (DateTime date) {
                      // Handle picked date
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle save action
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
