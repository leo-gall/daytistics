<<<<<<< HEAD
<<<<<<< HEAD
import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/services/auth/auth_service.dart';
import 'package:daytistics/application/services/settings/settings_service.dart';
=======
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/auth/auth_service.dart';
>>>>>>> 5b16379 (refactor providers structureg)
=======
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/auth/auth_service.dart';
>>>>>>> 5b1637973fed03b97c859d4746f72a1e363866c7
import 'package:daytistics/ui/auth/views/sign_in_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequireAuth extends ConsumerStatefulWidget {
  /// A widget that ensures the user is authenticated before displaying the child widget.
  ///
  /// If the user is not authenticated, they will be redirected to the SignInScreen.
  ///
  /// The [RequireAuth] widget takes a [Widget] as a child, which will be displayed
  /// if the user is authenticated.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// RequireAuth(
  ///   child: SomeProtectedWidget(),
  /// )
  /// ```
  ///
  /// The [RequireAuth] widget uses the [AuthService] to check if the user is authenticated.
  /// If the user is not authenticated, they will be redirected to the SignInScreen.

  const RequireAuth({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RequireAuth> createState() => _RequireAuthState();
}

class _RequireAuthState extends ConsumerState<RequireAuth> {
  @override
  void initState() {
<<<<<<< HEAD
<<<<<<< HEAD
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ref.watch(supabaseClientProvider).auth.currentUser == null) {
        await Navigator.pushAndRemoveUntil(
=======
=======
>>>>>>> 5b1637973fed03b97c859d4746f72a1e363866c7
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.watch(supabaseClientDependencyProvider).auth.currentUser ==
          null) {
        Navigator.pushAndRemoveUntil(
>>>>>>> 5b16379 (refactor providers structureg)
          context,
          MaterialPageRoute<SignInView>(
            builder: (context) => const SignInView(),
          ),
          (route) => false,
        );
      } else {
        await ref.read(settingsServiceProvider.notifier).init();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
