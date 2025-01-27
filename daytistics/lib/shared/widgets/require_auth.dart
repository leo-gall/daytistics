import 'package:daytistics/screens/auth/viewmodels/auth_view_model.dart';
import 'package:daytistics/screens/auth/views/sign_in_view.dart';
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
    final AuthViewModel authViewModel = ref.read(authViewModelProvider);

    if (authViewModel.isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!authViewModel.isAuthenticated()) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<SignInView>(
              builder: (BuildContext context) => const SignInView(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      });
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
