import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:daytistics/application/providers/di/awesome_notifications/awesome_notifications.dart';
import 'package:daytistics/application/providers/services/notification/notification_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../container.dart';

class FakeAwesomeNotifications extends Fake implements AwesomeNotifications {
  bool notificationsAllowed = true;
  bool assertHasRequestedPermission = false;
  int assertCancelledId = -1;
  NotificationCalendar? assertCalendar;
  NotificationContent? assertContent;

  @override
  Future<bool> isNotificationAllowed() {
    return Future.value(notificationsAllowed);
  }

  @override
  Future<bool> requestPermissionToSendNotifications({
    String? channelKey,
    List<NotificationPermission> permissions = const [
      NotificationPermission.Alert,
      NotificationPermission.Sound,
      NotificationPermission.Badge,
      NotificationPermission.Vibration,
      NotificationPermission.Light,
    ],
  }) {
    assertHasRequestedPermission = true;
    return Future.value(notificationsAllowed);
  }

  @override
  Future<void> cancel(int id) {
    assertCancelledId = id;
    return Future.value();
  }

  @override
  Future<bool> createNotification({
    required NotificationContent content,
    NotificationSchedule? schedule,
    List<NotificationActionButton>? actionButtons,
    Map<String, NotificationLocalization>? localizations,
  }) {
    final NotificationCalendar? calendar = schedule as NotificationCalendar?;
    assertContent = content;
    assertCalendar = calendar;

    return Future.value(true);
  }
}

void main() {
  final TimeOfDay timeOfDay = TimeOfDay.now();
  late NotificationService notificationService;
  late ProviderContainer container;

  setUp(() {
    container = createContainer(
      overrides: [
        awesomeNotificationsDependencyProvider
            .overrideWith((ref) => FakeAwesomeNotifications()),
      ],
    );

    notificationService = container.read(notificationServiceProvider);
  });

  group('scheduleDailyReminderNotification', () {
    test(
        'should request permission, cancel existing notification, and schedule a new one',
        () async {
      final awesomeNotifications = container.read(
        awesomeNotificationsDependencyProvider,
      ) as FakeAwesomeNotifications
        ..notificationsAllowed = false;

      await notificationService.scheduleDailyReminderNotification(timeOfDay);

      expect(awesomeNotifications.assertHasRequestedPermission, isTrue);
      expect(
        awesomeNotifications.assertCancelledId,
        NotificationSettings.dailyReminderId,
      );
      expect(awesomeNotifications.assertContent!.title, 'Daily Reminder');
      expect(
        awesomeNotifications.assertContent!.body,
        "Don't forget to log your day!",
      );
      expect(awesomeNotifications.assertCalendar!.hour, timeOfDay.hour);
      expect(awesomeNotifications.assertCalendar!.minute, timeOfDay.minute);
      expect(awesomeNotifications.assertCalendar!.second, 0);
      expect(awesomeNotifications.assertCalendar!.repeats, true);
    });

    test(
        'should cancel existing notification and schedule a new one, but not request permission if already allowed',
        () async {
      final awesomeNotifications = container.read(
        awesomeNotificationsDependencyProvider,
      ) as FakeAwesomeNotifications
        ..notificationsAllowed = true;

      await notificationService.scheduleDailyReminderNotification(timeOfDay);

      expect(awesomeNotifications.assertHasRequestedPermission, isFalse);
      expect(
        awesomeNotifications.assertCancelledId,
        NotificationSettings.dailyReminderId,
      );
      expect(awesomeNotifications.assertContent!.title, 'Daily Reminder');
      expect(
        awesomeNotifications.assertContent!.body,
        "Don't forget to log your day!",
      );
      expect(awesomeNotifications.assertCalendar!.hour, timeOfDay.hour);
      expect(awesomeNotifications.assertCalendar!.minute, timeOfDay.minute);
      expect(awesomeNotifications.assertCalendar!.second, 0);
      expect(awesomeNotifications.assertCalendar!.repeats, true);
    });
  });

  tearDown(() async {
    container.dispose();
  });
}
