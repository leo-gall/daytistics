import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/browser.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/profile/widgets/delete_account_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:settings_ui/settings_ui.dart';

class NewsProfileSection extends AbstractSettingsSection {
  const NewsProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SettingsSection(
          title: const StyledText('News & Community'),
          tiles: [
            SettingsTile.navigation(
              leading: SvgPicture.asset(
                'assets/svg/bluesky_mono.svg',
                colorFilter: const ColorFilter.mode(
                  ColorSettings.primary,
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
              trailing: const Icon(
                Icons.open_in_new,
                color: ColorSettings.textLight,
              ),
              title: const StyledText(
                'BlueSky',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await openUrl('https://bsky.app/profile/daytistics.com');
              },
            ),
            SettingsTile.navigation(
              leading: SvgPicture.asset(
                'assets/svg/github_mono.svg',
                colorFilter: const ColorFilter.mode(
                  ColorSettings.primary,
                  BlendMode.srcIn,
                ),
                width: 23,
                height: 23,
              ),
              trailing: const Icon(
                Icons.open_in_new,
                color: ColorSettings.textLight,
              ),
              title: const StyledText(
                'GitHub',
                style: TextStyle(color: ColorSettings.textLight),
              ),
              onPressed: (context) async {
                await openUrl('https://github.com/leo-gall/daytistics');
              },
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
              },
            ),
          ],
        );
      },
    );
  }
}
