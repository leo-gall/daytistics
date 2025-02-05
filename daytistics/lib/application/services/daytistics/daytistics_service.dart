import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/current_daytistic/current_daytistic.dart';
import 'package:daytistics/application/repositories/daytistics/daytistics_repository.dart';
import 'package:daytistics/application/repositories/wellbeings/wellbeings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daytistics_service.g.dart';

class DaytisticsServiceState {}

@riverpod
class DaytisticsService extends _$DaytisticsService {
  @override
  DaytisticsServiceState build() {
    return DaytisticsServiceState();
  }

  Future<Daytistic?> fetchDaytistic(DateTime date) async {
    final daytistic =
        await ref.read(daytisticsRepositoryProvider).selectDaytistic(date);

    ref.read(currentDaytisticProvider.notifier).daytistic = daytistic;
    return daytistic;
  }

  Future<Daytistic> fetchOrCreate(DateTime date) async {
    final DaytisticsRepository daytisticsRepository =
        ref.read(daytisticsRepositoryProvider);

    Daytistic? daytistic = await daytisticsRepository.selectDaytistic(date);

    if (daytistic == null) {
      daytistic = Daytistic(
        date: date,
      );

      await ref
          .read(wellbeingsRepositoryProvider)
          .insertWellbeing(daytistic.wellbeing);
      await daytisticsRepository.upsertDaytistic(daytistic);
    }

    ref.read(currentDaytisticProvider.notifier).daytistic = daytistic;

    return daytistic;
  }
}
