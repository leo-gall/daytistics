import 'package:daytistics/application/providers/services/user/user_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';

class DataExportSettingsTile extends AbstractSettingsTile {
  const DataExportSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> exporting = ValueNotifier(false);

    return Consumer(
      builder: (context, ref, child) {
        return ValueListenableBuilder(
          valueListenable: exporting,
          builder: (context, value, child) {
            return SettingsTile.navigation(
              trailing: exporting.value
                  ? const StyledText(
                      'Exporting...',
                      style: TextStyle(color: ColorSettings.error),
                    )
                  : const Icon(
                      Icons.download,
                      color: ColorSettings.error,
                    ),
              title: const Text(
                'Export data',
                style: TextStyle(color: ColorSettings.error),
              ),
              onPressed: exporting.value
                  ? null
                  : (context) => _handleDataExport(context, ref, exporting),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDataExport(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> exporting,
  ) async {
    exporting.value = true;
    final String filePath = await ref.read(userServiceProvider).exportData();

    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Data export',
        text: 'Download your data export below as a JSON file.',
      );
    } on ServerException catch (_) {
      if (context.mounted) {
        showToast(
          context: context,
          message: 'Failed to export data. Please try again later.',
          type: ToastType.error,
        );
      }
    }
    exporting.value = false;
  }
}
