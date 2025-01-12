import 'package:daytistics/config/settings.dart';
import 'package:daytistics/domains/auth/services/auth_service.dart';
import 'package:daytistics/domains/dashboard/screens/dashboard_screen.dart';
import 'package:daytistics/shared/utils/routing.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

class GuestSignInModal extends StatelessWidget {
  const GuestSignInModal({super.key});

  @override
  Widget build(BuildContext context) {
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
                pushAndClearHistory(context, const DashboardScreen());
              }
            },
            child: const StyledText('Continue'),
          ),
        ],
      ),
    );
  }
}
