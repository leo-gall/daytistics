import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/analytics.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class InfoProfileSection extends AbstractSettingsSection {
  const InfoProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SettingsSection(
          title: const StyledText('Information'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(
                Icons.emoji_emotions,
                color: ColorSettings.primary,
              ),
              title: const StyledText(
                'About',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async =>
                  Navigator.pushNamed(context, '/profile/about'),
            ),
            SettingsTile.navigation(
              leading: const Icon(
                Icons.email,
                color: ColorSettings.primary,
                size: 25,
              ),
              trailing: const Icon(
                Icons.open_in_new,
                color: ColorSettings.textLight,
              ),
              title: const StyledText(
                'Newsletter',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await openUrl('https://daytistics.com');
                await trackEvent(eventName: 'newsletter_opened');
              },
            ),
          ],
        );
      },
    );
  }
}
