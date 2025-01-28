import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/services/daytistics/daytistics_service.dart';
import 'package:daytistics/application/widgets/prompt_input_field.dart';
import 'package:daytistics/screens/daytistic_details/viewmodels/daytistic_details_view_model.dart';
import 'package:daytistics/screens/daytistic_details/widgets/add_activity_modal.dart';
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
        ref.watch(daytisticDetailsViewProvider).currentDaytistic;

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
              // Restarted application in 384ms.
              // flutter: supabase.supabase_flutter: INFO: ***** Supabase init completed *****
              // Reloaded 1 of 1573 libraries in 401ms (compile: 12 ms, reload: 238 ms, reassemble: 121 ms).
              // [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: type 'Null' is not a subtype of type 'Object'
              // #0      DaytisticsRepository.fetchDaytistic (package:daytistics/application/repositories/daytistics/daytistics_repository.dart:36:33)
              // daytistics_repository.dart:36
              // <asynchronous suspension>
              // #1      DaytisticsViewModel.fetchDaytistic (package:daytistics/application/viewmodels/daytistics/daytistics_view_model.dart:27:19)
              // daytistics_view_model.dart:27
              // <asynchronous suspension>
              // #2      DashboardDateCard.build.<anonymous closure> (package:daytistics/screens/dashboard/widgets/dashboard_date_card.dart:110:39)
              // dashboard_date_card.dart:110
              // <asynchronous suspension>
              // Reloaded 1 of 1573 libraries in 352ms (compile: 9 ms, reload: 198 ms, reassemble: 117 ms).
              Expanded(
                child: ListView.builder(
                  itemCount: daytistic.activities.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final randomActivity = 'Activity $index';

                    return Card(
                      child: ListTile(
                        title: Text('$index:00'),
                        subtitle: Text(randomActivity),
                        trailing: const Icon(
                          Icons.edit_outlined,
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
