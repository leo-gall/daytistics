import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/state/daytistics/daytistics.dart';
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
  final Daytistic? daytistic;

  const DaytisticDetailsView({super.key, required this.daytistic});

  @override
  ConsumerState<DaytisticDetailsView> createState() =>
      _DaytisticDetailsViewState();
}

class _DaytisticDetailsViewState extends ConsumerState<DaytisticDetailsView> {
  @override
  Widget build(BuildContext context) {
    final dashboardViewModelNotifier =
        ref.watch(dashboardViewModelProvider.notifier);

    final dashboardViewModelState = ref.watch(dashboardViewModelProvider);

    return PopScope(
      onPopInvokedWithResult: (result, _) {
        if (widget.daytistic != null) {
          dashboardViewModelNotifier.updateSelectedDate(widget.daytistic!.date);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: StyledText(
            DateFormat('MM/dd/yyyy').format(widget.daytistic != null
                ? widget.daytistic!.date
                : dashboardViewModelState.selectedDate),
            style: Theme.of(context).textTheme.titleMedium,
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
                    itemCount: widget.daytistic != null
                        ? widget.daytistic!.activities.length
                        : 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${dateTimeToHourMinute(widget.daytistic!.activities[index].startTime)} - ${dateTimeToHourMinute(widget.daytistic!.activities[index].endTime)}',
                          ),
                          subtitle:
                              Text(widget.daytistic!.activities[index].name),
                          trailing: IconButton(
                            onPressed: () => EditActivityDialog.showDialog(
                              context,
                              widget.daytistic!.activities[index],
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
      ),
    );
  }
}
