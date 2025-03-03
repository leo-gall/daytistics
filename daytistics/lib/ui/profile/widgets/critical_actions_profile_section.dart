import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:daytistics/ui/profile/widgets/delete_account_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class CriticalActionsProfileSection extends AbstractSettingsSection {
  const CriticalActionsProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SettingsSection(
          tiles: [
            SettingsTile.navigation(
              trailing: const Icon(
                Icons.download,
                color: ColorSettings.error,
              ),
              title: const StyledText(
                'Request data export',
                style: TextStyle(color: ColorSettings.error),
              ),
              onPressed: (context) async {
                final response = await ref
                    .read(supabaseClientDependencyProvider)
                    .functions
                    .invoke('data-export');

                await ref
                    .read(posthogDependencyProvider)
                    .capture(eventName: 'data_export_requested');
                if (context.mounted) {
                  if (response.status == 200) {
                    await showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const StyledText('Data Export'),
                        content: const StyledText(
                          'Your data export request has been submitted. You will receive an email with the data attached once it is ready. This process may take up to 2 business days.',
                          style: TextStyle(),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            child: const StyledText('Okay'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showToast(
                      context,
                      message: 'Failed to submit your data export request.',
                      type: ToastType.error,
                    );
                  }
                }
              },
            ),
            SettingsTile.navigation(
              trailing: const Icon(
                Icons.delete,
                color: ColorSettings.error,
              ),
              title: const StyledText(
                'Delete account',
                style: TextStyle(color: ColorSettings.error),
              ),
              onPressed: (context) {
                DeleteAccountModal.showModal(context);
              },
            ),
          ],
        );
      },
    );
  }
}
