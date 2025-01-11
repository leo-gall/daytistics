import 'package:daytistics_app/shared/widgets/styled_appbar.dart';
import 'package:daytistics_app/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String getGreetingMessage(String name) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning, $name!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon, $name!';
    } else if (hour >= 17 && hour < 20) {
      return 'Good evening, $name!';
    } else {
      return 'Good night, $name!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyledAppBar(title: 'Dashboard'),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            StyledHeading(
              getGreetingMessage('John'),
            ),
            StyledText(
              getGreetingMessage('John'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Hey"),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
            ),
          ],
        ),
      ),
    );
  }
}
