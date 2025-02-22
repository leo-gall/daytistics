import 'package:daytistics/application/providers/services/auth/auth_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteAccountModal extends ConsumerStatefulWidget {
  const DeleteAccountModal({super.key});

  static Future<void> showModal(BuildContext context) async {
    await showDialog<AlertDialog>(
      context: context,
      builder: (context) {
        return const DeleteAccountModal();
      },
    );
  }

  @override
  ConsumerState<DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends ConsumerState<DeleteAccountModal> {
  bool _canDeleteAccount = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const StyledText(
        'Confirm Account Deletion',
      ),
      content: const StyledText(
        'Are you sure you want to delete your account? This action cannot be undone. To confirm, type DELETE in the input field below.',
        style: TextStyle(),
      ),
      actionsOverflowButtonSpacing: 16,
      actions: <Widget>[
        TextField(
          decoration: const InputDecoration(
            labelText: 'Type DELETE',
          ),
          onChanged: (value) {
            setState(() {
              _canDeleteAccount = value == 'DELETE';
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 16,
          children: [
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
                  color: ColorSettings.textDark,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_canDeleteAccount) {
                  await ref.read(authServiceProvider.notifier).deleteAccount();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    await Navigator.pushNamed(context, '/signin');
                  }
                } else {
                  setState(() {
                    _canDeleteAccount = true;
                  });
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _canDeleteAccount
                      ? ColorSettings.primary
                      : ColorSettings.primary.withAlpha(128),
                ),
              ),
              child: const StyledText(
                'Confirm',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
