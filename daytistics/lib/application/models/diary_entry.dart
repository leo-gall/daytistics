import 'package:uuid/uuid.dart';

class DiaryEntry {
  String id;
  String daytisticId;
  String shortEntry;
  String happinessMoment;
  DateTime createdAt;
  DateTime updatedAt;

  DiaryEntry({
    String? id,
    required this.daytisticId,
    required this.shortEntry,
    required this.happinessMoment,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DiaryEntry copyWith({
    String? id,
    required String daytisticId,
    String? shortEntry,
    String? happinessMoment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      daytisticId: daytisticId,
      shortEntry: shortEntry ?? this.shortEntry,
      happinessMoment: happinessMoment ?? this.happinessMoment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'daytistic_id': daytisticId,
      'short_entry': shortEntry,
      'happiness_moment': happinessMoment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      daytisticId: json['daytistic_id'] as String,
      shortEntry: json['short_entry'] as String,
      happinessMoment: json['happiness_moment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
