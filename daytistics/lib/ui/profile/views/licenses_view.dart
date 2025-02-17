import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LicensesView extends StatelessWidget {
  const LicensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        // initial data ...,
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
            child: ListView(
              children: snapshot.data!.map((license) {
                return ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: StyledText(
                    license.packages.join(', ').toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ColorSettings.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StyledText(
                        license.paragraphs.map((e) => e.text).join('\n'),
                      ),
                    ),
                  ],
                );
                // return ListTile(
                //   title: StyledText(
                //     license.packages.join(', ').toUpperCase(),
                //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //         color: ColorSettings.textDark,
                //         fontWeight: FontWeight.bold),
                //   ),
                //   subtitle: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: ExpansionTile(
                //       tilePadding: EdgeInsets.zero,
                //       title: const Text('Show details'),
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: StyledText(
                //             license.paragraphs.map((e) => e.text).join('\n'),
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                // );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
