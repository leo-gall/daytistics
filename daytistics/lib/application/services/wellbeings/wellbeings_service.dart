import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/current_daytistic.dart';
import 'package:daytistics/application/repositories/wellbeings/wellbeings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wellbeings_service.g.dart';

class WellbeingsServiceState {}

@Riverpod(keepAlive: true)
class WellbeingsService extends _$WellbeingsService {
  @override
  WellbeingsServiceState build() {
    return WellbeingsServiceState();
  }

  Future<void> updateWellbeing(Wellbeing wellbeing) async {
    await ref.read(wellbeingsRepositoryProvider).upsertWellbeing(wellbeing);
    ref.read(currentDaytisticProvider.notifier).wellbeing = wellbeing;
  }
}
