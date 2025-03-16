import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'onboarding_service.g.dart';

class OnboardingService {
  Ref ref;

  OnboardingService(this.ref);

  Future<void> completeOnboarding() async {
    await ref.read(supabaseClientDependencyProvider).auth.updateUser(
          UserAttributes(
            data: {'onboarding': true},
          ),
        );
  }

  bool get hasCompletedOnboarding {
    final user = ref.read(userDependencyProvider);
    final onboarding = user?.userMetadata?['onboarding'];

    return onboarding != null && onboarding as bool;
  }
}

@riverpod
OnboardingService onboardingService(Ref ref) => OnboardingService(ref);
