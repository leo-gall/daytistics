import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  static bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }

  static Future<void> signInAnonymously() async {
    await supabase.auth.signInAnonymously();
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  static Future<void> signInWithGoogle() async {
    // await supabase.auth.signInWithOAuth()
  }
}
