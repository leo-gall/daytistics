import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/onboarding/onboarding_service.dart';
import 'package:daytistics/application/providers/services/user/user_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthButton extends ConsumerWidget {
  const OAuthButton(this.provider, {super.key});

  final OAuthProvider provider;

  SvgPicture _buildIcon() {
    final String iconPath;
    if (provider == OAuthProvider.google) {
      iconPath = 'assets/svg/google_mono.svg';
    } else if (provider == OAuthProvider.apple) {
      iconPath = 'assets/svg/apple_mono.svg';
    } else {
      throw UnimplementedError('Unsupported provider: $provider');
    }

    return SvgPicture.asset(
      iconPath,
      colorFilter: const ColorFilter.mode(
        ColorSettings.primary,
        BlendMode.srcIn,
      ),
      width: 20,
      height: 20,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: () async {
          if (await maybeRedirectToConnectionErrorView(context)) return;
          if (provider == OAuthProvider.google) {
            await ref.read(userServiceProvider).signInWithGoogle();
          } else if (provider == OAuthProvider.apple) {
            await ref.read(userServiceProvider).signInWithApple();
          } else {
            throw UnimplementedError('Unsupported provider: $provider');
          }

          if (context.mounted &&
              ref.watch(supabaseClientDependencyProvider).auth.currentUser !=
                  null) {
            if (!ref
                .read(onboardingServiceProvider)
                .hasCompletedOnboardingScreens) {
              await Navigator.pushReplacementNamed(
                context,
                '/onboarding',
              );
            } else {
              await Navigator.pushReplacementNamed(
                context,
                '/',
              );
            }
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildIcon(),
            const SizedBox(width: 10),
            StyledText(
              'Sign in with ${provider.name[0].toUpperCase()}${provider.name.substring(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
