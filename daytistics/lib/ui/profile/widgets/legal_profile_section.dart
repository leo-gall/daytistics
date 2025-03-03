import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class LegalProfileSection extends AbstractSettingsSection {
  const LegalProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SettingsSection(
          title: const StyledText('Legal'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(
                Icons.book,
                color: ColorSettings.primary,
                size: 25,
              ),
              trailing: const Icon(
                Icons.open_in_new,
                color: ColorSettings.textLight,
              ),
              title: const StyledText(
                'Imprint',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await openUrl(LegalSettings.imprintUrl);
                await ref.read(posthogDependencyProvider).capture(
                      eventName: 'imprint_opened',
                    );
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(
                Icons.privacy_tip,
                color: ColorSettings.primary,
                size: 25,
              ),
              trailing: const Icon(
                Icons.open_in_new,
                color: ColorSettings.textLight,
              ),
              title: const StyledText(
                'Privacy Policy',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await openUrl(LegalSettings.privacyPolicyUrl);
                await ref.read(posthogDependencyProvider).capture(
                      eventName: 'privacy_policy_opened',
                    );
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(
                Icons.article,
                color: ColorSettings.primary,
                size: 25,
              ),
              title: const StyledText(
                'Licenses',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await Navigator.pushNamed(context, '/profile/licenses');
              },
            ),
          ],
        );
      },
    );
  }
}
