import 'package:daytistics_app/domains/auth/screens/signin_screen.dart';
import 'package:daytistics_app/domains/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

class RequireAuth extends StatefulWidget {
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
  State<RequireAuth> createState() => _RequireAuthState();
}

class _RequireAuthState extends State<RequireAuth> {
  @override
  void initState() {
    if (AuthService.isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!AuthService.isAuthenticated()) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
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
