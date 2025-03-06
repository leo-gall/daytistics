import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/config/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_service.g.dart';

class FeedbackServiceState {}

@riverpod
class FeedbackService extends _$FeedbackService {
  @override
  FeedbackServiceState build() {
    return FeedbackServiceState();
  }

  Future<void> createFeatureRequest(String title, String description) async {
    await ref.read(supabaseClientDependencyProvider).functions.invoke(
      'add-to-roadmap',
      body: {
        'roadmap': 'features',
        'title': title,
        'description': description,
      },
    );
  }

  Future<void> createBugReport(String title, String description) async {
    await ref.read(supabaseClientDependencyProvider).functions.invoke(
      'add-to-roadmap',
      body: {
        'roadmap': 'bugs',
        'title': title,
        'description': description,
      },
    );
  }
}
