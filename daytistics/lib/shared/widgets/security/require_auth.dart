import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/services/auth/auth_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.watch(supabaseClientProvider).auth.currentUser == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<SignInView>(
            builder: (context) => const SignInView(),
          ),
          (route) => false,
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
