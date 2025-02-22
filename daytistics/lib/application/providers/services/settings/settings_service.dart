import 'package:daytistics/application/models/user_settings.dart';
import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/config/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_service.g.dart';

class SettingsServiceState {
  UserSettings? userSettings;

  SettingsServiceState({this.userSettings});

  SettingsServiceState copyWith({
    UserSettings? userSettings,
  }) {
    return SettingsServiceState(
      userSettings: userSettings ?? this.userSettings,
    );
  }
}

@riverpod
class SettingsService extends _$SettingsService {
  @override
  SettingsServiceState build() {
    return SettingsServiceState();
  }

  Future<void> toggleNotifications() async {
    if (state.userSettings == null) await init();

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.settingsTableName)
        .update({
      'notifications': !state.userSettings!.notifications,
    }).eq('user_id', ref.read(userDependencyProvider)!.id);

    state = state.copyWith(
      userSettings: state.userSettings!.copyWith(
        notifications: !state.userSettings!.notifications,
      ),
    );

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'settings_changed',
      properties: {
        'field': 'notifications',
        'old_value': !state.userSettings!.notifications,
        'new_value': state.userSettings!.notifications,
      },
    );
  }

  Future<void> toggleConversationAnalytics() async {
    if (state.userSettings == null) await init();

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.settingsTableName)
        .update({
      'conversation_analytics': !state.userSettings!.conversationAnalytics,
    }).eq('user_id', ref.read(userDependencyProvider)!.id);

    state = state.copyWith(
      userSettings: state.userSettings!.copyWith(
        conversationAnalytics: !state.userSettings!.conversationAnalytics,
      ),
    );

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'settings_changed',
      properties: {
        'field': 'conversation_analytics',
        'old_value': !state.userSettings!.conversationAnalytics,
        'new_value': state.userSettings!.conversationAnalytics,
      },
    );
  }

  Future<void> init() async {
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
      state = state.copyWith(
        userSettings: userSettings,
      );
    } else {
      state = state.copyWith(
        userSettings: UserSettings.fromSupabase(settings),
      );
    }
  }
}
