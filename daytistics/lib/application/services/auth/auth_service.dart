import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_service.g.dart';

class AuthServiceState {}

@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  @override
  AuthServiceState build() {
    return AuthServiceState();
  }

  Future<void> signInAnonymously() async {
    await ref.read(supabaseClientProvider).auth.signInAnonymously();
  }

  Future<void> signOut() async {
    final bool isAnonymous =
        ref.read(supabaseClientProvider).auth.currentUser?.isAnonymous ?? true;
    if (isAnonymous) await deleteAccount();
    await ref.read(supabaseClientProvider).auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: dotenv.env['SUPABASE_AUTH_EXTERNAL_GOOGLE_IOS_ID'],
        serverClientId: dotenv.env['SUPABASE_AUTH_EXTERNAL_GOOGLE_WEB_ID'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('User cancelled the sign-in process.');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found.');
      }
      if (idToken == null) {
        throw Exception('No ID Token found.');
      }

      await ref.read(supabaseClientProvider).auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    await ref.read(supabaseClientProvider).rpc<dynamic>('delete_account');
  }
}
