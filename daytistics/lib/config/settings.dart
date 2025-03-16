import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SupabaseSettings {
  static final String url = (kDebugMode && Platform.isAndroid)
      ? const String.fromEnvironment('SUPABASE_ANDROID_URL')
      : const String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Tables
  static const String daytisticsTableName = 'daytistics';
  static const String activitiesTableName = 'activities';
  static const String wellbeingsTableName = 'wellbeings';
  static const String conversationsTableName = 'conversations';
  static const String conversationMessagesTableName = 'conversation_messages';
  static const String settingsTableName = 'user_settings';
}

class PosthogSettings {
  static String apiKey = const String.fromEnvironment('POSTHOG_API_KEY');
  static String host = const String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://eu.i.posthog.com',
  );
}

class SentrySettings {
  static String dsn = const String.fromEnvironment('SENTRY_DSN');
}

class ColorSettings {
  static const Color primary = Color(0xFF0E9F6E);
  static const Color primaryAccent = Color(0xFF384B41);
  static const Color secondary = Color.fromRGBO(92, 107, 192, 1);
  static const Color secondaryAccent = Color(0xFF0064A6);
  static const Color background = Color(0xFFE5E5E5);
  static const Color textDark = Color.fromRGBO(60, 59, 59, 1);
  static const Color textLight = Color.fromRGBO(125, 125, 125, 1);
  static const Color success = Color.fromRGBO(9, 149, 110, 1);
  static const Color warning = Color.fromRGBO(212, 172, 13, 1);
  static const Color error = Color.fromRGBO(212, 13, 13, 1);
  static const Color info = Color.fromRGBO(13, 107, 212, 1);
}

class LegalSettings {
  static const String privacyPolicyUrl = 'https://daytistics.com/privacy';
  static const String imprintUrl = 'https://daytistics.com/imprint';
}

class NotificationSettings {
  static const String channelId = 'daytistics_channel';
  static const String channelName = 'Daytistics';
  static const String channelDescription = 'Daytistics notifications';
  static const int dailyReminderId = 1;
  static const int debugId = 999;
}
