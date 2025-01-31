import 'package:flutter/material.dart';

class StyledInputTimePickerFormField extends StatefulWidget {
  final void Function(TimeOfDay) onChanged;
  final String title;
  final TimeOfDay? initialTime;
  final TimeOfDay? minTime;
  final TimeOfDay? maxTime;
  final TextEditingController controller = TextEditingController();

  StyledInputTimePickerFormField({
    super.key,
    required this.onChanged,
    required this.title,
    this.minTime,
    this.maxTime,
    this.initialTime,
  });

  @override
  State<StyledInputTimePickerFormField> createState() =>
      _StyledInputTimePickerFormFieldState();
}

class _StyledInputTimePickerFormFieldState
    extends State<StyledInputTimePickerFormField> {
  @override
  void initState() {
    if (widget.initialTime != null) {
      if (widget.minTime != null &&
          widget.initialTime!.isBefore(widget.minTime!)) {
        widget.controller.text = widget.minTime!.format(context);
        widget.onChanged(widget.minTime!);
      } else if (widget.maxTime != null &&
          widget.initialTime!.isAfter(widget.maxTime!)) {
        widget.controller.text = widget.maxTime!.format(context);
        widget.onChanged(widget.maxTime!);
      }
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.text = widget.initialTime != null
        ? widget.initialTime!.format(context)
        : TimeOfDay.now().format(context);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.title,
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
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
