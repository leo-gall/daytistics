import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/main.dart';
import 'package:flutter/material.dart';

void maybeAskAllowNotifications() {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}

Future<void> scheduleDailyReminderNotification(TimeOfDay reminderTime) async {
  await AwesomeNotifications().cancel(NotificationSettings.dailyReminderId);
  final bool succeeded = await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: NotificationSettings.dailyReminderId,
      channelKey: NotificationSettings.channelId,
      title: 'Daily Reminder',
      body: "Don't forget to log your day!",
    ),
    schedule: NotificationCalendar(
      hour: reminderTime.hour,
      minute: reminderTime.minute,
      repeats: true,
    ),
  );
}

Future<void> sendDebugNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: NotificationSettings.debugId,
      channelKey: NotificationSettings.channelId,
      title: 'Debug Notification',
      body: 'This is a debug notification.',
    ),
  );
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Your code goes here

    await DaytisticsApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/',
      (route) => false,
      arguments: receivedAction,
    );
  }
}
