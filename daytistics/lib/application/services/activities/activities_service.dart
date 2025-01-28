import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
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

  Future<Daytistic> addActivity({
    required String name,
    required Daytistic daytistic,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final daytisticRepository = ref.read(daytisticsRepositoryProvider);

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

    await ref.read(activitiesRepositoryProvider).addActivity(activity);

    Daytistic updatedDaytistic = daytistic.copyWith(
      activities: [...daytistic.activities, activity],
    );

    return updatedDaytistic;
  }
}
