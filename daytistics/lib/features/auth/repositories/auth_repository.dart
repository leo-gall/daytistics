import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool get isAuthenticated => _supabase.auth.currentUser != null;

  Future<void> signInAnonymously() async {
    await _supabase.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> signInWithGoogle(
    String idToken,
    String accessToken,
  ) async {
    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}
