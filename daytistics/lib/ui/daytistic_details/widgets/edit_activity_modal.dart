import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/services/activities/activities_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/alert.dart';
import 'package:daytistics/shared/widgets/styled_input_time_picker_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class EditActivityModal extends ConsumerStatefulWidget {
  final Activity activity;

  const EditActivityModal(this.activity, {super.key});

  @override
  ConsumerState<EditActivityModal> createState() => _EditActivityModalState();

  static void showModal(BuildContext context, Activity activity) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EditActivityModal(activity);
      },
    );
  }
}

class _EditActivityModalState extends ConsumerState<EditActivityModal> {
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
                        onPressed: () => _handleEditActivity(),
                        child: const Text('Save Activity'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEditActivity() async {
    if (!mounted || !context.mounted) return;

    try {
      await ref.read(activitiesServiceProvider.notifier).updateActivity(
            id: widget.activity.id,
            name: _activityController.text,
            startTime: _startTime,
            endTime: _endTime,
          );
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorAlert(context, e.toString());
      return;
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: ColorSettings.success,
        duration: Duration(seconds: 1),
        content: Text('Activity updated successfully'),
      ),
    );
  }

  Future<void> _handleDeleteActivity() async {
    try {
      await ref.read(activitiesServiceProvider.notifier).deleteActivity(
            widget.activity,
          );
    } catch (e) {
      if (!mounted) return;
      showErrorAlert(context, e.toString());
      return;
    }

    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: ColorSettings.success,
          duration: Duration(seconds: 1),
          content: Text('Activity deleted successfully'),
        ),
      );
    }
  }
}
