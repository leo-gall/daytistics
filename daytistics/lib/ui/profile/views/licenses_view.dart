import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_app_bar_flexibable_space.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LicensesView extends StatelessWidget {
  const LicensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const StyledAppBarFlexibableSpace(),
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            const SizedBox(width: 4),
            StyledText(
              'Licenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<LicenseEntry>>(
        future: LicenseRegistry.licenses.toList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No licenses available.'));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: StyledText(
                    'Thanks to the following open-source projects, which made this app possible:',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: snapshot.data!.map((license) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: StyledText(
                            license.packages.join(', ').toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: ColorSettings.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: StyledText(
                                license.paragraphs
                                    .map((e) => e.text)
                                    .join('\n'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
