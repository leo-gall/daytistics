import 'package:daytistics/screens/auth/repositories/auth_repository.dart';
import 'package:daytistics/shared/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

class AuthViewModel {
  final AuthRepository authRepository;

  AuthViewModel(this.authRepository);

  bool isAuthenticated() {
    return authRepository.isAuthenticated;
  }

  Future<void> signInAnonymously() async {
    await authRepository.signInAnonymously();
  }

  Future<void> signOut() async {
    await authRepository.signOut();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: dotenv.env['SUPABASE_AUTH_EXTERNAL_GOOGLE_IOS_ID'],
        serverClientId: dotenv.env['SUPABASE_AUTH_EXTERNAL_GOOGLE_WEB_ID'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw 'User cancelled the sign-in process.';
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await authRepository.signInWithGoogle(idToken, accessToken);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      showErrorAlert(context, 'Failed to sign in with Google');
      rethrow;
    }
  }
}

@riverpod
AuthViewModel authViewModel(Ref ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
}
