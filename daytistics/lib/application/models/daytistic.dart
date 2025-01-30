import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class Daytistic {
  late String id;
  DateTime date;
  final List<Activity> activities = [];
  Wellbeing wellbeing = Wellbeing();

  Daytistic({
    required this.date,
    String? id,
    List<Activity>? activities,
    Wellbeing? wellbeing,
  }) {
    // if not id is provided, generate a new one using Uuid
    this.id = id ?? const Uuid().v4();

    if (activities != null) {
      this.activities.addAll(activities);
    }

    if (wellbeing != null) {
      this.wellbeing = wellbeing;
    }
  }

  Duration get totalDuration {
    return activities.fold(
      Duration.zero,
      (previousValue, element) => previousValue + element.duration,
    );
  }

  // STATE MANAGEMENT METHODS

  Daytistic copyWith({
    String? id,
    DateTime? date,
    List<Activity>? activities,
    Wellbeing? wellbeing,
  }) {
    return Daytistic(
      id: id ?? this.id,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      wellbeing: wellbeing ?? this.wellbeing,
    );
  }

  // TRANSFORMER METHODS

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'wellbeing_id': null, // TODO: Change to wellbeing.id
      'user_id': Supabase.instance.client.auth.currentUser!.id,
    };
  }

  factory Daytistic.fromSupabase(
    Map<String, dynamic> daytisticData,
    List<Map<String, dynamic>> activitiesData,
    Map<String, dynamic> wellbeingData,
  ) {
    return Daytistic(
      id: daytisticData['id'] as String,
      date: DateTime.parse(daytisticData['date'] as String),
      activities: activitiesData
          .map((activityData) => Activity.fromSupabase(activityData))
          .toList(),
      wellbeing: Wellbeing(id: daytisticData['wellbeing_id'].toString()),
    );
  }
}
