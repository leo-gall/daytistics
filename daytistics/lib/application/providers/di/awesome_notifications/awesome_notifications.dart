import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'awesome_notifications.g.dart';

@riverpod
AwesomeNotifications awesomeNotificationsDependency(Ref ref) =>
    AwesomeNotifications();
