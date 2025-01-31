import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentTimeProvider extends StateNotifier<DateTime> {
  Timer? _timer;

  CurrentTimeProvider() : super(DateTime.now()) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      state = DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<CurrentTimeProvider, DateTime> currentTimeProvider =
    StateNotifierProvider<CurrentTimeProvider, DateTime>(
  (Ref ref) => CurrentTimeProvider(),
);
