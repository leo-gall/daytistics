import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/shared/utils/time.dart';
import 'package:daytistics/ui/daytistic_details/widgets/edit_activity_dialog.dart';
import 'package:flutter/material.dart';

class ActivitiesList extends StatelessWidget {
  final Daytistic? daytistic;

  const ActivitiesList({super.key, required this.daytistic});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daytistic != null ? daytistic?.activities.length : 0,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(
              '${dateTimeToHourMinute(daytistic!.activities[index].startTime)} - ${dateTimeToHourMinute(daytistic!.activities[index].endTime)}',
            ),
            subtitle: Text(daytistic!.activities[index].name),
            trailing: IconButton(
              onPressed: () => EditActivityDialog.showDialog(
                context,
                daytistic!.activities[index],
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
    );
  }
}
