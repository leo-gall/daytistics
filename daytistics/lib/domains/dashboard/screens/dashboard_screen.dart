import 'package:daytistics/domains/auth/screens/signin_screen.dart';
import 'package:daytistics/domains/auth/services/auth_service.dart';
import 'package:daytistics/shared/widgets/require_auth.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 4),
            StyledText(
              'Dashboard',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          // TODO: The sign out button should be removed after implementing the settings screen.
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService.signOut();

                if (!AuthService.isAuthenticated()) {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                }
              }),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: RequireAuth(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Hey'),
              ),
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
