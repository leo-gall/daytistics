import 'package:daytistics/config/settings.dart';
import 'package:daytistics/config/theme.dart';
import 'package:daytistics/ui/auth/views/sign_in_view.dart';
import 'package:daytistics/ui/chat/views/chat_view.dart';
import 'package:daytistics/ui/dashboard/views/dashboard_view.dart';
import 'package:daytistics/ui/profile/views/licenses_view.dart';
import 'package:daytistics/ui/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseSettings.url,
    anonKey: SupabaseSettings.anonKey,
  );
}

Future<void> main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();

  await initSupabase();

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'];
    },
    appRunner: () => runApp(const ProviderScope(child: DaytisticsApp())),
  );
}

class DaytisticsApp extends StatelessWidget {
  const DaytisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daytistics',
      locale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      theme: daytisticsTheme,

      // routing
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const DashboardView(),
        '/signin': (BuildContext context) => const SignInView(),
        '/chat': (BuildContext context) => const ChatView(),
        '/profile': (BuildContext context) => const ProfileView(),
        '/profile/licenses': (BuildContext context) => const LicensesView(),
      },
    );
  }
}
