// import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
// import 'package:daytistics/application/providers/di/supabase/supabase.dart';
// import 'package:daytistics/application/providers/di/user/user.dart';
// import 'package:daytistics/application/providers/services/feedback/feedback_service.dart';
// import 'package:daytistics/config/settings.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../../container.dart';
// import '../../../fakes.dart';

void main() {
  // late ProviderContainer container;
  // late SupabaseClient mockSupabase;
  // late MockSupabaseHttpClient mockHttpClient;
  // late FakePosthog fakePosthog;

  // setUpAll(() {
  //   mockHttpClient = MockSupabaseHttpClient();
  //   mockSupabase = SupabaseClient(
  //     'https://mock.supabase.co',
  //     'fakeAnonKey',
  //     httpClient: mockHttpClient,
  //   );
  // });

  // setUp(() {
  //   fakePosthog = FakePosthog();
  //   container = createContainer(
  //     overrides: [
  //       supabaseClientDependencyProvider.overrideWith((ref) => mockSupabase),
  //       posthogDependencyProvider.overrideWith((ref) => fakePosthog),
  //       userDependencyProvider.overrideWith(
  //         (ref) => User(
  //           id: 'user-id',
  //           aud: 'authenticated',
  //           appMetadata: {},
  //           createdAt: DateTime.now().toIso8601String(),
  //           userMetadata: {},
  //         ),
  //       ),
  //     ],
  //   );
  // });

  // tearDown(() async {
  //   mockHttpClient.reset();
  // });

  // tearDownAll(() {
  //   mockHttpClient.close();
  // });

  // group('FeedbackService', () {
  //   test('createFeatureRequest inserts row and sends event', () async {
  //     final service = container.read(feedbackServiceProvider.notifier);
  //     const title = 'New Feature';
  //     const description = 'Add dark mode support';

  //     await service.createFeatureRequest(title, description);

  //     // Verify the row was inserted in the feature requests table.
  //     final dbResult = await mockSupabase
  //         .from(SupabaseSettings.featureRequestsTableName)
  //         .select();
  //     expect(dbResult.length, 1);
  //     expect(dbResult[0]['title'], title);
  //     expect(dbResult[0]['description'], description);
  //     expect(dbResult[0]['user_id'], 'user-id');

  //     // Verify that the Posthog event was captured.
  //     expect(
  //       fakePosthog.capturedEvents.contains('feature_request_created'),
  //       isTrue,
  //     );
  //   });

  //   test('createBugReport inserts row and sends event', () async {
  //     final service = container.read(feedbackServiceProvider.notifier);
  //     const title = 'Bug Found';
  //     const description = 'App crashes on login';

  //     await service.createBugReport(title, description);

  //     // Verify the row was inserted in the bug reports table.
  //     final dbResult = await mockSupabase
  //         .from(SupabaseSettings.bugReportsTableName)
  //         .select();
  //     expect(dbResult.length, 1);
  //     expect(dbResult[0]['title'], title);
  //     expect(dbResult[0]['description'], description);
  //     expect(dbResult[0]['user_id'], 'user-id');

  //     // Verify that the Posthog event was captured.
  //     expect(fakePosthog.capturedEvents.contains('bug_report_created'), isTrue);
  //   });
  // });
}
