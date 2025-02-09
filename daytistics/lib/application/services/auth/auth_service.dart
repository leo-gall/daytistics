import 'package:daytistics/application/repositories/auth/auth_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

class AuthServiceState {}

@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  late AuthRepository _authRepository;

  @override
  AuthServiceState build() {
    _authRepository = ref.read(authRepositoryProvider);
    return AuthServiceState();
  }

  bool isAuthenticated() {
    return _authRepository.isAuthenticated;
  }

  Future<void> signInAnonymously() async {
    await _authRepository.signInAnonymously();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
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

      await _authRepository.signInWithGoogle(idToken, accessToken);
    } catch (e) {
      rethrow;
    }
  }
}
