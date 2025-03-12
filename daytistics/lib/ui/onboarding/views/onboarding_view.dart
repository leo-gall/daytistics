import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/onboarding/onboarding_service.dart';
import 'package:daytistics/application/providers/services/settings/settings_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/notifications.dart';
import 'package:daytistics/shared/presets/home_view_preset.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/input/time_picker_input_field.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const StyledText(
        'Welcome to Daytistics, an innovative app to gain insights into your daily activities.',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      const StyledText(
        "To gain insights, you'll need to track your daily activities and rate your days regularly.",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      const StyledText(
        'Then, chat with our AI to get personalized insights on your daily activities.',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      const StyledText(
        "We're in beta and really need your feedback! Please share your thoughts with us in the profile section.",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
    ];

    return HomeViewPreset(
      child: Column(
        children: <Widget>[
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: pages[_currentPage],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () async {
              if (await maybeRedirectToConnectionErrorView(context)) return;
              if (_currentPage < pages.length - 1) {
                setState(() {
                  _currentPage++;
                });
              } else {
                if (context.mounted) {
                  await _showConversationAnalyticsDialog(
                    context,
                    onDone: () {
                      if (context.mounted) {
                        _showDailyReminderTimeDialog(
                          context,
                          onDone: () async {
                            await _showShowcaseDialog(
                              context,
                              onDone: ({required shouldStartShowcase}) async {
                                await ref
                                    .read(onboardingServiceProvider)
                                    .completeOnboarding();
                                if (context.mounted) {
                                  await Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                    '/',
                                    (route) => false,
                                    arguments: {
                                      'shouldStartShowcase': shouldStartShowcase
                                    },
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                }
              }
            },
            child: StyledText(
              pages.length - 1 == _currentPage ? "Okay, let's go!" : 'Next',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConversationAnalyticsDialog(
    BuildContext context, {
    required void Function() onDone,
  }) async {
    showConfirmationDialog(
      context,
      title: 'Allow Analytics',
      message: 'Do you want to allow conversation analytics? '
          'By enabling this setting, you agree to share your conversation data with us to improve our services.',
      onConfirm: () async {
        await ref
            .read(settingsServiceProvider)
            .updateConversationAnalytics(value: true);

        onDone();
      },
      onCancel: () async {
        await ref
            .read(settingsServiceProvider)
            .updateConversationAnalytics(value: false);
        onDone();
      },
      cancelText: 'Deny',
      confirmText: 'Accept',
      disableOutsideClickClose: true,
    );
  }

  Future<void> _showDailyReminderTimeDialog(BuildContext context,
      {required void Function() onDone}) async {
    TimeOfDay timeOfDay = TimeOfDay.now();

    await showDialog<AlertDialog>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Daily Reminder Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Would you like to set a daily reminder to track your day?'),
              const SizedBox(height: 20),
              TimePickerInputField(
                  onChanged: (selectedTime) async {
                    timeOfDay = selectedTime;
                  },
                  title: 'Daily Reminder Time'),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 6.0),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDone();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Colors.transparent,
                ),
              ),
              child: const StyledText(
                'Skip',
                style: TextStyle(color: ColorSettings.error),
              ),
            ),
            TextButton(
              onPressed: () {
                maybeAskAllowNotifications();
                ref
                    .read(settingsServiceProvider)
                    .updateDailyReminderTime(timeOfDay: timeOfDay);
                Navigator.of(context).pop();
                onDone();
              },
              child: const StyledText(
                'Done',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showShowcaseDialog(
    BuildContext context, {
    required void Function({required bool shouldStartShowcase}) onDone,
  }) async {
    bool shouldStartShowcase = false;
    showConfirmationDialog(
      context,
      disableOutsideClickClose: true,
      title: 'Showcase',
      message: 'Would you like to take a quick tour of the dashboard?',
      onConfirm: () async {
        shouldStartShowcase = true;
        onDone(
          shouldStartShowcase: shouldStartShowcase,
        );
      },
      onCancel: () async {
        shouldStartShowcase = false;
        onDone(
          shouldStartShowcase: shouldStartShowcase,
        );
      },
      cancelText: 'No',
      confirmText: 'Yes',
      popBeforeConfirm: true,
    );
  }
}
