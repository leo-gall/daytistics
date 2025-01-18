import 'package:daytistics/config/settings.dart';
import 'package:daytistics/features/auth/viewmodels/auth_view_model.dart';
import 'package:daytistics/features/core/views/dashboard_view.dart';
import 'package:daytistics/shared/utils/routing.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuestSignInModal extends ConsumerWidget {
  const GuestSignInModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthViewModel authViewModel = ref.watch(authViewModelProvider);

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
              await authViewModel.signInAnonymously();

              if (context.mounted) {
                pushAndClearHistory(context, const DashboardView());
              }
            },
            child: const StyledText('Continue'),
          ),
        ],
      ),
    );
  }
}
