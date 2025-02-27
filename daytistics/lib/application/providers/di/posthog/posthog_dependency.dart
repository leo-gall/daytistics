import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'posthog_dependency.g.dart';

@riverpod
Posthog posthogDependency(Ref ref) {
  final posthog = Posthog();
  final User? user = ref.watch(userDependencyProvider);
  if (user != null) {
    posthog.identify(userId: user.id);
  }
  return posthog;
}
