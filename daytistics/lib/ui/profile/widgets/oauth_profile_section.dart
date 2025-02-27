import 'dart:io';

import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/services/auth/auth_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:settings_ui/settings_ui.dart';

class OauthProfileSection extends AbstractSettingsSection {
  const OauthProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.read(userDependencyProvider);

        return SettingsSection(
          title: const StyledText('Authentications'),
          tiles: [
            if (Platform.isAndroid)
              SettingsTile.navigation(
                leading: SvgPicture.asset(
                  'assets/svg/google_mono.svg',
                  colorFilter: const ColorFilter.mode(
                    ColorSettings.primary,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
                title: StyledText(
                  ((user?.appMetadata['providers'] as List?) ?? [])
                          .contains('google')
                      ? 'Google connected'
                      : 'Connect Google',
                ),
                trailing: ((user?.appMetadata['providers'] as List?) ?? [])
                        .contains('google')
                    ? const Icon(
                        Icons.check,
                        color: ColorSettings.textLight,
                      )
                    : null,
              ),
            if (Platform.isIOS)
              SettingsTile.navigation(
                leading: SvgPicture.asset(
                  'assets/svg/apple_mono.svg',
                  colorFilter: const ColorFilter.mode(
                    ColorSettings.primary,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
                title: StyledText(
                  ((user?.appMetadata['providers'] as List?) ?? [])
                          .contains('apple')
                      ? 'Apple ID connected'
                      : 'Connect Apple ID',
                ),
                trailing: ((user?.appMetadata['providers'] as List?) ?? [])
                        .contains('apple')
                    ? const Icon(
                        Icons.check,
                        color: ColorSettings.textLight,
                      )
                    : null,
                onPressed: (context) async =>
                    ref.read(authServiceProvider.notifier).signInWithApple(),
              ),
          ],
        );
      },
    );
  }
}
