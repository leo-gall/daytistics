import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/services/auth/auth_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/browser.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/profile/widgets/critical_actions_settings_section.dart';
import 'package:daytistics/ui/profile/widgets/delete_account_modal.dart';
import 'package:daytistics/ui/profile/widgets/settings_profile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  bool _canDeleteAccount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            const SizedBox(width: 4),
            StyledText(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider.notifier).signOut();

              if (ref.watch(supabaseClientProvider).auth.currentUser == null) {
                if (context.mounted) {
                  await Navigator.pushNamed(context, '/signin');
                }
              }
            },
          ),
        ],
      ),
      body: RequireAuth(
        child: Center(
          child: SettingsList(
            lightTheme: SettingsThemeData(
              settingsListBackground: ColorSettings.background,
              settingsSectionBackground: Colors.grey[200],
            ),
            sections: [
              SettingsProfileSection(),
              SettingsSection(
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
              ),
              SettingsSection(
                title: const StyledText('Help & Feedback'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.feedback,
                        color: ColorSettings.primary, size: 25),
                    trailing: const Icon(
                      Icons.open_in_new,
                      color: ColorSettings.textLight,
                    ),
                    title: const StyledText(
                      'Share your feedback',
                      style: TextStyle(color: ColorSettings.textLight),
                    ),
                    onPressed: (context) async {
                      await openUrl('https://bsky.app/daytistics.com');
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.support,
                        color: ColorSettings.primary, size: 25),
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
                        'mailto:support@daytistics.com?subject=Support+${ref.read(supabaseClientProvider).auth.currentUser!.email}',
                      );
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const StyledText('Legal'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.book,
                        color: ColorSettings.primary, size: 25),
                    trailing: const Icon(
                      Icons.open_in_new,
                      color: ColorSettings.textLight,
                    ),
                    title: const StyledText(
                      'Imprint',
                      style: TextStyle(color: ColorSettings.textLight),
                    ),
                    onPressed: (context) async {
                      await openUrl('https://daytistics.com/imprint');
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.privacy_tip,
                        color: ColorSettings.primary, size: 25),
                    trailing: const Icon(
                      Icons.open_in_new,
                      color: ColorSettings.textLight,
                    ),
                    title: const StyledText(
                      'Privacy policy',
                      style: TextStyle(color: ColorSettings.textLight),
                    ),
                    onPressed: (context) async {
                      await openUrl('https://daytistics.com/privacy');
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.gavel,
                        color: ColorSettings.primary, size: 25),
                    trailing: const Icon(
                      Icons.open_in_new,
                      color: ColorSettings.textLight,
                    ),
                    title: const StyledText(
                      'Terms of service',
                      style: TextStyle(color: ColorSettings.textLight),
                    ),
                    onPressed: (context) async {
                      await openUrl('https://daytistics.com/terms');
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.article,
                        color: ColorSettings.primary, size: 25),
                    title: const StyledText(
                      'Licenses',
                      style: TextStyle(color: ColorSettings.textLight),
                    ),
                    onPressed: (context) async {
                      await Navigator.pushNamed(context, '/profile/licenses');
                    },
                  ),
                ],
              ),
              const CriticalActionsSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
