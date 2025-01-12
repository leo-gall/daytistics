import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: dotenv.env['SUPABASE_AUTH_EXTERNAL_GOOGLE_IOS_ID'],
      serverClientId: dotenv.env['SUPABASE_AUTH_EXTERNAL_GOOGLE_WEB_ID'],
    );
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return;
    }
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}
