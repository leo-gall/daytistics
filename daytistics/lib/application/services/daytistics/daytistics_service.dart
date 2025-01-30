import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/repositories/daytistics/daytistics_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daytistics_service.g.dart';

class DaytisticsServiceState {
  Daytistic? currentDaytistic;

  DaytisticsServiceState();

  DaytisticsServiceState copyWith({
    Daytistic? currentDaytistic,
  }) {
    return DaytisticsServiceState()
      ..currentDaytistic = currentDaytistic ?? this.currentDaytistic;
  }
}

@Riverpod(keepAlive: true)
class DaytisticsService extends _$DaytisticsService {
  @override
  DaytisticsServiceState build() {
    return DaytisticsServiceState();
  }

  set currentDaytistic(Daytistic? daytistic) {
    state = state.copyWith(currentDaytistic: daytistic);
  }

  Future<Daytistic?> fetchDaytistic(DateTime date) async {
    final daytistic =
        await ref.read(daytisticsRepositoryProvider).fetchDaytistic(date);
    currentDaytistic = daytistic;
    return daytistic;
  }

  Future<Daytistic> fetchOrCreate(DateTime date) async {
    final daytisticsRepository = ref.read(daytisticsRepositoryProvider);

    late Daytistic? daytistic;

    daytistic = await daytisticsRepository.fetchDaytistic(date);

    daytistic ??= Daytistic(
      date: date,
    );

    await daytisticsRepository.addDaytistic(daytistic);

    currentDaytistic = daytistic;

    return daytistic;
  }
}
