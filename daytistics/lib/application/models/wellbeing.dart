import 'package:uuid/uuid.dart';

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
