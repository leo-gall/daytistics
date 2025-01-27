import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/repositories/activities/activities_repository.dart';
import 'package:daytistics/application/repositories/daytistics/daytistics_repository.dart';
import 'package:daytistics/shared/exceptions/database.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activities_view_model.g.dart';

class ActivitiesViewModelState {
  ActivitiesViewModelState();
}

@riverpod
class ActivitiesViewModel extends _$ActivitiesViewModel {
  @override
  ActivitiesViewModelState build() {
    return ActivitiesViewModelState();
  }

  void addActivity({
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
  }
}
