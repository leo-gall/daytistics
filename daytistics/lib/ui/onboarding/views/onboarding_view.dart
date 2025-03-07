import 'package:daytistics/application/providers/services/onboarding/onboarding_service.dart';
import 'package:daytistics/shared/presets/home_view_preset.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final List<Widget> _pages = <Widget>[
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
  ];

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return HomeViewPreset(
      child: Column(
        children: <Widget>[
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _pages[_currentPage],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () async {
              if (await maybeRedirectToConnectionErrorView(context)) return;
              if (_currentPage < _pages.length - 1) {
                setState(() {
                  _currentPage++;
                });
              } else {
                await ref.read(onboardingServiceProvider).completeOnboarding();
                if (context.mounted) {
                  await Navigator.of(context).pushNamedAndRemoveUntil('/',
                      (route) {
                    return false;
                  });
                }
              }
            },
            child: StyledText(
              _pages.length - 1 == _currentPage ? "Okay, let's go!" : 'Next',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
