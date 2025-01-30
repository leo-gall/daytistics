import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/services/daytistics/daytistics_service.dart';
import 'package:daytistics/application/widgets/prompt_input_field.dart';
import 'package:daytistics/screens/daytistic_details/widgets/add_activity_modal.dart';
import 'package:daytistics/screens/daytistic_details/widgets/edit_activity_modal.dart';
import 'package:daytistics/shared/utils/time.dart';
import 'package:daytistics/shared/widgets/require_auth.dart';
import 'package:daytistics/shared/widgets/styled_text.dart';
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
    Daytistic? daytistic =
        ref.watch(daytisticsServiceProvider).currentDaytistic;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: StyledText(
          DateFormat('MM/dd/yyyy').format(daytistic!.date),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.local_library_outlined,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.star_outline,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () {
              AddActivityModal.showModal(context);
            },
          ),
        ],
      ),
      body: RequireAuth(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: daytistic.activities.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${dateTimeToHourMinute(daytistic.activities[index].startTime)} - ${dateTimeToHourMinute(daytistic.activities[index].endTime)}',
                        ),
                        subtitle: Text(daytistic.activities[index].name),
                        trailing: IconButton(
                          onPressed: () => EditActivityModal.showModal(
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
              const PromptInputField(),
            ],
          ),
        ),
      ),
    );
  }
}
