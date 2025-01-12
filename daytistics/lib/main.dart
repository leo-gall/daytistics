import 'package:daytistics_app/config/settings.dart';
import 'package:daytistics_app/config/theme.dart';
import 'package:daytistics_app/domains/auth/screens/signin_screen.dart';
import 'package:daytistics_app/domains/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  runApp(const DaytisticsApp());
}

class DaytisticsApp extends StatelessWidget {
  const DaytisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final isAuthenticated = supabase.auth.currentUser != null;

    return MaterialApp(
      title: 'Daytistics',
      theme: daytisticsTheme,
      home: isAuthenticated ? const DashboardScreen() : const SignInScreen(),
    );
  }
}
