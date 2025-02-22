import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/browser.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class HelpProfileSection extends AbstractSettingsSection {
  const HelpProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SettingsSection(
          title: const StyledText('Help & Feedback'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(
                Icons.feedback,
                color: ColorSettings.primary,
                size: 25,
              ),
              trailing: const Icon(
                Icons.open_in_new,
                color: ColorSettings.textLight,
              ),
              title: const StyledText(
                'Feedback Survey',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await openUrl('http://feedback.daytistics.com');
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(
                Icons.bug_report,
                color: ColorSettings.primary,
                size: 25,
              ),
              trailing: const Icon(
                Icons.open_in_new,
                color: ColorSettings.textLight,
              ),
              title: const StyledText(
                'Report a bug',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await openUrl('http://bugs.daytistics.com');
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(
                Icons.support,
                color: ColorSettings.primary,
                size: 25,
              ),
              trailing: const Icon(
                Icons.open_in_new,
                color: ColorSettings.textLight,
              ),
              title: const StyledText(
                'Contact support',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await openUrl(
                  'mailto:contact@daytistics.com?subject=Support+${ref.read(supabaseClientDependencyProvider).auth.currentUser!.id}',
                );
              },
            ),
          ],
        );
      },
    );
  }
}
