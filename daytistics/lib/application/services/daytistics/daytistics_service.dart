import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/repositories/daytistics/daytistics_repository.dart';
import 'package:daytistics/shared/exceptions/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daytistics_service.g.dart';

class DaytisticsServiceState {
  DaytisticsServiceState();
}

@riverpod
class DaytisticsService extends _$DaytisticsService {
  @override
  DaytisticsServiceState build() {
    return DaytisticsServiceState();
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
