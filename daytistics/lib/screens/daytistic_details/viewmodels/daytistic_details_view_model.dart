import 'package:daytistics/application/models/daytistic.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daytistic_details_view_model.g.dart';

class DaytisticDetailsViewModelState {
  late Daytistic currentDaytistic;

  DaytisticDetailsViewModelState copyWith({Daytistic? currentDaytistic}) {
    return DaytisticDetailsViewModelState()
      ..currentDaytistic = currentDaytistic ?? this.currentDaytistic;
  }
}

@riverpod
class DaytisticDetailsView extends _$DaytisticDetailsView {
  @override
  DaytisticDetailsViewModelState build() {
    return DaytisticDetailsViewModelState();
  }

  void setCurrentDaytistic(Daytistic currentDaytistic) {
    state = state.copyWith(currentDaytistic: currentDaytistic);
  }
}
