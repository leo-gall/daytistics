import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'activities_repository.g.dart';

class ActivitiesRepository {
  final _table =
      Supabase.instance.client.from(SupabaseSettings.activitiesTableName);

  Future<void> addActivity(Activity activity) async {
    await _table.upsert(activity.toSupabase());
  }

  Future<List<Activity>> getActivities() async {
    final response = await _table.select();
    return response.map((e) => Activity.fromSupabase(e)).toList();
  }
}

@riverpod
ActivitiesRepository activitiesRepository(Ref ref) => ActivitiesRepository();
