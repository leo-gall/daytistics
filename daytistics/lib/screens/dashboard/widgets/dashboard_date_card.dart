import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/services/daytistics/daytistics_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/screens/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:daytistics/screens/daytistic_details/views/daytistic_details_view.dart';
import 'package:daytistics/shared/utils/alert.dart';
import 'package:daytistics/shared/utils/time.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

Map<String, int> ratings = {
  'productivity': 4,
  'mood': 3,
  'energy': 2,
};

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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const StyledText(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return StyledText(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        );
                      } else {
                        final daytistic = snapshot.data;
                        return StyledText(
                          durationToHoursMinutes(
                            daytistic?.totalDuration ?? Duration.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 50, // Define a height for the CarouselView
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ratings.keys.map((String key) {
                              return Row(
                                children: <Widget>[
                                  StyledText(
                                    key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Row(
                                    children: List<Widget>.generate(
                                      ratings[key]!,
                                      (int index) {
                                        return const Icon(
                                          Icons.star,
                                          color: ColorSettings.primary,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (key != ratings.keys.last)
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
              ],
            ),
          ),
          Positioned(
            right: 1,
            top: 1,
            child: IconButton(
              onPressed: () async {
                try {
                  await ref
                      .read(daytisticsServiceProvider.notifier)
                      .fetchOrCreate(
                        (dashboardViewModelState.selectedDate),
                      );
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorAlert(context, e.toString());
                  return;
                }

                if (!context.mounted) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const DaytisticDetailsView(),
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
