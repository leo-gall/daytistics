import 'package:flutter/material.dart';

TimeOfDay timeFromUtc(TimeOfDay utcTime) {
  final utcOffset = DateTime.now().timeZoneOffset.inHours;
  return TimeOfDay(
    hour: (utcTime.hour + utcOffset) % 24,
    minute: utcTime.minute,
  );
}

TimeOfDay timeToUtc(TimeOfDay localTime) {
  final utcOffset = DateTime.now().timeZoneOffset.inHours;
  return TimeOfDay(
    hour: (localTime.hour - utcOffset) % 24,
    minute: localTime.minute,
  );
}

String dateTimeToHourMinute(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String durationToHoursMinutes(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '$hours hours $minutes minutes';
}
