import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/services/wellbeings/wellbeings_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/shared/extensions/string.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/input/star_rating_input_field.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WellbeingRating extends ConsumerStatefulWidget {
  const WellbeingRating({super.key});

  @override
  ConsumerState<WellbeingRating> createState() => _WellbeingRatingState();
}

class _WellbeingRatingState extends ConsumerState<WellbeingRating> {
  @override
  Widget build(BuildContext context) {
    final Daytistic? daytistic = ref.watch(currentDaytisticProvider);
    if (daytistic == null) {
      return const SizedBox();
    }

    final wellbeingsService = ref.read(wellbeingsServiceProvider.notifier);
    final Map<String, int?> wellbeingMap = daytistic.wellbeing!.toRatingMap();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(wellbeingMap.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                StyledText(
                  wellbeingMap.keys
                      .elementAt(index)
                      .capitalize()
                      .replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 16),
                ),
                const Expanded(child: SizedBox()),
                StarRatingInputField(
                  maxRating: 5,
                  rating: wellbeingMap[wellbeingMap.keys.elementAt(index)],
                  onRatingChanged: (stars) async {
                    wellbeingMap[wellbeingMap.keys.elementAt(index)] = stars;
                    if (await maybeRedirectToConnectionErrorView(context)) {
                      return;
                    }
                    if (mounted) {
                      await wellbeingsService.updateWellbeing(
                        Wellbeing.fromSupabase({
                          ...wellbeingMap,
                          'daytistic_id': daytistic.id,
                          'id': daytistic.wellbeing!.id,
                        }),
                      );
                    }
                  },
                  showFullRating: true,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
