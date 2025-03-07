import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/profile/widgets/data_export_settings_tile.dart';
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
            const DataExportSettingsTile(),
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
