import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user.g.dart';

@riverpod
User? userDependency(Ref ref) => Supabase.instance.client.auth.currentUser;
