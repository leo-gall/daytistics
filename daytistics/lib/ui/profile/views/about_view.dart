import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/auth/auth_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/security/require_auth.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/profile/widgets/critical_actions_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/legal_profile_section.dart';
import 'package:daytistics/ui/profile/widgets/settings_profile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';

class AboutView extends StatelessWidget {
  AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            const SizedBox(width: 4),
            StyledText(
              'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1000),
                child: Image.asset(
                  'assets/jpeg/leo.jpeg',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            const SizedBox(height: 16),
            StyledText(
              "Hey, I'm Leo! 👋",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            StyledText(
              "I am a young developer from Germany. I've built Daytistics because I wanted a tool for myself to track my daily habits and routines. I hope you enjoy using it as much as I do!",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            // social media profiles card
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
