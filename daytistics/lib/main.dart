import 'dart:io';

import 'package:daytistics/config/settings.dart';
import 'package:daytistics/config/theme.dart';
import 'package:daytistics/shared/presets/home_view_preset.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/auth/views/sign_in_view.dart';
import 'package:daytistics/ui/chat/views/chat_view.dart';
import 'package:daytistics/ui/chat/views/conversations_list_view.dart';
import 'package:daytistics/ui/dashboard/views/dashboard_view.dart';
import 'package:daytistics/ui/onboarding/views/onboarding_view.dart';
import 'package:daytistics/ui/profile/views/about_view.dart';
import 'package:daytistics/ui/profile/views/licenses_view.dart';
import 'package:daytistics/ui/profile/views/profile_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseSettings.url,
    anonKey: SupabaseSettings.anonKey,
  );
}

Future<void> initPosthog() async {
  final config = PostHogConfig(dotenv.env['POSTHOG_API_KEY']!);
  config.captureApplicationLifecycleEvents = true;
  config.host = dotenv.env['POSTHOG_HOST'] ?? 'https://eu.i.posthog.com';
  await Posthog().setup(config);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kReleaseMode) {
    await dotenv.load(mergeWith: Platform.environment);
  }

  runApp(
    MaterialApp(
      title: 'Daytistics',
      locale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      theme: daytisticsTheme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Supabase Credentials' + getEnvVar('TEST')),
        ),
        body: Center(
          child: Text(
            'Supabase Credentials are: ${getEnvVar('SUPABASE_URL')}/${getEnvVar('SUPABASE_ANDROID_URL')} \n\n\n\n and ${getEnvVar('SUPABASE_ANON_KEY')}',
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    ),
  );

  // await dotenv.load(mergeWith: Platform.environment);
  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn = dotenv.env['SENTRY_DSN'];
  //   },
  //   appRunner: () async {
  //     WidgetsFlutterBinding.ensureInitialized();
  //     await initSupabase();
  //     await initPosthog();
  //     runApp(
  //       const ProviderScope(child: DaytisticsApp()),
  //     );
  //   },
  // );
}

class StartupView extends StatefulWidget {
  const StartupView({super.key});
  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  bool _isConnected = false;
  bool _checking = true;
  String? _reason;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  void _restartApp() {
    setState(() {
      _checking = true;
    });
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    try {
      final bool connectedToNetwork = await checkNetworkConnection();
      final bool connectedToSupabase = await checkSupabaseConnection();

      if (connectedToNetwork && connectedToSupabase) {
        setState(() {
          _isConnected = true;
          _checking = false;
        });
      } else if (connectedToNetwork && !connectedToSupabase) {
        setState(() {
          _isConnected = false;
          _checking = false;
          _reason =
              'We are currently experiencing issues connecting to our server. Please try again later.';
        });
      } else {
        setState(() {
          _isConnected = false;
          _checking = false;
          _reason = 'Please check your internet connection and try again.';
        });
      }
    } on Exception catch (_) {
      setState(() {
        _isConnected = false;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const HomeViewPreset(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _isConnected
        ? const DashboardView() // Load your actual home screen
        : HomeViewPreset(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StyledText(
                      _reason ?? 'An error occurred.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _restartApp,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: Colors.white),
                          SizedBox(width: 5),
                          StyledText('Retry'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class DaytisticsApp extends StatefulWidget {
  const DaytisticsApp({super.key});

  @override
  State<DaytisticsApp> createState() => _DaytisticsAppState();
}

class _DaytisticsAppState extends State<DaytisticsApp> {
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
        '/': (BuildContext context) => const StartupView(),
        '/signin': (BuildContext context) => const SignInView(),
        '/chat': (BuildContext context) => const ChatView(),
        '/conversations-list': (BuildContext context) =>
            const ConversationsListView(),
        '/profile': (BuildContext context) => const ProfileView(),
        '/profile/licenses': (BuildContext context) => const LicensesView(),
        '/profile/about': (BuildContext context) => const AboutView(),
        '/onboarding': (BuildContext context) => const OnboardingView(),
      },
    );
  }
}

String getEnvVar(String key) {
  // ignore: do_not_use_environment
  return kReleaseMode ? String.fromEnvironment(key) : dotenv.env[key]!;
}
