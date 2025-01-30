import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/config/settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class Activity {
  String id;
  String name;
  String daytisticId;
  DateTime startTime;
  DateTime endTime;

  Activity({
    required this.name,
    required this.daytisticId,
    String? id,
    DateTime? startTime,
    DateTime? endTime,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        endTime = endTime ?? DateTime.now();

  Duration get duration {
    return endTime.difference(startTime);
  }

  factory Activity.fromSupabase(Map<String, dynamic> data) {
    return Activity(
      id: data['id'] as String,
      name: data['name'] as String,
      daytisticId: data['daytistic_id'],
      startTime: DateTime.parse(data['start_time'] as String),
      endTime: DateTime.parse(data['end_time'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'daytistic_id': daytisticId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
  }
}
