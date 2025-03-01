import 'dart:io';

import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/presets/home_view_preset.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/auth/widgets/guest_signin_dialog.dart';

import 'package:daytistics/ui/auth/widgets/oauth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  @override
  Widget build(BuildContext context) {
    return HomeViewPreset(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 50),
          if (Platform.isAndroid) const OAuthButton(OAuthProvider.google),
          if (Platform.isIOS) const OAuthButton(OAuthProvider.apple),
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
            ),
            onPressed: _openLogInAsGuestModal,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.science_outlined,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text('Try Daytistics'),
              ],
            ),
          ),
          const Spacer(),
          _buildLegalLinks(),
        ],
      ),
    );
  }

  void _openLogInAsGuestModal() {
    showBottomDialog(context, child: const GuestSigninDialog());
  }

  Widget _buildLegalLinks() {
    final Map<String, String> legalLinks = <String, String>{
      'Privacy Policy': LegalSettings.privacyPolicyUrl,
      'Imprint': LegalSettings.imprintUrl,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final String title in legalLinks.keys)
          TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              visualDensity: VisualDensity.compact,
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
            ),
            onPressed: () => openUrl(legalLinks[title]!),
            child: StyledText(title),
          ),
      ],
    );
  }
}
