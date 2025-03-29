import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/state/daytistics/daytistics.dart';
import 'package:daytistics/config/settings.dart';
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
    await ref
        .read(supabaseClientDependencyProvider)
        .from(SupabaseSettings.wellbeingsTableName)
        .upsert(wellbeing.toSupabase());
    ref
        .read(daytisticsProvider.notifier)
        .updateCurrentDaytisticWellbeing(wellbeing);

    await ref.read(analyticsDependencyProvider).trackEvent(
      eventName: 'wellbeing_updated',
      properties: {
        'wellbeing': wellbeing.toSupabase(),
      },
    );
  }
}
