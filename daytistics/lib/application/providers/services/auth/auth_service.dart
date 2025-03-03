import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/settings/settings_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
    await ref.read(supabaseClientDependencyProvider).auth.signInAnonymously();

    await ref.read(settingsServiceProvider).initializeSettings();

    await ref.read(posthogDependencyProvider).capture(
          eventName: 'anonymous_sign_in',
        );
  }

  Future<void> signOut() async {
    final bool isAnonymous = ref
            .read(supabaseClientDependencyProvider)
            .auth
            .currentUser
            ?.isAnonymous ??
        true;
    if (isAnonymous) await deleteAccount();
    await ref.read(supabaseClientDependencyProvider).auth.signOut();

    await ref.read(posthogDependencyProvider).capture(eventName: 'sign_out');
  }

  Future<void> signInWithApple() async {
    try {
      if (Platform.isIOS) {
        final rawNonce =
            ref.read(supabaseClientDependencyProvider).auth.generateRawNonce();
        final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce,
        );

        final idToken = credential.identityToken;
        if (idToken == null) {
          throw const AuthException(
            'Could not find ID Token from generated credential.',
          );
        }

        await ref.read(supabaseClientDependencyProvider).auth.signInWithIdToken(
              provider: OAuthProvider.apple,
              idToken: idToken,
              nonce: rawNonce,
            );

        await ref.read(settingsServiceProvider).initializeSettings();

        await ref.read(posthogDependencyProvider).capture(
              eventName: 'apple_sign_in',
            );
      } else {
        // gets the app name from the flutter manifest not .env
        // final String appName = (await PackageInfo.fromPlatform()).appName;
        // await ref.read(supabaseClientDependencyProvider).auth.signInWithOAuth(
        //       OAuthProvider.apple,
        //       authScreenLaunchMode:
        //           kIsWeb ? LaunchMode.platformDefault : LaunchMode.inAppWebView,
        //       redirectTo: 'com.daytistics.daytistics://auth/',
        //     );
        // print('Sign in with Apple initiated.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID'],
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

      await ref.read(supabaseClientDependencyProvider).auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

      await ref.read(settingsServiceProvider).initializeSettings();

      await ref.read(posthogDependencyProvider).capture(
            eventName: 'google_sign_in',
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    await ref
        .read(supabaseClientDependencyProvider)
        .rpc<dynamic>('delete_account');

    await ref
        .read(posthogDependencyProvider)
        .capture(eventName: 'account_deleted');
  }

  Future<void> linkAppleAccount() async {
    await ref
        .read(supabaseClientDependencyProvider)
        .auth
        .linkIdentity(OAuthProvider.google);
  }
}
