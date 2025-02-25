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
          UserAttributes(data: {'onboarding_completed': true}),
        );
  }

  bool get hasCompletedOnboarding {
    final user = ref.read(userDependencyProvider);
    return (user?.userMetadata?['onboarding_completed'] as bool?) ?? false;
  }
}

@riverpod
OnboardingService onboardingService(Ref ref) => OnboardingService(ref);
