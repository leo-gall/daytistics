import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/services/auth/auth_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/browser.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/profile/widgets/critical_actions_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/delete_account_modal.dart';
import 'package:daytistics/ui/profile/widgets/help_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/legal_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/news_profile_section.dart';
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
        child: SettingsList(
          lightTheme: SettingsThemeData(
            settingsListBackground: ColorSettings.background,
            settingsSectionBackground: Colors.grey[200],
          ),
          sections: const [
            SettingsProfileSection(),
            NewsProfileSection(),
            HelpProfileSection(),
            LegalProfileSection(),
            CriticalActionsProfileSection(),
          ],
        ),
      ),
    );
  }
}
