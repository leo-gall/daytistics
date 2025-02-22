import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activities_service.g.dart';

class ActivitiesServiceState {
  ActivitiesServiceState();
}

@riverpod
class ActivitiesService extends _$ActivitiesService {
  @override
  ActivitiesServiceState build() {
    return ActivitiesServiceState();
  }

  Future<void> addActivity({
    required String name,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }

    if (startTime.isAfter(endTime)) {
      throw Exception('Start time cannot be after end time');
    }

    if (startTime == endTime) {
      throw Exception('Start time cannot be the same as end time');
    }

    final Daytistic daytistic = ref.read(currentDaytisticProvider)!;

    final startTimeAsDateTime = DateTime(
      daytistic.date.year,
      daytistic.date.month,
      daytistic.date.day,
      startTime.hour,
      startTime.minute,
    );

    final endTimeAsDateTime = DateTime(
      daytistic.date.year,
      daytistic.date.month,
      daytistic.date.day,
      endTime.hour,
      endTime.minute,
    );

    final activity = Activity(
      name: name,
      daytisticId: daytistic.id,
      startTime: startTimeAsDateTime,
      endTime: endTimeAsDateTime,
    );

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.activitiesTableName)
        .upsert(activity.toSupabase());

    final Daytistic updatedDaytistic = daytistic.copyWith(
      activities: [...daytistic.activities, activity],
    );

    ref.read(currentDaytisticProvider.notifier).daytistic = updatedDaytistic;

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'activity_added',
      properties: {
        'name': name,
        'start_time': startTimeAsDateTime.toIso8601String(),
        'end_time': endTimeAsDateTime.toIso8601String(),
      },
    );
  }

  Future<void> deleteActivity(Activity activity) async {
    final Daytistic daytistic = ref.read(currentDaytisticProvider)!;

    if (!await existsActivity(activity)) {
      throw Exception('Activity does not exist');
    }

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.activitiesTableName)
        .delete()
        .eq('id', activity.id);

    final updatedActivities = daytistic.activities
        .where((element) => element.id != activity.id)
        .toList();

    final Daytistic updatedDaytistic =
        daytistic.copyWith(activities: updatedActivities);

    ref.read(currentDaytisticProvider.notifier).daytistic = updatedDaytistic;

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'activity_deleted',
      properties: {
        'name': activity.name,
        'start_time': activity.startTime.toIso8601String(),
        'end_time': activity.endTime.toIso8601String(),
      },
    );
  }

  Future<void> updateActivity({
    required String id,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    final Daytistic daytistic = ref.read(currentDaytisticProvider)!;

    if (name == null && startTime == null && endTime == null) {
      throw Exception('No changes to update');
    }

    if (name != null && name.isEmpty) {
      throw Exception('Name cannot be empty');
    }

    if (startTime != null && endTime != null) {
      if (startTime.isAfter(endTime)) {
        throw Exception('Start time cannot be after end time');
      }

      if (startTime == endTime) {
        throw Exception('Start time cannot be the same as end time');
      }
    } else if (startTime != null || endTime != null) {
      throw Exception('Both start and end time must be provided');
    }

    final activity = Activity(
      id: id,
      name: name ?? '',
      daytisticId: daytistic.id,
      startTime: startTime != null
          ? DateTime(
              daytistic.date.year,
              daytistic.date.month,
              daytistic.date.day,
              startTime.hour,
              startTime.minute,
            )
          : DateTime.now(),
      endTime: endTime != null
          ? DateTime(
              daytistic.date.year,
              daytistic.date.month,
              daytistic.date.day,
              endTime.hour,
              endTime.minute,
            )
          : DateTime.now(),
    );

    if (!await existsActivity(activity)) {
      throw Exception('Activity does not exist');
    }

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.activitiesTableName)
        .upsert(activity.toSupabase());

    final updatedActivities = daytistic.activities
        .map((element) => element.id == activity.id ? activity : element)
        .toList();

    final Daytistic updatedDaytistic =
        daytistic.copyWith(activities: updatedActivities);

    ref.read(currentDaytisticProvider.notifier).daytistic = updatedDaytistic;

    await ref.read(posthogDependencyProvider).capture(
      eventName: 'activity_updated',
      properties: {
        'name': activity.name,
        'start_time': activity.startTime.toIso8601String(),
        'end_time': activity.endTime.toIso8601String(),
      },
    );
  }

  Future<bool> existsActivity(Activity activity) async {
    return (await ref
            .read(supabaseClientDependencyProvider)
            .from(SupabaseSettings.activitiesTableName)
            .select()
            .eq('id', activity.id))
        .isNotEmpty;
  }
}
