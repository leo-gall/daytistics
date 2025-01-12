import 'package:daytistics/config/settings.dart';
import 'package:daytistics/domains/auth/services/auth_service.dart';
import 'package:daytistics/domains/dashboard/screens/dashboard_screen.dart';
import 'package:daytistics/shared/utils/routing.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthButton extends StatelessWidget {
  const OAuthButton(this.provider, {super.key});

  final OAuthProvider provider;

  SvgPicture _buildIcon() {
    final String iconPath;
    switch (provider) {
      case OAuthProvider.google:
        iconPath = 'assets/svg/google_mono.svg';
        break;
      case OAuthProvider.apple:
        iconPath = 'assets/svg/apple_mono.svg';
        break;
      default:
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: () async {
          await AuthService.signInWithGoogle();

          if (context.mounted && AuthService.isAuthenticated()) {
            pushAndClearHistory(context, const DashboardScreen());
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
