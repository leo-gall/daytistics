import 'package:daytistics/config/settings.dart';
import 'package:flutter/material.dart';

class StyledAppBarFlexibableSpace extends StatelessWidget {
  const StyledAppBarFlexibableSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorSettings.primary, ColorSettings.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
