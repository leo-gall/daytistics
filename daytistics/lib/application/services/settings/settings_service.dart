import 'package:daytistics/application/models/user_settings.dart';
import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/providers/user/user.dart';
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
        .read(supabaseClientProvider)
        .from(SupabaseSettings.settingsTableName)
        .update({
      'notifications': !state.userSettings!.notifications,
    }).eq('user_id', ref.read(userProvider)!.id);

    state = state.copyWith(
      userSettings: state.userSettings!.copyWith(
        notifications: !state.userSettings!.notifications,
      ),
    );
  }

  Future<void> toggleConversationAnalytics() async {
    if (state.userSettings == null) await init();

    await ref
        .read(supabaseClientProvider)
        .from(SupabaseSettings.settingsTableName)
        .update({
      'conversation_analytics': !state.userSettings!.conversationAnalytics,
    }).eq('user_id', ref.read(userProvider)!.id);

    state = state.copyWith(
      userSettings: state.userSettings!.copyWith(
        conversationAnalytics: !state.userSettings!.conversationAnalytics,
      ),
    );
  }

  Future<void> init() async {
    final settings = await ref
        .read(supabaseClientProvider)
        .from(SupabaseSettings.settingsTableName)
        .select()
        .eq('user_id', ref.read(userProvider)!.id)
        .maybeSingle();

    if (settings == null) {
      final userSettings = UserSettings();
      await ref
          .read(supabaseClientProvider)
          .from(SupabaseSettings.settingsTableName)
          .insert(
            userSettings.toSupabase(userId: ref.read(userProvider)!.id),
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
