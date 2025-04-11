import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_app_bar_flexibable_space.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:daytistics/ui/daytistic_details/widgets/activities_list.dart';
import 'package:daytistics/ui/daytistic_details/widgets/add_activity_dialog.dart';
import 'package:daytistics/ui/daytistic_details/widgets/wellbeing_rating.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DaytisticDetailsView extends ConsumerStatefulWidget {
  const DaytisticDetailsView({super.key});

  @override
  ConsumerState<DaytisticDetailsView> createState() =>
      _DaytisticDetailsViewState();
}

class _DaytisticDetailsViewState extends ConsumerState<DaytisticDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Daytistic? daytistic = ref.watch(currentDaytisticProvider);

    // Handle case when daytistic is null to avoid errors
    final date = daytistic != null ? daytistic.date : DateTime.now();
    final formattedDate = DateFormat('MM/dd/yyyy').format(date);

    return Scaffold(
      key: const ValueKey('daytistic-details-scaffold'),
      bottomNavigationBar: Material(
        color: Colors.grey[200],
        child: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: TabBar(
              key: const ValueKey('daytistic-tabs'),
              controller: _tabController,
              labelColor: ColorSettings.primary,
              unselectedLabelColor: ColorSettings.primary,
              indicatorColor: ColorSettings.primary,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  text: 'Activities',
                  icon: Icon(
                    Icons.track_changes,
                    color: ColorSettings.primary,
                  ),
                ),
                Tab(
                  text: 'Wellbeing',
                  icon: Icon(Icons.star, color: ColorSettings.primary),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorSettings.primary,
        onPressed: () async {
          _tabController.animateTo(0);
          AddActivityDialog.showDialog(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        flexibleSpace: const StyledAppBarFlexibableSpace(),
        titleSpacing: 0,
        title: StyledText(
          formattedDate,
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
      body: RequireAuth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                ActivitiesList(daytistic: daytistic),
                const WellbeingRating(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
