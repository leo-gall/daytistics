import 'package:uuid/uuid.dart';

class Wellbeing {
  String id;
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

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
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
}
