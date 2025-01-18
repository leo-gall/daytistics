import 'package:daytistics/features/activities/models/activity_entry.dart';
import 'package:daytistics/features/activities/viewmodels/activity_tracker_view_model.dart';
import 'package:daytistics/features/activities/widgets/activity_modal.dart';
import 'package:daytistics/features/activities/widgets/activity_modal.dart';
import 'package:daytistics/features/auth/viewmodels/auth_view_model.dart';
import 'package:daytistics/features/auth/views/sign_in_view.dart';
import 'package:daytistics/shared/widgets/require_auth.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthViewModel authViewModel = ref.watch(authViewModelProvider);
    final ActivityTrackerViewModel activityTrackerViewModel =
        ref.watch(activityTrackerViewModelProvider.notifier);

    final activityTrackerState = ref.watch(activityTrackerViewModelProvider);

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
          // TODO: The sign out button should be removed after implementing the settings screen.
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.signOut();

              if (!authViewModel.isAuthenticated()) {
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
          Text(activityTrackerState.isActivityInProgress.toString()),
          IconButton(
            icon: Icon(
              activityTrackerState.isActivityInProgress
                  ? Icons.stop
                  : Icons.play_arrow,
            ),
            onPressed: () {
              if (!activityTrackerState.isActivityInProgress) {
                activityTrackerViewModel.startActivity(
                  ActivityEntry(
                    name: 'Football',
                    date: DateTime.now(),
                  ),
                );
              }

              ActivityModal.showModal(
                context,
                activityEntry: activityTrackerState.currentActivity,
              );
            },
          ),
        ],
      ),
      body: RequireAuth(
        child: Center(
          child: Column(
            children: <Widget>[
              TableCalendar<dynamic>(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
