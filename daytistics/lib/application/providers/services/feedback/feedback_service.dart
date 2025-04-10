import 'package:daytistics/application/providers/di/supabase/supabase.dart';
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
        'kind': 'feature',
        'title': title,
        'description': description,
      },
    );
  }

  Future<void> createBugReport(String title, String description) async {
    await ref.read(supabaseClientDependencyProvider).functions.invoke(
      'add-to-roadmap',
      body: {
        'kind': 'bug',
        'title': title,
        'description': description,
      },
    );
  }
}
