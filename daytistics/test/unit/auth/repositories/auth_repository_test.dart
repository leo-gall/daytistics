import 'package:daytistics/features/auth/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ignore: unused_local_variable
  late AuthRepository authRepository;

  setUp(() {
    authRepository = AuthRepository();
  });

  test(
    'Signs in anonymously using the Supabase SDK',
    () {
      // Test implementation here
    },
    skip: true,
  );
}
