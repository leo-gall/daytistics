import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/services/wellbeings/wellbeings_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/shared/extensions/string.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/widgets/input/star_rating_input_field.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WellbeingRatingDialog extends ConsumerStatefulWidget {
  const WellbeingRatingDialog({super.key});

  @override
  ConsumerState<WellbeingRatingDialog> createState() =>
      _WellbeingRatingDialogState();

  static void showDialog(BuildContext context) {
    showBottomDialog(context, child: const WellbeingRatingDialog());
  }
}

class _WellbeingRatingDialogState extends ConsumerState<WellbeingRatingDialog> {
  @override
  Widget build(BuildContext context) {
    final Daytistic daytistic = ref.watch(currentDaytisticProvider)!;

    // iterate over the wellbeing ratings (daytistic)
    final Map<String, int?> wellbeingMap = daytistic.wellbeing!.toRatingMap();

    return Column(
      spacing: 15,
      children: List.generate(wellbeingMap.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              StyledText(
                wellbeingMap.keys
                    .elementAt(index)
                    .capitalize()
                    .replaceAll('_', ' '),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Expanded(child: SizedBox()),
              StarRatingInputField(
                maxRating: 5,
                rating: wellbeingMap[wellbeingMap.keys.elementAt(index)],
                onRatingChanged: (stars) async {
                  wellbeingMap[wellbeingMap.keys.elementAt(index)] = stars;

                  await ref
                      .read(wellbeingsServiceProvider.notifier)
                      .updateWellbeing(
                        Wellbeing.fromSupabase(
                          {
                            ...wellbeingMap,
                            'daytistic_id': daytistic.id,
                            'id': daytistic.wellbeing!.id,
                          },
                        ),
                      );
                },
                showFullRating: true,
              ),
            ],
          ),
        );
      }),
    );
  }
}
