import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/utils/time.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:daytistics/ui/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:daytistics/ui/daytistic_details/widgets/add_activity_dialog.dart';
import 'package:daytistics/ui/daytistic_details/widgets/edit_activity_dialog.dart';
import 'package:daytistics/ui/daytistic_details/widgets/wellbeing_rating_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class DaytisticDetailsView extends ConsumerStatefulWidget {
  const DaytisticDetailsView({super.key});

  @override
  ConsumerState<DaytisticDetailsView> createState() =>
      _DaytisticDetailsViewState();
}

class _DaytisticDetailsViewState extends ConsumerState<DaytisticDetailsView> {
  @override
  Widget build(BuildContext context) {
    final Daytistic? daytistic = ref.watch(currentDaytisticProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: StyledText(
          DateFormat('MM/dd/yyyy').format(
            daytistic != null ? daytistic.date : DateTime.now(),
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
            final notifier = ref.refresh(dashboardViewModelProvider.notifier);
            notifier.updateSelectedDate(daytistic!.date);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.all_inbox_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, '/conversations-list');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_2_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Wellbeing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            WellbeingRatingDialog.showDialog(context);
          } else if (index == 1) {
            AddActivityDialog.showDialog(context);
          } else if (index == 2) {
            showToast(
              context,
              message: 'Diary is not implemented yet',
              type: ToastType.info,
            );
          }
        },
      ),
      body: RequireAuth(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      daytistic != null ? daytistic.activities.length : 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${dateTimeToHourMinute(daytistic!.activities[index].startTime)} - ${dateTimeToHourMinute(daytistic.activities[index].endTime)}',
                        ),
                        subtitle: Text(daytistic.activities[index].name),
                        trailing: IconButton(
                          onPressed: () => EditActivityDialog.showDialog(
                            context,
                            daytistic.activities[index],
                          ),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        contentPadding: const EdgeInsets.only(
                          left: 20,
                          top: 2,
                          right: 5,
                          bottom: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
