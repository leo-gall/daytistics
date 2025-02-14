import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/current_daytistic/current_daytistic.dart';
import 'package:daytistics/shared/utils/time.dart';
import 'package:daytistics/shared/widgets/application/prompt_input_field.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:daytistics/ui/daytistic_details/widgets/add_activity_modal.dart';
import 'package:daytistics/ui/daytistic_details/widgets/edit_activity_modal.dart';
import 'package:daytistics/ui/daytistic_details/widgets/wellbeing_rating_modal.dart';
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
          DateFormat('MM/dd/yyyy').format(daytistic!.date),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
            final notifier = ref.refresh(dashboardViewModelProvider.notifier);
            notifier.updateSelectedDate(daytistic.date);
          },
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
            onPressed: () => WellbeingRatingModal.showModal(context),
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
                  itemBuilder: (context, index) {
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
              PromptInputField(
                onChat: (query, reply) => Navigator.pushNamed(context, '/chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
