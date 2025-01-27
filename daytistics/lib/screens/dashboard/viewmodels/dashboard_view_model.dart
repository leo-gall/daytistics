import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_view_model.g.dart';

class DashboardViewModelState {
  DateTime selectedDate = DateTime.now();

  DashboardViewModelState({required this.selectedDate});

  DashboardViewModelState copyWith({DateTime? selectedDate}) {
    return DashboardViewModelState(
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  DashboardViewModelState build() {
    return DashboardViewModelState(selectedDate: DateTime.now());
  }

  void setSelectedDate(DateTime selectedDate) {
    state = state.copyWith(selectedDate: selectedDate);
  }
}
