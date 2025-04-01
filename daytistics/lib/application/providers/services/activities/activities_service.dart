import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
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

  /// Adds an activity with the name [name] and the start and end times
  /// [startTime] and [endTime] to the given [daytistic].
  ///
  /// Returns `true` if the activity was added successfully, otherwise `false`.
  Future<bool> addActivity({
    required String name,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required Daytistic daytistic,
  }) async {
    if (name.isEmpty || startTime.isAfter(endTime) || startTime == endTime) {
      return false;
    }

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

    await ref.read(analyticsDependencyProvider).trackEvent(
      eventName: 'activity_added',
      properties: {
        'name': name,
        'start_time': startTimeAsDateTime.toIso8601String(),
        'end_time': endTimeAsDateTime.toIso8601String(),
      },
    );

    return true;
  }

  Future<bool> deleteActivity(Activity activity) async {
    if (!await existsActivity(activity)) {
      return false;
    }

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.activitiesTableName)
        .delete()
        .eq('id', activity.id);

    await ref.read(analyticsDependencyProvider).trackEvent(
      eventName: 'activity_deleted',
      properties: {
        'name': activity.name,
        'start_time': activity.startTime.toIso8601String(),
        'end_time': activity.endTime.toIso8601String(),
      },
    );

    return true;
  }

  Future<bool> updateActivity({
    required Activity activity,
    required Daytistic daytistic,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    if (name == null && startTime == null && endTime == null) {
      return false;
    }

    if (name != null && name.isEmpty) {
      return false;
    }

    if (startTime != null && endTime != null) {
      if (startTime.isAfter(endTime)) {
        return false;
      }

      if (startTime == endTime) {
        return false;
      }
    } else if (startTime != null || endTime != null) {
      return false;
    }

    final updatedActivity = Activity(
      id: activity.id,
      name: name ?? activity.name,
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
      return false;
    }

    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.activitiesTableName)
        .upsert(updatedActivity.toSupabase());

    await ref.read(analyticsDependencyProvider).trackEvent(
      eventName: 'activity_updated',
      properties: {
        'name': activity.name,
        'start_time': activity.startTime.toIso8601String(),
        'end_time': activity.endTime.toIso8601String(),
      },
    );

    return true;
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
