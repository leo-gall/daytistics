import 'package:daytistics/application/models/user_settings.dart';
import 'package:daytistics/application/providers/services/settings/settings_service.dart';
import 'package:daytistics/application/providers/state/settings/settings.dart';
import 'package:daytistics/config/settings.dart';
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(settingsServiceProvider).initializeSettings();
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
            // SettingsTile.switchTile(
            //   onToggle: (value) async {
            //     await ref.read(settingsServiceProvider).toggleNotifications();
            //   },
            //   initialValue: userSettings.notifications,
            //   leading: const Icon(
            //     Icons.notifications,
            //     color: ColorSettings.primary,
            //   ),
            //   title: const StyledText('Enable notifications'),
            //   description: const StyledText(
            //     'Receive notifications to remind you of tracking your daily activities.',
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
