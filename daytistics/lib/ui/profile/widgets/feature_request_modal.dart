import 'package:daytistics/application/providers/services/feedback/feedback_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeatureRequestModal extends ConsumerStatefulWidget {
  const FeatureRequestModal({super.key});

  static Future<void> showModal(BuildContext context) async {
    await showDialog<AlertDialog>(
      context: context,
      builder: (context) {
        return const FeatureRequestModal();
      },
    );
  }

  @override
  ConsumerState<FeatureRequestModal> createState() =>
      _FeatureRequestModalState();
}

class _FeatureRequestModalState extends ConsumerState<FeatureRequestModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool hasSubmitted = false;
  bool loading = false;
  bool canSubmit = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: StyledText(
        hasSubmitted ? 'Thank you!' : 'Feature Request',
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
                  onChanged: (value) => setState(() {
                    canSubmit = value.isNotEmpty;
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
                  onPressed: canSubmit ? () async => handleSubmit() : null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      canSubmit
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
                    openUrl('https://github.com/users/leo-gall/projects/6'),
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

    await ref.read(feedbackServiceProvider.notifier).createFeatureRequest(
          _titleController.text,
          _descriptionController.text,
        );

    setState(() {
      hasSubmitted = true;
      loading = false;
    });
  }
}
