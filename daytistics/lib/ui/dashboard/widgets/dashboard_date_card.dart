import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/services/daytistics/daytistics_service.dart';
import 'package:daytistics/shared/extensions/string.dart';
import 'package:daytistics/shared/utils/time.dart';
import 'package:daytistics/shared/widgets/application/star_rating.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:daytistics/ui/daytistic_details/views/daytistic_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class DashboardDateCard extends ConsumerStatefulWidget {
  const DashboardDateCard({super.key});

  @override
  ConsumerState<DashboardDateCard> createState() => _DashboardDateCardState();
}

class _DashboardDateCardState extends ConsumerState<DashboardDateCard> {
  @override
  Widget build(BuildContext context) {
    final dashboardViewModelState = ref.watch(dashboardViewModelProvider);

    // in format "Monday, 01/01/2021"
    final readableDate = DateFormat('EEEE, MM/dd/yyyy')
        .format(dashboardViewModelState.selectedDate);

    return Card(
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StyledText(
                  readableDate,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: FutureBuilder<Daytistic?>(
                    key: ValueKey(dashboardViewModelState.selectedDate),
                    future: ref
                        .read(daytisticsServiceProvider.notifier)
                        .fetchDaytistic(
                          dashboardViewModelState.selectedDate,
                        ),
                    builder: (context, snapshot) {
                      final daytistic = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyledText(
                            durationToHoursMinutes(
                              daytistic?.totalDuration ?? Duration.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (daytistic == null) const SizedBox(height: 50),
                          if (daytistic != null)
                            SizedBox(
                              height:
                                  50, // Define a height for the CarouselView
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: daytistic.wellbeing!
                                            .toRatingMap()
                                            .keys
                                            .map((key) {
                                          return Row(
                                            children: <Widget>[
                                              StyledText(
                                                key
                                                    .capitalize()
                                                    .replaceAll('_', ' '),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              StarRating(
                                                maxRating: 5,
                                                rating: daytistic.wellbeing!
                                                    .toRatingMap()[key],
                                              ),
                                              const SizedBox(width: 10),
                                              if (key !=
                                                  daytistic.wellbeing!
                                                      .toRatingMap()
                                                      .keys
                                                      .last)
                                                const Text(
                                                  '|',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              const SizedBox(width: 10),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 5),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 1,
            top: 1,
            child: IconButton(
              onPressed: () async {
                await ref.read(daytisticsServiceProvider.notifier).fetchOrAdd(
                      dashboardViewModelState.selectedDate,
                    );

                if (!context.mounted) {
                  return;
                }

                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const DaytisticDetailsView(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
