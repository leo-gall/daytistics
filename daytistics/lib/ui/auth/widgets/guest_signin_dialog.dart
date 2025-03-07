import 'package:daytistics/application/providers/services/onboarding/onboarding_service.dart';
import 'package:daytistics/application/providers/services/user/user_service.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuestSigninDialog extends ConsumerWidget {
  const GuestSigninDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final AuthViewModel authViewModel = ref.watch(authViewModelProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 10),
        StyledText(
          'Try Daytistics as Guest',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: StyledText(
            'Continue as a guest to explore the app without an account. Note that your data will not be saved, and you cannot transfer data from a guest account to a registered account.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () async {
            if (await maybeRedirectToConnectionErrorView(context)) return;
            await ref.read(userServiceProvider).signInAnonymously();

            if (context.mounted) {
              if (!ref.read(onboardingServiceProvider).hasCompletedOnboarding) {
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
    );
  }
}
