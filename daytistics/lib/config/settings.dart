import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseSettings {
  static final String url = (kDebugMode && Platform.isAndroid)
      ? dotenv.env['SUPABASE_ANDROID_URL']!
      : dotenv.env['SUPABASE_API_URL']!;
  static final String anonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  // Tables
  static const String daytisticsTableName = 'daytistics';
  static const String activitiesTableName = 'activities';
  static const String wellbeingsTableName = 'wellbeings';
  static const String conversationsTableName = 'conversations';
  static const String conversationMessagesTableName = 'conversation_messages';
}

class ColorSettings {
  static const Color primary = Color(0xFF0E9F6E);
  static const Color primaryAccent = Color(0xFF384B41);
  static const Color secondary = Color(0xFF5C6BC0);
  static const Color secondaryAccent = Color(0xFF0064A6);
  static const Color background = Color(0xFFE5E5E5);
  static const Color text = Color.fromRGBO(60, 59, 59, 1);
  static const Color success = Color.fromRGBO(9, 149, 110, 1);
  static const Color warning = Color.fromRGBO(212, 172, 13, 1);
  static const Color error = Color.fromRGBO(212, 13, 13, 1);
}

class LegalSettings {
  static const String privacyPolicyUrl =
      'https://daytistics.com/privacy-policy';
  static const String termsOfServiceUrl =
      'https://daytistics.com/terms-of-service';
  static const String imprintUrl = 'https://daytistics.com/imprint';
}
