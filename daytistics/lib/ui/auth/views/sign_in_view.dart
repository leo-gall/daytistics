import 'dart:io';

import 'package:daytistics/shared/presets/home_view_preset.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/ui/auth/widgets/guest_signin_dialog.dart';

import 'package:daytistics/ui/auth/widgets/oauth_button.dart';
import 'package:flutter/material.dart';
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
          const Expanded(child: SizedBox()),
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
                Text(String.fromEnvironment(
                    'SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openLogInAsGuestModal() {
    showBottomDialog(context, child: const GuestSigninDialog());
  }
}
