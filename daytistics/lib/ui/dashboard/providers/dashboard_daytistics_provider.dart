import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/services/daytistics/daytistics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardDaytisticsProvider =
    FutureProvider.autoDispose.family<Daytistic?, DateTime>(
  (ref, date) async {
    return ref.read(daytisticsServiceProvider.notifier).fetchDaytistic(date);
  },
);
