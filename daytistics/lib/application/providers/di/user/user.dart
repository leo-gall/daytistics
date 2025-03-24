import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user.g.dart';

@riverpod
User? userDependency(Ref ref) {
  final supabase = ref.watch(supabaseClientDependencyProvider);
  final user = supabase.auth.currentUser;

  return user;
}
