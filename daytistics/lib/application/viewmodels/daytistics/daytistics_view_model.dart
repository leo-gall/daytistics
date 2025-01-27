import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/repositories/activities/activities_repository.dart';
import 'package:daytistics/application/repositories/daytistics/daytistics_repository.dart';
import 'package:daytistics/shared/exceptions/database.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daytistics_view_model.g.dart';

class DaytisticsViewModelState {
  DaytisticsViewModelState();
}

@riverpod
class DaytisticsViewModel extends _$DaytisticsViewModel {
  @override
  DaytisticsViewModelState build() {
    return DaytisticsViewModelState();
  }

  Future<Daytistic> fetchDaytistic(DateTime date) async {
    final daytisticsRepository = ref.read(daytisticsRepositoryProvider);

    late Daytistic daytistic;
    try {
      daytistic = await daytisticsRepository.fetchDaytistic(date);
    } catch (e) {
      if (e is RecordNotFoundException) {
        daytistic = Daytistic(date: date);
        await daytisticsRepository.addDaytistic(daytistic);
      } else {
        rethrow;
      }
    }
    return daytistic;
  }
}
