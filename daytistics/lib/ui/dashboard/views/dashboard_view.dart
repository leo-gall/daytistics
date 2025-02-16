import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/services/auth/auth_service.dart';
import 'package:daytistics/shared/widgets/application/chat_list_modal.dart';
import 'package:daytistics/shared/widgets/application/prompt_input_field.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/auth/views/sign_in_view.dart';
import 'package:daytistics/ui/dashboard/widgets/dashboard_calendar.dart';
import 'package:daytistics/ui/dashboard/widgets/dashboard_date_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
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
            icon: const Icon(Icons.all_inbox_outlined),
            onPressed: () async {
              ChatListModal.showModal(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_2_outlined),
            onPressed: () async {
              // await ref.read(authServiceProvider.notifier).signOut();

              // if (ref.watch(supabaseClientProvider).auth.currentUser == null) {
              //   if (context.mounted) {
              //     await Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute<SignInView>(
              //         builder: (context) => const SignInView(),
              //       ),
              //       (route) => false,
              //     );
              //   }
              // }

              await Navigator.pushNamed(context, '/profile');
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
      body: RequireAuth(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                PromptInputField(
                  onChat: (query, reply) =>
                      Navigator.pushNamed(context, '/chat'),
                ),
                const DashboardCalendar(),
                const DashboardDateCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
