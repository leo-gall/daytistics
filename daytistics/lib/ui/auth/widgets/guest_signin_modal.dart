import 'package:daytistics/application/providers/services/auth/auth_service.dart';
import 'package:daytistics/application/providers/services/onboarding/onboarding_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuestSignInModal extends ConsumerWidget {
  const GuestSignInModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final AuthViewModel authViewModel = ref.watch(authViewModelProvider);

    return Container(
      color: ColorSettings.background,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
              await ref.read(authServiceProvider.notifier).signInAnonymously();

              if (context.mounted) {
                if (!ref
                    .read(onboardingServiceProvider)
                    .hasCompletedOnboarding) {
                  await Navigator.pushReplacementNamed(
                    context,
                    '/onboarding',
                  );
                }
              }
            },
            child: const StyledText('Continue'),
          ),
        ],
      ),
    );
  }
}
