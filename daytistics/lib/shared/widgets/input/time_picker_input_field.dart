import 'package:flutter/material.dart';

class TimePickerInputField extends StatefulWidget {
  final void Function(TimeOfDay) onChanged;
  final String title;
  final TimeOfDay? initialTime;
  final TextEditingController controller = TextEditingController();

  TimePickerInputField({
    super.key,
    required this.onChanged,
    required this.title,
    this.initialTime,
  });

  @override
  State<TimePickerInputField> createState() => _TimePickerInputFieldState();
}

class _TimePickerInputFieldState extends State<TimePickerInputField> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.text = widget.initialTime != null
        ? widget.initialTime!.format(context)
        : TimeOfDay.now().format(context);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.title,
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null && context.mounted) {
          widget.controller.text = pickedTime.format(context);
          widget.onChanged(pickedTime);
        }
      },
    );
  }
}
