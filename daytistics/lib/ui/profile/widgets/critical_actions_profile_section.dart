import 'dart:convert';
import 'dart:io';

import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/profile/widgets/delete_account_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';

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
                'Export data',
                style: TextStyle(color: ColorSettings.error),
              ),
              onPressed: (context) => _handleDataExport(ref, context),
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

  Future<void> _handleDataExport(WidgetRef ref, BuildContext context) async {
    final response = await ref
        .read(supabaseClientDependencyProvider)
        .functions
        .invoke('data-export');

    await ref
        .read(posthogDependencyProvider)
        .capture(eventName: 'data_exported');

    if (context.mounted) {
      if (response.status == 200) {
        final String jsonString =
            const JsonEncoder.withIndent('  ').convert(response.data);

        final Directory directory = await getApplicationDocumentsDirectory();
        final String filePath =
            '${directory.path}/data-export-${DateTime.now().millisecondsSinceEpoch}.json';

        final File file = File(filePath);
        await file.writeAsString(jsonString);

        // Share the file (or use another method to download)
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Data export',
          text: 'Download your data export below as a JSON file.',
        );
      } else {
        await ref.read(posthogDependencyProvider).capture(
          eventName: 'data_export_failed',
          properties: {
            'data': response.data.toString(),
            'status': response.status.toString(),
          },
        );
        if (context.mounted) {
          showToast(
            context,
            message: 'Failed to export data. Please try again later.',
            type: ToastType.error,
          );
        }
      }
    }
  }
}
