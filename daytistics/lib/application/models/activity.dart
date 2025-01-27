import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/config/settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class Activity {
  final String id = const Uuid().v4();
  String name;
  String daytisticId;
  Daytistic? _daytistic;
  DateTime startTime;
  DateTime endTime;

  Daytistic get daytistic {
    if (_daytistic != null) {
      return _daytistic!;
    } else {
      SupabaseClient client = Supabase.instance.client;

      late Map<String, dynamic> daytisticData;
      late List<Map<String, dynamic>> activitiesData;
      late Map<String, dynamic> wellbeingData;

      // fetch daytistic from Supabase

      client
          .from(SupabaseSettings.daytisticsTableName)
          .select()
          .eq('id', daytisticId)
          .then((response) {
        daytisticData = response.first;
      });

      // fetch all activities from Supabase

      client
          .from(SupabaseSettings.activitiesTableName)
          .select()
          .eq('daytistic_id', daytisticId)
          .then((response) {
        activitiesData = response;
      });

      // fetch wellbeing from Supabase

      client
          .from(SupabaseSettings.wellbeingsTableName)
          .select()
          .eq('id', daytisticData['wellbeing_id'])
          .then((response) {
        wellbeingData = response.first;
      });

      _daytistic =
          Daytistic.fromSupabase(daytisticData, activitiesData, wellbeingData);

      return _daytistic!;
    }
  }

  Activity({
    required this.name,
    required this.daytisticId,
    DateTime? startTime,
    DateTime? endTime,
  })  : startTime = startTime ?? DateTime.now(),
        endTime = endTime ?? DateTime.now();

  factory Activity.fromSupabase(Map<String, dynamic> data) {
    return Activity(
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
