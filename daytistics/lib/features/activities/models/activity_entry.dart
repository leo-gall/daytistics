import 'package:uuid/uuid.dart';

class ActivityEntry {
  final String id = const Uuid().v4();
  final String name;
  DateTime date;
  DateTime startTime;
  DateTime endTime;

  ActivityEntry({
    required this.name,
    required this.date,
    DateTime? startTime,
    DateTime? endTime,
  })  : startTime = startTime ?? DateTime.now(),
        endTime = endTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}
