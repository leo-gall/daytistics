import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/repositories/activities/activities_repository.dart';
import 'package:daytistics/application/repositories/daytistics/daytistics_repository.dart';
import 'package:daytistics/application/services/daytistics/daytistics_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/screens/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final daytisticRepository = ref.read(daytisticsRepositoryProvider);
    Daytistic daytistic = ref.read(daytisticsServiceProvider).currentDaytistic!;

    if (!await daytisticRepository.existsDaytistic(daytistic)) {
      await daytisticRepository.addDaytistic(daytistic);
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

    await ref.read(activitiesRepositoryProvider).updateActivity(activity);

    Daytistic updatedDaytistic = daytistic.copyWith(
      activities: [...daytistic.activities, activity],
    );

    ref.read(daytisticsServiceProvider.notifier).currentDaytistic =
        updatedDaytistic;
  }

  Future<void> deleteActivity(Activity activity) async {
    ActivitiesRepository activitiesRepository =
        ref.read(activitiesRepositoryProvider);

    Daytistic daytistic = ref.read(daytisticsServiceProvider).currentDaytistic!;

    if (!await activitiesRepository.existsActivity(activity)) {
      throw Exception('Activity does not exist');
    }

    await activitiesRepository.deleteActivity(activity);

    final updatedActivities = daytistic.activities
        .where((element) => element.id != activity.id)
        .toList();

    Daytistic updatedDaytistic =
        daytistic.copyWith(activities: updatedActivities);

    ref.read(daytisticsServiceProvider.notifier).currentDaytistic =
        updatedDaytistic;
  }

  Future<void> updateActivity({
    required String id,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    ActivitiesRepository activitiesRepository =
        ref.read(activitiesRepositoryProvider);

    Daytistic daytistic = ref.read(daytisticsServiceProvider).currentDaytistic!;

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

    if (!await activitiesRepository.existsActivity(activity)) {
      throw Exception('Activity does not exist');
    }

    await activitiesRepository.updateActivity(activity);

    final updatedActivities = daytistic.activities
        .map((element) => element.id == activity.id ? activity : element)
        .toList();

    Daytistic updatedDaytistic =
        daytistic.copyWith(activities: updatedActivities);

    ref.read(daytisticsServiceProvider.notifier).currentDaytistic =
        updatedDaytistic;
  }
}
