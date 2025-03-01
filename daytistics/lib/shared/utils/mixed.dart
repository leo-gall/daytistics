import 'package:url_launcher/url_launcher.dart';

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
