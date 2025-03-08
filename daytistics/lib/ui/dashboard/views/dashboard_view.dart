import 'package:daytistics/application/providers/services/onboarding/onboarding_service.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/widgets/input/prompt_input_field.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/dashboard/widgets/dashboard_calendar.dart';
import 'package:daytistics/ui/dashboard/widgets/dashboard_date_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final GlobalKey _selectDate = GlobalKey();
  final GlobalKey _editDaytistic = GlobalKey();
  final GlobalKey _startConversation = GlobalKey();
  final GlobalKey _listConversations = GlobalKey();
  final GlobalKey _viewProfile = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RequireAuth(
      child: ShowCaseWidget(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!ref
                .read(onboardingServiceProvider)
                .hasCompletedDashboardOnboarding) {
              showConfirmationDialog(
                context,
                title: 'Showcase',
                message:
                    'Would you like to take a quick tour of the dashboard?',
                onConfirm: () async {
                  await ref
                      .read(onboardingServiceProvider)
                      .completeDashboardOnboarding();
                  if (context.mounted) {
                    ShowCaseWidget.of(context).startShowCase([
                      _selectDate,
                      _editDaytistic,
                      _startConversation,
                      _listConversations,
                      _viewProfile,
                    ]);
                  }
                },
                onCancel: () async => ref
                    .read(onboardingServiceProvider)
                    .completeDashboardOnboarding(),
                cancelText: 'No',
                confirmText: 'Yes',
                popBeforeConfirm: true,
              );
            }
          });

          return Scaffold(
            resizeToAvoidBottomInset: false,
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
                Showcase(
                  key: _listConversations,
                  title: 'Conversations List',
                  description: 'View your previous conversations.',
                  child: IconButton(
                    icon: const Icon(Icons.all_inbox_outlined),
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        '/conversations-list',
                      );
                    },
                  ),
                ),
                Showcase(
                  key: _viewProfile,
                  title: 'Profile',
                  description: 'View and edit your preferences.',
                  child: IconButton(
                    icon: const Icon(Icons.person_2_outlined),
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ),
              ],
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  Showcase(
                    key: _startConversation,
                    title: 'Chat',
                    description: 'Type in your question and press enter.',
                    child: PromptInputField(
                      onChat: (query, reply) =>
                          Navigator.pushNamed(context, '/chat'),
                    ),
                  ),
                  Expanded(
                    child: Showcase(
                      key: _selectDate,
                      title: 'Calendar',
                      description:
                          'Select a date, where you want to view the daytistic.',
                      child: const DashboardCalendar(),
                    ),
                  ),
                  DashboardDateCard(editDaytisticKey: _editDaytistic),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
