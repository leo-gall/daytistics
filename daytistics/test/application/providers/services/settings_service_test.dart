import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/services/settings/settings_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../container.dart';
import '../../../fakes.dart';

void main() {
  late SettingsService settingsService;
  late final SupabaseClient mockSupabase;
  late final MockSupabaseHttpClient mockHttpClient;
  late ProviderContainer container;

  setUpAll(() {
    mockHttpClient = MockSupabaseHttpClient();

    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fakeAnonKey',
      httpClient: mockHttpClient,
    );
  });

  setUp(() {
    container = createContainer(
      overrides: [
        supabaseClientDependencyProvider.overrideWith((ref) => mockSupabase),
        userDependencyProvider.overrideWith(
          (ref) => User(
            id: 'user-1',
            aud: 'authenticated',
            appMetadata: {},
            createdAt: DateTime.now().toIso8601String(),
            userMetadata: {},
          ),
        ),
        posthogDependencyProvider.overrideWith((ref) => FakePosthog()),
      ],
    );
    settingsService = container.read(settingsServiceProvider.notifier);
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  test('toggleNotifications', () async {
    await mockSupabase.from('user_settings').insert([
      {
        'id': 'user-settings-1',
        'user_id': 'user-1',
        'notifications': true,
        'conversation_analytics': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ]);

    await settingsService.toggleNotifications();

    final response = await mockSupabase
        .from('user_settings')
        .select()
        .eq('user_id', 'user-1')
        .single();

    expect(response['notifications'], false);
  });

  test('toggleConversationAnalytics', () async {
    await mockSupabase.from(SupabaseSettings.settingsTableName).insert([
      {
        'id': 'user-settings-1',
        'user_id': 'user-1',
        'conversation_analytics': true,
        'notifications': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ]);

    await settingsService.toggleConversationAnalytics();

    final response = await mockSupabase
        .from('user_settings')
        .select()
        .eq('user_id', 'user-1')
        .single();

    expect(response['conversation_analytics'], false);
  });

  test('read state', () async {
    await mockSupabase.from(SupabaseSettings.settingsTableName).insert([
      {
        'id': 'user-settings-1',
        'user_id': 'user-1',
        'conversation_analytics': true,
        'notifications': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ]);

    await settingsService.toggleConversationAnalytics();

    final state = container.read(settingsServiceProvider);

    expect(state.userSettings!.conversationAnalytics, false);
    expect(state.userSettings!.notifications, false);
  });
}
