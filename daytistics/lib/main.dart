import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:daytistics/application/providers/state/settings/settings.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/config/theme.dart';
import 'package:daytistics/notifications.dart';
import 'package:daytistics/shared/presets/home_view_preset.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/startup.dart';
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
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = SentrySettings.dsn;
    },
    appRunner: () async {
      await initSupabase();
      await initPosthog();
      await initAwesomeNotifications();

      runApp(
        const ProviderScope(child: DaytisticsApp()),
      );
    },
  );
}

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseSettings.url,
    anonKey: SupabaseSettings.anonKey,
  );
}

Future<void> initPosthog() async {
  final config = PostHogConfig(PosthogSettings.apiKey);
  config.captureApplicationLifecycleEvents = true;
  config.host = PosthogSettings.host;
  await Posthog().setup(config);
}

Future<bool> initAwesomeNotifications() {
  return AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: NotificationSettings.channelId,
        channelKey: NotificationSettings.channelId,
        channelName: NotificationSettings.channelName,
        channelDescription: NotificationSettings.channelDescription,
        defaultColor: ColorSettings.primary,
        ledColor: Colors.white,
      ),
    ],
    debug: true,
  );
}

class DaytisticsApp extends ConsumerStatefulWidget {
  const DaytisticsApp({super.key});

  // ignore: unreachable_from_main
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  ConsumerState<DaytisticsApp> createState() => _DaytisticsAppState();
}

class _DaytisticsAppState extends ConsumerState<DaytisticsApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ref.read(settingsProvider)?.dailyReminderTime != null) {
        final TimeOfDay reminderTime =
            ref.read(settingsProvider)!.dailyReminderTime!;
        scheduleDailyReminderNotification(
          reminderTime,
        );
      }
    });

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
