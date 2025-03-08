import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'onboarding_service.g.dart';

class OnboardingService {
  Ref ref;

  OnboardingService(this.ref);

  Future<void> completeOnboardingScreens() async {
    await ref.read(supabaseClientDependencyProvider).auth.updateUser(
          UserAttributes(
            data: {
              'onboarding': {
                'screens': true,
                'dashboard': hasCompletedDashboardOnboarding,
              },
            },
          ),
        );
  }

  Future<void> completeDashboardOnboarding() async {
    await ref.read(supabaseClientDependencyProvider).auth.updateUser(
          UserAttributes(
            data: {
              'onboarding': {
                'dashboard': true,
                'screens': hasCompletedOnboardingScreens,
              },
            },
          ),
        );
  }

  bool get hasCompletedOnboardingScreens {
    final user = ref.read(userDependencyProvider);
    final onboarding = user?.userMetadata?['onboarding'];

    if (onboarding is Map) {
      return (onboarding['screens'] as bool?) ?? false;
    } else if (onboarding is bool) {
      return onboarding;
    }

    return false;
  }

  bool get hasCompletedDashboardOnboarding {
    final user = ref.read(userDependencyProvider);
    final onboarding = user?.userMetadata?['onboarding'];

    if (onboarding is Map) {
      return (onboarding['dashboard'] as bool?) ?? false;
    } else if (onboarding is bool) {
      return onboarding;
    }

    return false;
  }
}

@riverpod
OnboardingService onboardingService(Ref ref) => OnboardingService(ref);
