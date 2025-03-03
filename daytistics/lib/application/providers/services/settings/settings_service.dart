import 'package:daytistics/application/models/user_settings.dart';
import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/state/settings/settings.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_service.g.dart';

class SettingsService {
  Ref ref;

  SettingsService(this.ref);

  Future<void> toggleNotifications() async {
    var userSettings = ref.read(settingsProvider);

    if (userSettings == null) {
      await initializeSettings();
      userSettings = ref.read(settingsProvider);
    }

    final newValue = !userSettings!.notifications;

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.settingsTableName)
        .update({
      'notifications': newValue,
    }).eq('user_id', ref.read(userDependencyProvider)!.id);

    ref.read(settingsProvider.notifier).update(
          userSettings.copyWith(notifications: newValue),
        );

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'settings_changed',
      properties: {
        'field': 'notifications',
        'old_value': !userSettings.notifications,
        'new_value': userSettings.notifications,
      },
    );
  }

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

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'settings_changed',
      properties: {
        'field': 'conversation_analytics',
        'old_value': !value,
        'new_value': value,
      },
    );
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
