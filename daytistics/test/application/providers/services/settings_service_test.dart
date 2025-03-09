import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/services/settings/settings_service.dart';
import 'package:daytistics/application/providers/state/settings/settings.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter/material.dart' show TimeOfDay;
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
    settingsService = container.read(settingsServiceProvider);
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
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

  group('updateDailyReminderTime', () {
    test('should update the daily reminder time', () async {
      // Setup initial settings
      await mockSupabase.from(SupabaseSettings.settingsTableName).insert([
        {
          'id': 'user-settings-1',
          'user_id': 'user-1',
          'conversation_analytics': true,
          'daily_reminder_time': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ]);

      // Initialize settings in the provider
      await settingsService.initializeSettings();

      // Update daily reminder time
      await settingsService.updateDailyReminderTime(
          timeOfDay: const TimeOfDay(hour: 9, minute: 30));

      // Verify Supabase was updated
      final response = await mockSupabase
          .from('user_settings')
          .select()
          .eq('user_id', 'user-1')
          .single();

      expect(response['daily_reminder_time'], '08:30');

      // Verify provider state was updated
      final state = container.read(settingsProvider);
      expect(state!.dailyReminderTime!.hour, 9);
      expect(state.dailyReminderTime!.minute, 30);
    });

    test('should set daily reminder time to null', () async {
      // Setup initial settings with an existing reminder time
      await mockSupabase.from(SupabaseSettings.settingsTableName).insert([
        {
          'id': 'user-settings-2',
          'user_id': 'user-1',
          'conversation_analytics': true,
          'daily_reminder_time': '08:00',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ]);

      // Initialize settings in the provider
      await settingsService.initializeSettings();

      // Update daily reminder time to null
      await settingsService.updateDailyReminderTime(timeOfDay: null);

      // Verify Supabase was updated
      final response = await mockSupabase
          .from('user_settings')
          .select()
          .eq('user_id', 'user-1')
          .single();

      expect(response['daily_reminder_time'], null);

      // Verify provider state was updated
      final state = container.read(settingsProvider);
      expect(state!.dailyReminderTime, null);
    });

    test('should pad hours and minutes correctly', () async {
      // Setup initial settings
      await mockSupabase.from(SupabaseSettings.settingsTableName).insert([
        {
          'id': 'user-settings-3',
          'user_id': 'user-1',
          'conversation_analytics': true,
          'daily_reminder_time': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ]);

      // Initialize settings in the provider
      await settingsService.initializeSettings();

      // Update daily reminder time with single-digit hour and minute
      await settingsService.updateDailyReminderTime(
          timeOfDay: const TimeOfDay(hour: 7, minute: 5));

      // Verify Supabase was updated with padded values
      final response = await mockSupabase
          .from('user_settings')
          .select()
          .eq('user_id', 'user-1')
          .single();

      expect(response['daily_reminder_time'], '06:05');
    });
  });

  test('read state', () async {
    await mockSupabase.from(SupabaseSettings.settingsTableName).insert([
      {
        'id': 'user-settings-1',
        'user_id': 'user-1',
        'conversation_analytics': true,
        'daily_reminder_time': '08:00',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ]);

    await settingsService.toggleConversationAnalytics();

    final state = container.read(settingsProvider);

    expect(state!.conversationAnalytics, false);
  });
}
