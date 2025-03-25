import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:daytistics/application/providers/di/awesome_notifications/awesome_notifications.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

class NotificationService {
  final AwesomeNotifications awesomeNotifications;

  NotificationService({required this.awesomeNotifications});

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

  static void setListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationService.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationService.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationService.onDismissActionReceivedMethod,
    );
  }

  Future<void> scheduleDailyReminderNotification(TimeOfDay reminderTime) async {
    await awesomeNotifications.isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await awesomeNotifications.requestPermissionToSendNotifications();
      }
    }).then((_) async {
      await awesomeNotifications.cancel(NotificationSettings.dailyReminderId);
      await awesomeNotifications.createNotification(
        content: NotificationContent(
          id: NotificationSettings.dailyReminderId,
          channelKey: NotificationSettings.channelId,
          title: 'Daily Reminder',
          body: "Don't forget to log your day!",
        ),
        schedule: NotificationCalendar(
          hour: reminderTime.hour,
          minute: reminderTime.minute,
          second: 0,
          repeats: true,
        ),
      );
    });
  }
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService(
      awesomeNotifications: ref.read(awesomeNotificationsDependencyProvider),
    );
