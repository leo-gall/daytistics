import 'package:daytistics/application/models/user_settings.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
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
  late FakeAnalytics fakeAnalytics;

  setUpAll(() {
    mockHttpClient = MockSupabaseHttpClient();

    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fakeAnonKey',
      httpClient: mockHttpClient,
    );
  });

  setUp(() {
    fakeAnalytics = FakeAnalytics();

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
        analyticsDependencyProvider.overrideWith((ref) => fakeAnalytics),
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

    expect(fakeAnalytics.capturedEvents.contains('settings_changed'), isTrue);
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
        timeOfDay: const TimeOfDay(hour: 9, minute: 30),
      );

      // Verify Supabase was updated
      final response = await mockSupabase
          .from('user_settings')
          .select()
          .eq('user_id', 'user-1')
          .single();

      final UserSettings userSettings = UserSettings.fromSupabase(response);
      final String formattedDailyReminderTime =
          '${userSettings.dailyReminderTime!.hour.toString().padLeft(2, '0')}:${userSettings.dailyReminderTime!.minute.toString().padLeft(2, '0')}';

      expect(formattedDailyReminderTime, '09:30');

      // Verify provider state was updated
      final state = container.read(settingsProvider);
      expect(state!.dailyReminderTime!.hour, 9);
      expect(state.dailyReminderTime!.minute, 30);

      expect(fakeAnalytics.capturedEvents.contains('settings_changed'), isTrue);
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

      expect(fakeAnalytics.capturedEvents.contains('settings_changed'), isTrue);
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
        timeOfDay: const TimeOfDay(hour: 7, minute: 5),
      );

      // Verify Supabase was updated with padded values
      final response = await mockSupabase
          .from('user_settings')
          .select()
          .eq('user_id', 'user-1')
          .single();

      final UserSettings userSettings = UserSettings.fromSupabase(response);
      final String formattedDailyReminderTime =
          '${userSettings.dailyReminderTime!.hour.toString().padLeft(2, '0')}:${userSettings.dailyReminderTime!.minute.toString().padLeft(2, '0')}';

      expect(formattedDailyReminderTime, '07:05');

      expect(fakeAnalytics.capturedEvents.contains('settings_changed'), isTrue);
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
