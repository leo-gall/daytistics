import 'package:daytistics/application/providers/services/feedback/feedback_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BugReportModal extends ConsumerStatefulWidget {
  const BugReportModal({super.key});

  static Future<void> showModal(BuildContext context) async {
    await showDialog<AlertDialog>(
      context: context,
      builder: (context) {
        return const BugReportModal();
      },
    );
  }

  @override
  ConsumerState<BugReportModal> createState() => _BugReportModalState();
}

class _BugReportModalState extends ConsumerState<BugReportModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String error = '';
  bool loading = false;
  bool hasSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: StyledText(
        hasSubmitted ? 'Thank you!' : 'Bug Report',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: !hasSubmitted
            ? [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
                if (error.isNotEmpty)
                  StyledText(
                    error,
                    style: const TextStyle(
                      color: ColorSettings.error,
                    ),
                  ),
              ]
            : [
                const StyledText(
                  'Thank you for your feedback!',
                ),
              ],
      ),
      actionsOverflowButtonSpacing: 16,
      actions: !hasSubmitted
          ? [
              if (loading)
                const CircularProgressIndicator()
              else ...[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                  child: const StyledText(
                    'Cancel',
                    style: TextStyle(
                      color: ColorSettings.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async => handleSubmit(),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      ColorSettings.primary,
                    ),
                  ),
                  child: const StyledText(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ]
          : [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                ),
                child: const StyledText(
                  'Close',
                  style: TextStyle(
                    color: ColorSettings.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async =>
                    openUrl('https://github.com/users/leo-gall/projects/7'),
                child: const StyledText(
                  'Roadmap',
                ),
              ),
            ],
    );
  }

  Future<void> handleSubmit() async {
    if (await maybeRedirectToConnectionErrorView(context)) return;

    setState(() {
      loading = true;
    });

    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      setState(() {
        error = 'Please fill out all fields.';
      });
      return;
    }

    await ref.read(feedbackServiceProvider.notifier).createBugReport(
          _titleController.text,
          _descriptionController.text,
        );

    setState(() {
      hasSubmitted = true;
      loading = false;
    });
  }
}
