import 'package:daytistics/application/models/user_settings.dart';
import 'package:daytistics/application/providers/services/notification/notification_service.dart';
import 'package:daytistics/application/providers/services/settings/settings_service.dart';
import 'package:daytistics/application/providers/state/settings/settings.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsProfileSection extends AbstractSettingsSection {
  const SettingsProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final UserSettings? userSettings = ref.watch(settingsProvider);
        if (userSettings == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (await maybeRedirectToConnectionErrorView(context)) return;
            await ref.read(settingsServiceProvider).initializeSettings();
          });
          return const Center(child: CircularProgressIndicator());
        }

        return SettingsSection(
          title: const StyledText('Settings'),
          tiles: [
            SettingsTile.switchTile(
              onToggle: (value) async {
                await ref
                    .read(settingsServiceProvider)
                    .toggleConversationAnalytics();
              },
              initialValue: userSettings.conversationAnalytics,
              leading: const Icon(
                Icons.analytics,
                color: ColorSettings.primary,
              ),
              title: const StyledText('Allow conversation analytics'),
              description: const StyledText(
                'By enabling this setting, you agree to share your conversation data with us to improve our services.',
              ),
            ),
            SettingsTile.navigation(
              trailing: const Icon(
                Icons.calendar_month_outlined,
                color: ColorSettings.textLight,
              ),
              onPressed: (context) async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  barrierDismissible: false,
                  context: context,
                  cancelText: 'Unset',
                  initialTime: userSettings.dailyReminderTime != null
                      ? userSettings.dailyReminderTime!
                      : TimeOfDay.now(),
                );

                if (pickedTime == null) {
                  await ref
                      .read(settingsServiceProvider)
                      .updateDailyReminderTime(timeOfDay: null);
                  if (context.mounted) {
                    showToast(
                      context: context,
                      message: 'Daily reminder disabled.',
                    );
                  }
                } else {
                  await ref
                      .read(settingsServiceProvider)
                      .updateDailyReminderTime(
                        timeOfDay: pickedTime,
                      );
                  await ref
                      .read(notificationServiceProvider)
                      .scheduleDailyReminderNotification(pickedTime);
                }
              },
              leading: const Icon(
                Icons.notifications,
                color: ColorSettings.primary,
              ),
              title: const StyledText('Daily reminder'),
              description: const StyledText(
                'Set a daily notification reminder for logging your day. This helps maintain consistent tracking.',
              ),
            ),
          ],
        );
      },
    );
  }
}
