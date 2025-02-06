import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/current_daytistic/current_daytistic.dart';
import 'package:daytistics/application/services/wellbeings/wellbeings_service.dart';
import 'package:daytistics/shared/widgets/application/star_rating.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:daytistics/shared/extensions/string.dart';

class WellbeingRatingModal extends ConsumerStatefulWidget {
  const WellbeingRatingModal({super.key});

  @override
  ConsumerState<WellbeingRatingModal> createState() =>
      _WellbeingRatingModalState();

  static void showModal(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return const WellbeingRatingModal();
      },
    );
  }
}

class _WellbeingRatingModalState extends ConsumerState<WellbeingRatingModal> {
  @override
  Widget build(BuildContext context) {
    final Daytistic daytistic = ref.watch(currentDaytisticProvider)!;

    // iterate over the wellbeing ratings (daytistic)
    final Map<String, int?> wellbeingMap = daytistic.wellbeing!.toRatingMap();

    return Container(
      height: 500,
      color: const Color.fromRGBO(255, 255, 255, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Column(
            spacing: 15,
            children: List.generate(wellbeingMap.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    StyledText(
                      wellbeingMap.keys.elementAt(index).capitalize(),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    StarRating(
                      maxRating: 5,
                      rating: wellbeingMap[wellbeingMap.keys.elementAt(index)],
                      onRatingChanged: (stars) async {
                        wellbeingMap[wellbeingMap.keys.elementAt(index)] =
                            stars;

                        await ref
                            .read(wellbeingsServiceProvider.notifier)
                            .updateWellbeing(
                              Wellbeing.fromSupabase(
                                {
                                  ...wellbeingMap,
                                  'id': daytistic.wellbeing!.id
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
          ),
        ],
      ),
    );
  }
}
