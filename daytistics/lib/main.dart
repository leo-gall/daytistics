import 'package:daytistics/config/settings.dart';
import 'package:daytistics/config/theme.dart';
import 'package:daytistics/screens/auth/views/sign_in_view.dart';
import 'package:daytistics/screens/dashboard/views/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseSettings.url,
    anonKey: SupabaseSettings.anonKey,
  );
}

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  WidgetsFlutterBinding.ensureInitialized();

  await initSupabase();

  runApp(const ProviderScope(child: DaytisticsApp()));
}

class DaytisticsApp extends StatelessWidget {
  const DaytisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final bool isAuthenticated = supabase.auth.currentUser != null;

    return MaterialApp(
      title: 'Daytistics',
      locale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      theme: daytisticsTheme,
      home: isAuthenticated ? const DashboardView() : const SignInView(),
    );
  }
}
