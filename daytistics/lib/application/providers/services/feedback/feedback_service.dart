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
    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.featureRequestsTableName)
        .insert({
      'title': title,
      'description': description,
      'user_id': ref.read(userDependencyProvider)!.id,
    });

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'feature_request_created',
      properties: {
        'title': title,
        'description': description,
      },
    );
  }

  Future<void> createBugReport(String title, String description) async {
    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.bugReportsTableName)
        .insert({
      'title': title,
      'description': description,
      'user_id': ref.read(userDependencyProvider)!.id,
    });

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'bug_report_created',
      properties: {
        'title': title,
        'description': description,
      },
    );
  }
}
