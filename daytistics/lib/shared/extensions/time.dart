import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  /// Converts a [TimeOfDay] to a [DateTime] object.
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
