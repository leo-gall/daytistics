import 'package:daytistics/application/models/user_settings.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/state/settings/settings.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';

import 'package:daytistics/shared/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_service.g.dart';

class SettingsService {
  Ref ref;

  SettingsService(this.ref);

  Future<void> toggleConversationAnalytics() async {
    var userSettings = ref.read(settingsProvider);

    if (userSettings == null) await initializeSettings();

    userSettings = ref.read(settingsProvider);
    final newValue = !userSettings!.conversationAnalytics;

    await updateConversationAnalytics(value: newValue);
  }

  Future<void> updateConversationAnalytics({required bool value}) async {
    var userSettings = ref.read(settingsProvider);

    if (userSettings == null) await initializeSettings();

    userSettings = ref.read(settingsProvider);

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.settingsTableName)
        .update({
      'conversation_analytics': value,
    }).eq('user_id', ref.read(userDependencyProvider)!.id);

    ref
        .read(settingsProvider.notifier)
        .update(userSettings!.copyWith(conversationAnalytics: value));

    await ref.read(analyticsDependencyProvider).trackEvent(
      eventName: 'settings_changed',
      properties: {
        'field': 'conversation_analytics',
        'old_value': !value,
        'new_value': value,
      },
    );
  }

  Future<void> updateDailyReminderTime({required TimeOfDay? timeOfDay}) async {
    final userSettings = ref.read(settingsProvider);

    if (userSettings == null) return initializeSettings();

    final timeAsUtc = timeOfDay != null ? timeToUtc(timeOfDay) : null;
    final hours = timeAsUtc?.hour.toString().padLeft(2, '0') ?? '';
    final minutes = timeAsUtc?.minute.toString().padLeft(2, '0') ?? '';

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.settingsTableName)
        .update({
      'daily_reminder_time': timeOfDay != null ? '$hours:$minutes' : null,
    }).eq('user_id', ref.read(userDependencyProvider)!.id);

    await ref.read(analyticsDependencyProvider).trackEvent(
      eventName: 'settings_changed',
      properties: {
        'field': 'daily_reminder_time',
        'old_value': userSettings.dailyReminderTime.toString(),
        'new_value': timeOfDay.toString(),
      },
    );

    ref
        .read(settingsProvider.notifier)
        .update(userSettings.copyWith(dailyReminderTime: timeOfDay));
  }

  Future<void> initializeSettings() async {
    if (ref.read(userDependencyProvider) == null) return;

    final settings = await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.settingsTableName)
        .select()
        .eq('user_id', ref.read(userDependencyProvider)!.id)
        .maybeSingle();

    if (settings == null) {
      final userSettings = UserSettings();
      await ref
          .read(supabaseClientDependencyProvider)
          .from(SupabaseSettings.settingsTableName)
          .insert(
            userSettings.toSupabase(
              userId: ref.read(userDependencyProvider)!.id,
            ),
          );

      ref.read(settingsProvider.notifier).update(userSettings);
    } else {
      ref.read(settingsProvider.notifier).update(
            UserSettings.fromSupabase(settings),
          );
    }
  }
}

@Riverpod(keepAlive: true)
SettingsService settingsService(Ref ref) => SettingsService(ref);
