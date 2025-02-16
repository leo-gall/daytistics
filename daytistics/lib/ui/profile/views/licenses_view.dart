import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/services/auth/auth_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/browser.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/profile/widgets/delete_account_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                    )
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
