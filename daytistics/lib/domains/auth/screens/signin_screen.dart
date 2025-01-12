import 'package:daytistics_app/config/settings.dart';
import 'package:daytistics_app/domains/auth/services/auth_service.dart';
import 'package:daytistics_app/domains/dashboard/screens/dashboard_screen.dart';
import 'package:daytistics_app/shared/utils/browser.dart';
import 'package:daytistics_app/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorSettings.secondary, ColorSettings.primary],
            transform: GradientRotation(0.3),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            SvgPicture.asset(
              'assets/svg/daytistics_mono.svg',
              width: 130,
              height: 130,
            ),
            const Text(
              'Daytistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            _buildGoogleSignInButton(),
            const SizedBox(height: 5),
            _buildAppleSignInButton(),
            const SizedBox(height: 10),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: () => _openLogInAsGuestModal(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/svg/google_mono.svg',
              colorFilter: const ColorFilter.mode(
                ColorSettings.primary,
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 10),
            const Text('Sign in with Google'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleSignInButton() {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/svg/apple_mono.svg',
              colorFilter: const ColorFilter.mode(
                ColorSettings.primary,
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 10),
            const Text('Sign in with Apple'),
          ],
        ),
      ),
    );
  }

  void _openLogInAsGuestModal() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: ColorSettings.background,
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              StyledText(
                'Login as guest',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: StyledText(
                  'You can login as a guest to explore the app without creating an account. Please note that your data will not be saved.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.signInAnonymously();

                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegalLinks() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ensure column takes minimum space

      children: [
        TextButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                EdgeInsets.zero), // Remove internal padding
            visualDensity:
                VisualDensity.compact, // Reduce space inside the button
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: () => openUrl('https://daytistics.com/legal/privacy'),
          child: const Text('Privacy Policy'),
        ),
        TextButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            visualDensity: VisualDensity.compact,
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: () => openUrl('https://daytistics.com/legal/terms'),
          child: const Text('Terms of Service'),
        ),
        TextButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            visualDensity: VisualDensity.compact,
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: () => openUrl('https://daytistics.com/legal/imprint'),
          child: const Text('Imprint'),
        ),
      ],
    );
  }
}
