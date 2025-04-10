import 'package:daytistics/application/providers/services/feedback/feedback_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BugReportDialog extends ConsumerStatefulWidget {
  const BugReportDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<AlertDialog>(
      context: context,
      builder: (context) {
        return const BugReportDialog();
      },
    );
  }

  @override
  ConsumerState<BugReportDialog> createState() => _BugReportDialogState();
}

class _BugReportDialogState extends ConsumerState<BugReportDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _hasSubmitted = false;
  bool _loading = false;
  bool _canSubmit = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: StyledText(
        _hasSubmitted ? 'Thank you!' : 'Bug Report',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: !_hasSubmitted
            ? [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  onChanged: (value) => setState(() {
                    _canSubmit = value.isNotEmpty;
                  }),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
              ]
            : [
                const StyledText(
                  'Thank you for your feedback!',
                ),
              ],
      ),
      actionsOverflowButtonSpacing: 16,
      actions: !_hasSubmitted
          ? [
              if (_loading)
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
                  onPressed: _canSubmit ? () async => handleSubmit() : null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      _canSubmit
                          ? ColorSettings.primary
                          : ColorSettings.primary.withAlpha(100),
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
      _loading = true;
    });

    await ref.read(feedbackServiceProvider.notifier).createBugReport(
          _titleController.text,
          _descriptionController.text,
        );

    setState(() {
      _hasSubmitted = true;
      _loading = false;
    });
  }
}
