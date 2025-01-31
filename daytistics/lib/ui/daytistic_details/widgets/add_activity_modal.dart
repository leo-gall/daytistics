import 'package:daytistics/application/services/activities/activities_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/alert.dart';
import 'package:daytistics/shared/widgets/styled_input_time_picker_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddActivityModal extends ConsumerStatefulWidget {
  const AddActivityModal({super.key});

  @override
  ConsumerState<AddActivityModal> createState() => _ActivityModalState();

  static void showModal(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const AddActivityModal();
      },
    );
  }
}

class _ActivityModalState extends ConsumerState<AddActivityModal> {
  final TextEditingController _activityController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 255,
      color: const Color.fromRGBO(255, 255, 255, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
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
                    controller: _activityController,
                    decoration: const InputDecoration(
                      labelText: 'I spend my time with...',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: StyledInputTimePickerFormField(
                          onChanged: (TimeOfDay time) => _startTime = time,
                          title: 'Start Time',
                          initialTime: _startTime,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StyledInputTimePickerFormField(
                          onChanged: (TimeOfDay time) => _endTime = time,
                          title: 'End Time',
                          initialTime: _endTime,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextButton(
                    onPressed: () => _handleAddActivity(),
                    child: const Text('Add Activity'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddActivity() async {
    try {
      await ref.read(activitiesServiceProvider.notifier).addActivity(
            name: _activityController.text,
            startTime: _startTime,
            endTime: _endTime,
          );
    } catch (e) {
      if (!mounted) return;
      showErrorAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: ColorSettings.success,
        duration: Duration(seconds: 1),
        content: Text('Activity added successfully'),
      ),
    );
  }
}
