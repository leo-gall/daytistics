import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/auth/auth_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/profile/widgets/critical_actions_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/help_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/info_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/legal_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/settings_profile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
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

              if (ref
                      .watch(supabaseClientDependencyProvider)
                      .auth
                      .currentUser ==
                  null) {
                if (context.mounted) {
                  await Navigator.pushNamed(context, '/signin');
                }
              }
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final String? email = ref
              .watch(supabaseClientDependencyProvider)
              .auth
              .currentUser
              ?.email;

          String version = 'unknown';

          // postframe callback
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            version = (await PackageInfo.fromPlatform()).version;
          });

          return RequireAuth(
            child: SettingsList(
              lightTheme: SettingsThemeData(
                settingsListBackground: ColorSettings.background,
                settingsSectionBackground: Colors.grey[200],
              ),
              sections: [
                // const OauthProfileSection(),
                const SettingsProfileSection(),
                const InfoProfileSection(),
                const HelpProfileSection(),
                const LegalProfileSection(),
                const CriticalActionsProfileSection(),
                CustomSettingsSection(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      StyledText(
                        version,
                        style: const TextStyle(
                          color: ColorSettings.textDark,
                          fontSize: 12,
                        ),
                      ),
                      StyledText(
                        (email != null && email.isNotEmpty)
                            ? email
                            : 'Anonymous User',
                        style: const TextStyle(
                          color: ColorSettings.textDark,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
