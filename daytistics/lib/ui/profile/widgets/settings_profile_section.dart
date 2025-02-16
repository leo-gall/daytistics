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
        return SettingsSection(
          title: const StyledText('Settings'),
          tiles: [
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              leading: const Icon(
                Icons.analytics,
                color: ColorSettings.primary,
              ),
              title: const StyledText('Allow conversation analytics'),
              description: const StyledText(
                'By enabling this setting, you agree to share your conversation data with us to improve our services.',
              ),
            ),
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              leading: const Icon(
                Icons.notifications,
                color: ColorSettings.primary,
              ),
              title: const StyledText('Enable notifications'),
              description: const StyledText(
                'Receive notifications to remind you of tracking your daily activities.',
              ),
            ),
          ],
        );
      },
    );
  }
}
