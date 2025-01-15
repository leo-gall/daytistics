import 'package:daytistics/config/settings.dart';
import 'package:daytistics/features/auth/viewmodels/auth_view_model.dart';
import 'package:daytistics/features/dashboard/views/dashboard_view.dart';
import 'package:daytistics/shared/utils/routing.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthViewModel authViewModel = ref.watch(authViewModelProvider);

    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: () async {
          switch (provider) {
            case OAuthProvider.google:
              await authViewModel.signInWithGoogle(context);
              break;
            case OAuthProvider.apple:
              throw UnimplementedError('Apple sign in is not implemented yet');
            default:
              throw UnimplementedError('Unsupported provider: $provider');
          }

          if (context.mounted && authViewModel.isAuthenticated()) {
            pushAndClearHistory(context, const DashboardView());
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
