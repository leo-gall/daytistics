import 'package:supabase_flutter/supabase_flutter.dart';
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

  factory Activity.fromJson(Map<String, dynamic> data) {
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

  Map<String, dynamic> toJson() {
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

  Activity copyWith({
    String? id,
    String? name,
    String? daytisticId,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      daytisticId: daytisticId ?? this.daytisticId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Wellbeing {
  String id;
  String daytisticId;

  int? meTime;
  int? health;
  int? productivity;
  int? happiness;
  int? recovery;
  int? sleep;
  int? stress;
  int? energy;
  int? focus;
  int? mood;
  int? gratitude;

  Wellbeing({
    String? id,
    required this.daytisticId,
    this.meTime,
    this.health,
    this.productivity,
    this.happiness,
    this.recovery,
    this.sleep,
    this.stress,
    this.energy,
    this.focus,
    this.mood,
    this.gratitude,
  }) : id = id ?? const Uuid().v4();

  Wellbeing copyWith({
    String? id,
    required String daytisticId,
    int? meTime,
    int? health,
    int? productivity,
    int? happiness,
    int? recovery,
    int? sleep,
    int? stress,
    int? energy,
    int? focus,
    int? mood,
    int? gratitude,
  }) {
    return Wellbeing(
      id: id,
      daytisticId: daytisticId,
      meTime: meTime ?? this.meTime,
      health: health ?? this.health,
      productivity: productivity ?? this.productivity,
      happiness: happiness ?? this.happiness,
      recovery: recovery ?? this.recovery,
      sleep: sleep ?? this.sleep,
      stress: stress ?? this.stress,
      energy: energy ?? this.energy,
      focus: focus ?? this.focus,
      mood: mood ?? this.mood,
      gratitude: gratitude ?? this.gratitude,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'daytistic_id': daytisticId,
      'me_time': meTime,
      'health': health,
      'productivity': productivity,
      'happiness': happiness,
      'recovery': recovery,
      'sleep': sleep,
      'stress': stress,
      'energy': energy,
      'focus': focus,
      'mood': mood,
      'gratitude': gratitude,
    };
  }

  Map<String, int?> toRatingMap() {
    return {
      'me_time': meTime,
      'health': health,
      'productivity': productivity,
      'happiness': happiness,
      'recovery': recovery,
      'sleep': sleep,
      'stress': stress,
      'energy': energy,
      'focus': focus,
      'mood': mood,
      'gratitude': gratitude,
    };
  }

  factory Wellbeing.fromSupabase(Map<String, dynamic> data) {
    return Wellbeing(
      id: data['id'] as String,
      meTime: data['me_time'] as int?,
      daytisticId: data['daytistic_id'] as String,
      health: data['health'] as int?,
      productivity: data['productivity'] as int?,
      happiness: data['happiness'] as int?,
      recovery: data['recovery'] as int?,
      sleep: data['sleep'] as int?,
      stress: data['stress'] as int?,
      energy: data['energy'] as int?,
      focus: data['focus'] as int?,
      mood: data['mood'] as int?,
      gratitude: data['gratitude'] as int?,
    );
  }
}

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
}

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

  Map<String, dynamic> toJson({String? userId}) {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'user_id': userId ?? Supabase.instance.client.auth.currentUser!.id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Daytistic.fromJson(
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
