import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
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

@riverpod
class Daytistics extends _$Daytistics {
  @override
  DaytisticsState build() {
    return DaytisticsState(
      daytistics: [],
    );
  }

  void addDaytistic(Daytistic daytistic) {
    state = state.copyWith(
      daytistics: [...state.daytistics, daytistic],
    );
  }

  void removeDaytistic(Daytistic daytistic) {
    state = state.copyWith(
      daytistics: state.daytistics.where((d) => d.id != daytistic.id).toList(),
    );
  }

  void updateCurrentDaytistic(Daytistic daytistic) {
    state = state.copyWith(
      currentDaytistic: daytistic,
    );
  }

  void updateCurrentDaytisticWellbeing(Wellbeing wellbeing) {
    if (state.currentDaytistic != null) {
      state = state.copyWith(
        currentDaytistic:
            state.currentDaytistic!.copyWith(wellbeing: wellbeing),
      );
    }
  }
}
