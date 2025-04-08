import 'package:daytistics/application/providers/services/notification/notification_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/config/theme.dart';
import 'package:daytistics/initializers.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = SentrySettings.dsn;
    },
    appRunner: () async {
      await initSupabase();
      await initAwesomeNotifications();

      runApp(
        const ProviderScope(child: DaytisticsApp()),
      );
    },
  );
}

class DaytisticsApp extends ConsumerStatefulWidget {
  const DaytisticsApp({super.key});

  // ignore: unreachable_from_main
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  ConsumerState<DaytisticsApp> createState() => _DaytisticsAppState();
}

class _DaytisticsAppState extends ConsumerState<DaytisticsApp> {
  @override
  void initState() {
    NotificationService.setListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Daytistics',
      locale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      theme: daytisticsTheme,
      scaffoldMessengerKey: DaytisticsApp.scaffoldMessengerKey,

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
      final bool connectedToSupabase = await checkSupabaseConnection();
      final bool connectedToNetwork =
          connectedToSupabase || await checkNetworkConnection();

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
                    ElevatedButton(
                      onPressed: _restartApp,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: ColorSettings.primary),
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
