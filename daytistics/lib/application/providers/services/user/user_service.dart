import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/settings/settings_service.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_service.g.dart';

class UserService {
  final Ref ref;

  UserService(this.ref);

  Future<void> signInAnonymously() async {
    await ref.read(supabaseClientDependencyProvider).auth.signInAnonymously();

    await ref.read(settingsServiceProvider).initializeSettings();

    await ref.read(analyticsDependencyProvider).trackEvent(
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

    await ref
        .read(analyticsDependencyProvider)
        .trackEvent(eventName: 'sign_out');

    await Restart.restartApp();
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

        await ref.read(analyticsDependencyProvider).trackEvent(
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
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        rethrow;
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: const String.fromEnvironment(
          'SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID',
        ),
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

      await ref.read(analyticsDependencyProvider).trackEvent(
            eventName: 'google_sign_in',
          );
    } on Exception catch (e) {
      if (!e.toString().contains('User cancelled the sign-in process')) {
        return;
      }
    }
  }

  Future<void> deleteAccount() async {
    await ref
        .read(supabaseClientDependencyProvider)
        .rpc<dynamic>('delete_account');

    await ref
        .read(analyticsDependencyProvider)
        .trackEvent(eventName: 'account_deleted');

    await Restart.restartApp();
  }

  /// Exports user data to a JSON file.
  ///
  /// This function calls a Supabase function to export the data, captures an event in the configured analytics service,
  /// and saves the data to a JSON file in the application documents directory.
  ///
  /// Returns:
  ///   A Future&lt;String&gt; that resolves to the file path of the exported JSON file.
  ///
  /// Throws:
  ///   ServerException: If the Supabase function call fails (status code is not 200).
  Future<String> exportData() async {
    final response = await ref
        .read(supabaseClientDependencyProvider)
        .functions
        .invoke('data-export');

    await ref
        .read(analyticsDependencyProvider)
        .trackEvent(eventName: 'data_exported');

    if (response.status == 200) {
      final String jsonString = jsonEncode(response.data);
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File(
        '${directory.path}/daytistics_data_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonString);

      return file.path;
    } else {
      await ref.read(analyticsDependencyProvider).trackEvent(
        eventName: 'data_export_failed',
        properties: {
          'data': response.data.toString(),
          'status': response.status.toString(),
        },
      );
      throw SupabaseException('Failed to export data.');
    }
  }
}

@Riverpod(keepAlive: true)
UserService userService(Ref ref) => UserService(ref);
