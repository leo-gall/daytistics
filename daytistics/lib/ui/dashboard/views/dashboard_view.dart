import 'package:daytistics/application/services/auth/auth_service.dart';
import 'package:daytistics/ui/auth/views/sign_in_view.dart';
import 'package:daytistics/application/widgets/prompt_input_field.dart';
import 'package:daytistics/ui/dashboard/widgets/dashboard_calendar.dart';
import 'package:daytistics/ui/dashboard/widgets/dashboard_date_card.dart';
import 'package:daytistics/shared/widgets/require_auth.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 4),
            StyledText(
              'Dashboard',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: <Widget>[
          //
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider.notifier).signOut();

              if (!ref.read(authServiceProvider.notifier).isAuthenticated) {
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute<SignInView>(
                      builder: (BuildContext context) => const SignInView(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              }
            },
          ),
          // IconButton(
          //   icon: Icon(
          //     activityTrackerState.isActivityInProgress
          //         ? Icons.stop
          //         : Icons.play_arrow,
          //   ),
          //   onPressed: () {
          //     if (!activityTrackerState.isActivityInProgress) {
          //       activityTrackerViewModel.startActivity(
          //         ActivityEntry(
          //           name: 'Football',
          //           date: DateTime.now(),
          //         ),
          //       );
          //     }

          //     ActivityModal.showModal(
          //       context,
          //       activityEntry: activityTrackerState.currentActivity,
          //     );
          //   },
          // ),
        ],
      ),
      body: const RequireAuth(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                PromptInputField(),
                DashboardCalendar(),
                DashboardDateCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
