import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/services/daytistics/daytistics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daytistics.g.dart';

class DaytisticsState {
  final List<Daytistic> daytistics;
  Daytistic? currentDaytistic;

  DaytisticsState({
    required this.daytistics,
    this.currentDaytistic,
  });

  DaytisticsState copyWith({
    List<Daytistic>? daytistics,
    Daytistic? currentDaytistic,
  }) {
    return DaytisticsState(
      daytistics: daytistics ?? this.daytistics,
      currentDaytistic: currentDaytistic ?? this.currentDaytistic,
    );
  }
}

@Riverpod(keepAlive: true)
class Daytistics extends _$Daytistics {
  @override
  Future<DaytisticsState> build() async {
    final daytisticsService = ref.read(daytisticsServiceProvider.notifier);
    final List<Daytistic> daytistics =
        await daytisticsService.fetchRecentDaytistics();

    return DaytisticsState(
      daytistics: daytistics,
    );
  }

  void addDaytistic(Daytistic daytistic) {
    state = AsyncValue.data(
      state.requireValue.copyWith(
        daytistics: [...state.requireValue.daytistics, daytistic],
      ),
    );
  }

  void updateCurrentDaytistic(Daytistic daytistic) {
    state = AsyncValue.data(state.requireValue.copyWith(
      currentDaytistic: daytistic,
    ));
  }

  void updateCurrentDaytisticWellbeing(Wellbeing wellbeing) {
    if (state.requireValue.currentDaytistic != null) {
      state = AsyncValue.data(state.requireValue.copyWith(
        currentDaytistic: state.requireValue.currentDaytistic!.copyWith(
          wellbeing: wellbeing,
        ),
      ));
    }
  }
}
