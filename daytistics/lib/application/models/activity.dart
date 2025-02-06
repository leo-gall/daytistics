import 'package:uuid/uuid.dart';

class Activity {
  late String id;
  String name;
  String daytisticId;
  late DateTime startTime;
  late DateTime endTime;
  late DateTime? createdAt;
  DateTime? updatedAt;

  Activity({
    required this.name,
    required this.daytisticId,
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.startTime = startTime ?? DateTime.now();
    this.endTime = endTime ?? DateTime.now();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  Duration get duration {
    return endTime.difference(startTime);
  }

  factory Activity.fromSupabase(Map<String, dynamic> data) {
    return Activity(
      id: data['id'] as String,
      name: data['name'] as String,
      daytisticId: data['daytistic_id'] as String,
      startTime: DateTime.parse(data['start_time'] as String),
      endTime: DateTime.parse(data['end_time'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'daytistic_id': daytisticId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'created_at': createdAt!.toIso8601String(),
      'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
