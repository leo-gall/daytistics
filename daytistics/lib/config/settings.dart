import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseSettings {
  static final String url = dotenv.env['SUPABASE_URL']!;
  static final String anonKey = dotenv.env['SUPABASE_ANON_KEY']!;
}

class ColorSettings {
  static const Color primary = Color(0xFF0E9F6E);
  static const Color primaryAccent = Color(0xFF384B41);
  static const Color secondary = Color(0xFF0097DD);
  static const Color secondaryAccent = Color(0xFF0064A6);
  static const Color background = Color(0xFFE5E5E5);
  static const Color text = Color.fromRGBO(113, 111, 111, 1);
  static const Color success = Color.fromRGBO(9, 149, 110, 1);
  static const Color warning = Color.fromRGBO(212, 172, 13, 1);
  static const Color error = Color.fromRGBO(212, 13, 13, 1);
}
