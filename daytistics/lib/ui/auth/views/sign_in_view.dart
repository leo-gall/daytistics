import 'package:daytistics/config/settings.dart';
import 'package:daytistics/ui/auth/widgets/guest_signin_modal.dart';
import 'package:daytistics/ui/auth/widgets/oauth_button.dart';

import 'package:daytistics/shared/utils/browser.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[ColorSettings.secondary, ColorSettings.primary],
            transform: GradientRotation(0.3),
          ),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 80),
            SvgPicture.asset(
              'assets/svg/daytistics_mono.svg',
              width: 130,
              height: 130,
            ),
            const StyledText(
              'Daytistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            const OAuthButton(OAuthProvider.google),
            const SizedBox(height: 5),
            const OAuthButton(OAuthProvider.apple),
            const SizedBox(height: 10),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: _openLogInAsGuestModal,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text('Login as guest'),
                ],
              ),
            ),
            const Spacer(),
            _buildLegalLinks(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openLogInAsGuestModal() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return const GuestSignInModal();
      },
    );
  }

  Widget _buildLegalLinks() {
    final Map<String, String> legalLinks = <String, String>{
      'Privacy Policy': LegalSettings.privacyPolicyUrl,
      'Terms of Service': LegalSettings.termsOfServiceUrl,
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
