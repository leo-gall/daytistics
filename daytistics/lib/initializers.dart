import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseSettings.url,
    anonKey: SupabaseSettings.anonKey,
  );
}

Future<bool> initAwesomeNotifications() {
  return AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelGroupKey: NotificationSettings.channelId,
        channelKey: NotificationSettings.channelId,
        channelName: NotificationSettings.channelName,
        channelDescription: NotificationSettings.channelDescription,
        defaultColor: ColorSettings.primary,
        ledColor: Colors.white,
      ),
    ],
    debug: kDebugMode,
  );
}
