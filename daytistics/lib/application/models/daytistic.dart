import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/diary_entry.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class Daytistic {
  late String id;
  DateTime date;
  late List<Activity> activities;
  late Wellbeing? wellbeing;
  late DiaryEntry? diaryEntry;
  late DateTime createdAt;
  late DateTime updatedAt;

  Daytistic({
    required this.date,
    this.wellbeing,
    this.diaryEntry,
    String? id,
    List<Activity>? activities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? const Uuid().v4();

    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();

    this.activities = [];

    if (activities != null) {
      this.activities.addAll(activities);
    }
  }

  Duration get totalDuration {
    return activities.fold(
      Duration.zero,
      (previousValue, element) => previousValue + element.duration,
    );
  }

  Daytistic copyWith({
    String? id,
    DateTime? date,
    List<Activity>? activities,
    DiaryEntry? diaryEntry,
    Wellbeing? wellbeing,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Daytistic(
      id: id ?? this.id,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      diaryEntry: diaryEntry ?? this.diaryEntry,
      wellbeing: wellbeing ?? this.wellbeing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toSupabase({String? userId}) {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'user_id': userId ?? Supabase.instance.client.auth.currentUser!.id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Daytistic.fromSupabase(
    Map<String, dynamic> daytisticData,
  ) {
    return Daytistic(
      id: daytisticData['id'] as String,
      date: DateTime.parse(daytisticData['date'] as String),
      createdAt: DateTime.parse(daytisticData['created_at'] as String),
      updatedAt: DateTime.parse(daytisticData['updated_at'] as String),
    );
  }
}
