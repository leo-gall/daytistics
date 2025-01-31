import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/current_daytistic.dart';
import 'package:daytistics/application/repositories/activities/activities_repository.dart';
import 'package:daytistics/application/repositories/daytistics/daytistics_repository.dart';
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

    final daytisticRepository = ref.read(daytisticsRepositoryProvider);
    Daytistic daytistic = ref.read(currentDaytisticProvider)!;

    if (!await daytisticRepository.existsDaytistic(daytistic)) {
      await daytisticRepository.upsertDaytistic(daytistic);
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

    ref.read(currentDaytisticProvider.notifier).daytistic = updatedDaytistic;
  }

  Future<void> deleteActivity(Activity activity) async {
    ActivitiesRepository activitiesRepository =
        ref.read(activitiesRepositoryProvider);

    Daytistic daytistic = ref.read(currentDaytisticProvider)!;

    if (!await activitiesRepository.existsActivity(activity)) {
      throw Exception('Activity does not exist');
    }

    await activitiesRepository.deleteActivity(activity);

    final updatedActivities = daytistic.activities
        .where((element) => element.id != activity.id)
        .toList();

    Daytistic updatedDaytistic =
        daytistic.copyWith(activities: updatedActivities);

    ref.read(currentDaytisticProvider.notifier).daytistic = updatedDaytistic;
  }

  Future<void> updateActivity({
    required String id,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    ActivitiesRepository activitiesRepository =
        ref.read(activitiesRepositoryProvider);

    Daytistic daytistic = ref.read(currentDaytisticProvider)!;

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

    if (!await activitiesRepository.existsActivity(activity)) {
      throw Exception('Activity does not exist');
    }

    await activitiesRepository.updateActivity(activity);

    final updatedActivities = daytistic.activities
        .map((element) => element.id == activity.id ? activity : element)
        .toList();

    Daytistic updatedDaytistic =
        daytistic.copyWith(activities: updatedActivities);

    ref.read(currentDaytisticProvider.notifier).daytistic = updatedDaytistic;
  }
}
